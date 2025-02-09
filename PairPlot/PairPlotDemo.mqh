//+------------------------------------------------------------------+
//|                                                 PairPlotDemo.mqh |
//|                                             Copyright 2018, DNG® |
//|                                 http://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, DNG®"
#property link      "http://www.mql5.com/en/users/dng"
#property version   "1.00"
//---
#include <Controls\Dialog.mqh>
#include "PairPlot.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPairPlotDemo : public CAppDialog
  {
private:
   CPairPlot         m_PairPlot;
public:
                     CPairPlotDemo();
                    ~CPairPlotDemo();
//---
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2,const string &symbols[],const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT, const int bars=1000, const uint cells=10);
   bool              Refresh(void);
//---
   bool              HistogramOrientation(ENUM_HISTOGRAM_ORIENTATION value)   {  return m_PairPlot.HistogramOrientation(value);   }
   ENUM_HISTOGRAM_ORIENTATION    HistogramOrientation(void)                   {  return m_PairPlot.HistogramOrientation();   }
   };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPairPlotDemo::CPairPlotDemo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPairPlotDemo::~CPairPlotDemo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlotDemo::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2,const string &symbols[],const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT, const int bars=1000, const uint cells=10)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;
   if(!m_PairPlot.Create(m_chart_id,m_name+"PairPlot",m_subwin,0,0,ClientAreaWidth(),ClientAreaHeight(),symbols,timeframe,bars,cells))
      return false;
   if(!Add(m_PairPlot))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPairPlotDemo::Refresh(void)
  {
   return m_PairPlot.Refresh();
  }
//+------------------------------------------------------------------+
