//+------------------------------------------------------------------+
//|                                                      CSVcube.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

#include <OLAP/GroupReportInputs.mqh>

#include <Marketeer/CSVReader.mqh>
#include <Marketeer/CSVcolumns.mqh>
#include <Marketeer/RubbArray.mqh>

template<typename T>
class CSVTradeRecord: public T // TradeRecord
{
  public:
    CSVTradeRecord(const double balance, const string symbol, const IndexMap *row)
    {
      const int add = row.getSize() == 13 ? 2 : 0;
      set(FIELD_NUMBER, counter);
      set(FIELD_TICKET, counter++);
      set(FIELD_SYMBOL, symbols.add(symbol));
      string t = row[CSV_COLUMN_TYPE].get<string>();
      StringToLower(t);
      const int _type = t == "buy" ? +1 : (t == "sell" ? -1 : 0);
      set(FIELD_TYPE, _type == +1 ? OP_BUY : (_type == -1 ? OP_SELL : OP_BALANCE));
      datetime time1 = StringToTime(row[CSV_COLUMN_TIME1].get<string>()) + TimeShift;
      datetime time2 = StringToTime(row[CSV_COLUMN_TIME2 + add].get<string>()) + TimeShift;
      set(FIELD_OPEN_DATETIME, time1);
      set(FIELD_CLOSE_DATETIME, time2);
      set(FIELD_DURATION, time2 - time1);
      double price1 = StringToDouble(row[CSV_COLUMN_PRICE1].get<string>());
      double price2 = StringToDouble(row[CSV_COLUMN_PRICE2 + add].get<string>());
      set(FIELD_OPEN_PRICE, price1);
      set(FIELD_CLOSE_PRICE, price2);
      set(FIELD_MAGIC, 0);
      magics.add(0);
      set(FIELD_LOT, StringToDouble(row[CSV_COLUMN_VOLUME].get<string>()));
      t = row[CSV_COLUMN_PROFIT + add].get<string>();
      StringReplace(t, " ", "");
      const double profit = StringToDouble(t);
      set(FIELD_PROFIT_AMOUNT, profit);
      set(FIELD_PROFIT_PERCENT, (profit / balance));
      set(FIELD_PROFIT_POINT, (_type * (price2 - price1) / SymbolInfoDouble(symbol, SYMBOL_POINT)));
      set(FIELD_COMMISSION, StringToDouble(row[CSV_COLUMN_COMMISSION + add].get<string>()));
      set(FIELD_SWAP, StringToDouble(row[CSV_COLUMN_SWAP + add].get<string>()));
      
      fillCustomFields();
    }

};

template<typename T>
class CSVReportAdapter: public DataAdapter
{
  private:
    RubbArray<CSVTradeRecord<T> *> trades;

    int cursor;
    int size;
    double balance;
    IndexMap *data;

    void reset()
    {
      cursor = 0;
      balance = 0;
    }

  public:
    CSVReportAdapter()
    {
      reset();
      TradeRecord::reset();
    }
    
    ~CSVReportAdapter()
    {
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
    }

    bool load(const string file)
    {
      reset();
      TradeRecord::reset();
      if(CheckPointer(data) == POINTER_DYNAMIC) delete data;
      data = CSVConverter::ReadCSV(file);
      if(data != NULL)
      {
        size = generate();
        Print(data.getSize(), " records transferred to ", size, " trades");
      }
      return data != NULL;
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

  protected:
    int generate()
    {
      trades.clear();
      int count = 0;
      balance = 0;
      for(int i = data.getSize() - 1; i >= 0; --i) // csv-files have reverse chronological order
      {
        IndexMap *row = data[i];
        const int add = row.getSize() == 13 ? 2 : 0;
        string s = row[CSV_COLUMN_SYMBOL].get<string>();
        StringTrimLeft(s);
        if(StringLen(s) > 0)
        {
          if(balance == 0)
          {
            Print("Zero balance, 10000 emulated");
            balance = 10000;
          }

          string real = TradeRecord::realsymbol(s, Prefix, Suffix);
          if(real == NULL) continue;
          
          trades << new CSVTradeRecord<T>(balance, real, row);
          ++count;
        }
        else
        {
          string type = row[CSV_COLUMN_TYPE].get<string>();
          StringToLower(type);
          if(type == "balance")
          {
            string t = row[CSV_COLUMN_PROFIT + add].get<string>();
            StringReplace(t, " ", "");
            balance += StringToDouble(t);
          }
        }
        
      }

      return count;
    }
};

CSVReportAdapter<RECORD_CLASS> _defaultCSVReportAdapter;
