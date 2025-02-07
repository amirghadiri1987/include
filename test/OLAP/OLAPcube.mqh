//+------------------------------------------------------------------+
//|                                                     OLAPcube.mqh |
//|                                 Copyright © 2016-2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/ru/articles/6602 |
//|                            https://www.mql5.com/ru/articles/6603 |
//+------------------------------------------------------------------+

#define MT4ORDERS_FASTHISTORY_OFF
#include <MT4orders.mqh>

#include <Marketeer/IndexMap.mqh>
#include <Marketeer/TimeMT4.mqh>
#include <Marketeer/Converter.mqh>
#include <OLAP/PairArray.mqh>

#ifndef OP_BALANCE
#define OP_BALANCE 6
#endif

enum SELECTORS
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
  SELECTOR_WEEKDAY,    // day-of-week(datetime field)
  SELECTOR_DAYHOUR,    // hour-of-day(datetime field)
  SELECTOR_HOURMINUTE, // minute-of-hour(datetime field)
  SELECTOR_SCALAR,     // scalar(field)
  SELECTOR_QUANTS      // quants(field)
};

enum AGGREGATORS
{
  AGGREGATOR_SUM,         // SUM
  AGGREGATOR_AVERAGE,     // AVERAGE
  AGGREGATOR_MAX,         // MAX
  AGGREGATOR_MIN,         // MIN
  AGGREGATOR_COUNT,       // COUNT
  AGGREGATOR_PROFITFACTOR, // PROFIT FACTOR
  AGGREGATOR_PROGRESSIVE,  // PROGRESSIVE TOTAL
  AGGREGATOR_IDENTITY      // IDENTITY
};

enum DATA_TYPES
{
  DATA_TYPE_NONE,
  DATA_TYPE_NUMBER = 'd',
  DATA_TYPE_INTEGER = 'i',
  DATA_TYPE_TIME = 't',
  DATA_TYPE_STRING = 's'
};

class Record
{
  private:
    double data[];
    
  public:
    Record(const int length)
    {
      ArrayResize(data, length);
      ArrayInitialize(data, 0);
    }
    
    void set(const int index, double value)
    {
      data[index] = value;
    }
    
    double get(const int index) const
    {
      return data[index];
    }
    
    virtual string legend(const int index) const
    {
      return NULL;
    }

    virtual char datatype(const int index) const
    {
      return 0;
    }

    virtual void fillCustomFields() {/* does nothing */};
};

// single pass data reader
class DataAdapter
{
  public:
    virtual Record *getNext() = 0;
    virtual int reservedSize() = 0;
};

template<typename E>
int EnumToArray(E dummy, int &values[], const int start = INT_MIN, const int stop = INT_MAX)
{
  string t = typename(E) + "::";
  int length = StringLen(t);
  
  ArrayResize(values, 0);
  int count = 0;
  
  for(int i = start; i < stop && !IsStopped(); i++)
  {
    E e = (E)i;
    if(StringCompare(StringSubstr(EnumToString(e), 0, length), t) != 0)
    {
      ArrayResize(values, count + 1);
      values[count++] = i;
    }
  }
  return count;
}

// MT4 and MT5 hedge
enum TRADE_RECORD_FIELDS
{
  FIELD_NONE,          // none
  FIELD_NUMBER,        // serial number
  FIELD_TICKET,        // ticket
  FIELD_SYMBOL,        // symbol
  FIELD_TYPE,          // type (OP_BUY/OP_SELL)
  FIELD_DATETIME1,     // open datetime
  FIELD_DATETIME2,     // close datetime
  FIELD_DURATION,      // duration
  FIELD_PRICE1,        // open price
  FIELD_PRICE2,        // close price
  FIELD_MAGIC,         // magic number
  FIELD_LOT,           // lot
  FIELD_PROFIT_AMOUNT, // profit amount
  FIELD_PROFIT_PERCENT,// profit percent
  FIELD_PROFIT_POINT,  // profit points
  FIELD_COMMISSION,    // commission
  FIELD_SWAP,          // swap
  FIELD_CUSTOM1,       // custom 1
  FIELD_CUSTOM2        // custom 2
};


template<typename E>
class Selector
{
  protected:
    E selector;
    string _typename;
    
  public:
    Selector(const E field): selector(field)
    {
      _typename = typename(this);
    }

    virtual void prepare(const Record *r)
    {
      // no action by default
    }
    
    // returns index of cell to store values from the record
    virtual bool select(const Record *r, int &index) const = 0;
    
    virtual int getRange() const = 0;
    virtual double getMin() const = 0;
    virtual double getMax() const = 0;
    
    virtual E getField() const
    {
      return selector;
    }
    
    virtual string getLabel(const int index) const = 0;
    
    virtual string getTitle() const
    {
      return _typename + "(" + EnumToString(selector) + ")";
    }
};


class TradeSelector: public Selector<TRADE_RECORD_FIELDS>
{
  public:
    TradeSelector(const TRADE_RECORD_FIELDS field): Selector(field)
    {
      _typename = typename(this);
    }

    virtual bool select(const Record *r, int &index) const override
    {
      index = 0;
      return true;
    }
    
    virtual int getRange() const override
    {
      return 1; // this is a scalar by default, returns 1 value
    }
    
    virtual double getMin() const override
    {
      return 0;
    }
    
    virtual double getMax() const override
    {
      return (double)(getRange() - 1);
    }
    
    virtual string getLabel(const int index) const override
    {
      return EnumToString(selector) + "[" + (string)index + "]"; // "scalar"
    }
    /*
    virtual string format(const double value) const override
    {
      if(selector == FIELD_DATETIME1 || selector == FIELD_DATETIME2)
      {
        return TimeToString(value);
      }
    }
    */
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

template<typename E>
class DateTimeSelector: public TradeSelector
{
  protected:
    int granularity;
    
  public:
    DateTimeSelector(const E field, const int size): TradeSelector(field), granularity(size)
    {
      _typename = typename(this);
    }
    
    virtual int getRange() const
    {
      return granularity;
    }
};


class WeekDaySelector: public DateTimeSelector<TRADE_RECORD_FIELDS>
{
  public:
    WeekDaySelector(const TRADE_RECORD_FIELDS f): DateTimeSelector<TRADE_RECORD_FIELDS>(f, 7)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      datetime t = (datetime)d;
      index = TimeDayOfWeek(t);
      return true;
    }
    
    virtual string getLabel(const int index) const
    {
      static string days[7] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
      return days[index];
    }
};

class DayHourSelector: public DateTimeSelector<TRADE_RECORD_FIELDS>
{
  public:
    DayHourSelector(const TRADE_RECORD_FIELDS f): DateTimeSelector<TRADE_RECORD_FIELDS>(f, 24)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      datetime t = (datetime)d;
      index = TimeHour(t);
      return true;
    }
    
    virtual string getLabel(const int index) const
    {
      return (string)index;
    }
};

class HourMinuteSelector: public DateTimeSelector<TRADE_RECORD_FIELDS>
{
  public:
    HourMinuteSelector(const TRADE_RECORD_FIELDS f): DateTimeSelector<TRADE_RECORD_FIELDS>(f, 60)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      datetime t = (datetime)d;
      index = TimeMinute(t);
      return true;
    }
    
    virtual string getLabel(const int index) const
    {
      return (string)index;
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

template<typename T>
class Vocabulary
{
  protected:
    T index[];
    
  public:
    int get(const T &text) const
    {
      int n = ArraySize(index);
      for(int i = 0; i < n; i++)
      {
        if(index[i] == text) return i;
      }
      return -(n + 1);
    }
    
    int add(const T text)
    {
      int n = get(text);
      if(n < 0)
      {
        n = -n;
        ArrayResize(index, n);
        index[n - 1] = text;
        return n - 1;
      }
      return n;
    }
    
    int size() const
    {
      return ArraySize(index);
    }
    
    T operator[](const int position) const
    {
      return index[position];
    }
    
    void clear()
    {
      ArrayResize(index, 0);
    }

};

class QuantizationSelector: public TradeSelector
{
  protected:
    Vocabulary<double> quants;

  public:
    QuantizationSelector(const TRADE_RECORD_FIELDS field): TradeSelector(field)
    {
      _typename = typename(this);
    }

    virtual void prepare(const Record *r) override
    {
      double value = r.get(selector);
      quants.add(value);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      double value = r.get(selector);
      index = quants.get(value);
      return (index >= 0);
    }
    
    virtual int getRange() const override
    {
      return quants.size();
    }
    
    virtual string getLabel(const int index) const override
    {
      return (string)(float)quants[index];
    }
};


class SerialNumberSelector: public TradeSelector
{
  public:
    SerialNumberSelector(): TradeSelector(FIELD_NUMBER)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      index = (int)r.get(selector);
      return true;
    }
    
    virtual int getRange() const override
    {
      return TradeRecord::getRecordCount();
    }

    virtual string getLabel(const int index) const override
    {
      return (string)(index);
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
class Filter
{
  protected:
    Selector<E> *selector;
    double filter;
    
  public:
    Filter(Selector<E> &s, const double value): selector(&s), filter(value)
    {
    }
    
    virtual bool matches(const Record *r) const
    {
      int index;
      if(selector.select(r, index))
      {
        if(index == (int)filter) return true;
      }
      return false;
    }
    
    Selector<E> *getSelector() const
    {
      return selector;
    }
    
    virtual string getTitle() const
    {
      return selector.getTitle() + "[" + (string)filter + "]";
    }
};

template<typename E>
class FilterRange: public Filter<E>
{
  protected:
    double filterMax;
    
  public:
    FilterRange(Selector<E> &s, const double valueMin, const double valueMax): Filter(&s, valueMin), filterMax(valueMax)
    {
    }
    
    virtual bool matches(const Record *r) const override
    {
      int index;
      if(selector.select(r, index))
      {
        if(index >= filter && index <= filterMax) return true;
      }
      return false;
    }
    
    virtual string getTitle() const override
    {
      return selector.getTitle() + "[" + (string)filter + ".." + (string)filterMax + "]";
    }
};

enum SORT_BY // applicable only for 1-dimensional cubes
{
  SORT_BY_NONE,             // none
  SORT_BY_VALUE_ASCENDING,  // value (ascending)
  SORT_BY_VALUE_DESCENDING, // value (descending)
  SORT_BY_LABEL_ASCENDING,  // label (ascending)
  SORT_BY_LABEL_DESCENDING  // label (descending)
};

#define SORT_ASCENDING(A) (((A) & 1) != 0)
#define SORT_VALUE(A)     ((A) < 3)


class MetaCube
{
  protected:
    int dimensions[];
    int offsets[];
    double totals[];
    string _typename;
    
  public:
    int getDimension() const
    {
      return ArraySize(dimensions);
    }
    
    int getDimensionRange(const int n) const
    {
      return dimensions[n];
    }
    
    int getCubeSize() const
    {
      return ArraySize(totals);
    }
    
    virtual double getValue(const int &indices[]) const = 0;
    virtual string getMetaCubeTitle() const = 0;
    virtual string getDimensionTitle(const int d) const = 0;
    virtual string getDimensionIndexLabel(const int d, const int index) const = 0;
    virtual string getFilterTitles() const = 0;
    virtual bool getVector(const int dimension, const int &consts[], PairArray *&result, const SORT_BY sortby = SORT_BY_NONE) const = 0;
    //virtual string getDimensionFormat(const int d) const = 0;
};

template<typename E>
class Aggregator: public MetaCube
{
  protected:
    const E field;
    const int selectorCount;
    const Selector<E> *selectors[];
    const int filterCount;
    const Filter<E> *filters[];
    
    virtual int mixIndex(const int &k[]) const
    {
      int result = 0;
      for(int i = 0; i < selectorCount; i++)
      {
        result += k[i] * offsets[i];
      }
      return result;
    }
    
    virtual bool decode(const int _input, int &k[]) const
    {
      int index = _input;
      ArrayResize(k, selectorCount);
      ArrayInitialize(k, 0);
      for(int i = selectorCount - 1; i >= 0; i--)
      {
        k[i] = index / offsets[i];
        index -= k[i] * offsets[i];
      }
      
      if(index != 0)
      {
        Print("Bad index decode: ", _input);
        ArrayPrint(k);
        return false;
      }
      return true;
    }

    virtual bool filter(const Record *data) const
    {
      int q = 0;
      for(; q < filterCount; q++)
      {
        if(!filters[q].matches(data))
        {
          break;
        }
      }
      
      if(q < filterCount) return false;
      
      return true;
    }
    
  
  public:
    Aggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): field(f), selectorCount(ArraySize(s)), filterCount(ArraySize(t))
    {
      ArrayResize(selectors, selectorCount);
      for(int i = 0; i < selectorCount; i++)
      {
        selectors[i] = s[i];
      }
      ArrayResize(filters, filterCount);
      for(int i = 0; i < filterCount; i++)
      {
        filters[i] = t[i];
      }
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0)
    {
      ArrayResize(dimensions, selectorCount);
      int total = 1;
      for(int i = 0; i < selectorCount; i++)
      {
        dimensions[i] = selectors[i].getRange();
        total *= dimensions[i];
      }
      ArrayResize(totals, total);
      ArrayInitialize(totals, 0);
      
      ArrayResize(offsets, selectorCount);
      offsets[0] = 1;
      for(int i = 1; i < selectorCount; i++)
      {
        offsets[i] = dimensions[i - 1] * offsets[i - 1]; // 1, X, Y*X
      }
    }
    
    virtual void prepareSelectors(const Record *&data[])
    {
      int n = ArraySize(data);
      for(int i = 0; i < n; i++)
      {
        for(int j = 0; j < selectorCount; j++)
        {
          Selector<E> *s = (Selector<E> *)selectors[j];
          s.prepare(data[i]);
        }
      }
    }
    
    // build an array with number of dimensions equal to number of selectors
    virtual void calculate(const Record *&data[])
    {
      int k[];
      ArrayResize(k, selectorCount);
      int n = ArraySize(data);
      for(int i = 0; i < n; i++)
      {
        if(!filter(data[i])) continue;
        
        int j = 0;
        for(; j < selectorCount; j++)
        {
          int d;
          if(!selectors[j].select(data[i], d)) // record successfully mapped to a cell of selector?
          {
            break;                             // skip it, if not
          }
          k[j] = d;                            // save index in j-th dimension in array
        }
        if(j == selectorCount)                 // all coordinates are resolved
        {
          update(mixIndex(k), data[i].get(field)); // apply maths/stats
        }
      }
    }
    
    double getValue(const int &indices[]) const override
    {
      return totals[mixIndex(indices)];
    }
    
    virtual string getMetaCubeTitle() const override
    {
      return _typename + " " + EnumToString(field);
    }
    
    virtual string getDimensionTitle(const int d) const override
    {
      if(d >= ArraySize(selectors)) return "n/a";
      return selectors[d].getTitle();
    }
    
    /*
    virtual string getDimensionFormat(const int d) const override
    {
      if(d >= ArraySize(selectors)) return NULL;
      return selectors[d].format(); // there's no such thing like datetime format
    }
    */

    virtual string getDimensionIndexLabel(const int d, const int index) const override
    {
      if(d >= ArraySize(selectors)) return "n/a";
      return selectors[d].getLabel(index);
    }
    
    virtual string getFilterTitles() const override
    {
      string titles = "";
      for(int i = 0; i < ArraySize(filters); i++)
      {
        titles += filters[i].getTitle() + ";";
      }
      if(titles == "") titles = "no";
      return titles;
    }
    
    virtual void update(const int index, const double value) = 0;
    
    virtual bool getVector(const int dimension, const int &consts[], PairArray *&result, const SORT_BY sortby = SORT_BY_NONE) const
    {
      const int n = getDimension();
      if(dimension >= n || n < 0) return false;
      
      result = new PairArray;

      int indices[];
      ArrayResize(indices, n);
      
      if(sortby != SORT_BY_NONE)
      {
        result.compareBy((SORT_ASCENDING(sortby) ? (Comparator *)(new Greater()) : (Comparator *)(new Lesser())));
      }
      else
      {
        result.compareBy(NULL);
      }
      
      int m = getDimensionRange(dimension);
      result.allocate(m);
      int count = 0;
      for(int i = 0; i < m; i++)
      {
        ArrayCopy(indices, consts);
        indices[dimension] = i;
        
        double v = getValue(indices);
        if(SORT_VALUE(sortby))
        {
          result.insert(count, v, getDimensionIndexLabel(dimension, i));
        }
        else
        {
          result.insert(count, getDimensionIndexLabel(dimension, i), v);
        }
        count++;
      }
      
      result.allocate(count);
      
      return true;
    }
    
};

template<typename E>
class IdentityAggregator: public Aggregator<E>
{
  private:
    int size;

  protected:
    virtual int mixIndex(const int &k[/*0 - record number, 1 - field number*/]) const override
    {
      int result = 0;
      for(int i = 0; i < size; i++)
      {
        result += k[i] * offsets[i];
      }
      return result;
    }
    
    virtual bool decode(const int _input, int &k[]) const override
    {
      int index = _input;
      ArrayResize(k, size);
      ArrayInitialize(k, 0);
      for(int i = 1; i >= 0; i--)
      {
        k[i] = index / offsets[i];
        index -= k[i] * offsets[i];
      }
      
      if(index != 0)
      {
        Print("Bad index decode: ", _input);
        ArrayPrint(k);
        return false;
      }
      return true;
    }
  
  public:
    IdentityAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }

    virtual void setSelectorBounds(const int length = 0) override
    {
      size = 1 + (selectorCount > 1);
      ArrayResize(dimensions, size);
      int total = length * selectorCount;
      dimensions[0] = length;
      if(selectorCount > 1) dimensions[1] = selectorCount;
      ArrayResize(totals, total);
      ArrayInitialize(totals, 0);
      
      ArrayResize(offsets, size);
      offsets[0] = 1;
      if(selectorCount > 1)
      {
        offsets[1] = dimensions[0];
      }
    }

    virtual void calculate(const Record *&data[]) override
    {
      int k[];
      ArrayResize(k, size);
      int n = ArraySize(data);
      for(int i = 0; i < n; i++)
      {
        if(!filter(data[i])) continue;
        
        k[0] = i;
        for(int j = 0; j < selectorCount; j++)
        {
          if(selectorCount > 1) k[1] = j;
          update(mixIndex(k), data[i].get(selectors[j].getField()));
        }
      }
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index] = value;
    }

    virtual string getMetaCubeTitle() const override
    {
      return _typename + (field != FIELD_NONE ? " (field has no effect and ignored)" : "");
    }

    virtual string getDimensionTitle(const int d) const override
    {
      if(d < 0)
      {
        return Aggregator<E>::getDimensionTitle(-d - 1);
      }
      else
      if(d == 0)
      {
        if(selectorCount > 1) return "index";
        else return selectors[0].getTitle() + " by index";
      }
      else
      {
        string titles = "";
        for(int i = 0; i < selectorCount; i++)
        {
          titles += (string)i + ":" + selectors[i].getTitle() + "; ";
        }
        return titles;
      }
    }

    virtual string getDimensionIndexLabel(const int d, const int index) const override
    {
      return "[" + (string)index + "]";
    }
};


template<typename E>
class SumAggregator: public Aggregator<E>
{
  public:
    SumAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index] += value;
    }
    
};


template<typename E>
class ProgressiveTotalAggregator: public Aggregator<E>
{
  private:
    double accumulators[];

  public:
    ProgressiveTotalAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0) override
    {
      Aggregator<E>::setSelectorBounds();
      int dim = 1;
      for(int i = 1; i < selectorCount; i++) // except 1-st dimention, for which progressive total is calculated
      {
        dim *= dimensions[i];
      }
      ArrayResize(accumulators, dim);
      ArrayInitialize(accumulators, 0);

      Converter<ulong,double> converter;
      double nan = converter[0x7FF8000000000000]; // quiet NaN
      ArrayInitialize(totals, nan);
    }
    
    virtual void update(const int index, const double value) override
    {
      int subindex = 0;
      if(selectorCount > 1)
      {
        int k[];
        decode(index, k);
        // eliminate 1-st dimension, special case of index mix
        for(int i = 1; i < selectorCount; i++)
        {
          subindex += k[i] * (offsets[i] / dimensions[0]);
        }
      }

      accumulators[subindex] += value;
      totals[index] = accumulators[subindex];
    }
};

template<typename E>
class AverageAggregator: public Aggregator<E>
{
  protected:
    int counters[];
    
  public:
    AverageAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0) override
    {
      Aggregator<E>::setSelectorBounds();
      ArrayResize(counters, ArraySize(totals));
      ArrayInitialize(counters, 0);
    }

    virtual void update(const int index, const double value) override
    {
      totals[index] = (totals[index] * counters[index] + value) / (counters[index] + 1);
      counters[index]++;
    }
};

template<typename E>
class ProfitFactorAggregator: public Aggregator<E>
{
  protected:
    double positives[];
    double negatives[];
    
  public:
    ProfitFactorAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0) override
    {
      Aggregator<E>::setSelectorBounds();
      ArrayResize(positives, ArraySize(totals));
      ArrayResize(negatives, ArraySize(totals));
      ArrayInitialize(positives, 0);
      ArrayInitialize(negatives, 0);
    }

    virtual void update(const int index, const double value) override
    {
      if(value >= 0) positives[index] += value;
      else negatives[index] -= value;
      
      if(negatives[index] > 0)
      {
        totals[index] = positives[index] / negatives[index];
      }
      else
      {
        Converter<ulong,double> converter;

        totals[index] = converter[0x7FF0000000000000]; // infinity
      }
    }
};

template<typename E>
class MaxAggregator: public Aggregator<E>
{
  public:
    MaxAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index] = MathMax(totals[index], value);
    }
};

template<typename E>
class MinAggregator: public Aggregator<E>
{
  public:
    MinAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0) override
    {
      Aggregator<E>::setSelectorBounds();
      ArrayInitialize(totals, DBL_MAX);
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index] = MathMin(totals[index], value);
    }
};

template<typename E>
class CountAggregator: public Aggregator<E>
{
  public:
    CountAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index]++;
    }
};


#define TRADE_RECORD_FIELDS_NUMBER_DEFAULT 19
static TRADE_RECORD_FIELDS _f;
static int _dummy[];
const static int TRADE_RECORD_FIELDS_NUMBER = EnumToArray(_f, _dummy, 0, 100);

class TradeRecord: public Record
{
  protected:
    static Vocabulary<string> symbols;
    static Vocabulary<long> magics;
    static int counter;
    static IndexMap symbol2symbol;
    static Vocabulary<string> missing;
    const static char datatypes[TRADE_RECORD_FIELDS_NUMBER_DEFAULT];

    void fillByOrder(const double balance)
    {
      set(FIELD_NUMBER, counter++);
      set(FIELD_TICKET, OrderTicket());
      set(FIELD_SYMBOL, symbols.add(OrderSymbol()));
      set(FIELD_TYPE, OrderType());
      set(FIELD_DATETIME1, OrderOpenTime());
      set(FIELD_DATETIME2, OrderCloseTime());
      set(FIELD_DURATION, OrderCloseTime() - OrderOpenTime());
      set(FIELD_PRICE1, OrderOpenPrice());
      set(FIELD_PRICE2, OrderClosePrice());
      set(FIELD_MAGIC, OrderMagicNumber());
      magics.add(OrderMagicNumber());
      set(FIELD_LOT, OrderLots());
      set(FIELD_PROFIT_AMOUNT, OrderProfit());
      set(FIELD_PROFIT_PERCENT, (OrderProfit() / balance));
      set(FIELD_PROFIT_POINT, ((OrderType() == OP_BUY ? +1 : -1) * (OrderClosePrice() - OrderOpenPrice()) / SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT)));
      set(FIELD_COMMISSION, OrderCommission());
      set(FIELD_SWAP, OrderSwap());
    }

  private:
    class _StaticCheck
    {
      private:
        _StaticCheck()
        {
          // ASSERT that datatypes[] are provided for all TRADE_RECORD_FIELDS elements
          if(TRADE_RECORD_FIELDS_NUMBER != TRADE_RECORD_FIELDS_NUMBER_DEFAULT)
          {
            Print("TRADE_RECORD_FIELDS cardinality mismatch: actual ", TRADE_RECORD_FIELDS_NUMBER, ", supposed ", TRADE_RECORD_FIELDS_NUMBER_DEFAULT);
            Print("Execution stopped");
            ExpertRemove();
          }
        }

        static void instantiate()
        {
          static _StaticCheck staticCheck;
        }
    };

  public:
    static string realsymbol(const string symbol)
    {
      string real;
      double temp;
      if(!SymbolInfoDouble(symbol, SYMBOL_BID, temp) && GetLastError() == ERR_MARKET_UNKNOWN_SYMBOL)
      {
        real = symbol2symbol.get(symbol);
        if(real != NULL) return real;
        
        if(Suffix != "")
        {
          int pos = StringLen(symbol) - StringLen(Suffix);
          if((pos > 0) && (StringFind(symbol, Suffix) == pos))
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
        if(Prefix != "")
        {
          int diff = StringLen(symbol) - StringLen(Prefix);
          if((diff > 0) && (StringFind(symbol, Prefix) == 0))
          {
            real = StringSubstr(symbol, StringLen(Prefix));
            if(SymbolInfoDouble(real, SYMBOL_BID, temp))
            {
              symbol2symbol.setValue(symbol, real);
              return real;
            }
          }
          if(StringFind(symbol, Prefix) == -1)
          {
            real = Prefix + symbol;
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
    TradeRecord(): Record(TRADE_RECORD_FIELDS_NUMBER)
    {
    }

    TradeRecord(const double balance): Record(TRADE_RECORD_FIELDS_NUMBER)
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
      if(index >= 0 && index < TRADE_RECORD_FIELDS_NUMBER)
      {
        return EnumToString((TRADE_RECORD_FIELDS)index);
      }
      return "unknown";
    }

    virtual char datatype(const int index) const override
    {
      return datatypes[index];
    }
};

class CustomTradeRecord: public TradeRecord
{
  private:
    // Start-up time announcement of custom fields specialization
    class CustomFieldsDescription
    {
      private:
        CustomFieldsDescription()
        {
          Print("Custom fields processing attached:");
          Print("FIELD_CUSTOM1 == Single Trade MFE (%)");
          Print("FIELD_CUSTOM2 == Single Trade MAE (%)");
        }

      public:
        static CustomFieldsDescription *instantiate()
        {
          static CustomFieldsDescription instance;
          return &instance;
        }
    };

  public:
    CustomTradeRecord(): TradeRecord()
    {
    }
    CustomTradeRecord(const double balance): TradeRecord(balance)
    {
    }
    
    // calculate MFE/MAE in percents
    virtual void fillCustomFields() override
    {
      static CustomFieldsDescription *legend = CustomFieldsDescription::instantiate();

      double positiveExcursion = 0, negativeExcursion = 0;
      string symbol = symbols[(int)get(FIELD_SYMBOL)];
      int t1 = iBarShift(symbol, _Period, (datetime)get(FIELD_DATETIME1), false);
      int t2 = iBarShift(symbol, _Period, (datetime)get(FIELD_DATETIME2), false);
      int type = (int)get(FIELD_TYPE);
      double open = get(FIELD_PRICE1);
      double close = get(FIELD_PRICE2);

      for(int t = t1; t >= t2; t--)
      {
        if(type == OP_BUY)
        {
          positiveExcursion = MathMax(positiveExcursion, MathMax((iHigh(symbol, _Period, t) - close), 0) / close);
          negativeExcursion = MathMin(negativeExcursion, MathMin((iLow(symbol, _Period, t) - open), 0) / open);
        }
        else if(type == OP_SELL)
        {
          positiveExcursion = MathMax(positiveExcursion, MathMax((close - iLow(symbol, _Period, t)), 0) / close);
          negativeExcursion = MathMin(negativeExcursion, MathMin((open - iHigh(symbol, _Period, t)), 0) / open);
        }
      }
      set(FIELD_CUSTOM1, positiveExcursion * 100);
      set(FIELD_CUSTOM2, negativeExcursion * 100);
    }

    virtual string legend(const int index) const override
    {
      if(index == FIELD_CUSTOM1) return "MFE per trade(%)";
      else
      if(index == FIELD_CUSTOM2) return "MAE per trade(%)";
      
      return TradeRecord::legend(index);
    }
};

static Vocabulary<string> TradeRecord::symbols;
static Vocabulary<long> TradeRecord::magics;
static int TradeRecord::counter = 0;
static IndexMap TradeRecord::symbol2symbol;
static Vocabulary<string> TradeRecord::missing;

const static char TradeRecord::datatypes[TRADE_RECORD_FIELDS_NUMBER_DEFAULT] =
{
  0,   // none
  'i', // serial number
  'i', // ticket
  's', // symbol
  'i', // type (OP_BUY/OP_SELL)
  't', // open datetime
  't', // close datetime
  'i', // duration (seconds)
  'd', // open price
  'd', // close price
  'i', // magic number
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
class HistoryTradeRecord: public T // CustomTradeRecord
{
  public:
    HistoryTradeRecord()
    {
      fillCustomFields();
    }
    HistoryTradeRecord(const double balance): T(balance)
    {
      fillCustomFields();
    }
};

template<typename T>
class HistoryDataAdapter: public DataAdapter
{
  private:
    int size;
    int cursor;
    double balance;
    
  protected:
    void reset()
    {
      cursor = 0;
      size = OrdersHistoryTotal();
      balance = 0;
    }
    
  public:
    HistoryDataAdapter()
    {
      reset();
      T::reset();
    }
    
    virtual int reservedSize()
    {
      return size;
    }
    
    virtual Record *getNext()
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
              return new HistoryTradeRecord<T>(balance);
            }
          }
        }
        
        return NULL;
      }
      return NULL;
    }
};


class Display
{
  public:
    virtual void display(MetaCube *metaData, const SORT_BY sortby = SORT_BY_NONE, const bool identity = false) = 0;
};


class LogDisplay: public Display
{
  private:
    string format;
    int digits;
    
  public:
    LogDisplay(const int w, const int d)
    {
      digits = d;
      format = StringFormat("%%%d.%df", w, d);
    }


    virtual void display(MetaCube *metaData, const SORT_BY sortby = SORT_BY_NONE, const bool identity = false) override
    {
      int n = metaData.getDimension();
      int indices[], cursors[];
      ArrayResize(indices, n);
      ArrayResize(cursors, n);
      ArrayInitialize(cursors, 0);

      Print(metaData.getMetaCubeTitle(), " [", metaData.getCubeSize(), "]");
      
      bool sorting = n == 1 && sortby != SORT_BY_NONE;
      
      PairArray *flat = NULL;
      
      if(sorting)
      {
        flat = new PairArray(metaData.getCubeSize(), (SORT_ASCENDING(sortby) ? (Comparator *)(new Greater()) : (Comparator *)(new Lesser())));
      }

      for(int i = 0; i < n; i++)
      {
        indices[i] = metaData.getDimensionRange(i);
        Print(CharToString((uchar)('X' + i)), ": ", metaData.getDimensionTitle(i), " [", indices[i], "]");
      }
      
      string labels[];
      ArrayResize(labels, n);
      
      bool looping = false;
      int count = 0;
      do
      {
        for(int j = 0; j < n; j++)
        {
          labels[j] = metaData.getDimensionIndexLabel(j, cursors[j]);
        }

        if(sorting)
        {
          // sort single (first) dimension by sort_by
          if(SORT_VALUE(sortby))
          {
            flat.insert(count++, metaData.getValue(cursors), labels[0]);
          }
          else
          {
            flat.insert(count++, labels[0], metaData.getValue(cursors));
          }
        }
        else
        {
          arrayPrint(StringFormat(format, metaData.getValue(cursors)), labels);
        }

        for(int i = 0; i < n; i++)
        {
          if(cursors[i] < indices[i] - 1)
          {
            looping = true;
            cursors[i]++;
            break;
          }
          else
          {
            cursors[i] = 0;
          }
          looping = false;
        }
      }
      while(looping && !IsStopped());
      
      if(sorting)
      {
        ArrayPrint(flat.array, digits);
        delete flat;
      }
    }
};

template<typename T>
bool Comparator::compare(const Pair &v1, const T v2)
{
  Greater *g = dynamic_cast<Greater *>(&this);
  if(g != NULL) return g.compare(v1, v2);
  Lesser *l = dynamic_cast<Lesser *>(&this);
  if(l != NULL) return l.compare(v1, v2);
  return false;
}


template<typename T>
void arrayPrint(const string title, const T &V[])
{
  int n = ArraySize(V);
  string s;
  for(int i = 0; i < n; i++)
  {
    s = s + " " + (string)V[i];
  }
  Print(title + ":" + s);
}    


template<typename E>
class Analyst
{
  private:
    DataAdapter *adapter;
    Record *data[];
    Aggregator<E> *aggregator;
    Display *output;
    
  public:
    Analyst(DataAdapter &a, Aggregator<E> &g, Display &d): adapter(&a), aggregator(&g), output(&d)
    {
      ArrayResize(data, adapter.reservedSize());
    }
    
    ~Analyst()
    {
      int n = ArraySize(data);
      for(int i = 0; i < n; i++)
      {
        if(CheckPointer(data[i]) == POINTER_DYNAMIC) delete data[i];
      }
    }
    
    void acquireData()
    {
      Record *record;
      int i = 0;
      while((record = adapter.getNext()) != NULL)
      {
        data[i++] = record;
      }
      ArrayResize(data, i);
      
      aggregator.prepareSelectors(data);
      
      aggregator.setSelectorBounds(i);
    }
    
    void build()
    {
      aggregator.calculate(data);
    }
    
    void display(const SORT_BY sortby = SORT_BY_NONE, const bool identity = false)
    {
      output.display(aggregator, sortby, identity);
    }
};
