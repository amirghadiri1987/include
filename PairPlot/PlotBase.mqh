//+------------------------------------------------------------------+
//|                                                     PlotBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//---
#include <Graphics\Graphic.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPlotBase : public CGraphic
  {
protected:
   long              m_chart_id;                // chart ID
   int               m_subwin;                  // chart subwindow

public:
                     CPlotBase();
                    ~CPlotBase();
//---
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int size);
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      SetTimeseriesColor(uint clr, uint timeserie=0);
//---
   // virtual void      TextUp(string text, uint clr);
   // virtual void      TextDown(string text, uint clr);
   // virtual void      TextLeft(string text, uint clr);
   // virtual void      TextRight(string text, uint clr);
//--- geometry
   virtual bool      Shift(const int dx,const int dy);
//--- state
   virtual bool      Show(void);
   virtual bool      Hide(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPlotBase::CPlotBase()
  {
   HistoryNameWidth(0);
   HistorySymbolSize(0);
   m_x.MaxLabels(3);
   m_y.MaxLabels(3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPlotBase::~CPlotBase()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int size)
  {
   int x2=x1+size;
   int y2=y1+size;
   return Create(chart,name,subwin,x1,y1,x2,y2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CGraphic::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;
   m_chart_id=chart;
   m_subwin=subwin;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::SetTimeseriesColor(uint clr,uint timeserie=0)
  {
   if((int)timeserie>=m_arr_curves.Total())
      return false;
//---
   CCurve *curve=m_arr_curves.At(timeserie);
   if(CheckPointer(curve)==POINTER_INVALID)
      return false;
//---
   curve.Color(clr);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// CPlotBase::TextUp(string text, uint clr)
//   {
//    // m_canvas.FontAngleSet(0);
//    // TextAdd(m_width/2,1,text,clr,TA_CENTER|TA_TOP);
//   }
// //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// CPlotBase::TextDown(string text, uint clr)
//   {
//    m_canvas.FontAngleSet(0);
//    TextAdd(m_width/2,m_height-1,text,clr,TA_CENTER|TA_BOTTOM);
//   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// CPlotBase::TextLeft(string text, uint clr)
//   {
//    m_canvas.FontAngleSet(900);
//    TextAdd(1,m_height/2,text,clr,TA_CENTER|TA_TOP);
//   }
// //+------------------------------------------------------------------+
// //|                                                                  |
// //+------------------------------------------------------------------+
// CPlotBase::TextRight(string text, uint clr)
//   {
//    m_canvas.FontAngleSet(900);
//    TextAdd(m_width-1,m_height/2,text,clr,TA_CENTER|TA_BOTTOM);
//   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::Show(void)
  {
   string obj_name=ChartObjectName();
   if(obj_name==NULL || ObjectFind(m_chart_id,obj_name)<0)
      return false;
   if(!ObjectSetInteger(m_chart_id,obj_name,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS))
      return false;
   Update(false);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::Hide(void)
  {
   string obj_name=ChartObjectName();
   if(obj_name==NULL || ObjectFind(m_chart_id,obj_name)<0)
      return false;
   return ObjectSetInteger(m_chart_id,obj_name,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlotBase::Shift(const int dx,const int dy)
  {
   string obj_name=ChartObjectName();
   if(obj_name==NULL || ObjectFind(m_chart_id,obj_name)<0)
      return false;
//---
   int x=(int)ObjectGetInteger(m_chart_id,obj_name,OBJPROP_XDISTANCE)+dx;
   int y=(int)ObjectGetInteger(m_chart_id,obj_name,OBJPROP_YDISTANCE)+dy;
   if(!ObjectSetInteger(m_chart_id,obj_name,OBJPROP_XDISTANCE,x))
      return false;
   if(!ObjectSetInteger(m_chart_id,obj_name,OBJPROP_YDISTANCE,y))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
