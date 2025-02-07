//+------------------------------------------------------------------+
//|                                                    IndexMapT.mqh |
//|                           https://www.mql5.com/ru/articles/5706/ |
//+------------------------------------------------------------------+

#define EMPTY ((int)EMPTY_VALUE)

#ifdef HASHMAP_WARNING
#define NULL_PLACEHOLDER "n/a"
#else
#define NULL_PLACEHOLDER ""
#endif

class Object
{
  public:
    
    virtual string asString() const
    {
      return(__FUNCSIG__);
    }

    virtual string asCSVString() const
    {
      return(__FUNCSIG__);
    }
    
    virtual string getTypeName() const = 0;
};

/**
  * Base container for indexed map. Can contain plain types and pointers.
  */
class Container: public Object
{
  protected:
    enum datatype
    {
      null,
      s,
      d,
      t,
      i,
      o,
      u
    };

    datatype type;

  public:    
    datatype getType() const
    {
      return type;
    }
    
    // helper method to access plain type values from the base class
    template<typename R>
    R get() const;
    
    // helper method to access object pointers from the base class
    template<typename R>
    Object *getObject() const;
};

/**
 * Variable type data for indexed map; plain types only.
 */
template<typename T>
class TypeContainer: public Container
{
  private:
    int digits;
    int flags;
    
  protected:
    T v;
    
    TypeContainer()
    {
      digits = _Digits;
      flags = TIME_DATE | TIME_MINUTES;
    }
    
  public:
    TypeContainer(T _v, int precision = INT_MIN, int timeflags = TIME_DATE | TIME_MINUTES)
    {
      v = _v;
      digits = precision == INT_MIN ? _Digits : precision;
      flags = timeflags;

      if(typename(T) == "string")
      {
        type = datatype::s;
      }
      else
      if(typename(T) == "double" || typename(T) == "float")
      {
        type = datatype::d;
      }
      else
      if(typename(T) == "datetime")
      {
        type = datatype::t;
      }
      else
      if(typename(T) == "char" || typename(T) == "short" || typename(T) == "int" || typename(T) == "long")
      {
        type = datatype::i;
      }
      else
      {
        type = datatype::u;
      }
    }
    
    virtual T getValue() const
    {
      return v;
    }

    // represent data as a string, convert if necessary
    virtual string asString() const
    {
      switch(type)
      {
        case datatype::s: return (string)v;
        case datatype::d: return DoubleToString((double)v, digits);
        case datatype::t: return TimeToString((datetime)v, flags);
        case datatype::i: return IntegerToString((long)v);
        default: return (string)v;
      }
    }
    
    virtual string asCSVString() const
    {
      return asString();
    }
    
    virtual string getTypeName() const override
    {
      return typename(this);
    }
};

/**
  * Object pointer types for indexed map.
  * Pointer will be deleted automatically.
  */
template<typename T>
class ObjectContainer: public Container
{
  protected:
    Object *o;
    
  public:
    ObjectContainer(T _v)
    {
      o = _v;
      type = datatype::o;
    }
    
    ~ObjectContainer()
    {
      if(CheckPointer(o) == POINTER_DYNAMIC)
      {
        delete(o);
      }
    }

    T getObject() const
    {
      return o;
    }
    
    virtual string asString() const override
    {
      return o.asString();
    }

    virtual string asCSVString() const
    {
      return o.asCSVString();
    }

    virtual string getTypeName() const override
    {
      return typename(this);
    }
};


template<typename R>
R Container::get() const
{
  const TypeContainer<R> *ptr = dynamic_cast<const TypeContainer<R> *>(&this);
  if(ptr != NULL) return (R)ptr.getValue();
  return (R)NULL;
}

template<typename R> // R is supposed to be an object pointer
Object *Container::getObject() const
{
  const ObjectContainer<R> *obj = dynamic_cast<const ObjectContainer<R> *>(&this);
  if(obj != NULL) return obj.getObject();
  return NULL;
}


/**
  * Indexed map with random access by key and index.
  */
template<typename T>
class IndexMapT: public Container // Object
{
  private:
    T keys[];
    Container *values[];
    int count;
    string id;
    uchar delimiter;
    
  public:
    IndexMapT(): count(0), delimiter(',') {}
    IndexMapT(string obj): id (obj), count(0), delimiter(',') {}
    IndexMapT(uchar d): count(0), delimiter(d) {}
    
    ~IndexMapT()
    {
      reset();
    }

    virtual string getTypeName() const override
    {
      return typename(this);
    }
    
    void add(const T key, Container *value)
    {
      ArrayResize(keys, count + 1);
      ArrayResize(values, count + 1);
      keys[count] = key;
      values[count] = value;
      count++;
    }
    
    void reset()
    {
      for(int i = 0; i < count; i++)
      {
        if(CheckPointer(values[i]) == POINTER_DYNAMIC)
        {
          delete(values[i]);
        }
      }
      ArrayResize(keys, 0);
      ArrayResize(values, 0);
      count = 0;
    }

    bool isKeyExisting(const T key) const
    {
      return (getIndex(key) != EMPTY);
    }

    int getIndex(const T key) const
    {
      for(int i = 0; i < count; i++)
      {
        if(keys[i] == key) return(i);
      }
      #ifdef HASHMAP_VERBOSE
      Print(__FUNCSIG__, ": no key=", key);
      #endif
      return EMPTY;
    }

    Container *operator[](const int index) const
    {
      if(index < 0 || index >= count)
      {
        #ifdef HASHMAP_VERBOSE
        Print(__FUNCSIG__, ": index=", index);
        #endif
        return(NULL);
      }
      return(GetPointer(values[index]));
    }

    Container *operator[](const T key) const
    {
      for(int i = 0; i < count; i++)
      {
        if(keys[i] == key) return(GetPointer(values[i]));
      }
      #ifdef HASHMAP_VERBOSE
      Print(__FUNCSIG__, ": no key=", key);
      #endif
      return(NULL);
    }
    
    T getKey(const int index) const
    {
      if(index < 0 || index >= count)
      {
        Print(__FUNCSIG__, ": index=", index);
      }
      return(keys[index]);
    }

    template<typename R>
    void setValue(const T key, R value)
    {
      // NB: implementation specific
      //   in HTML every attribute can occur only once in a tag,
      //   all successive assignments are ignored
      if(!isKeyExisting(key))
      {
        set(key, new TypeContainer<R>(value));
      }
    }

    void set(const T key, Container *value)
    {
      int index = getIndex(key);
      if(index != EMPTY)
      {
        #ifdef HASHMAP_WARNING
        Print(__FUNCSIG__, ": overwritten key=", key, ", old value=", (values[index] != NULL ? values[index].asString() : "null"), ", new value=", (value != NULL ? value.asString() : "null"));
        #endif
        values[index] = value;
      }
      else
      {
        add(key, value);
      }
    }
    
    void set(const T key)
    {
      int index = getIndex(key);
      if(index == EMPTY)
      {
        add(key, NULL);
      }
    }
    
    int getSize() const
    {
      return(count);
    }
    
    virtual string asString() const
    {
      string result = "";
      for(int i = 0; i < count; i++)
      {
        result += (string)keys[i] + "=" + (CheckPointer(values[i]) == POINTER_INVALID ? NULL_PLACEHOLDER : values[i].asString()) + ";";
      }
      return result;
    }

    virtual string asCSVString() const
    {
      string result = "";
      string d = CharToString(delimiter);
      for(int i = 0; i < count; i++)
      {
        string v = NULL_PLACEHOLDER;
        
        if(CheckPointer(values[i]) != POINTER_INVALID)
        {
          v = values[i].asCSVString();
          StringReplace(v, d, "");
        }
        
        if(i < count - 1)
        {
          result += v + d;
        }
        else
        {
          result += v;
        }
      }
      return result;
    }
};

class IndexMap: public IndexMapT<string>
{
  public:
    IndexMap(): IndexMapT() {}
    IndexMap(string obj): IndexMapT(obj) {}
    IndexMap(uchar d): IndexMapT(d) {}
    string get(const string key)
    {
      Container *c = this[key];
      if(c == NULL) return NULL;
      return c.get<string>();
    }
};