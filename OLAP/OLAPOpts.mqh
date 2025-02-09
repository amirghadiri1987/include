//+------------------------------------------------------------------+
//|                                                     OLAPOpts.mqh |
//|                                 Copyright © 2016-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7535 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include "OLAPCommon.mqh"
#include <fxsaber/TesterCache/TesterCache.mqh>

#define SELECTORS OPT_CACHE_SELECTORS
#define ENUM_FIELDS OPT_CACHE_RECORD_FIELDS

#define DEFAULT_SELECTOR_TYPE SELECTOR_INDEX
#define DEFAULT_SELECTOR_FIELD FIELD_NONE
#define DEFAULT_AGGREGATOR_TYPE AGGREGATOR_COUNT
#define DEFAULT_AGGREGATOR_FIELD FIELD_NONE

#ifndef PRT
#define PRT(A) Print(__FILE__, " ", __LINE__, " ", #A, " ", (A))
#endif


// SELECTORS

enum OPT_CACHE_SELECTORS
{
  SELECTOR_NONE,       // none
  SELECTOR_INDEX,      // ordinal number
  /* all the next require a field as parameter */
  SELECTOR_SCALAR,     // scalar(field)
  SELECTOR_QUANTS,     // quants(field)
  SELECTOR_FILTER      // filter(field)
};

enum OPT_CACHE_RECORD_FIELDS
{
  FIELD_NONE,
  FIELD_INDEX,
  FIELD_PASS,
  FIELD_DEPOSIT,
  FIELD_WITHDRAWAL,
  FIELD_PROFIT,
  FIELD_GROSS_PROFIT,
  FIELD_GROSS_LOSS,
  FIELD_MAX_TRADE_PROFIT,
  FIELD_MAX_TRADE_LOSS,
  FIELD_LONGEST_SERIAL_PROFIT,
  FIELD_MAX_SERIAL_PROFIT,
  FIELD_LONGEST_SERIAL_LOSS,
  FIELD_MAX_SERIAL_LOSS,
  FIELD_MIN_BALANCE,
  FIELD_MAX_DRAWDOWN,
  FIELD_MAX_DRAWDOWN_PCT,
  FIELD_REL_DRAWDOWN,
  FIELD_REL_DRAWDOWN_PCT,
  FIELD_MIN_EQUITY,
  FIELD_MAX_DRAWDOWN_EQ,
  FIELD_MAX_DRAWDOWN_PCT_EQ,
  FIELD_REL_DRAWDOWN_EQ,
  FIELD_REL_DRAWDOWN_PCT_EQ,
  FIELD_EXPECTED_PAYOFF,
  FIELD_PROFIT_FACTOR,
  FIELD_RECOVERY_FACTOR,
  FIELD_SHARPE_RATIO,
  FIELD_MARGIN_LEVEL,
  FIELD_CUSTOM_FITNESS,

  FIELD_DEALS,
  FIELD_TRADES,
  FIELD_PROFIT_TRADES,
  FIELD_LOSS_TRADES,
  FIELD_LONG_TRADES,
  FIELD_SHORT_TRADES,
  FIELD_WIN_LONG_TRADES,
  FIELD_WIN_SHORT_TRADES,
  FIELD_LONGEST_WIN_CHAIN,
  FIELD_MAX_PROFIT_CHAIN,
  FIELD_LONGEST_LOSS_CHAIN,
  FIELD_MAX_LOSS_CHAIN,
  FIELD_AVERAGE_SERIAL_WIN_TRADES,
  FIELD_AVERAGE_SERIAL_LOSS_TRADES//,
  //OPT_CACHE_RECORD_FIELDS_LAST //  
};                            //  ^ invisible non-breaking space to hide this element name in EA inputs (it's auxiliary)

#define OPT_CACHE_RECORD_FIELDS_LAST (FIELD_AVERAGE_SERIAL_LOSS_TRADES + 1)

class OptCacheSelector: public BaseSelector<OPT_CACHE_RECORD_FIELDS>
{
  public:
    OptCacheSelector(const OPT_CACHE_RECORD_FIELDS field): BaseSelector(field)
    {
    }
};

struct OptCacheRecordInternal
{
  ExpTradeSummary summary;
  MqlParam params[][5]; // [][name, current, low, step, high]
};

#define DBL_MAX_GUARD(X) ((X) == DBL_MAX ? nan : (X))

class OptCacheRecord: public Record
{
  protected:
    static int counter; // number of passes
    
    void fillByTesterPass(const OptCacheRecordInternal &internal)
    {
      Converter<ulong,double> converter;
      const double nan = converter[0x7FF8000000000000]; // quiet NaN
    
      const ExpTradeSummary record = internal.summary;
      set(FIELD_INDEX, counter++);
      set(FIELD_PASS, record.Pass);
      set(FIELD_DEPOSIT, record.initial_deposit); // Q: why do we have inital deposit, not all amount of deposits?
      set(FIELD_WITHDRAWAL, record.withdrawal);
      set(FIELD_PROFIT, record.profit);
      set(FIELD_GROSS_PROFIT, record.grossprofit);
      set(FIELD_GROSS_LOSS, record.grossloss);
      set(FIELD_MAX_TRADE_PROFIT, record.maxprofit);
      set(FIELD_MAX_TRADE_LOSS, record.minprofit);
      set(FIELD_LONGEST_SERIAL_PROFIT, record.conprofitmax);
      set(FIELD_MAX_SERIAL_PROFIT, record.maxconprofit);
      set(FIELD_LONGEST_SERIAL_LOSS, record.conlossmax);
      set(FIELD_MAX_SERIAL_LOSS, record.maxconloss);
      set(FIELD_MIN_BALANCE, record.balance_min);
      set(FIELD_MAX_DRAWDOWN, record.maxdrawdown);
      set(FIELD_MAX_DRAWDOWN_PCT, record.drawdownpercent);
      set(FIELD_REL_DRAWDOWN, record.reldrawdown);
      set(FIELD_REL_DRAWDOWN_PCT, record.reldrawdownpercent);
      set(FIELD_MIN_EQUITY, record.equity_min);
      set(FIELD_MAX_DRAWDOWN_EQ, record.maxdrawdown_e);
      set(FIELD_MAX_DRAWDOWN_PCT_EQ, record.drawdownpercent_e);
      set(FIELD_REL_DRAWDOWN_EQ, record.reldrawdown_e);
      set(FIELD_REL_DRAWDOWN_PCT_EQ, record.reldrawdownpercnt_e);
      set(FIELD_EXPECTED_PAYOFF, record.expected_payoff);
      set(FIELD_PROFIT_FACTOR, DBL_MAX_GUARD(record.profit_factor));
      set(FIELD_RECOVERY_FACTOR, record.recovery_factor);
      set(FIELD_SHARPE_RATIO, record.sharpe_ratio);
      set(FIELD_MARGIN_LEVEL, DBL_MAX_GUARD(record.margin_level));
      set(FIELD_CUSTOM_FITNESS, DBL_MAX_GUARD(record.custom_fitness));
    
      set(FIELD_DEALS, record.deals);
      set(FIELD_TRADES, record.trades);
      set(FIELD_PROFIT_TRADES, record.profittrades);
      set(FIELD_LOSS_TRADES, record.losstrades);
      set(FIELD_LONG_TRADES, record.longtrades);
      set(FIELD_SHORT_TRADES, record.shorttrades);
      set(FIELD_WIN_LONG_TRADES, record.winlongtrades);
      set(FIELD_WIN_SHORT_TRADES, record.winshorttrades);
      set(FIELD_LONGEST_WIN_CHAIN, record.conprofitmax_trades);
      set(FIELD_MAX_PROFIT_CHAIN, record.maxconprofit_trades);
      set(FIELD_LONGEST_LOSS_CHAIN, record.conlossmax_trades);
      set(FIELD_MAX_LOSS_CHAIN, record.maxconloss_trades);
      set(FIELD_AVERAGE_SERIAL_WIN_TRADES, record.avgconwinners);
      set(FIELD_AVERAGE_SERIAL_LOSS_TRADES, record.avgconloosers);
      
      const int n = ArrayRange(internal.params, 0);
      for(int i = 0; i < n; i++)
      {
        set(OPT_CACHE_RECORD_FIELDS_LAST + i, internal.params[i][PARAM_VALUE].double_value);
      }
    }
  
  public:
    OptCacheRecord(const int customFields = 0): Record(OPT_CACHE_RECORD_FIELDS_LAST + customFields)
    {
    }
    
    OptCacheRecord(const OptCacheRecordInternal &record, const int customFields = 0): Record(OPT_CACHE_RECORD_FIELDS_LAST + customFields)
    {
      fillByTesterPass(record);
    }
    
    static int getRecordCount()
    {
      return counter;
    }

    static void reset()
    {
      counter = 0;
    }

    virtual string legend(const int index) const override
    {
      return legendFromEnum((OPT_CACHE_RECORD_FIELDS)index);
    }

    static char datatype(const int index)
    {
      if(index < FIELD_DEALS || index >= OPT_CACHE_RECORD_FIELDS_LAST)
      {
        return 'd';
      }
      return 'i';
    }
};

static int OptCacheRecord::counter = 0;


template<typename T>
class OptCacheDataAdapter: public DataAdapter
{
  private:
    int size;
    int cursor;
    int paramCount;
    string paramNames[];
    TESTERCACHE<ExpTradeSummary> Cache;

    void customize()
    {
      size = (int)Cache.Header.passes_passed;
      paramCount = (int)Cache.Header.opt_params_total;
      const int n = ArraySize(Cache.Inputs);

      ArrayResize(paramNames, n);
      int k = 0;
      
      for(int i = 0; i < n; i++)
      {
        if(Cache.Inputs[i].flag)
        {
          paramNames[k++] = Cache.Inputs[i].name[];
        }
      }
      if(k > 0)
      {
        ArrayResize(paramNames, k);
        Print("Optimized Parameters (", paramCount, " of ", n, "):");
        ArrayPrint(paramNames);
      }
    }
    
  public:
    OptCacheDataAdapter()
    {
      reset();
    }
    
    void load(const string optName)
    {
      if(Cache.Load(optName))
      {
        customize();
        reset();
      }
      else
      {
        cursor = -1;
      }
    }
    
    virtual void reset() override
    {
      cursor = 0;
      if(Cache.Header.version == 0) return;
      T::reset();
    }
    
    virtual int reservedSize() const override
    {
      return size;
    }
    
    virtual Record *getNext() override
    {
      if(cursor < size)
      {
        OptCacheRecordInternal internal;
        internal.summary = Cache[cursor];
        Cache.GetInputs(cursor, internal.params);
        cursor++;
        return new T(internal, paramCount);
      }
      return NULL;
    }

    virtual bool isOwner() const override
    {
      return false;
    }

    virtual int getFieldCount() const override
    {
      return OPT_CACHE_RECORD_FIELDS_LAST;
    }
    
    virtual int getCustomFieldCount() const override
    {
      return paramCount;
    }
    
    virtual int getCustomFields(string &names[]) const override
    {
      return ArrayCopy(names, paramNames);
    };
};

class OLAPEngineOptCache: public OLAPEngine<OPT_CACHE_SELECTORS,OPT_CACHE_RECORD_FIELDS>
{
  protected:
    virtual Selector<OPT_CACHE_RECORD_FIELDS> *createSelector(const OPT_CACHE_SELECTORS selector, const OPT_CACHE_RECORD_FIELDS field) override
    {
      const int standard = adapter.getFieldCount();
      switch(selector)
      {
        case SELECTOR_INDEX:
          return new SerialNumberSelector<OPT_CACHE_RECORD_FIELDS,OptCacheRecord>(FIELD_INDEX);
        case SELECTOR_SCALAR:
          return new OptCacheSelector(field);
        case SELECTOR_QUANTS:
          return field != FIELD_NONE ? new QuantizationSelector<OPT_CACHE_RECORD_FIELDS>(field, (int)field < standard ? quantGranularity : 0) : NULL;
        case SELECTOR_FILTER:
          return field != FIELD_NONE ? new FilterSelector<OPT_CACHE_RECORD_FIELDS>(field) : NULL;
      }
      return NULL;
    }

    virtual void initialize() override
    {
      Print("Passes read: ", OptCacheRecord::getRecordCount());
    }

  public:
    OLAPEngineOptCache(): OLAPEngine() {}
    OLAPEngineOptCache(DataAdapter *ptr): OLAPEngine(ptr) {}
  
};

#ifndef RECORD_CLASS
#define RECORD_CLASS OptCacheRecord
#endif

OptCacheDataAdapter<RECORD_CLASS> _defaultOptCacheAdapter;
OLAPEngineOptCache _defaultEngine;
