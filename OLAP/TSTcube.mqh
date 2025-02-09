//+------------------------------------------------------------------+
//|                                                      TSTcube.mqh |
//|                                    Copyright (c) 2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include "ReportCubeBase.mqh"
#include <fxsaber/SingleTesterCache/SingleTesterCache.mqh>


class TesterDeal: public Deal
{
  public:
    TesterDeal(const TradeDeal &td)
    {
      time = (datetime)td.time_create + TimeShift;
      price = td.price_open;
      string t = dealType(td.action);
      type = t == "buy" ? +1 : (t == "sell" ? -1 : 0);
      t = dealDir(td.entry);
      direction = 0;
      if(StringFind(t, "in") > -1) ++direction;
      if(StringFind(t, "out") > -1) --direction;
      volume = (double)td.volume;
      profit = td.profit;
      deal = (long)td.deal;
      order = (long)td.order;
      comment = td.comment[];
      symbol = td.symbol[];
      commission = td.commission;
      swap = td.storage;
      
      // balance - SingleTesterCache.Deals[i].reserve
    }

    static string dealType(const ENUM_DEAL_TYPE type)
    {
      return type == DEAL_TYPE_BUY ? "buy" : (type == DEAL_TYPE_SELL ? "sell" : "balance");
    }

    static string dealDir(const ENUM_DEAL_ENTRY entry)
    {
      string result = "";
      if(entry == DEAL_ENTRY_IN) result += "in";
      else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY) result += "out";
      else if(entry == DEAL_ENTRY_INOUT) result += "in out";
      return result;
    }
};

template<typename T>
class TesterReportAdapter: public BaseReportAdapter<T>
{
  protected:
    SINGLETESTERCACHE *ptrSingleTesterCache;

    virtual bool fillDealsArray() override
    {
      for(int i = 0; i < ArraySize(ptrSingleTesterCache.Deals); i++)
      {
        if(TesterDeal::dealType(ptrSingleTesterCache.Deals[i].action) == "balance")
        {
          balance += ptrSingleTesterCache.Deals[i].profit;
        }
        else
        {
          array << new TesterDeal(ptrSingleTesterCache.Deals[i]);
        }
      }
      return true;
    }

  public:
    ~TesterReportAdapter()
    {
      if(CheckPointer(ptrSingleTesterCache) == POINTER_DYNAMIC) delete ptrSingleTesterCache;
    }

    virtual bool load(const string file) override
    {
      if(StringFind(file, ".tst") > 0)
      {
        BaseReportAdapter<T>::load(file);

        if(CheckPointer(ptrSingleTesterCache) == POINTER_DYNAMIC) delete ptrSingleTesterCache;

        ptrSingleTesterCache = new SINGLETESTERCACHE();
        if(!ptrSingleTesterCache.Load(file))
        {
          delete ptrSingleTesterCache;
          ptrSingleTesterCache = NULL;
          return false;
        }
        size = generate();
        
        Print("Tester cache import: ", size, " trades from ", ArraySize(ptrSingleTesterCache.Deals), " deals");
      }
      return true;
    }
};

TesterReportAdapter<RECORD_CLASS> _defaultTSTReportAdapter;
