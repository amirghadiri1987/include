//+------------------------------------------------------------------+
//|                                                    PairArray.mqh |
//|                                      Copyright © 2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+

class PairArray
{
  public:
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
        return title > s;
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

    void convert(double &x[], string &s[]) const
    {
      int n = ArraySize(array);
      ArrayResize(x, n);
      ArrayResize(s, n);
      for(int i = 0; i < n; i++)
      {
        x[i] = array[i].value;
        s[i] = array[i].title;
      }
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
