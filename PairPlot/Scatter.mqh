//+------------------------------------------------------------------+
//|                                                      Scatter.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//---
#include "PlotBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CScatter : public CPlotBase
  {
public:
                     CScatter();
                    ~CScatter();
//---
   int               AddTimeseries(const double &timeseries_1[],const double &timeseries_2[]);
   bool              UpdateTimeseries(const double &timeseries_1[],const double &timeseries_2[],uint timeserie=0);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CScatter::CScatter()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CScatter::~CScatter()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CScatter::AddTimeseries(const double &timeseries_1[],const double &timeseries_2[])
  {
   CCurve *curve=CGraphic::CurveAdd(timeseries_1,timeseries_2,CURVE_POINTS);
   if(curve==NULL)
      return -1;
   curve.PointsSize(2);
   curve.TrendLineVisible(true);
   return (m_arr_curves.Total()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CScatter::UpdateTimeseries(const double &timeseries_1[],const double &timeseries_2[], uint timeserie=0)
  {
   if((int)timeserie>=m_arr_curves.Total())
      return false;
   if(ArraySize(timeseries_1)!=ArraySize(timeseries_2) || ArraySize(timeseries_1)==0)
      return false;
//---
   CCurve *curve=m_arr_curves.At(timeserie);
   if(CheckPointer(curve)==POINTER_INVALID)
      return false;
//---
   curve.Update(timeseries_1,timeseries_2);
//---
   return true;
  }
//+------------------------------------------------------------------+
