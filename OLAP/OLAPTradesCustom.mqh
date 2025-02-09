//+------------------------------------------------------------------+
//|                                             OLAPTradesCustom.mqh |
//|                                      Copyright © 2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7535 |
//|                            https://www.mql5.com/en/articles/7656 |
//|                                                  rev. 25.02.2020 |
//+------------------------------------------------------------------+

class CustomTradeRecord;

#define RECORD_CLASS CustomTradeRecord

#include "OLAPTrades.mqh"

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
      fillCustomFields();
    }
    
    // calculate MFE/MAE in percents
    virtual void fillCustomFields() override
    {
      static CustomFieldsDescription *legend = CustomFieldsDescription::instantiate();

      double positiveExcursion = 0, negativeExcursion = 0;
      string symbol = symbols[(int)get(FIELD_SYMBOL)];
      int t1 = iBarShift(symbol, _Period, (datetime)get(FIELD_OPEN_DATETIME), false);
      int t2 = iBarShift(symbol, _Period, (datetime)get(FIELD_CLOSE_DATETIME), false);
      int type = (int)get(FIELD_TYPE);
      double open = get(FIELD_OPEN_PRICE);
      double close = get(FIELD_CLOSE_PRICE);

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
      set(TRADE_RECORD_FIELDS::FIELD_CUSTOM_1, positiveExcursion * 100);
      set(TRADE_RECORD_FIELDS::FIELD_CUSTOM_2, negativeExcursion * 100);
    }

    virtual string legend(const int index) const override
    {
      if(index == TRADE_RECORD_FIELDS::FIELD_CUSTOM_1) return "MFE per trade(%)";
      else
      if(index == TRADE_RECORD_FIELDS::FIELD_CUSTOM_2) return "MAE per trade(%)";
      
      return TradeRecord::legend(index);
    }
};
