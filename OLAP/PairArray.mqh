//+------------------------------------------------------------------+
//|                                                    PairArray.mqh |
//|                                 Copyright © 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+

// aux struct to populate temp array when sorting is enabled
struct Pair
{
  double value;
  string title;
  Pair(): value(DBL_MAX), title(NULL) {}
  Pair(const double v, const string s): value(v), title(s) {}
  Pair(const string s, const double v): value(v), title(s) {}
  bool operator>(const double v) const
  {
    return value > v;
  }
  bool operator>(const string s) const
  {
    const double d1 = StringToDouble(title);
    const double d2 = StringToDouble(s);
    if(d1 != 0 && d2 != 0) return d1 > d2;
    else if(isNumber(title) && isNumber(s))
    {
      return d1 > d2;
    }

    return title > s;
  }
  static bool isNumber(const string &s)
  {
    ushort a[];
    const int n = StringToShortArray(s, a);
    for(int i = 0; i < n - 1; i++)
    {
      if((a[i] < '+' || a[i] > '9') && a[i] != ' ')
      {
        return false;
      }
    }
    return true;
  }
};

// this is a common parent, so it can not be templatized
class Comparator
{
  public:
    // templatized method can not be virtual,
    // so we do artificial dynamic dispatching manually
    // (see below after declaration of descendant classes)
    template<typename T>
    bool compare(const Pair &v1, const T v2);
};

class Greater: public Comparator
{
  public:
    template<typename T>
    bool compare(const Pair &v1, const T v2)
    {
      return v1 > v2;
    }
};

class Lesser: public Comparator
{
  public:
    template<typename T>
    bool compare(const Pair &v1, const T v2)
    {
      return !(v1 > v2);
    }
};

class PairArray
{
  private:
    Comparator *comparator;

  public:
    // temp array for sorting (if enabled)
    Pair array[];

    PairArray(): comparator(NULL)
    {
    }

    PairArray(const int reserved, Comparator *c = NULL)
    {
      comparator = c;
      ArrayResize(array, reserved);
    }

    ~PairArray()
    {
      ArrayResize(array, 0);
      if(CheckPointer(comparator) == POINTER_DYNAMIC) delete comparator;
    }
    
    void allocate(const int reserved)
    {
      ArrayResize(array, reserved);
    }
    
    void compareBy(Comparator *c)
    {
      if(CheckPointer(comparator) == POINTER_DYNAMIC) delete comparator;
      comparator = c;
    }

    void move(const int index, const int count)
    {
      for(int i = count - 1; i >= index; --i)
      {
        array[i + 1] = array[i];
      }
    }

    template<typename T1, typename T2>
    void insert(const int count, const T1 v, const T2 s)
    {
      Pair p(v, s);
      for(int i = 0; i < count; i++)
      {
        if(comparator != NULL && comparator.compare(array[i], v))
        {
          move(i, count);
          array[i] = p;
          return;
        }
      }
      array[count] = p;
    }

    void convert(double &x[], string &s[], const bool skipNANs = false) const
    {
      int k = 0, n = ArraySize(array);
      ArrayResize(x, n);
      ArrayResize(s, n);
      for(int i = 0; i < n; i++)
      {
        if(!skipNANs || MathIsValidNumber(array[i].value))
        {
          x[k] = array[i].value;
          s[k] = array[i].title;
          k++;
        }
      }
      ArrayResize(x, k);
      ArrayResize(s, k);
    }

    void convert(double &x[]) const
    {
      int n = ArraySize(array);
      ArrayResize(x, n);
      for(int i = 0; i < n; i++)
      {
        x[i] = array[i].value;
      }
    }

    void convert(string &s[]) const
    {
      int n = ArraySize(array);
      ArrayResize(s, n);
      for(int i = 0; i < n; i++)
      {
        s[i] = array[i].title;
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
