//+------------------------------------------------------------------+
//|                                                     HTMLcube.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include <Marketeer/HTMLcolumns.mqh>
#include <Marketeer/RubbArray.mqh>

template<typename T>
class ReportTradeRecord: public T // TradeRecord
{
  public:
    ReportTradeRecord(
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
      set(FIELD_OPEN_DATETIME, time1);
      set(FIELD_CLOSE_DATETIME, time2);
      set(FIELD_DURATION, time2 - time1);
      set(FIELD_OPEN_PRICE, (float)price1);
      set(FIELD_CLOSE_PRICE, (float)price2);
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

class Deal
{
  public:
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
    Deal() {}
    Deal(const IndexMap *row)
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

template<typename T>
class BaseReportAdapter: public DataAdapter
{
  protected:
    RubbArray<Deal *> array;
    RubbArray<Deal *> queue;

    int size;
    int cursor;
    double balance;
    
    RubbArray<ReportTradeRecord<T> *> trades;
    
  protected:
    virtual bool fillDealsArray() = 0;
    
    int generate()
    {
      array.clear();
      queue.clear();
      trades.clear();
      balance = 0;
      
      if(!fillDealsArray()) return 0;
      
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
        
        string real = TradeRecord::realsymbol(current.symbol, Prefix, Suffix);
        if(real == NULL) continue;
        
        if(current.isOut())
        {
          // first try to find exact match
          for(int j = 0; j < queue.size(); ++j)
          {
            if(queue[j].isIn() && queue[j].isOpposite(current) && queue[j].volume == current.volume && queue[j].symbol == current.symbol)
            {
              trades << new ReportTradeRecord<T>(
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
                
                trades << new ReportTradeRecord<T>(
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

                trades << new ReportTradeRecord<T>(
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
    }
    
  public:
    BaseReportAdapter()
    {
      reset();
      TradeRecord::reset();
    }
    
    ~BaseReportAdapter()
    {
      ((BaseArray<Deal *> *)&queue).clear();
    }
    
    virtual bool load(const string file)
    {
      reset();
      TradeRecord::reset();
      return false;
    }
    
    virtual int reservedSize() const override
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

    virtual bool isOwner() const override
    {
      return true;
    }

    virtual int getFieldCount() const override
    {
      return TRADE_RECORD_FIELDS_LAST;
    }
};
