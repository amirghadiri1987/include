//+------------------------------------------------------------------+
//|                                                   OLAPCommon.mqh |
//|                                 Copyright © 2016-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7535 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+


#include <Marketeer/IndexMap.mqh>
#include <MT4Bridge/MT4Time.mqh>
#include <Marketeer/Converter.mqh>
#include <OLAP/PairArray.mqh>


enum AGGREGATORS
{
  AGGREGATOR_SUM,          // SUM
  AGGREGATOR_AVERAGE,      // AVERAGE
  AGGREGATOR_MAX,          // MAX
  AGGREGATOR_MIN,          // MIN
  AGGREGATOR_COUNT,        // COUNT
  AGGREGATOR_PROFITFACTOR, // PROFIT FACTOR
  AGGREGATOR_PROGRESSIVE,  // PROGRESSIVE TOTAL
  AGGREGATOR_IDENTITY,     // IDENTITY
  AGGREGATOR_STDDEV        // DEVIATION
};

enum DATA_TYPES
{
  DATA_TYPE_NONE,
  DATA_TYPE_NUMBER = 'd',
  DATA_TYPE_INTEGER = 'i',
  DATA_TYPE_TIME = 't',
  DATA_TYPE_STRING = 's'
};

int MathSign(const double x)
{
  return x > 0 ? +1 : (x < 0 ? -1 : 0);
}

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

    template<typename T>
    static char datatype2(const int index)
    {
      return T::datatype(index);
    }
    
    template<typename E>
    static string legendFromEnum(E e)
    {
      string text = EnumToString(e);
      // don't return NULL as a flag of overflow (custom fields not in enum)
      // better to show lengthy wording then empty space
      if(StringFind(text, "::") > 0) return text;
      StringToLower(text);
      StringReplace(text, "_", " ");
      const string field = "field ";
      if(StringFind(text, field) == 0)
      {
        return StringSubstr(text, StringLen(field));
      }
      return text;
    }
    
    static char datatype(const int index)
    {
      return 0;
    }

    virtual void fillCustomFields() {/* does nothing */};
};

// single pass data reader
class DataAdapter
{
  public:
    virtual void reset() = 0;
    virtual Record *getNext() = 0;
    virtual int reservedSize() const = 0;
    virtual bool isOwner() const = 0;
    virtual int getFieldCount() const = 0;
    virtual int getCustomFieldCount() const { return 0; };
    virtual int getCustomFields(string &names[]) const { return 0; };
};

interface Progress
{
  void progress(const int cursor, const int total) const;
};

class PackedEnum
{
  public:
    static bool type;
};

static bool PackedEnum::type = true;

template<typename E,typename PACKED>
int EnumToArray(E dummy, int &values[], const int start = 0, const int stop = INT_MAX)
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
    else if(PACKED::type)
    {
      break;
    }
  }
  return count;
}

template<typename E,typename PACKED>
int EnumSize(E dummy, const int start = 0, const int stop = INT_MAX)
{
  string t = typename(E) + "::";
  int length = StringLen(t);
  
  int count = 0;
  
  for(int i = start; i < stop && !IsStopped(); i++)
  {
    E e = (E)i;
    if(StringCompare(StringSubstr(EnumToString(e), 0, length), t) != 0)
    {
      count++;
    }
    else if(PACKED::type)
    {
      break;
    }
  }
  return count;
}


// COMMON SELECTORS

template<typename E>
class Selector
{
  protected:
    E selector;
    string _typename;
    int size;
    static bool shortTitles;
    
  public:
    Selector(const E field): selector(field)
    {
      size = EnumSize<E,PackedEnum>(field);
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
      if(shortTitles)
      {
        return Record::legendFromEnum(selector);
      }
      return _typename + "(" + EnumToString(selector) + ")";
    }
    
    virtual int getFieldSize() const
    {
      return size;
    }
    
    static void setShortTitles(const bool t)
    {
      shortTitles = t;
    }
};

template<typename E>
static bool Selector::shortTitles = false;

template<typename T>
class BaseSelector: public Selector<T>
{
  public:
    BaseSelector(const T field): Selector(field)
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
};

template<typename T>
class FilterSelector: public BaseSelector<T>
{
  public:
    FilterSelector(const T field): BaseSelector(field)
    {
      _typename = typename(this);
    }

    virtual bool select(const Record *r, int &index) const override
    {
      index = -1;
      return true;
    }
    
    virtual int getRange() const override
    {
      return 0;
    }
    
    virtual double getMin() const override
    {
      return 0;
    }
    
    virtual double getMax() const override
    {
      return 0;
    }
    
    virtual string getLabel(const int index) const override
    {
      return EnumToString(selector);
    }
};

template<typename E>
class DateTimeSelector: public BaseSelector<E>
{
  protected:
    int granularity;
    
  public:
    DateTimeSelector(const E field, const int gsize): BaseSelector(field), granularity(gsize)
    {
      _typename = typename(this);
    }
    
    virtual int getRange() const
    {
      return granularity;
    }
};

template<typename E>
class MonthSelector: public DateTimeSelector<E>
{
  public:
    MonthSelector(const E f): DateTimeSelector(f, 12)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      datetime t = (datetime)d;
      index = TimeMonth(t) - 1;
      return true;
    }
    
    virtual string getLabel(const int index) const
    {
      static string months[12] = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
      return months[index];
    }
};

template<typename E>
class WeekDaySelector: public DateTimeSelector<E>
{
  public:
    WeekDaySelector(const E f): DateTimeSelector(f, 7)
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
      static string days[7] = {"7`Sunday", "1`Monday", "1`Tuesday", "3`Wednesday", "4`Thursday", "5`Friday", "6`Saturday"};
      return days[index];
    }
};

template<typename E>
class WorkWeekDaySelector: public DateTimeSelector<E>
{
  public:
    WorkWeekDaySelector(const E f): DateTimeSelector(f, 5)
    {
      _typename = typename(this);
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      datetime t = (datetime)d;
      index = TimeDayOfWeek(t) - 1;
      return (index >= 0 && index < 5);
    }
    
    virtual string getLabel(const int index) const
    {
      static string days[5] = {"1`Monday", "2`Tuesday", "3`Wednesday", "4`Thursday", "5`Friday"};
      return days[index];
    }
};

template<typename E>
class DayHourSelector: public DateTimeSelector<E>
{
  public:
    DayHourSelector(const E f): DateTimeSelector(f, 24)
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
      return StringFormat("%02d", index);
    }
};

template<typename E>
class HourMinuteSelector: public DateTimeSelector<E>
{
  public:
    HourMinuteSelector(const E f): DateTimeSelector(f, 60)
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
      return StringFormat("%02d", index);
    }
};

// aux class for QuantizationSelector below
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

template<typename T>
class QuantizationSelector: public BaseSelector<T>
{
  protected:
    Vocabulary<double> quants;
    uint cell;
    double min, max;

  public:
    QuantizationSelector(const T field, const uint granularity = 0): BaseSelector<T>(field), cell(granularity)
    {
      _typename = typename(this);
      min = DBL_MAX;
      max = -DBL_MAX;
    }

    virtual void prepare(const Record *r) override
    {
      double value = r.get(selector);
      if(cell != 0) value = MathSign(value) * MathFloor(MathAbs(value) / cell) * cell;
      quants.add(value);
      double abs = MathAbs(value);
      if(abs > max) max = abs;
      abs = NormalizeDouble(abs - MathFloor(abs), 8);
      if(abs > 0.0000001 && abs < min) min = abs;
    }
    
    virtual bool select(const Record *r, int &index) const override
    {
      double value = r.get(selector);
      if(cell != 0) value = MathSign(value) * MathFloor(MathAbs(value) / cell) * cell;
      index = quants.get(value);
      return (index >= 0);
    }
    
    virtual int getRange() const override
    {
      return quants.size();
    }
    
    virtual string getLabel(const int index) const override
    {
      int minbase = 0;
      int maxbase = 0;
      
      if(min > 0 && min != DBL_MAX)
      {
        double b1 = NormalizeDouble(min, (int)MathRound(MathAbs(MathLog10(min)) + 0.5));
        if(b1 > 0) minbase = (int)MathAbs(MathFloor(MathLog10(b1)));
      }
      
      if(max > 0)
      {
        maxbase = (int)MathFloor(MathLog10(max));
      }

      string format; // %5.2f
      format = StringFormat("%c%d.%df", '%', ((int)MathAbs(minbase) + (int)MathAbs(maxbase) + 3), (int)MathAbs(minbase));
      string result = StringFormat(format, quants[index]);
      return result;
    }
};

template<typename T,typename R>
class SerialNumberSelector: public BaseSelector<T>
{
  public:
    SerialNumberSelector(const T field): BaseSelector<T>(field)
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
      return R::getRecordCount();
    }

    virtual string getLabel(const int index) const override
    {
      return (string)(index);
    }
};


// FILTERS

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
        if(index == -1)
        {
          if(dynamic_cast<FilterSelector<E> *>(selector) != NULL)
          {
            return r.get(selector.getField()) == filter;
          }
        }
        else
        {
          if(index == (int)filter) return true;
        }
      }
      return false;
    }
    
    Selector<E> *getSelector() const
    {
      return selector;
    }
    
    virtual string getTitle() const
    {
      return "Filter::" + selector.getTitle() + "[" + (string)filter + "]";
    }
};

template<typename E>
class FilterRange: public Filter<E>
{
  protected:
    double filterMax;
    
  public:
    FilterRange(Selector<E> &s, const double valueMin, const double valueMax): Filter(s, valueMin), filterMax(valueMax)
    {
    }
    
    virtual bool matches(const Record *r) const override
    {
      int index;
      if(selector.select(r, index))
      {
        if(index == -1)
        {
          if(dynamic_cast<FilterSelector<E> *>(selector) != NULL)
          {
            const double v = r.get(selector.getField());
            if(filterMax > filter)
            {
              return v >= filter && v < filterMax; // range [;) is included
            }
            else
            {
              return v >= filter || v < filterMax; // range [;) is excluded
            }
          }
        }
        else
        {
          if(filterMax > filter)
          {
            return index >= (int)filter && index < (int)filterMax;
          }
          else
          {
            return index >= (int)filter || index < (int)filterMax;
          }
        }
      }
      return false;
    }
    
    virtual string getTitle() const override
    {
      return "FilterRange::" + selector.getTitle() + "[" + (string)filter + " ... " + (string)filterMax + "]";
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
#define SORT_VALUE(A)     ((A) > 0 && (A) < 3)


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
    virtual string getMetaCubeTitle(const bool shortNames = false) const = 0;
    virtual string getDimensionTitle(const int d) const = 0;
    virtual string getDimensionIndexLabel(const int d, const int index) const = 0;
    virtual string getFilterTitles() const = 0;
    virtual bool getVector(const int dimension, const int &consts[], PairArray *&result, const SORT_BY sortby = SORT_BY_NONE) const = 0;
    virtual int getDimensionField(const int d) const = 0;

    virtual bool hasSpecialFormat() const
    {
      return false;
    }
    virtual string getValueFormatted(const double value) const
    {
      return (string)value; // stub
    }
    //virtual string getDimensionFormat(const int d) const = 0;

    virtual bool isSerial() const
    {
      return false;
    }
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
    string customNames[];
    
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
      dimensions[0] = length == 0 ? selectors[0].getRange() : length;
      int total = dimensions[0];
      for(int i = 1; i < selectorCount; i++)
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
    
    virtual int prepareSelectors(const Record *&data[])
    {
      int n = ArraySize(data);
      int count = 0;
      for(int i = 0; i < n; i++)
      {
        if(!filter(data[i])) continue;

        for(int j = 0; j < selectorCount; j++)
        {
          Selector<E> *s = (Selector<E> *)selectors[j];
          s.prepare(data[i]);
        }
        count++;
      }
      return count;
    }
    
    // build an array with number of dimensions equal to number of selectors
    virtual int calculate(const Record *&data[], const Progress *callback = NULL)
    {
      int k[];
      int processed = 0;
      ArrayResize(k, selectorCount);
      int n = ArraySize(data);
      for(int i = 0; i < n && !IsStopped(); i++)
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
          processed++;
        }
        if(callback != NULL) callback.progress(i, n);
      }
      return processed;
    }
    
    double getValue(const int &indices[]) const override
    {
      return totals[mixIndex(indices)];
    }
    
    virtual string getMetaCubeTitle(const bool shortNames = false) const override
    {
      const int size = EnumSize<E,PackedEnum>(field);
      if(field >= size && field - size < ArraySize(customNames))
      {
        return _typename + " " + customNames[field - size];
      }
      return _typename + " " + (shortNames ? Record::legendFromEnum(field) : EnumToString(field));
      // return _typename + " " + EnumToString(field);
    }
    
    virtual string getDimensionTitle(const int d) const override
    {
      if(d >= ArraySize(selectors)) return "n/a";
      string title = selectors[d].getTitle();
      if(StringFind(title, "::") > 0) // not found in enum, assume dynamically added custom field
      {
        const int n = getDimensionField(d);
        const int m = selectors[d].getFieldSize();
        if(n != -1 && n >= m && n - m < ArraySize(customNames))
        {
          return customNames[n - m];
        }
      }
      
      return title;
    }
    
    virtual int getDimensionField(const int d) const override
    {
      if(d >= ArraySize(selectors)) return -1;
      return (int)selectors[d].getField();
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

    virtual void assignCustomFields(const string &fields[])
    {
      ArrayCopy(customNames, fields);
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

    virtual int calculate(const Record *&data[], const Progress *callback = NULL) override
    {
      int k[];
      int processed = 0;
      ArrayResize(k, size);
      int n = ArraySize(data);
      for(int i = 0; i < n && !IsStopped(); i++)
      {
        if(!filter(data[i])) continue;
        
        k[0] = processed; // i;
        for(int j = 0; j < selectorCount; j++)
        {
          if(selectorCount > 1) k[1] = j;
          update(mixIndex(k), data[i].get(selectors[j].getField()));
        }
        processed++;
        if(callback != NULL) callback.progress(i, n);
      }
      return processed;
    }
    
    virtual void update(const int index, const double value) override
    {
      totals[index] = value;
    }

    virtual string getMetaCubeTitle(const bool shortNames = false) const override
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

    virtual int getDimensionField(const int d) const override
    {
      return Aggregator<E>::getDimensionField((d < 0 ? -d - 1 : d));
    }

    virtual string getDimensionIndexLabel(const int d, const int index) const override
    {
      return "[" + (string)index + "]";
    }

    virtual bool isSerial() const override
    {
      return true;
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
      Aggregator<E>::setSelectorBounds(length);
      int dim = 1;
      for(int i = 1; i < selectorCount; i++) // except 1-st dimention, for which progressive total is calculated
      {
        dim *= dimensions[i];
      }
      ArrayResize(accumulators, dim);
      ArrayInitialize(accumulators, 0);

      Converter<ulong,double> converter;
      const double nan = converter[0x7FF8000000000000]; // quiet NaN
      ArrayInitialize(totals, nan);
    }

    virtual int calculate(const Record *&data[], const Progress *callback = NULL) override
    {
      int k[];
      int processed = 0;
      int cursor = 0;
      ArrayResize(k, selectorCount);
      int n = ArraySize(data);
      for(int i = 0; i < n && !IsStopped(); i++)
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
          k[j] = j == 0 ? cursor : d;          // save index in j-th dimension in array
        }
        if(j == selectorCount)                 // all coordinates are resolved
        {
          update(mixIndex(k), data[i].get(field)); // apply maths/stats
          processed++;
        }
        cursor++;
        if(callback != NULL) callback.progress(i, n);
      }
      return processed;
    }
    
    virtual void update(const int index, const double value) override
    {
      if(index < 0 || index >= ArraySize(totals))
      {
        Print(__FUNCSIG__, ": Index out of bound: ", index, " size: ", ArraySize(totals));
      }

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

    virtual bool isSerial() const override
    {
      return true;
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
class VarianceAggregator: public Aggregator<E>
{
  protected:
    int counters[];
    double sumx[];
    double sumx2[];
    
  public:
    VarianceAggregator(const E f, const Selector<E> *&s[], const Filter<E> *&t[]): Aggregator(f, s, t)
    {
      _typename = typename(this);
    }
    
    virtual void setSelectorBounds(const int length = 0) override
    {
      Aggregator<E>::setSelectorBounds();
      ArrayResize(counters, ArraySize(totals));
      ArrayResize(sumx, ArraySize(totals));
      ArrayResize(sumx2, ArraySize(totals));
      ArrayInitialize(counters, 0);
      ArrayInitialize(sumx, 0);
      ArrayInitialize(sumx2, 0);
    }
    /*
      union floats
      {
        double d1;
        struct f2
        {
          float mean;
          float deviation;
        }
        ff;
      };
    */

    virtual void update(const int index, const double value) override
    {
      // TODO: probably replace with Welford's algorithm
      counters[index]++;
      sumx[index] += value;
      sumx2[index] += value * value;
      
      const int n = counters[index];
      // const double mean = sumx[index] / n;
      const double variance = (sumx2[index] - sumx[index] * sumx[index] / n) / MathMax(n - 1, 1);
      /*
      floats f;
      f.ff.mean = (float)mean;
      f.ff.deviation = (float)MathSqrt(variance);
      totals[index] = f.d1;
      */
      totals[index] = MathSqrt(variance);
    }

    /*
    virtual bool hasSpecialFormat() const override
    {
      return true;
    }

    virtual string getValueFormatted(const double value) const override
    {
      floats f;
      f.d1 = value;
      return (f.ff.mean > 0 ? "+" : "") + (string)f.ff.mean + ShortToString(0x0B1) + (string)f.ff.deviation;
    }
    */
    
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
    bool dropZeros;
    
  public:
    LogDisplay(const int w, const int d, const bool omitZeros = false)
    {
      digits = d;
      format = StringFormat("%%%d.%df", w, d);
      dropZeros = omitZeros;
    }

    virtual void display(MetaCube *metaData, const SORT_BY sortby = SORT_BY_NONE, const bool identity = false) override
    {
      int n = metaData.getDimension();
      int indices[], cursors[];
      ArrayResize(indices, n);
      ArrayResize(cursors, n);
      ArrayInitialize(cursors, 0);

      for(int i = 0; i < n; i++)
      {
        indices[i] = metaData.getDimensionRange(i);
      }
      
      if(metaData.getCubeSize() == 0)
      {
        Print("[empty]");
        return;
      }

      bool sorting = (n == 1 && sortby != SORT_BY_NONE) || SORT_VALUE(sortby);
      if(n > 1 && !sorting)
      {
        Print("Sorting of multidimentional arrays is fully supported for values only, labels are sorted as is");
      }
      
      PairArray *flat = NULL;
      
      if(sorting)
      {
        flat = new PairArray(metaData.getCubeSize(), (SORT_ASCENDING(sortby) ? (Comparator *)(new Greater()) : (Comparator *)(new Lesser())));
      }
      
      string labels[];
      string allLabels;
      ArrayResize(labels, n);
      
      bool looping = false;
      int count = 0;
      Converter<ulong,double> converter;
      const double nan = converter[0x7FF8000000000000]; // quiet NaN

      do
      {
        allLabels = "";
        for(int j = 0; j < n; j++)
        {
          labels[j] = metaData.getDimensionIndexLabel(j, cursors[j]);
          allLabels += (j > 0 ? ";\t" : "") + labels[j];
        }

        if(!dropZeros || (metaData.getValue(cursors) != 0 && MathIsValidNumber(metaData.getValue(cursors))))
        {
          if(sorting)
          {
            // sort single (first) dimension by sort_by
            if(SORT_VALUE(sortby))
            {
              flat.insert(count++, metaData.getValue(cursors), allLabels);
            }
            else
            {
              flat.insert(count++, allLabels, metaData.getValue(cursors));
            }
          }
          else
          {
            if(metaData.hasSpecialFormat())
            {
              arrayPrint(metaData.getValueFormatted(metaData.getValue(cursors)), labels);
            }
            else
            {
              arrayPrint(StringFormat(format, metaData.getValue(cursors)), labels);
            }
          }
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
        flat.allocate(count); // shrink (if neccessary)
        if(metaData.hasSpecialFormat())
        {
          for(int i = 0; i < ArraySize(flat.array); i++)
          {
            Print(i, ": ", flat.array[i].title, " ", metaData.getValueFormatted(flat.array[i].value));
          }
        }
        else
        {
          ArrayPrint(flat.array, digits);
        }
        delete flat;
      }
    }
};



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
    bool dataOwner;
    
  public:
    Analyst(DataAdapter &a, Aggregator<E> &g, Display &d): adapter(&a), aggregator(&g), output(&d)
    {
      ArrayResize(data, adapter.reservedSize());
      dataOwner = false;
    }
    
    ~Analyst()
    {
      if(dataOwner)
      {
        const int n = ArraySize(data);
        for(int i = 0; i < n; i++)
        {
          if(CheckPointer(data[i]) == POINTER_DYNAMIC) delete data[i];
        }
      }
    }
    
    void setDataOwner(const bool owner)
    {
      dataOwner = owner;
    }
    
    void acquireData()
    {
      Record *record;
      int i = 0;
      dataOwner = !adapter.isOwner();
      adapter.reset();
      while((record = adapter.getNext()) != NULL)
      {
        data[i++] = record;
      }
      ArrayResize(data, i);
      
      const int n = aggregator.prepareSelectors(data);
      
      if(aggregator.isSerial())
      {
        aggregator.setSelectorBounds(n);
      }
      else
      {
        aggregator.setSelectorBounds();
      }
      string names[];
      if(adapter.getCustomFields(names) > 0)
      {
        aggregator.assignCustomFields(names);
      }
    }
    
    int build(const Progress *ptr = NULL)
    {
      return aggregator.calculate(data, ptr);
    }
    
    void display(const SORT_BY sortby = SORT_BY_NONE, const bool identity = false)
    {
      output.display(aggregator, sortby, identity);
    }
};

template<typename S,typename T>
class OLAPEngine
{
  protected:
    DataAdapter *adapter;
    const Progress *progress;

    uint quantGranularity;
    bool shortTitles;

    virtual Selector<T> *createSelector(const S selector, const T field) = 0;
    virtual void initialize() = 0;

  public:
    OLAPEngine(): adapter(NULL), progress(NULL), shortTitles(false) {}
    OLAPEngine(DataAdapter *ptr, const uint quant = 0, const Progress *show = NULL):
      adapter(ptr), quantGranularity(quant), progress(show), shortTitles(false) {}

    void setAdapter(DataAdapter *ptr)
    {
      adapter = ptr;
    }
    
    void setProgress(Progress *ptr)
    {
      progress = ptr;
    }
    
    void setQuant(const uint quant)
    {
      quantGranularity = quant; // FIXME: need to be selector property
    }
    
    void setShortTitles(const bool t)
    {
      shortTitles = t;
      Selector<T>::setShortTitles(t);
    }

    int process(
        const S &selectorArray[], const T &selectorField[],
        const AGGREGATORS AggregatorType, const T AggregatorField,
        Display &display,
        const SORT_BY SortBy = SORT_BY_NONE,
        const double Filter1value1 = 0, const double Filter1value2 = 0)
    {
      int selectorCount = 0;
      for(int i = 0; i < MathMin(ArraySize(selectorArray), 3); i++)
      {
        selectorCount += selectorArray[i] != SELECTOR_NONE;
      }
    
      if(selectorCount == 0)
      {
        Alert("No selectors. Setup at least one of them.");
        return 0;
      }
      
      // filter section part.1 starts
      S Filter1 = SELECTOR_NONE;
      T Filter1Field = FIELD_NONE;
      
      if(ArraySize(selectorArray) > 3)
      {
        Filter1 = selectorArray[3];
      }

      if(ArraySize(selectorField) > 3)
      {
        Filter1Field = selectorField[3];
      }
      // filter section part.1 ends
      
      Selector<T> *selectors[];
      ArrayResize(selectors, selectorCount);
      
      for(int i = 0; i < selectorCount; i++)
      {
        selectors[i] = createSelector(selectorArray[i], selectorField[i]);
        if(selectors[i] == NULL)
        {
          Print("Selector ", i, " is empty. Setup selectors successively (don't leave a hole in-between), specify a field when required");
          return 0;
        }
      }

      // filter section part.2 starts
      Filter<T> *filters[];
      if(Filter1 != SELECTOR_NONE)
      {
        ArrayResize(filters, 1);
        Selector<T> *filterSelector = createSelector(Filter1, Filter1Field);
        if(Filter1value1 != Filter1value2)
        {
          filters[0] = new FilterRange<T>(filterSelector, Filter1value1, Filter1value2);
        }
        else
        {
          filters[0] = new Filter<T>(filterSelector, Filter1value1);
        }
      }
      // filter section part.2 ends
      
      Aggregator<T> *aggregator;
      
      // MQL does not support a 'class info' metaclass.
      // Otherwise we could use an array of classes instead of the switch
      switch(AggregatorType)
      {
        case AGGREGATOR_SUM:
          aggregator = new SumAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_AVERAGE:
          aggregator = new AverageAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_MAX:
          aggregator = new MaxAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_MIN:
          aggregator = new MinAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_COUNT:
          aggregator = new CountAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_PROFITFACTOR:
          aggregator = new ProfitFactorAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_PROGRESSIVE:
          aggregator = new ProgressiveTotalAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_IDENTITY:
          aggregator = new IdentityAggregator<T>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_STDDEV:
          aggregator = new VarianceAggregator<T>(AggregatorField, selectors, filters);
          break;
      }

      Analyst<T> *analyst = new Analyst<T>(adapter, aggregator, display);
      
      analyst.acquireData();

      initialize();
      Print("Aggregator: ", aggregator.getMetaCubeTitle(shortTitles), " [", aggregator.getCubeSize(), "]", " dimensions: ", aggregator.getDimension());
      Print("Filters: ", aggregator.getFilterTitles());
      Print("Selectors: ", selectorCount);
      for(int i = 0; i < aggregator.getDimension(); i++)
      {
        Print(CharToString((uchar)('X' + i)), ": ", aggregator.getDimensionTitle(i) /*display.getCustomDimensionTitle(aggregator, i)*/, " [", aggregator.getDimensionRange(i), "]");
      }
      
      const int p = analyst.build(progress);
      Print("Processed records: ", p);
      if(p > 0)
      {
        analyst.display(SortBy, AggregatorType == AGGREGATOR_IDENTITY);
      }

      delete analyst;
      delete aggregator;
      for(int i = 0; i < selectorCount; i++)
      {
        delete selectors[i];
      }
      for(int i = 0; i < ArraySize(filters); i++)
      {
        delete filters[i].getSelector();
        delete filters[i];
      }
      
      return p;
    }
};
