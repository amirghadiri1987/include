//+------------------------------------------------------------------+
//|                                             WebDataExtractor.mqh |
//|                               Copyright (c) 2015-2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|                           https://www.mql5.com/ru/articles/5706/ |
//|                           https://www.mql5.com/ru/articles/5913/ |
//|                                            HTML to CSV converter |
//+------------------------------------------------------------------+

//#define HASHMAP_WARNING // HASHMAP_VERBOSE
#include <Marketeer/IndexMap.mqh>
#include <Marketeer/GroupSettings.mqh>


input GroupSettings HTMLR_Settings; // H T M L   R E P O R T   S E T T I N G S

input string RowSelector = "tr:has-n-children(13)[bgcolor^=\"#F\"]"; // · RowSelector
input string ColumnSettingsFile = "ReportHistoryDeals.cfg.csv"; // · ColumnSettingsFile
input string SubstitutionSettingsFile = ""; // · SubstitutionSettingsFile

input bool LogDomElements = false; // · LogDomElements
input bool LogDomWarnings = false; // · LogDomWarnings
input bool LogSelectedElements = false; // · LogSelectedElements


#define LOG_MASK_DOM         1
#define LOG_MASK_DOM_WARNING 2
#define LOG_MASK_SELECTOR    4
#define LOG_MASK_MAX         4
#define LOG_MASK_ALL ((LOG_MASK_MAX << 1) - 1)

ushort combinators[] =
{
  ' ', '+', '>', '~'
};

string empty_tags[] =
{
  #include <Marketeer/empty_strings.h>
};

/*

  CSS selectors:
  1  *         any element
  1  .intro    class="intro"
  1  #id1      id="id1"
  1  p         p tag
  1  div p     p tag somewhere inside div tag
  2  div > p   p tag with parent div tag
  2  div + p   p tag as a sibling immediately after div tag, common parent
  3  div ~ p   p tag as a sibling somewhere after div tag (less strict than +), common parent
  2  [target]  a tag with target attribute
  2  [target=_blank] a tag with attribute target="_blank"
  2- [title~=flower] a tag with attribute title containing "space"-separated word "flower" somewhere
  3  [title*=flower] a tag with attribute title containing "flower" sequence somewhere (less strict than ~)
  2- [data-value|="foo"] a tag whose attribute value has this "foo" in a dash-separated list somewhere
  3  [data-value^="foo"] attribute value starts with this
  3  [data-value$="foo"] attribute value ends with this
  
  2  p:first-child a tag <p> that is the first child of its parent
  3  p:last-child a tag <p> that is the last child of its parent
  3  p:nth-child(n)
  3  p:nth-last-child(n)
  3- p:not(selector)
  
  http://www.w3.org/TR/CSS2/selector.html
  A simple selector is either a type selector or universal selector followed immediately by
  zero or more attribute selectors, ID selectors, or pseudo-classes, in any order.
  
  The simple selector matches if all of its components match.
  
  A selector is a chain of one or more simple selectors separated by combinators.
  
  It always begins with a type selector or a universal selector. No other type selector or universal selector is allowed in the sequence.
  
  Combinators are: white space, ">", and "+" (and "~" css3)

*/

enum StateBit
{
  blank,
  insideTagOpen,
  insideTagClose,
  insideComment,
  insideScript
};

enum AttrBit
{
  name,
  value
};

class AttributesParser
{
  private:
    AttrBit state;
    int offset;
    int cursor;
    int length;
    string key;
    
    void skipWhiteSpace(const string &data)
    {
      int n = StringLen(data);
      while(offset < n && StringGetCharacter(data, offset) <= 32)
      {
        offset++;
        cursor++;
      }
    }
    
  public:
    AttributesParser(): state(AttrBit::name), offset(0), cursor(0), key(""){}
    
    void parseAll(const string &data, IndexMap &attributes)
    {
      length = StringLen(data);
      while(parse(data, attributes));

      if(offset < length)
      {
        string ending = StringSubstr(data, cursor);
        StringTrimRight(ending);
        StringTrimLeft(ending);
        if(StringLen(ending) > 0)
        {
          attributes.set(ending);
        }
        else if(key != "")
        {
          attributes.set(key);
        }
      }
      else if(key != "")
      {
        attributes.set(key);
      }
    }
  
  
    bool parse(const string &data, IndexMap &attributes)
    {
      skipWhiteSpace(data);
      
      int x = 0;
      if(state == AttrBit::name)
      {
        while(offset < length)
        {
          x = StringGetCharacter(data, offset);
          if(x == '=' || (x <= 32)) break;
          offset++;
        }
        
        string attr = StringSubstr(data, cursor, offset - cursor);
        if(StringLen(attr) > 0)
        {
          key = attr;
        }
        
        if(x == '=')
        {
          state = AttrBit::value;
          offset++;
          cursor = offset;
        }
        // else - attribute without value
        
        return(offset < length);
      }
      else
      if(state == AttrBit::value)
      {
        if(key == "")
        {
          Print("Wrong state::value with empty key");
        }
        ushort c = StringGetCharacter(data, offset);
        if(c == '"' || c == '\'')
        {
          offset++;
          cursor++;
          while(offset < length)
          {
            if(StringGetCharacter(data, offset) == c) break;
            offset++;
          }
          
          attributes.setValue(key, StringSubstr(data, cursor, offset - cursor));
          key = "";
          
          state = AttrBit::name;
          offset++;
          cursor = offset;
          return(offset < length);
        }
        else
        if(c > 32)
        {
          while(offset < length)
          {
            if(StringGetCharacter(data, offset) == ' ') break;
            offset++;
          }

          attributes.setValue(key, StringSubstr(data, cursor, offset - cursor));
          key = "";
          
          state = AttrBit::name;
          offset++;
          cursor = offset;
          return(offset < length);
          
        }
        else
        if(c <= 32) // empty value, 'attr='
        {
          while(offset < length)
          {
            if(StringGetCharacter(data, offset) > ' ') break;
            offset++;
          }
          
          attributes.set(key);
          key = "";
          
          state = AttrBit::name;
          cursor = offset;
          return(offset < length);
        }
      }
      return(false);
    }
};

class SubSelector
{
  enum PseudoClassModifier
  {
    none,
    firstChild,
    lastChild,
    nthChild,
    nthLastChild,
    hasNthChildren
  };
  
  public:
    ushort type;
    string value;
    PseudoClassModifier modifier;
    string param;
    
    SubSelector(ushort t, string v): type(t), value(v), modifier(PseudoClassModifier::none) {}
    
    SubSelector(ushort t, string v, PseudoClassModifier m): type(t), value(v), modifier(m) {}
    
    SubSelector(ushort t, string v, PseudoClassModifier m, string p): type(t), value(v), modifier(m), param(p) {}
};


class SubSelectorArray
{
  private:
    SubSelector *selectors[];
    IndexMap mod;
    
    static TypeContainer<PseudoClassModifier> first;
    static TypeContainer<PseudoClassModifier> last;
    static TypeContainer<PseudoClassModifier> nth;
    static TypeContainer<PseudoClassModifier> nthLast;
    static TypeContainer<PseudoClassModifier> hasN;
    
    void init()
    {
      mod.add(":first-child", &first);
      mod.add(":last-child", &last);
      mod.add(":nth-child", &nth);
      mod.add(":nth-last-child", &nthLast);
      mod.add(":has-n-children", &hasN);
    }

    void createFromString(const string &selector)
    {
      ushort p = 0; // previous/pending type
      int ppos = 0;
      int i, n = StringLen(selector);
      bool quotes = false;
      for(i = 0; i < n; i++)
      {
        ushort t = StringGetCharacter(selector, i);
        if(t == '"')
        {
          quotes = !quotes;
        }
        
        if(quotes) continue;
        
        if(t == '.' || t == '#' || t == '[' || t == ']')
        {
          string v = StringSubstr(selector, ppos, i - ppos);
          if(i == 0) v = "*";
          if(p == '[' && StringLen(v) > 0 && StringGetCharacter(v, StringLen(v) - 1) == ']')
          {
            v = StringSubstr(v, 0, StringLen(v) - 1);
          }
          add(p, v);
          p = t;
          if(p == ']') p = 0;
          ppos = i + 1;
        }
      }
      
      if(ppos < n)
      {
        string v = StringSubstr(selector, ppos, n - ppos);
        if(p == '[' && StringLen(v) > 0 && StringGetCharacter(v, StringLen(v) - 1) == ']')
        {
          v = StringSubstr(v, 0, StringLen(v) - 1);
        }
        add(p, v);
      }
    }
    
  public:
    
    SubSelectorArray()
    {
      init();
    }

    SubSelectorArray(const string selector)
    {
      init();
      createFromString(selector);
    }
    
    int size() const
    {
      return ArraySize(selectors);
    }
    
    SubSelector *operator[](int i) const
    {
      return selectors[i];
    }
    
    void add(const ushort t, string v)
    {
      int n = ArraySize(selectors);
      ArrayResize(selectors, n + 1);
      
      PseudoClassModifier m = PseudoClassModifier::none;
      string param;
      
      for(int j = 0; j < mod.getSize(); j++)
      {
        int p = StringFind(v, mod.getKey(j));
        if(p > -1)
        {
          if(p + StringLen(mod.getKey(j)) < StringLen(v))
          {
            param = StringSubstr(v, p + StringLen(mod.getKey(j)));
            if(StringGetCharacter(param, 0) == '(' && StringGetCharacter(param, StringLen(param) - 1) == ')')
            {
              param = StringSubstr(param, 1, StringLen(param) - 2);
            }
            else
            {
              param = "";
            }
          }
        
          m = mod[j].get<PseudoClassModifier>();
          v = StringSubstr(v, 0, p);
          
          break;
        }
      }
      
      if(t == '[' && m == PseudoClassModifier::none)
      {
        AttributesParser p;
        IndexMap attr;
        p.parseAll(v, attr);

        // attributes are selected one by one: element[attr1=value][attr2=value]
        // the map should contain only 1 valid pair at a time
        if(attr.getSize() > 0)
        {
          param = attr.getKey(0);
          v = attr[0] != NULL ? attr[0].get<string>() : "";
        }
      }
      
      if(StringLen(param) == 0)
      {
        selectors[n] = new SubSelector(t, v, m);
      }
      else
      {
        selectors[n] = new SubSelector(t, v, m, param);
      }
    }
    
    ~SubSelectorArray()
    {
      int i, n = ArraySize(selectors);
      for(i = 0; i < n; i++)
      {
        delete(selectors[i]);
      }
    }
};

TypeContainer<PseudoClassModifier> SubSelectorArray::first(PseudoClassModifier::firstChild);
TypeContainer<PseudoClassModifier> SubSelectorArray::last(PseudoClassModifier::lastChild);
TypeContainer<PseudoClassModifier> SubSelectorArray::nth(PseudoClassModifier::nthChild);
TypeContainer<PseudoClassModifier> SubSelectorArray::nthLast(PseudoClassModifier::nthLastChild);
TypeContainer<PseudoClassModifier> SubSelectorArray::hasN(PseudoClassModifier::hasNthChildren);

class DomIterator;

class DomElement
{
  private:
    string name;
    string content;
    IndexMap attributes;
    
    DomElement *parent;
    
    int level;

  protected:
    bool childrenOwner;
    DomElement *children[];
  
    void clear()
    {
      int i, n = ArraySize(children);
      for(i = 0; i < n; i++)
      {
        delete children[i];
      }
      ArrayResize(children, 0);
    }
    
    bool isCombinator(ushort c)
    {
      for(int i = 0; i < ArraySize(combinators); i++)
      {
        if(combinators[i] == c) return(true);
      }
      return(false);
    }
    
  public:
    DomElement(): parent(NULL), childrenOwner(true) {}
    DomElement(const string n): parent(NULL), childrenOwner(true)
    {
      name = n;
    }

    DomElement(const string n, const string text): parent(NULL), childrenOwner(true)
    {
      name = n;
      content = text;
    }
    
    DomElement(DomElement *p, const string &n, const string text = ""): childrenOwner(true)
    {
      p.addChild(&this);
      parent = p;
      level = p.level + 1;
      name = n;
      if(text != "") content = text;
    }

    ~DomElement()
    {
      if(childrenOwner)
      {
        clear();
      }
    }
    
    void addChild(DomElement *child)
    {
      int n = ArraySize(children);
      ArrayResize(children, n + 1);
      children[n] = child;
    }
    
    int getChildrenCount() const
    {
      return ArraySize(children);
    }
    
    DomElement *getChild(const int i) const
    {
      if(i >= 0 && i < ArraySize(children))
      {
        return children[i];
      }
      return NULL;
    }
    
    void addChildren(DomElement *p)
    {
      if(CheckPointer(p) == POINTER_DYNAMIC)
      {
        for(int i = 0; i < p.getChildrenCount(); i++)
        {
          addChild(p.getChild(i));
        }
      }
    }
    
    int getChildIndex(DomElement *e) const
    {
      for(int i = 0; i < ArraySize(children); i++)
      {
        if(children[i] == e) return(i);
      }
      return(-1);
    }
    
    void setName(string n)
    {
      name = n;
    }
    
    void setText(string t)
    {
      content = t;
    }
    
    DomElement *getParent() const
    {
      return parent;
    }
    
    string getName() const
    {
      return name;
    }
    
    string getText() const
    {
      string text;
      for(int i = 0; i < ArraySize(children); i++)
      {
        text += children[i].getText();
      }
      return content + text;
    }
    
    int getLevel() const
    {
      return level;
    }
    
    void print(bool full = true)
    {
      PrintFormat("%" + IntegerToString(level) + "c %s, %s", ' ', name, attributes.asString());
      if(full)
      {
        int i, n = ArraySize(children);
        for(i = 0; i < n; i++)
        {
          children[i].print();
        }
      }
    }

    void printWithContent(bool full = true)
    {
      PrintFormat("%" + IntegerToString(level) + "c %s, %s, %s", ' ', name, content, attributes.asString());
      if(full)
      {
        int i, n = ArraySize(children);
        for(i = 0; i < n; i++)
        {
          children[i].printWithContent();
        }
      }
    }
    
    void printShort()
    {
      string id = "";
      Container *pid = attributes["id"];
      if(pid != NULL) id = pid.get<string>();
      PrintFormat("%" + IntegerToString(level) + "c %d %s %s", ' ', level, name, id);
    }

    void printShortWithChildren()
    {
      string id = "";
      Container *pid = attributes["id"];
      if(pid != NULL) id = pid.get<string>();
      PrintFormat("%" + IntegerToString(level) + "c %d %s %s", ' ', level, name, id);
      int i, n = ArraySize(children);
      for(i = 0; i < n; i++)
      {
        children[i].printShort();
      }
    }
    
    void parseAttributes(const string &data)
    {
      AttributesParser p;
      p.parseAll(data, attributes);
    }
    
    void setAttribute(const string id, Container *value)
    {
      attributes.set(id, value);
    }
    
    bool hasAttribute(const string key) const
    {
      return (attributes.isKeyExisting(key));
    }
    
    string getAttribute(const string key) const
    {
      Container *c = attributes[key];
      if(c != NULL) return c.get<string>();
      return "";
    }

    string getAttribute(const int index) const
    {
      Container *c = attributes[index];
      if(c != NULL) return c.get<string>();
      return "";
    }
    
    bool match(const SubSelectorArray *u)
    {
      bool matched = true;
      int i, n = u.size();
      for(i = 0; i < n && matched; i++)
      {
        if(u[i].type == 0) // tag name
        {
          if(u[i].value == "*")
          {
            // any tag
          }
          else
          if(StringLen(u[i].value) > 0 && StringCompare(name, u[i].value) != 0)
          {
            matched = false;
          }
          else
          if(u[i].modifier == PseudoClassModifier::firstChild)
          {
            if(parent != NULL && parent.getChildIndex(&this) != 0)
            {
              matched = false;
            }
          }
          else
          if(u[i].modifier == PseudoClassModifier::lastChild)
          {
            if(parent != NULL && parent.getChildIndex(&this) != parent.getChildrenCount() - 1)
            {
              matched = false;
            }
          }
          else
          if(u[i].modifier == PseudoClassModifier::nthChild)
          {
            int x = (int)StringToInteger(u[i].param);
            if(parent != NULL && parent.getChildIndex(&this) != x - 1) // children are counted starting from 1
            {
              matched = false;
            }
          }
          else
          if(u[i].modifier == PseudoClassModifier::nthLastChild)
          {
            int x = (int)StringToInteger(u[i].param);
            if(parent != NULL && parent.getChildrenCount() - parent.getChildIndex(&this) - 1 != x - 1)
            {
              matched = false;
            }
          }
          else
          if(u[i].modifier == PseudoClassModifier::hasNthChildren)
          {
            int x = (int)StringToInteger(u[i].param);
            if(getChildrenCount() != x)
            {
              matched = false;
            }
          }
        }
        else
        if(u[i].type == '.') // class
        {
          if(attributes.isKeyExisting("class"))
          {
            Container *c = attributes["class"];
            if(c == NULL || StringFind(" " + c.get<string>() + " ", " " + u[i].value + " ") == -1)
            {
              matched = false;
            }
          }
          else
          {
            matched = false;
          }
        }
        else
        if(u[i].type == '#') // id
        {
          if(attributes.isKeyExisting("id"))
          {
            Container *c = attributes["id"];
            if(c == NULL || StringCompare(c.get<string>(), u[i].value) != 0)
            {
              matched = false;
            }
          }
          else
          {
            matched = false;
          }
        }
        else
        if(u[i].type == '[') // attributes
        {
          string key = u[i].param;
          string v = u[i].value;
          
          ushort suffix = StringGetCharacter(key, StringLen(key) - 1);
          
          if(suffix == '*' || suffix == '^' || suffix == '$') // contains, starts with, or ends with
          {
            key = StringSubstr(key, 0, StringLen(key) - 1);
          }
          else
          {
            suffix = 0;
          }
          
          if(hasAttribute(key) && attributes[key] != NULL)
          {
            if(StringLen(v) > 0)
            {
              if(suffix == 0)
              {
                if(key == "class")
                {
                  matched &= (StringFind(" " + attributes[key].get<string>() + " ", " " + v + " ") > -1);
                }
                else
                {
                  matched &= (StringCompare(v, attributes[key].get<string>()) == 0);
                }
              }
              else
              if(suffix == '*')
              {
                matched &= (StringFind(attributes[key].get<string>(), v) != -1);
              }
              else
              if(suffix == '^')
              {
                matched &= (StringFind(attributes[key].get<string>(), v) == 0);
              }
              else
              if(suffix == '$')
              {
                string x = attributes[key].get<string>();
                if(StringLen(x) > StringLen(v))
                {
                  matched &= (StringFind(x, v, StringLen(x) - StringLen(v)) == StringLen(v));
                }
              }
            }
          }
          else
          {
            matched = false;
          }
        }
      }
      
      return matched;
    }

    bool find(const ushort op, const SubSelectorArray *selectors, DomIterator *output)
    {
      bool found = false;
      int i, n;
      if(op == ' ' || op == '>' || op == '/')
      {
        n = ArraySize(children);
        for(i = 0; i < n; i++)
        {
          if(children[i].match(selectors))
          {
            if(op == '/')
            {
              found = true;
              output.addChild(GetPointer(children[i]));
            }
            else
            if(op == ' ')
            {
              DomElement *p = &this;
              while(p != NULL)
              {
                if(output.getChildIndex(p) != -1)
                {
                  found = true;
                  output.addChild(GetPointer(children[i]));
                  break;
                }
                p = p.parent;
              }
            }
            else // op == '>'
            {
              if(output.getChildIndex(&this) != -1)
              {
                found = true;
                output.addChild(GetPointer(children[i]));
              }
            }
          }
          
          children[i].find(op, selectors, output);
        }
      }
      else
      if(op == '+' || op == '~')
      {
        if(CheckPointer(parent) == POINTER_DYNAMIC)
        {
          if(output.getChildIndex(&this) != -1)
          {
            int q = parent.getChildIndex(&this);
            if(q != -1)
            {
              n = (op == '+') ? (q + 2) : parent.getChildrenCount();
              if(n > parent.getChildrenCount()) n = parent.getChildrenCount();
              for(i = q + 1; i < n; i++)
              {
                DomElement *m = parent.getChild(i);
                if(CheckPointer(m) != POINTER_DYNAMIC)
                {
                  Print("bad:", name, " i=", i, " q=", q, " n=", n);
                }
                if(m.match(selectors))
                {
                  found = true;
                  output.addChild(m);
                }
              }
            }
            else
            {
              Print("Error: can't find 'this' element");
            }
          }
        }
        else
        {
          if(name != "root")
          {
            Print("No parent for: ", name);
          }
        }
        for(i = 0; i < ArraySize(children); i++)
        {
          found = children[i].find(op, selectors, output) || found;
        }
      }
      else
      {
        Print("Error: unknown combinator:", ShortToString(op));
      }
      return found;
    }

    
    DomIterator *querySelect(const string q)
    {
      DomIterator *result = new DomIterator();
      
      if(q == ".")
      {
        result.addChild(&this); // root
        return result;
      }
      
      int cursor = 0; // where selector string started
      int i, n = StringLen(q);
      ushort p = 0;   // previous character
      ushort a = 0;   // next/pending operator
      ushort b = '/'; // current operator, root notation from the start
      string selector = "*"; // current simple selector, 'any' by default
      int index = 0;  // position in the resulting array of objects
      
      
      for(i = 0; i < n; i++)
      {
        ushort c = StringGetCharacter(q, i);
        if(isCombinator(c))
        {
          a = c;
          if(!isCombinator(p))
          {
            selector = StringSubstr(q, cursor, i - cursor);
          }
          else
          {
            // suppress blanks around other combinators
            a = MathMax(c, p);
          }
          cursor = i + 1;
        }
        else
        {
          if(isCombinator(p))
          {
            index = result.getChildrenCount();
            
            SubSelectorArray selectors(selector);
            find(b, &selectors, result);
            b = a;
            
            // now we can delete outdated results in positions up to 'index'
            result.removeFirst(index);
          }
        }
        p = c;
      }
      
      if(cursor < i)
      {
        selector = StringSubstr(q, cursor, i - cursor);
        
        index = result.getChildrenCount();
        
        SubSelectorArray selectors(selector);
        find(b, &selectors, result);
        result.removeFirst(index);
      }
      
      return result;
    }
    
    IndexMap *tableSelect(const string rowSelector, const string &headers[], const string &columSelectors[], const string &dataSelectors[], const IndexMap *subst = NULL, const bool numericKeys = false)
    {
      if(ArraySize(columSelectors) != ArraySize(dataSelectors)) return NULL;
      
      int n = ArraySize(columSelectors);
    
      DomIterator *r = querySelect(rowSelector);
      if((HtmlParser::isDebug() & LOG_MASK_SELECTOR) != 0)
      {
        r.printAllWithContent();
      }
      
      IndexMap *data = new IndexMap('\n');
      int counter = 0;
      
      r.rewind();
      while(r.hasNext())
      {
        DomElement *e = r.next();
        if((HtmlParser::isDebug() & LOG_MASK_SELECTOR) != 0)
        {
          Print("row N" + (string)counter);
        }
        
        string id = IntegerToString(counter);
        if(!numericKeys) // we can store IDs of found elements in results, optionally
        {
          if(e.hasAttribute("id")) id += "-" + e.getAttribute("id");
        }
        
        IndexMap *row = new IndexMap();
        
        for(int i = 0; i < n; i++)
        {
          if(StringLen(columSelectors[i]))
          {
            DomIterator *d = e.querySelect(columSelectors[i]);
            if((HtmlParser::isDebug() & LOG_MASK_SELECTOR) != 0)
            {
              d.printAllWithContent();
            }
            
            string value;
            
            if(d.getChildrenCount() > 0)
            {
              if(d.getChildrenCount() > 1)
              {
                if((HtmlParser::isDebug() & LOG_MASK_SELECTOR) != 0)
                {
                  Print("Too many elements selected:", d.getChildrenCount());
                }
              }
              
              if(dataSelectors[i] == "")
              {
                value = d[0].getText();
              }
              else
              {
                value = d[0].getAttribute(dataSelectors[i]);
              }
              
              if(CheckPointer(subst) != POINTER_INVALID)
              {
                if(subst.isKeyExisting(columSelectors[i]))
                {
                  IndexMap *rules = dynamic_cast<IndexMap *>(subst[columSelectors[i]]);
                  
                  if(rules != NULL)
                  {
                    for(int j = 0; j < rules.getSize(); j++)
                    {
                      StringReplace(value, rules.getKey(j), (rules[j] != NULL ? rules[j].asString() : ""));
                    }
                  }
                }
              }
              
              StringTrimLeft(value);
              StringTrimRight(value);
              
              if(numericKeys)
              {
                row.setValue(IntegerToString(i), value);
              }
              else
              {
                row.setValue(headers[i]/*columSelectors[i] + dataSelectors[i]*/, value);
              }
            }
            else // field not found
            {
              if(numericKeys)
              {
                row.set(IntegerToString(i));
              }
              else
              {
                row.set(columSelectors[i] + dataSelectors[i]);
              }
            }
            delete d;
          }
          else // constant data
          {
            if(numericKeys)
            {
              row.setValue(IntegerToString(i), dataSelectors[i]);
            }
            else
            {
              row.setValue(dataSelectors[i], dataSelectors[i]);
            }
          
          }
        }
        if(row.getSize() > 0)
        {
          data.set(id, row);
          counter++;
        }
        else
        {
          delete row;
        }
      }
      
      delete r;
    
      return data;
    }
};

class DomIterator: public DomElement
{
  private:
    int cursor;

  public:
    DomIterator()
    {
      childrenOwner = false;
    }
    
    bool hasNext()
    {
      return(cursor < ArraySize(children));
    }
    
    DomElement *next()
    {
      if(hasNext())
      {
        return children[cursor++];
      }
      return NULL;
    }

    DomElement *operator[](int index)
    {
      if(index >= 0 && index < ArraySize(children))
      {
        return children[index];
      }
      return NULL;
    }
    
    void rewind()
    {
      cursor = 0;
    }
    
    void removeFirst(const int n)
    {
      int m = ArraySize(children);
      if(n < m)
      {
        ArrayCopy(children, children, 0, n);
        ArrayResize(children, m - n);
      }
      else
      if(n == m)
      {
        ArrayResize(children, 0);
      }
    }

    void printAll()
    {
      rewind();
      while(hasNext())
      {
        DomElement *e = next();
        e.print(false);
      }
    }
    
    void printAllWithContent()
    {
      rewind();
      while(hasNext())
      {
        DomElement *e = next();
        e.printWithContent(false);
      }
    }
    
};


class HtmlParser
{
  private:
    const string TAG_OPEN_START;
    const string TAG_OPEN_STOP;
    
    const string TAG_OPENCLOSE_STOP;
    
    const string TAG_CLOSE_START;
    const string TAG_CLOSE_STOP;
    
    const string COMMENT_START;
    const string COMMENT_STOP;
    
    const string SCRIPT_STOP;
    
    
    StateBit state;
    
    DomElement *root;
    DomElement *cursor;
    int offset;
    
    IndexMap empties;
    
    static int debugLevel;
  
  public:
    HtmlParser():
      TAG_OPEN_START("<"),
      TAG_OPEN_STOP(">"),
      TAG_OPENCLOSE_STOP("/>"),
      TAG_CLOSE_START("</"),
      TAG_CLOSE_STOP(">"),
      COMMENT_START("<!--"),
      COMMENT_STOP("-->"),
      SCRIPT_STOP("/script>"),
      state(blank)
    {
      for(int i = 0; i < ArraySize(empty_tags); i++)
      {
        empties.set(empty_tags[i]);
      }
    }
    
    ~HtmlParser()
    {
      if(root != NULL)
      {
        delete root;
      }
    }
    
    DomElement *parse(const string &html)
    {
      if(root != NULL)
      {
        delete root;
      }
      root = new DomElement("root");
      cursor = root;
      offset = 0;
      
      while(processText(html));
      
      return root;
    }
    
    bool processText(const string &html)
    {
      int p;
      if(state == blank)
      {
        p = StringFind(html, "<", offset);
        if(p == -1) // no more tags
        {
          return(false);
        }
        else if(p > 0)
        {
          if(p > offset)
          {
            string text = StringSubstr(html, offset, p - offset);
            StringTrimLeft(text);
            StringTrimRight(text);
            StringReplace(text, "&nbsp;", "");
            if(StringLen(text) > 0)
            {
              cursor.setText(text);
            }
          }
        }
        
        offset = p;
        
        if(IsString(html, COMMENT_START)) state = insideComment;
        else
        if(IsString(html, TAG_CLOSE_START)) state = insideTagClose;
        else
        if(IsString(html, TAG_OPEN_START)) state = insideTagOpen;
        
        return(true);
      }
      else
      if(state == insideTagOpen)
      {
        offset++;
        int pspace = StringFind(html, " ", offset);
        int pright = StringFind(html, ">", offset);
        p = MathMin(pspace, pright);
        if(p == -1)
        {
          p = MathMax(pspace, pright);
        }
        
        if(p == -1 || pright == -1) // no tag closing
        {
          return(false);
        }
        
        if(pspace > pright)
        {
          pspace = -1; // outer space
        }

        bool selfclose = false;
        if(IsString(html, TAG_OPENCLOSE_STOP, pright - StringLen(TAG_OPENCLOSE_STOP) + 1))
        {
          selfclose = true;
          if(p == pright) p--;
          pright--;
        }
        
        string name = StringSubstr(html, offset, p - offset);
        
        StringToLower(name);
        StringTrimRight(name);
        DomElement *e = new DomElement(cursor, name);
        
        if(pspace != -1)
        {
          string txt;
          if(pright - pspace > 1)
          {
            txt = StringSubstr(html, pspace + 1, pright - (pspace + 1));
            e.parseAttributes(txt);
          }
        }
        
        if((HtmlParser::isDebug() & LOG_MASK_DOM) != 0)
        {
          e.print(false);
        }
        
        bool softSelfClose = false;
        if(!selfclose)
        {
          if(empties.isKeyExisting(name))
          {
            selfclose = true;
            softSelfClose = true;
          }
        }
        
        pright++;
        if(!selfclose)
        {
          cursor = e;
        }
        else
        {
          if(!softSelfClose) pright++;
        }
        
        offset = pright;
        
        if((name == "script") && !selfclose)
        {
          state = insideScript;
        }
        else
        {
          state = blank;
        }
        
        return(true);
        
      }
      else
      if(state == insideTagClose)
      {
        offset += StringLen(TAG_CLOSE_START);
        p = StringFind(html, ">", offset);
        if(p == -1)
        {
          return(false);
        }
        
        string tag = StringSubstr(html, offset, p - offset);
        StringToLower(tag);
        
        DomElement *rewind = cursor;
        
        while(StringCompare(cursor.getName(), tag) != 0)
        {
          string previous = cursor.getName();
          cursor = cursor.getParent();
          if(cursor == NULL)
          {
            // orphan closing tag
            cursor = rewind;
            state = blank;
            offset = p + 1;
            return(true);
          }

          if((isDebug() & LOG_MASK_DOM_WARNING) != 0)
          {
            Print("Misplaced /", tag, ">. Go from ", previous, " up to ", cursor.getName(), " ", cursor.getLevel());
          }
        }
        
        cursor = cursor.getParent();
        if(cursor == NULL) return(false);
        
        state = blank;
        offset = p + 1;
        
        return(true);
      }
      else
      if(state == insideComment)
      {
        offset += StringLen(COMMENT_START);
        p = StringFind(html, COMMENT_STOP, offset);
        if(p == -1)
        {
          return(false);
        }
        
        offset = p + StringLen(COMMENT_STOP);
        state = blank;
        
        return(true);
      }
      else
      if(state == insideScript)
      {
        p = StringFind(html, SCRIPT_STOP, offset);
        if(p == -1)
        {
          return(false);
        }
        
        offset = p + StringLen(SCRIPT_STOP);
        state = blank;
        
        cursor = cursor.getParent();
        if(cursor == NULL) return(false);
        
        return(true);
      }
      return(false);
    }
    
    bool IsString(const string &html, const string x, int subset = -1)
    {
      if(subset == -1) subset = offset;
      return(StringSubstr(html, subset, StringLen(x)) == x);
    }
    
    static void enableDebug(int level)
    {
      debugLevel = level;
    }
    
    static int isDebug()
    {
      return debugLevel;
    }
    
};


int HtmlParser::debugLevel = 0;

class HTMLConverter
{
  protected:
    static bool loadColumnConfig(string &columnSelectors[], string &dataSelectors[], string &headers[])
    {
      Print("Reading column configuration ", ColumnSettingsFile);
      int h = FileOpen(ColumnSettingsFile, FILE_READ|FILE_ANSI|FILE_TXT|FILE_SHARE_READ|FILE_SHARE_WRITE, '|', CP_UTF8);
      if(h == -1)
      {
        Print("Error reading file '", ColumnSettingsFile, "': ", GetLastError());
        return false;
      }
      
      int n = 0;
      bool headerRead = false;
      while(!FileIsEnding(h))
      {
        string stParts[];
        string stLine = FileReadString(h);
        int nParts = StringSplit(stLine, ',', stParts);
        if(nParts == 3)
        {
          if(!headerRead)
          {
            headerRead = true;
            continue;
          }
          ArrayResize(columnSelectors, n + 1);
          ArrayResize(dataSelectors, n + 1);
          ArrayResize(headers, n + 1);
          headers[n] = stParts[0];
          columnSelectors[n] = stParts[1];
          dataSelectors[n] = stParts[2];
          // Print("Column ", (n + 1), ": '", stParts[0], "', selector: '", stParts[1], "', locator: '", stParts[2], "'");
          n++;
        }
      }
      
      FileClose(h);
      return true;
    }

    static bool loadSubstConfig(int &rulesColumns[], string &rulesHave[], string &rulesWant[])
    {
      Print("Reading column configuration ", SubstitutionSettingsFile);
      int h = FileOpen(SubstitutionSettingsFile, FILE_READ|FILE_ANSI|FILE_TXT|FILE_SHARE_READ|FILE_SHARE_WRITE, '|', CP_UTF8);
      if(h == -1)
      {
        Print("Error reading file '", SubstitutionSettingsFile, "': ", GetLastError());
        return false;
      }
      
      int n = 0;
      bool headerRead = false;
      while(!FileIsEnding(h))
      {
        string stParts[];
        string stLine = FileReadString(h);
        int nParts = StringSplit(stLine, ',', stParts);
        if(nParts == 3)
        {
          if(!headerRead)
          {
            headerRead = true;
            continue;
          }
          ArrayResize(rulesColumns, n + 1);
          ArrayResize(rulesHave, n + 1);
          ArrayResize(rulesWant, n + 1);
          rulesColumns[n] = (int)StringToInteger(stParts[0]) - 1;
          if(rulesColumns[n] < 0)
          {
            Print("Invalid column number ", rulesColumns[n], " changed to 0");
            rulesColumns[n] = 0;
          }
          rulesHave[n] = stParts[1];
          rulesWant[n] = stParts[2];
          // Print("Rule ", (n + 1), " for column ", (rulesColumns[n] + 1), ": find '", stParts[1], "', replace with: '", stParts[2], "'");
          n++;
        }
      }
      
      FileClose(h);
      return true;
    }

  public:
    static IndexMap *convertReport2Map(const string URL, const bool columnNames = false)
    {
      if(URL == "")
      {
        Print("Parameter URL can not be empty");
        return NULL;
      }
    
      if(RowSelector == "")
      {
        Print("Enter at least one of parameters: RowSelector, SaveName, TestQuery");
        return NULL;
      }
    
      HtmlParser p;
      
      string xml;
      
      Print("Reading html-file ", URL);
      int h = FileOpen(URL, FILE_READ|FILE_TXT|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI, 0, CP_UTF8);
      if(h == INVALID_HANDLE)
      {
        Print("Error reading file '", URL, "': ", GetLastError());
        return NULL;
      }
      StringInit(xml, (int)FileSize(h));
      while(!FileIsEnding(h))
      {
        xml += FileReadString(h) + "\n";
      }
      // xml = FileReadString(h, (int)FileSize(h)); - has 4095 bytes limit in binary files!
      FileClose(h);
      
      int logLevel = 0;
      if(LogDomElements) logLevel |= LOG_MASK_DOM;
      if(LogDomWarnings) logLevel |= LOG_MASK_DOM_WARNING;
      if(LogSelectedElements) logLevel |= LOG_MASK_SELECTOR;
    
      if(logLevel != 0)
      {
        p.enableDebug(logLevel);
      }
      DomElement *document = p.parse(xml);
    
      Print("Row selector: '", RowSelector, "'");
      
      
      string columnSelectors[];
      string dataSelectors[];
      string headers[];
      
      if(!loadColumnConfig(columnSelectors, dataSelectors, headers)) return NULL;
      
      IndexMap subst;
      int rulesColumns[];
      string rulesHave[];
      string rulesWant[];
      
      if(SubstitutionSettingsFile != "")
      {
        if(!loadSubstConfig(rulesColumns, rulesHave, rulesWant)) return NULL;
      }
      
      for(int i = 0; i < ArraySize(rulesHave); i++)
      {
        string key = columnSelectors[rulesColumns[i]];
        
        if(!subst.isKeyExisting(key))
        {
          subst.add(key, new IndexMap("id" + IntegerToString(i)));
        }
    
        IndexMap *hm = (IndexMap *)subst[key];
        
        hm.setValue(rulesHave[i], rulesWant[i]);
      }
      
      IndexMap *data = document.tableSelect(RowSelector, headers, columnSelectors, dataSelectors, &subst, !columnNames);
    
      return data;
    }
};
