//+------------------------------------------------------------------+
//|                                                     HTMLcube.mqh |
//|                                    Copyright (c) 2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/ru/articles/6602 |
//|                            https://www.mql5.com/ru/articles/6603 |
//+------------------------------------------------------------------+

#include <Marketeer/GroupSettings.mqh>

input GroupSettings Common_Settings; // G E N E R A L     S E T T I N G S

input string ReportFile = ""; // · ReportFile
input string Prefix = ""; // · Prefix
input string Suffix = ""; // · Suffix
input int  TimeShift = 0; // · TimeShift


#include <Marketeer/WebDataExtractor.mqh>
#include <Marketeer/RubbArray.mqh>
#include <Marketeer/HTMLcolumns.mqh>


template<typename T>
class HTMLTradeRecord: public T // TradeRecord
{
  public:
    HTMLTradeRecord(
      const double balance,
      const long ticket,
      const string symbol,
      const int type,
      const datetime time1,
      const datetime time2,
      const double price1,
      const double price2,
      const double lot,
      const double profit,
      const double commission,
      const double swap)
    {
      set(FIELD_NUMBER, counter++);
      set(FIELD_TICKET, ticket);
      set(FIELD_SYMBOL, symbols.add(symbol));
      set(FIELD_TYPE, type);
      set(FIELD_DATETIME1, time1);
      set(FIELD_DATETIME2, time2);
      set(FIELD_DURATION, time2 - time1);
      set(FIELD_PRICE1, (float)price1);
      set(FIELD_PRICE2, (float)price2);
      set(FIELD_MAGIC, 0);
      magics.add(0);
      set(FIELD_LOT, (float)lot);
      set(FIELD_PROFIT_AMOUNT, (float)profit);
      set(FIELD_PROFIT_PERCENT, (float)(profit / balance));
      set(FIELD_PROFIT_POINT, (float)((type == OP_BUY ? +1 : -1) * (price2 - price1) / SymbolInfoDouble(symbol, SYMBOL_POINT)));
      set(FIELD_COMMISSION, (float)commission);
      set(FIELD_SWAP, (float)swap);
      
      fillCustomFields(); // calls implementation from T
    }
    
};

template<typename T>
class HTMLReportAdapter: public DataAdapter
{
  private:

    class Deal   // if MQL5 could respect private access specifier for classes,
    {            // Trades will be unreachable from outer world, so it would be fine to have
      public:    // fields made public for direct access from Processor only
        datetime time;
        double price;
        int type;      // +1 - buy, -1 - sell
        int direction; // +1 - in, -1 - out, 0 - in/out
        double volume;
        double profit;
        long deal;
        long order;
        string comment;
        string symbol;
        double commission;
        double swap;
        
      public:
        Deal(const IndexMap *row) // this is MT5 deal
        {
          time = StringToTime(row[COLUMN_TIME].get<string>()) + TimeShift;
          price = StringToDouble(row[COLUMN_PRICE].get<string>());
          string t = row[COLUMN_TYPE].get<string>();
          type = t == "buy" ? +1 : (t == "sell" ? -1 : 0);
          t = row[COLUMN_DIRECTION].get<string>();
          direction = 0;
          if(StringFind(t, "in") > -1) ++direction;
          if(StringFind(t, "out") > -1) --direction;
          volume = StringToDouble(row[COLUMN_VOLUME].get<string>());
          t = row[COLUMN_PROFIT].get<string>();
          StringReplace(t, " ", "");
          profit = StringToDouble(t);
          deal = StringToInteger(row[COLUMN_DEAL].get<string>());
          order = StringToInteger(row[COLUMN_ORDER].get<string>());
          comment = row[COLUMN_COMMENT].get<string>();
          symbol = row[COLUMN_SYMBOL].get<string>();
          commission = StringToDouble(row[COLUMN_COMISSION].get<string>());
          swap = StringToDouble(row[COLUMN_SWAP].get<string>());
        }
    
        bool isIn() const
        {
          return direction >= 0;
        }
        
        bool isOut() const
        {
          return direction <= 0;
        }
        
        bool isOpposite(const Deal *t) const
        {
          return type * t.type < 0;
        }
        
        bool isActive() const
        {
          return volume > 0;
        }
        
        int op_type() const
        {
          if(type == +1) return OP_BUY;
          else if(type == -1) return OP_SELL;
          return OP_BALANCE;
        }
    };

    RubbArray<Deal *> array;
    RubbArray<Deal *> queue;


    int size;
    int cursor;
    double balance;
    IndexMap *data;
    
    RubbArray<HTMLTradeRecord<T> *> trades;
    
    
  protected:
    int generate()
    {
      array.clear();
      balance = 0;
      for(int i = 0; i < data.getSize(); ++i)
      {
        IndexMap *row = data[i];
        if(CheckPointer(row) == POINTER_INVALID || row.getSize() != COLUMNS_COUNT) return 0; // something is broken
        string s = row[COLUMN_SYMBOL].get<string>();
        StringTrimLeft(s);
        if(StringLen(s) > 0)
        {
          array << new Deal(row);
        }
        else if(row[COLUMN_TYPE].get<string>() == "balance")
        {
          string t = row[COLUMN_PROFIT].get<string>();
          StringReplace(t, " ", "");
          balance += StringToDouble(t);
        }
      }
      
      if(balance == 0) balance = 10000; // default, if missing
    
      int count = 0;
      // abstract:
      // if direction <= 0
      //   collect all Trades from the queue which have direction >= 0 and opposite type
      //   if this volume is greater than collected volumes
      //     reduce volume in this Deal by the total volume of collected Trades
      //   else if collected volumes are greater than this volume
      //     reduce volume in matched Trades in a loop until all volume of this Deal is exhausted
      //   create object-lines from all affected Trades to this Deal
      //   'delete' all affected Trades with zero volume from queue
      //   if volume == 0, 'delete' this Deal (disactivate)
      // if direction >= 0 push the new Deal object to the queue
      
      for(int i = 0; i < array.size(); ++i)
      {
        Deal *current = array[i];
        
        if(!current.isActive()) continue;
        
        string real = TradeRecord::realsymbol(current.symbol);
        if(real == NULL) continue;
        
        if(current.isOut())
        {
          // first try to find exact match
          for(int j = 0; j < queue.size(); ++j)
          {
            if(queue[j].isIn() && queue[j].isOpposite(current) && queue[j].volume == current.volume && queue[j].symbol == current.symbol)
            {
              trades << new HTMLTradeRecord<T>(
                balance,
                queue[j].deal,
                real, // current.symbol,
                queue[j].op_type(),
                queue[j].time,
                current.time,
                queue[j].price,
                current.price,
                current.volume,
                current.profit,
                queue[j].commission + current.commission,
                current.swap);
              balance += current.profit;
              
              current.volume = 0;
              queue >> j; // remove from queue
              ++count;
              break;
            }
          }

          if(!current.isActive()) continue;
          
          // second try to perform partial close
          for(int j = 0; j < queue.size(); ++j)
          {
            if(queue[j].isIn() && queue[j].isOpposite(current) && queue[j].symbol == current.symbol)
            {
              if(current.volume >= queue[j].volume)
              {
                double fraction = queue[j].volume / current.volume;
                
                trades << new HTMLTradeRecord<T>(
                  balance,
                  queue[j].deal,
                  real, // current.symbol,
                  queue[j].op_type(),
                  queue[j].time,
                  current.time,
                  queue[j].price,
                  current.price,
                  queue[j].volume,
                  current.profit * fraction,
                  queue[j].commission + current.commission * fraction,
                  current.swap * fraction);
                balance += current.profit * fraction;

                current.volume -= queue[j].volume;
                queue[j].volume = 0;
                ++count;
              }
              else
              {
                double fraction = current.volume / queue[j].volume;

                trades << new HTMLTradeRecord<T>(
                  balance,
                  queue[j].deal,
                  real, // current.symbol,
                  queue[j].op_type(),
                  queue[j].time,
                  current.time,
                  queue[j].price,
                  current.price,
                  current.volume,
                  queue[j].profit * fraction, // should be 0
                  queue[j].commission * fraction + current.commission,
                  current.swap);
                balance += queue[j].profit * fraction;

                queue[j].volume -= current.volume;
                current.volume = 0;
                ++count;
                break;
              }
            }
          }
          
          // purge all inactive from queue
          for(int j = queue.size() - 1; j >= 0; --j)
          {
            if(!queue[j].isActive())
            {
              queue >> j;
            }
          }
        }
        
        if(current.isActive()) // is _still_ active
        {
          if(current.isIn())
          {
            queue << current;
          }
        }
      }
      
      return count;
    }
    
    void reset()
    {
      cursor = 0;
      balance = 0;
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
    }
    
  public:
    HTMLReportAdapter()
    {
      reset();
      TradeRecord::reset();
    }
    
    ~HTMLReportAdapter()
    {
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
      ((BaseArray<Deal *> *)&queue).clear();
    }

    bool load(const string file)
    {
      reset();
      data = HTMLConverter::convertReport2Map(file, true);
      if(data != NULL)
      {
        size = generate();
        Print(data.getSize(), " deals transferred to ", size, " trades");
      }
      return data != NULL;
    }
    
    virtual int reservedSize() override
    {
      return size;
    }
    
    virtual Record *getNext() override
    {
      if(cursor < size)
      {
        return trades[cursor++];
      }
      return NULL;
    }
};
