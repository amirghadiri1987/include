//+------------------------------------------------------------------+
//|                                                     HTMLcube.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include <OLAP/GroupReportInputs.mqh>

#include <Marketeer/WebDataExtractor.mqh>
#include "ReportCubeBase.mqh"
#include <Marketeer/RubbArray.mqh>


template<typename T>
class HTMLReportAdapter: public BaseReportAdapter<T>
{
  protected:
    IndexMap *data;

  protected:
    virtual bool fillDealsArray() override
    {
      for(int i = 0; i < data.getSize(); ++i)
      {
        IndexMap *row = data[i];
        if(CheckPointer(row) == POINTER_INVALID || row.getSize() != COLUMNS_COUNT) return false; // something is broken
        string s = row[COLUMN_SYMBOL].get<string>();
        StringTrimLeft(s);
        if(StringLen(s) > 0)
        {
          array << new Deal(row);
        }
        else if(row[COLUMN_TYPE].get<string>() == "balance")
        {
          string t = row[COLUMN_PROFIT].get<string>();
          StringReplace(t, " ", "");
          balance += StringToDouble(t);
        }
      }
      return true;
    }
  
  public:
    ~HTMLReportAdapter()
    {
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
    }
  
    virtual bool load(const string file) override
    {
      BaseReportAdapter<T>::load(file);
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
      data = NULL;
      if(StringFind(file, ".htm") > 0)
      {
        data = HTMLConverter::convertReport2Map(file, true);
        if(data != NULL)
        {
          size = generate();
          Print(data.getSize(), " deals transferred to ", size, " trades");
        }
      }
      return data != NULL;
    }
};

HTMLReportAdapter<RECORD_CLASS> _defaultHTMLReportAdapter;
