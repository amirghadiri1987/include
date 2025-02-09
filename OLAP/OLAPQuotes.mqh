//+------------------------------------------------------------------+
//|                                                   OLAPQuotes.mqh |
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

#define SELECTORS QUOTE_SELECTORS
#define ENUM_FIELDS QUOTE_RECORD_FIELDS

#define DEFAULT_SELECTOR_TYPE SELECTOR_SHAPE
#define DEFAULT_SELECTOR_FIELD FIELD_NONE
#define DEFAULT_AGGREGATOR_TYPE AGGREGATOR_COUNT
#define DEFAULT_AGGREGATOR_FIELD FIELD_NONE


// QUOTE SELECTORS

enum QUOTE_SELECTORS
{
  SELECTOR_NONE,       // none
  SELECTOR_SHAPE,      // type
  SELECTOR_INDEX,      // ordinal number
  /* below datetime field assumed */
  SELECTOR_MONTH,      // month-of-year
  SELECTOR_WEEKDAY,    // day-of-week
  SELECTOR_DAYHOUR,    // hour-of-day
  SELECTOR_HOURMINUTE, // minute-of-hour
  /* the next require a field as parameter */
  SELECTOR_SCALAR,     // scalar(field)
  SELECTOR_QUANTS,     // quants(field)
  SELECTOR_FILTER      // filter(field)
};

enum QUOTE_RECORD_FIELDS
{
  FIELD_NONE,          // none
  FIELD_INDEX,         // index
  FIELD_SHAPE,         // type (bearish/flat/bullish)
  FIELD_DATETIME,      // datetime
  FIELD_PRICE_OPEN,    // open price
  FIELD_PRICE_HIGH,    // high price
  FIELD_PRICE_LOW,     // low price
  FIELD_PRICE_CLOSE,   // close price
  FIELD_PRICE_RANGE_OC,// price range (OC)
  FIELD_PRICE_RANGE_HL,// price range (HL)
  FIELD_SPREAD,        // spread
  FIELD_TICK_VOLUME,   // tick volume
  FIELD_REAL_VOLUME,   // real volume
  FIELD_CUSTOM1,       // custom 1
  FIELD_CUSTOM2,       // custom 2
  FIELD_CUSTOM3,       // custom 3
  FIELD_CUSTOM4,       // custom 4
  QUOTE_RECORD_FIELDS_LAST //  
};                        //  ^ invisible non-breaking space to hide this element name (it's auxiliary)

class QuoteSelector: public BaseSelector<QUOTE_RECORD_FIELDS>
{
  public:
    QuoteSelector(const QUOTE_RECORD_FIELDS field): BaseSelector(field)
    {
    }
};

class ShapeSelector: public QuoteSelector
{
  public:
    ShapeSelector(): QuoteSelector(FIELD_SHAPE)
    {
      _typename = typename(this);
    }

    virtual bool select(const Record *r, int &index) const
    {
      index = (int)r.get(selector);
      index += 1; // shift from -1, 0, +1 to [0..2]
      return index >= getMin() && index <= getMax();
    }
    
    virtual int getRange() const
    {
      return 3; // 0 through 2
    }
    
    virtual string getLabel(const int index) const
    {
      const static string types[3] = {"bearish", "flat", "bullish"};
      return types[index];
    }
};


class QuotesRecord: public Record
{
  protected:
    static int counter; // number of bars
    const static char datatypes[QUOTE_RECORD_FIELDS_LAST];
    
    void fillByQuotes(const MqlRates &rate)
    {
      set(FIELD_INDEX, counter++);
      set(FIELD_SHAPE, rate.close > rate.open ? +1 : (rate.close < rate.open ? -1 : 0));
      set(FIELD_DATETIME, (double)rate.time);
      set(FIELD_PRICE_OPEN, rate.open);
      set(FIELD_PRICE_HIGH, rate.high);
      set(FIELD_PRICE_LOW, rate.low);
      set(FIELD_PRICE_CLOSE, rate.close);
      set(FIELD_PRICE_RANGE_OC, (rate.close - rate.open) / _Point);
      set(FIELD_PRICE_RANGE_HL, (rate.high - rate.low) * MathSign(rate.close - rate.open) / _Point);
      set(FIELD_SPREAD, (double)rate.spread);
      set(FIELD_TICK_VOLUME, (double)rate.tick_volume);
      set(FIELD_REAL_VOLUME, (double)rate.real_volume);
    }
  
  public:
    QuotesRecord(): Record(QUOTE_RECORD_FIELDS_LAST)
    {
    }
    
    QuotesRecord(const MqlRates &rate): Record(QUOTE_RECORD_FIELDS_LAST)
    {
      fillByQuotes(rate);
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
      if(index >= 0 && index < QUOTE_RECORD_FIELDS_LAST)
      {
        return legendFromEnum<QUOTE_RECORD_FIELDS>((QUOTE_RECORD_FIELDS)index);
        //return EnumToString((QUOTE_RECORD_FIELDS)index);
      }
      return "unknown";
    }

    static char datatype(const int index)
    {
      return datatypes[index];
    }
  
};

static int QuotesRecord::counter = 0;

const static char QuotesRecord::datatypes[QUOTE_RECORD_FIELDS_LAST] =
{
  0,   // none
  'i', // index, serial number
  'i', // type (-1 down/0/+1 up)
  't', // datetime
  'd', // open price
  'd', // high price
  'd', // low price
  'd', // close price
  'd', // range OC
  'd', // range HL
  'i', // spread
  'i', // tick
  'i', // real
  'd',    // custom 1
  'd',    // custom 2
  'd',    // custom 3
  'd'     // custom 4
};


template<typename T>
class QuotesDataAdapter: public DataAdapter
{
  private:
    int size;
    int cursor;
    
  public:
    QuotesDataAdapter()
    {
      reset();
    }

    virtual void reset() override
    {
      size = MathMin(Bars(_Symbol, _Period), TerminalInfoInteger(TERMINAL_MAXBARS));
      cursor = size - 1;
      T::reset();
    }
    
    virtual int reservedSize() const override
    {
      return size;
    }
    
    virtual Record *getNext() override
    {
      if(cursor >= 0)
      {
        MqlRates rate[1];
        if(CopyRates(_Symbol, _Period, cursor, 1, rate) > 0)
        {
          cursor--;
          return new T(rate[0]);
        }
        
        Print(__FILE__, " ", __LINE__, " ", GetLastError());
        
        return NULL;
      }
      return NULL;
    }

    virtual bool isOwner() const override
    {
      return false;
    }

    virtual int getFieldCount() const override
    {
      return QUOTE_RECORD_FIELDS_LAST;
    }
};

class OLAPEngineQuotes: public OLAPEngine<QUOTE_SELECTORS,QUOTE_RECORD_FIELDS>
{
  protected:
    virtual Selector<QUOTE_RECORD_FIELDS> *createSelector(const QUOTE_SELECTORS selector, const QUOTE_RECORD_FIELDS field) override
    {
      switch(selector)
      {
        case SELECTOR_SHAPE:
          return new ShapeSelector();
        case SELECTOR_INDEX:
          return new SerialNumberSelector<QUOTE_RECORD_FIELDS,QuotesRecord>(FIELD_INDEX);
        case SELECTOR_MONTH:
          return new MonthSelector<QUOTE_RECORD_FIELDS>(FIELD_DATETIME);
        case SELECTOR_WEEKDAY:
          return new WorkWeekDaySelector<QUOTE_RECORD_FIELDS>(FIELD_DATETIME);
        case SELECTOR_DAYHOUR:
          return new DayHourSelector<QUOTE_RECORD_FIELDS>(FIELD_DATETIME);
        case SELECTOR_HOURMINUTE:
          return new DayHourSelector<QUOTE_RECORD_FIELDS>(FIELD_DATETIME);
        case SELECTOR_SCALAR:
          return field != FIELD_NONE ? new BaseSelector<QUOTE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_QUANTS:
          return field != FIELD_NONE ? new QuantizationSelector<QUOTE_RECORD_FIELDS>(field, quantGranularity) : NULL;
        case SELECTOR_FILTER:
          return field != FIELD_NONE ? new FilterSelector<QUOTE_RECORD_FIELDS>(field) : NULL;
      }
      return NULL;
    }

    virtual void initialize() override
    {
      Print("Bars read: ", QuotesRecord::getRecordCount());
    }

  public:
    OLAPEngineQuotes(): OLAPEngine() {}
    OLAPEngineQuotes(DataAdapter *ptr): OLAPEngine(ptr) {}
  
};

#ifndef RECORD_CLASS
#define RECORD_CLASS QuotesRecord
#endif

QuotesDataAdapter<RECORD_CLASS> _defaultQuotesAdapter;
OLAPEngineQuotes _defaultEngine;
