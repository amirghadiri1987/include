//+------------------------------------------------------------------+
//|                                                   OLAPTrades.mqh |
//|                                 Copyright © 2016-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7535 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include <MT4Bridge/MT4Orders.mqh>

#include "OLAPCommon.mqh"

#ifndef OP_BALANCE
#define OP_BALANCE 6
#endif


#define SELECTORS TRADE_SELECTORS
#define ENUM_FIELDS TRADE_RECORD_FIELDS

#define DEFAULT_SELECTOR_TYPE SELECTOR_SYMBOL
#define DEFAULT_SELECTOR_FIELD FIELD_NONE
#define DEFAULT_AGGREGATOR_TYPE AGGREGATOR_SUM
#define DEFAULT_AGGREGATOR_FIELD FIELD_PROFIT_AMOUNT


// TRADE SELECTORS

enum TRADE_SELECTORS
{
  SELECTOR_NONE,       // none
  SELECTOR_TYPE,       // type
  SELECTOR_SYMBOL,     // symbol
  SELECTOR_SERIAL,     // ordinal
  SELECTOR_MAGIC,      // magic
  SELECTOR_PROFITABLE, // profitable
  /* custom selector (see demo) */
  SELECTOR_DURATION,   // duration in days
  /* all the next require a field as parameter */
  SELECTOR_MONTH,      // month-of-year(datetime field)
  SELECTOR_WEEKDAY,    // day-of-week(datetime field)
  SELECTOR_DAYHOUR,    // hour-of-day(datetime field)
  SELECTOR_HOURMINUTE, // minute-of-hour(datetime field)
  SELECTOR_SCALAR,     // scalar(field)
  SELECTOR_QUANTS,     // quants(field)
  SELECTOR_FILTER      // filter(field)
};

// MT4 and MT5 hedge
enum TRADE_RECORD_FIELDS
{
  FIELD_NONE,          // none
  FIELD_NUMBER,        // serial number
  FIELD_TICKET,        // ticket
  FIELD_SYMBOL,        // symbol
  FIELD_TYPE,          // type (buy/sell)
  FIELD_OPEN_DATETIME, // open datetime
  FIELD_CLOSE_DATETIME,// close datetime
  FIELD_DURATION,      // duration
  FIELD_OPEN_PRICE,    // open price
  FIELD_CLOSE_PRICE,   // close price
  FIELD_MAGIC,         // magic number
  FIELD_LOT,           // lot
  FIELD_PROFIT_AMOUNT, // profit amount
  FIELD_PROFIT_PERCENT,// profit percent
  FIELD_PROFIT_POINT,  // profit points
  FIELD_COMMISSION,    // commission
  FIELD_SWAP,          // swap
  FIELD_CUSTOM_1,      // custom 1
  FIELD_CUSTOM_2,      // custom 2
  TRADE_RECORD_FIELDS_LAST //  
};

class TradeSelector: public BaseSelector<TRADE_RECORD_FIELDS>
{
  public:
    TradeSelector(const TRADE_RECORD_FIELDS field): BaseSelector(field)
    {
    }
};

class TypeSelector: public TradeSelector
{
  public:
    TypeSelector(): TradeSelector(FIELD_TYPE)
    {
      _typename = typename(this);
    }

    virtual bool select(const Record *r, int &index) const
    {
      index = (int)r.get(selector);
      return index >= getMin() && index <= getMax();
    }
    
    virtual int getRange() const
    {
      return 2; // OP_BUY, OP_SELL
    }
    
    virtual double getMin() const
    {
      return OP_BUY;
    }
    
    virtual double getMax() const
    {
      return OP_SELL;
    }
    
    virtual string getLabel(const int index) const
    {
      const static string types[2] = {"buy", "sell"};
      return types[index];
    }
};

class SymbolSelector: public TradeSelector
{
  public:
    SymbolSelector(): TradeSelector(FIELD_SYMBOL)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      index = (int)r.get(selector); // symbols are stored as indices in vocabulary
      return (index >= 0);
    }
    
    virtual int getRange() const override
    {
      return TradeRecord::getSymbolCount();
    }
    
    virtual string getLabel(const int index) const override
    {
      return TradeRecord::getSymbol(index);
    }
};

class MagicSelector: public TradeSelector
{
  public:
    MagicSelector(): TradeSelector(FIELD_MAGIC)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      index = TradeRecord::getMagicIndex((int)r.get(selector));
      return true;
    }
    
    virtual int getRange() const override
    {
      return TradeRecord::getMagicCount();
    }
};

class ProfitableSelector: public TradeSelector
{
  public:
    ProfitableSelector(): TradeSelector(FIELD_PROFIT_AMOUNT)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      index = (r.get(selector) > 0) ? 1 : 0;
      return true;
    }
    
    virtual int getRange() const override
    {
      return 2; // 0(false) - loss, 1(true) - profit
    }
    
    virtual string getLabel(const int index) const override
    {
      return index ? "profit" : "loss";
    }
};

template<typename E>
class DaysRangeSelector: public DateTimeSelector<E>
{
  public:
    DaysRangeSelector(const int n, const E field): DateTimeSelector(field, n)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      double d = r.get(selector);
      int days = (int)(d / (60 * 60 * 24));
      index = MathMin(days, granularity - 1);
      return true;
    }
    
    virtual string getLabel(const int index) const override
    {
      return index < granularity - 1 ? ((index < 10 ? " ": "") + (string)index + "D") : ((string)index + "D+");
    }
};


class TradeRecord: public Record
{
  protected:
    static Vocabulary<string> symbols;
    static Vocabulary<long> magics;
    static int counter;
    static IndexMap symbol2symbol;
    static Vocabulary<string> missing;
    const static char datatypes[TRADE_RECORD_FIELDS_LAST];

    void fillByOrder(const double balance)
    {
      set(FIELD_NUMBER, counter++);
      set(FIELD_TICKET, OrderTicket());
      set(FIELD_SYMBOL, symbols.add(OrderSymbol()));
      set(FIELD_TYPE, OrderType());
      set(FIELD_OPEN_DATETIME, OrderOpenTime());
      set(FIELD_CLOSE_DATETIME, OrderCloseTime());
      set(FIELD_DURATION, OrderCloseTime() - OrderOpenTime());
      set(FIELD_OPEN_PRICE, OrderOpenPrice());
      set(FIELD_CLOSE_PRICE, OrderClosePrice());
      set(FIELD_MAGIC, OrderMagicNumber());
      magics.add(OrderMagicNumber());
      set(FIELD_LOT, OrderLots());
      set(FIELD_PROFIT_AMOUNT, OrderProfit());
      set(FIELD_PROFIT_PERCENT, (OrderProfit() / balance));
      set(FIELD_PROFIT_POINT, ((OrderType() == OP_BUY ? +1 : -1) * (OrderClosePrice() - OrderOpenPrice()) / SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT)));
      set(FIELD_COMMISSION, OrderCommission());
      set(FIELD_SWAP, OrderSwap());
    }

  public:
    static string realsymbol(const string symbol, const string prefix = "", const string suffix = "")
    {
      string real;
      double temp;
      if(!SymbolInfoDouble(symbol, SYMBOL_BID, temp) && GetLastError() == ERR_MARKET_UNKNOWN_SYMBOL)
      {
        real = symbol2symbol.get(symbol);
        if(real != NULL) return real;
        
        if(Suffix != "")
        {
          int pos = StringLen(symbol) - StringLen(suffix);
          if((pos > 0) && (StringFind(symbol, suffix) == pos))
          {
            real = StringSubstr(symbol, 0, pos);
            if(SymbolInfoDouble(real, SYMBOL_BID, temp))
            {
              symbol2symbol.setValue(symbol, real);
              return real;
            }
          }
          if(StringFind(symbol, Suffix) == -1)
          {
            real = symbol + Suffix;
            if(SymbolInfoDouble(real, SYMBOL_BID, temp))
            {
              symbol2symbol.setValue(symbol, real);
              return real;
            }
          }
        }
        if(prefix != "")
        {
          int diff = StringLen(symbol) - StringLen(prefix);
          if((diff > 0) && (StringFind(symbol, prefix) == 0))
          {
            real = StringSubstr(symbol, StringLen(prefix));
            if(SymbolInfoDouble(real, SYMBOL_BID, temp))
            {
              symbol2symbol.setValue(symbol, real);
              return real;
            }
          }
          if(StringFind(symbol, prefix) == -1)
          {
            real = prefix + symbol;
            if(SymbolInfoDouble(real, SYMBOL_BID, temp))
            {
              symbol2symbol.setValue(symbol, real);
              return real;
            }
          }
        }
        int size = missing.size();
        if(missing.add(symbol) == size)
        {
          Print("Can't find correct symbol for ", symbol);
        }
        return NULL;
      }
      return symbol;
    }
    
  public:
    TradeRecord(): Record(TRADE_RECORD_FIELDS_LAST)
    {
    }

    TradeRecord(const double balance): Record(TRADE_RECORD_FIELDS_LAST)
    {
      fillByOrder(balance);
    }
    
    static int getSymbolCount()
    {
      return symbols.size();
    }
    
    static string getSymbol(const int index)
    {
      if(index < 0 || index >= symbols.size()) return NULL;
      return symbols[index];
    }
    
    static int getSymbolIndex(const string s)
    {
      return symbols.get(s);
    }

    static int getMagicCount()
    {
      return magics.size();
    }
    
    static long getMagic(const int index)
    {
      return magics[index];
    }
    
    static int getMagicIndex(const long m)
    {
      return magics.get(m);
    }
    
    static int getRecordCount()
    {
      return counter;
    }
    
    static void reset()
    {
      symbols.clear();
      magics.clear();
      counter = 0;
    }

    virtual string legend(const int index) const override
    {
      if(index >= 0 && index < TRADE_RECORD_FIELDS_LAST)
      {
        return legendFromEnum((TRADE_RECORD_FIELDS)index);
        //return EnumToString((TRADE_RECORD_FIELDS)index);
      }
      return "unknown";
    }

    static char datatype(const int index)
    {
      return datatypes[index];
    }
};


static Vocabulary<string> TradeRecord::symbols;
static Vocabulary<long> TradeRecord::magics;
static int TradeRecord::counter = 0;
static IndexMap TradeRecord::symbol2symbol;
static Vocabulary<string> TradeRecord::missing;

const static char TradeRecord::datatypes[TRADE_RECORD_FIELDS_LAST] = // not used yet
{
  0,   // none
  'i', // serial number
  'i', // ticket
  's', // symbol ('i'?, index in vocabulary)
  'i', // type (OP_BUY/OP_SELL)
  't', // open datetime
  't', // close datetime
  'i', // duration (seconds)
  'd', // open price
  'd', // close price
  'i', // magic number (index in vocabulary)
  'd', // lot
  'd', // profit amount
  'd', // profit percent
  'i', // profit points
  'd', // commission
  'd', // swap
  'd',    // custom 1
  'd'     // custom 2
};


template<typename T>
class HistoryDataAdapter: public DataAdapter
{
  private:
    int size;
    int cursor;
    double balance;
    
  public:
    HistoryDataAdapter()
    {
      reset();
      T::reset();
    }

    virtual void reset() override
    {
      cursor = 0;
      size = OrdersHistoryTotal();
      balance = 0;
    }
    
    virtual int reservedSize() const override
    {
      return size;
    }
    
    virtual Record *getNext() override
    {
      if(cursor < size)
      {
        while(OrderSelect(cursor++, SELECT_BY_POS, MODE_HISTORY))
        {
          if(OrderType() < 2 || OrderType() == OP_BALANCE)
          {
            if(SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT) == 0)
            {
              Print("MarketInfo is missing:");
              OrderPrint();
              continue;
            }

            balance += OrderProfit();
            if(OrderType() != OP_BALANCE)
            {
              return new T(balance);
            }
          }
        }
        
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
      return TRADE_RECORD_FIELDS_LAST;
    }
};


class OLAPEngineTrade: public OLAPEngine<TRADE_SELECTORS,TRADE_RECORD_FIELDS>
{
  protected:
    virtual Selector<TRADE_RECORD_FIELDS> *createSelector(const TRADE_SELECTORS selector, const TRADE_RECORD_FIELDS field) override
    {
      switch(selector)
      {
        case SELECTOR_TYPE:
          return new TypeSelector();
        case SELECTOR_SYMBOL:
          return new SymbolSelector();
        case SELECTOR_SERIAL:
          return new SerialNumberSelector<TRADE_RECORD_FIELDS,TradeRecord>(FIELD_NUMBER);
        case SELECTOR_MAGIC:
          return new MagicSelector();
        case SELECTOR_PROFITABLE:
          return new ProfitableSelector();
        case SELECTOR_DURATION:
          return new DaysRangeSelector<TRADE_RECORD_FIELDS>(15, FIELD_DURATION); // up to 14 days
        case SELECTOR_MONTH:
          return field != FIELD_NONE ? new MonthSelector<TRADE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_WEEKDAY:
          return field != FIELD_NONE ? new WorkWeekDaySelector<TRADE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_DAYHOUR:
          return field != FIELD_NONE ? new DayHourSelector<TRADE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_HOURMINUTE:
          return field != FIELD_NONE ? new DayHourSelector<TRADE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_SCALAR:
          return field != FIELD_NONE ? new BaseSelector<TRADE_RECORD_FIELDS>(field) : NULL;
        case SELECTOR_QUANTS:
          return field != FIELD_NONE ? new QuantizationSelector<TRADE_RECORD_FIELDS>(field, quantGranularity) : NULL;
        case SELECTOR_FILTER:
          return field != FIELD_NONE ? new FilterSelector<TRADE_RECORD_FIELDS>(field) : NULL;
      }
      return NULL;
    }
    
    virtual void initialize() override
    {
      Print("Symbol number: ", TradeRecord::getSymbolCount());
      for(int i = 0; i < TradeRecord::getSymbolCount(); i++)
      {
        Print(i, "] ", TradeRecord::getSymbol(i));
      }
    
      Print("Magic number: ", TradeRecord::getMagicCount());
      for(int i = 0; i < TradeRecord::getMagicCount(); i++)
      {
        Print(i, "] ", TradeRecord::getMagic(i));
      }
    }

  public:
    OLAPEngineTrade(): OLAPEngine() {}
    OLAPEngineTrade(DataAdapter *ptr): OLAPEngine(ptr) {}
  
};

#ifndef RECORD_CLASS
#define RECORD_CLASS TradeRecord
#endif

HistoryDataAdapter<RECORD_CLASS> _defaultHistoryAdapter; // CustomTradeRecord
OLAPEngineTrade _defaultEngine;
