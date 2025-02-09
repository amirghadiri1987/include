//+------------------------------------------------------------------+
//|                                                    Histogram.mqh |
//|                                             Copyright 2018, DNG® |
//|                                 http://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, DNG®"
#property link      "http://www.mql5.com/en/users/dng"
#property version   "1.00"
//---
#include "PlotBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_HISTOGRAM_ORIENTATION
  {
   HISTOGRAM_VERTICAL,     //Markert Profile
   HISTOGRAM_HORIZONTAL    //Classic
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHistogram : public CPlotBase
  {
private:
   ENUM_HISTOGRAM_ORIENTATION    e_orientation;
   uint                          i_cells;

public:
                                 CHistogram();
                                ~CHistogram();
//---
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int size, ENUM_HISTOGRAM_ORIENTATION orientation=HISTOGRAM_HORIZONTAL);
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2, ENUM_HISTOGRAM_ORIENTATION orientation=HISTOGRAM_HORIZONTAL);
   int               AddTimeserie(const double &timeserie[]);
   bool              UpdateTimeserie(const double &timeserie[],uint timeserie=0);
   bool              SetCells(uint value)    { if(i_cells<=1) return (false);  i_cells=value; return (true);}

protected:
   // virtual void      HistogramPlot(CCurve *curve);
   bool              CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[], 
                                             double &maxv,double &minv);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistogram::CHistogram()   :  e_orientation(HISTOGRAM_HORIZONTAL),
                              i_cells(10)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistogram::~CHistogram()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistogram::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int size,ENUM_HISTOGRAM_ORIENTATION orientation=1)
  {
   int x2=x1+size;
   int y2=y1+size;
   return Create(chart,name,subwin,x1,y1,x2,y2,orientation);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistogram::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2,ENUM_HISTOGRAM_ORIENTATION orientation=1)
  {
   e_orientation=orientation;
   if(!CGraphic::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;
   m_chart_id=chart;
   m_subwin=subwin;
   return true;
  }
//+------------------------------------------------------------------+ 
//|  Calculate frequencies for data set                              | 
//+------------------------------------------------------------------+ 
bool CHistogram::CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[], 
                             double &maxv,double &minv) 
  { 
   int size=ArraySize(data); 
   if(size<(int)i_cells*10) return (false); 
   minv=data[ArrayMinimum(data)]; 
   maxv=data[ArrayMaximum(data)]; 
   double range=maxv-minv; 
   double width=range/i_cells; 
   if(width==0) return false; 
   ArrayResize(intervals,i_cells); 
   ArrayResize(frequency,i_cells); 
//--- set the interval centers 
   for(uint i=0; i<i_cells; i++) 
     { 
      intervals[i]=minv+(i+0.5)*width; 
      frequency[i]=0; 
     } 
//--- fill in the interval fitting frequencies 
   for(int i=0; i<size; i++) 
     { 
      uint ind=int((data[i]-minv)/width); 
      if(ind>=i_cells) ind=i_cells-1; 
      frequency[ind]++; 
     } 
//--- normalize frequencies into percentage
   for(uint i=0; i<i_cells; i++) 
      frequency[i]*=(100.0/(double)size); 
   return (true); 
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CHistogram::AddTimeserie(const double &timeserie[])
  {
   CCurve *curve=CGraphic::CurveAdd(timeserie,CURVE_HISTOGRAM);
   if(curve==NULL)
      return -1;
//--- Set width of histogram
   int total=CurvesTotal();
   int width=fmax((e_orientation==HISTOGRAM_HORIZONTAL ? m_width-m_right-m_left : m_height-m_up-m_down)/((int)(i_cells)*(total+1)),1);
   for(int i=0;i<total;i++)
     {
      curve=CurveGetByIndex(i);
      if(curve==NULL)
         continue;
      curve.HistogramWidth(width);
     }
//--- Return index of new timeserie
   return (total-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistogram::UpdateTimeserie(const double &timeserie[], uint timeserie_number=0)
  {
   if((int)timeserie_number>=m_arr_curves.Total())
      return false;
   if(ArraySize(timeserie)==0)
      return false;
//---
   CCurve *curve=m_arr_curves.At(timeserie_number);
   if(CheckPointer(curve)==POINTER_INVALID)
      return false;
//---
   curve.Update(timeserie);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// CHistogram::HistogramPlot(CCurve *curve)
//   {
//    double data[],intervals[],frequency[];
//    double max_value, min_value;
//    curve.GetY(data);
//    if(!CalculateHistogramArray(data,intervals,frequency,max_value,min_value))
//       return;
// //--- historgram parametrs
//    int histogram_width=fmax(curve.HistogramWidth(),2);
// //--- check
//    if(ArraySize(frequency)==0 || ArraySize(intervals)==0)
//       return;
// //---
//    switch(e_orientation)
//      {
//       case HISTOGRAM_HORIZONTAL:
//         m_y.AutoScale(false);
//         m_x.Min(intervals[ArrayMinimum(intervals)]);
//         m_x.Max(intervals[ArrayMaximum(intervals)]);
//         m_x.MaxLabels(3);
//         m_x.ValuesFormat("%.0f");
//         m_y.Min(0);
//         m_y.Max(frequency[ArrayMaximum(frequency)]);
//         m_y.ValuesFormat("%.2f");
//         break;
//       case HISTOGRAM_VERTICAL:
//         m_x.AutoScale(false);
//         m_y.Min(intervals[ArrayMinimum(intervals)]);
//         m_y.Max(intervals[ArrayMaximum(intervals)]);
//         m_y.MaxLabels(3);
//         m_y.ValuesFormat("%.0f");
//         m_x.Min(0);
//         m_x.Max(frequency[ArrayMaximum(frequency)]);
//         m_x.ValuesFormat("%.2f");
//         break;
//      }
// //---
//    CalculateXAxis();
//    CalculateYAxis();
// //--- calculate original of y
//    int originalY=m_height-m_down;
//    int originalX=m_width-m_right;
//    int yc0=ScaleY(0.0);
//    int xc0=ScaleX(0.0);
// //--- gets curve color
//    uint clr=curve.Color();
// //--- draw 
//    for(uint i=0; i<i_cells; i++)
//      {
//       //--- check coordinates
//       if(!MathIsValidNumber(frequency[i]) || !MathIsValidNumber(intervals[i]))
//          continue;
//       if(e_orientation==HISTOGRAM_HORIZONTAL)
//         {
//          int xc=ScaleX(intervals[i]);
//          int yc=ScaleY(frequency[i]);
//          int xc1 = xc - histogram_width/2;
//          int xc2 = xc + histogram_width/2;
//          int yc1 = yc;
//          int yc2 = (originalY>yc0 && yc0>0) ? yc0 : originalY;
//          //---
//          if(yc1>yc2)
//             yc2++;
//          else
//             yc2--;
//          //---
//          m_canvas.FillRectangle(xc1,yc1,xc2,yc2,clr);
//         }
//       else
//         {
//          int yc=ScaleY(intervals[i]);
//          int xc=ScaleX(frequency[i]);
//          int yc1 = yc - histogram_width/2;
//          int yc2 = yc + histogram_width/2;
//          int xc1 = xc;
//          int xc2 = (originalX>xc0 && xc0>0) ? xc0 : originalX;
//          //---
//          if(xc1>xc2)
//             xc2++;
//          else
//             xc2--;
//          //---
//          m_canvas.FillRectangle(xc1,yc1,xc2,yc2,clr);
//         }
//      }
// //---
//   }
//+------------------------------------------------------------------+
