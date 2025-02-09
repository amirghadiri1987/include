//+------------------------------------------------------------------+
//|                                                     PairPlot.mqh |
//|                                             Copyright 2018, DNG® |
//|                                 http://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, DNG®"
#property link      "http://www.mql5.com/en/users/dng"
#property version   "1.00"
//---
#include <Controls\WndClient.mqh>
#include "Histogram.mqh"
#include "Scatter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTimeserie :  public CObject
  {
protected:
   string               s_symbol;
   ENUM_TIMEFRAMES      e_timeframe;
   ENUM_APPLIED_PRICE   e_price;
   double               d_timeserie[];
   int                  i_bars;
   datetime             dt_last_load;
   
public:
                     CTimeserie(void);
                    ~CTimeserie(void);
   bool              Create(const string symbol=NULL, const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT, const ENUM_APPLIED_PRICE price=PRICE_CLOSE);
//--- Change settings of timeserie
   void              SetBars(const int value)            {  i_bars=value;  }
   void              Symbol(string value)                {  s_symbol=value;      dt_last_load=0;  }
   void              Timeframe(ENUM_TIMEFRAMES value)    {  e_timeframe=value;   dt_last_load=0;  }
   void              Price(ENUM_APPLIED_PRICE value)     {  e_price=value;       dt_last_load=0;  }
//---
   string            Symbol(void)                        {  return s_symbol;     }
   ENUM_TIMEFRAMES   Timeframe(void)                     {  return e_timeframe;  }
   ENUM_APPLIED_PRICE Price(void)                        {  return e_price;      }
//--- Load data
   bool              UpdateTimeserie(void);
   bool              GetTimeserie(double &timeserie[])   {  return ArrayCopy(timeserie,d_timeserie)>0;   }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTimeserie::CTimeserie(void)  :  s_symbol(_Symbol),
                                 e_timeframe(PERIOD_CURRENT),
                                 e_price(PRICE_CLOSE),
                                 i_bars(1000)
  {
   ArrayFree(d_timeserie);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTimeserie::~CTimeserie(void)
  {
   ArrayFree(d_timeserie);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTimeserie::Create(const string symbol=NULL,const ENUM_TIMEFRAMES timeframe=0, const ENUM_APPLIED_PRICE price=PRICE_CLOSE)
  {
   ResetLastError();
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
       if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL || !SymbolSelect(symbol,true))
            return false;
   s_symbol=(symbol==NULL ? _Symbol : symbol);
   e_timeframe=(timeframe==PERIOD_CURRENT ? _Period : timeframe);
   e_price=price;
   UpdateTimeserie();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTimeserie::UpdateTimeserie(void)
  {
   datetime cur_date=(datetime)SeriesInfoInteger(s_symbol,e_timeframe,SERIES_LASTBAR_DATE);
   if(dt_last_load>=cur_date && ArraySize(d_timeserie)>=i_bars)
      return true;
//---
   MqlRates rates[];
   int bars=0,i;
   double data[];
   switch(e_price)
     {
      case PRICE_CLOSE:
        bars=CopyClose(s_symbol,e_timeframe,1,i_bars+1,data);
        break;
      case PRICE_OPEN:
        bars=CopyOpen(s_symbol,e_timeframe,1,i_bars+1,data);
      case PRICE_HIGH:
        bars=CopyHigh(s_symbol,e_timeframe,1,i_bars+1,data);
      case PRICE_LOW:
        bars=CopyLow(s_symbol,e_timeframe,1,i_bars+1,data);
      case PRICE_MEDIAN:
        bars=CopyRates(s_symbol,e_timeframe,1,i_bars+1,rates);
        bars=ArrayResize(data,bars);
        for(i=0;i<bars;i++)
           data[i]=(rates[i].high+rates[i].low)/2;
        break;
      case PRICE_TYPICAL:
        bars=CopyRates(s_symbol,e_timeframe,1,i_bars+1,rates);
        bars=ArrayResize(data,bars);
        for(i=0;i<bars;i++)
           data[i]=(rates[i].high+rates[i].low+rates[i].close)/3;
        break;
      case PRICE_WEIGHTED:
        bars=CopyRates(s_symbol,e_timeframe,1,i_bars+1,rates);
        bars=ArrayResize(data,bars);
        for(i=0;i<bars;i++)
           data[i]=(rates[i].high+rates[i].low+2*rates[i].close)/4;
        break;
     }
//---
   if(bars<=0)
      return false;
//---
   dt_last_load=cur_date;
//---
   if(ArraySize(d_timeserie)!=(bars-1) && ArrayResize(d_timeserie,bars-1)<=0)
      return false;
   double point=SymbolInfoDouble(s_symbol,SYMBOL_POINT);
   for(i=0;i<bars-1;i++)
      d_timeserie[i]=(data[i+1]-data[i])/point;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPairPlot : public CWndClient
  {
private:
   CPlotBase                    *m_arr_graphics[];
   CArrayObj                     m_arr_symbols;
   ENUM_TIMEFRAMES               e_timeframe;
   ENUM_APPLIED_PRICE            e_price;
   int                           i_total_symbols;
   uint                          i_bars;
   ENUM_HISTOGRAM_ORIENTATION    e_orientation;
   uint                          i_text_color;
      
public:
                     CPairPlot();
                    ~CPairPlot();
//---
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2, const string &symbols[],const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT, const int bars=1000, const uint cells=10, const ENUM_APPLIED_PRICE price=PRICE_CLOSE);
   bool              Refresh(void);
   bool              HistogramOrientation(ENUM_HISTOGRAM_ORIENTATION value);
   ENUM_HISTOGRAM_ORIENTATION    HistogramOrientation(void)    {  return e_orientation;   }
   bool              SetTextColor(color value);
//--- geometry
   virtual bool      Shift(const int dx,const int dy);
//--- state
   virtual bool      Show(void);
   virtual bool      Hide(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPairPlot::CPairPlot()  :  e_timeframe(PERIOD_CURRENT),
                           i_bars(1000),
                           i_total_symbols(0),
                           e_orientation(HISTOGRAM_HORIZONTAL)
  {
   ArrayFree(m_arr_graphics);
   i_text_color=ColorToARGB(clrBlack,255);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPairPlot::~CPairPlot()
  {
   int total=ArraySize(m_arr_graphics);
   for(int i=0;i<total;i++)
      if(CheckPointer(m_arr_graphics[i])!=POINTER_INVALID)
        {
         m_arr_graphics[i].Destroy();
         delete m_arr_graphics[i];
        }
   ArrayFree(m_arr_graphics);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2, const string &symbols[],const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT, const int bars=1000, const uint cells=10, const ENUM_APPLIED_PRICE price=PRICE_CLOSE)
  {
   i_total_symbols=0;
   int total=ArraySize(symbols);
   if(total<=1 || bars<100)
      return false;
//---
   e_timeframe=timeframe;
   i_bars=bars;
   e_price=price;
//---
   for(int i=0;i<total;i++)
     {
      CTimeserie *temp=new CTimeserie;
      if(temp==NULL)
         return false;
      temp.SetBars(i_bars);
      if(!temp.Create(symbols[i],e_timeframe,e_price))
         return false;
      if(!m_arr_symbols.Add(temp))
         return false;
     }
   i_total_symbols=m_arr_symbols.Total();
   if(i_total_symbols<=1)
      return false;
//---
   if(!CWndClient::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;
//---
   if(ArraySize(m_arr_graphics)!=(i_total_symbols*i_total_symbols))
      if(ArrayResize(m_arr_graphics,i_total_symbols*i_total_symbols)<=0)
         return false;
   int width=Width()/i_total_symbols;
   int height=Height()/i_total_symbols;
   for(int i=0;i<i_total_symbols;i++)
     {
      CTimeserie *timeserie1=m_arr_symbols.At(i);
      if(timeserie1==NULL)
         continue;
      for(int j=0;j<i_total_symbols;j++)
        {
         string obj_name=m_name+"_"+(string)i+"_"+(string)j;
         int obj_x1=m_rect.left+j*width;
         int obj_x2=obj_x1+width;
         int obj_y1=m_rect.top+i*height;
         int obj_y2=obj_y1+height;
         if(i==j)
           {
            CHistogram *temp=new CHistogram();
            if(CheckPointer(temp)==POINTER_INVALID)
               return false;
            if(!temp.Create(m_chart_id,obj_name,m_subwin,obj_x1,obj_y1,obj_x2,obj_y2,e_orientation))
               return false;
            m_arr_graphics[i*i_total_symbols+j]=temp;
            temp.SetCells(cells);
           }
         else
           {
            CScatter *temp=new CScatter();
            if(CheckPointer(temp)==POINTER_INVALID)
               return false;
            if(!temp.Create(m_chart_id,obj_name,m_subwin,obj_x1,obj_y1,obj_x2,obj_y2))
               return false;
            CTimeserie *timeserie2=m_arr_symbols.At(j);
            if(timeserie2==NULL)
               continue;
            m_arr_graphics[i*i_total_symbols+j]=temp;
           }
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::Hide(void)
  {
   int total=ArraySize(m_arr_graphics);
   for(int i=0;i<total;i++)
     {
      if(CheckPointer(m_arr_graphics[i])==POINTER_INVALID)
         continue;
      if(!m_arr_graphics[i].Hide())
         return false;
     } 
//---
   return CWndClient::Hide();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::Show(void)
  {
   if(!CWndClient::Show())
      return false;
//---
   int total=ArraySize(m_arr_graphics);
   for(int i=0;i<total;i++)
     {
      if(CheckPointer(m_arr_graphics[i])==POINTER_INVALID)
         continue;
      if(!m_arr_graphics[i].Show())
         return false;
     } 
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::Shift(const int dx,const int dy)
  {
   int total=ArraySize(m_arr_graphics);
   for(int i=0;i<total;i++)
     {
      if(CheckPointer(m_arr_graphics[i])==POINTER_INVALID)
         continue;
      if(!m_arr_graphics[i].Shift(dx,dy))
         return false;
     } 
//---
   return CWndClient::Shift(dx,dy);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::Refresh(void)
  {
   bool updated=true;
   for(int i=0;i<i_total_symbols;i++)
     {
      CTimeserie *timeserie=m_arr_symbols.At(i);
      if(timeserie==NULL)
         continue;
      updated=(updated && timeserie.UpdateTimeserie());
     }
   if(!updated)
      return false;
//---
   for(int i=0;i<i_total_symbols;i++)
     {
      CTimeserie *timeserie1=m_arr_symbols.At(i);
      if(CheckPointer(timeserie1)==POINTER_INVALID)
         continue;
      double ts1[];
      if(!timeserie1.GetTimeserie(ts1))
         continue;
//---
      for(int j=0;j<i_total_symbols;j++)
        {
         if(i==j)
           {
            CHistogram *temp=m_arr_graphics[i*i_total_symbols+j];
            if(CheckPointer(temp)==POINTER_INVALID)
               return false;
            if(temp.CurvesTotal()==0)
              {
               if(temp.AddTimeserie(ts1)<0)
                  continue;
              }
            else
              {
               if(!temp.UpdateTimeserie(ts1))
                  continue;
              }
            if(!temp.CurvePlotAll())
               continue;
            // if(i==0)
            //    temp.TextUp(timeserie1.Symbol(),i_text_color);
            // if(i==(i_total_symbols-1))
            //    temp.TextDown(timeserie1.Symbol(),i_text_color);
            // if(j==0)
            //    temp.TextLeft(timeserie1.Symbol(),i_text_color);
            // if(j==(i_total_symbols-1))
            //    temp.TextRight(timeserie1.Symbol(),i_text_color);
            temp.Update(false);
           }
         else
           {
            CScatter *temp=m_arr_graphics[i*i_total_symbols+j];
            if(CheckPointer(temp)==POINTER_INVALID)
               return false;
            CTimeserie *timeserie2=m_arr_symbols.At(j);
            if(CheckPointer(timeserie2)==POINTER_INVALID)
               continue;
            double ts2[];
            if(!timeserie2.GetTimeserie(ts2))
               continue;
            if(temp.CurvesTotal()==0)
              {
               if(temp.AddTimeseries(ts1,ts2)<0)
                  continue;
              }
            else
               if(!temp.UpdateTimeseries(ts1,ts2))
                  continue;
            if(!temp.CurvePlotAll())
               continue;
            // if(i==0)
            //    temp.TextUp(timeserie2.Symbol(),i_text_color);
            // if(i==(i_total_symbols-1))
            //    temp.TextDown(timeserie2.Symbol(),i_text_color);
            // if(j==0)
            //    temp.TextLeft(timeserie1.Symbol(),i_text_color);
            // if(j==(i_total_symbols-1))
            //    temp.TextRight(timeserie1.Symbol(),i_text_color);
            temp.Update(false);
           }
        }
     }
//---
   ChartRedraw(m_chart_id);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlot::HistogramOrientation(ENUM_HISTOGRAM_ORIENTATION value)
  {
   e_orientation=value;
   return Refresh();
  }
//+------------------------------------------------------------------+
