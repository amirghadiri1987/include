//+------------------------------------------------------------------+
//|                                                     OLAPcore.mqh |
//|                                      Copyright © 2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/ru/articles/6602 |
//|                            https://www.mql5.com/ru/articles/6603 |
//+------------------------------------------------------------------+

#include <OLAP/OLAPcube.mqh>
#include <OLAP/HTMLcube.mqh>
#include <OLAP/CSVcube.mqh>


class DaysRangeSelector: public DateTimeSelector<TRADE_RECORD_FIELDS>
{
  protected:
    int granulatity;
    
  public:
    DaysRangeSelector(const int n): DateTimeSelector<TRADE_RECORD_FIELDS>(FIELD_DURATION, 7), granulatity(n)
    {
      _typename = typename(this);
    }
    
    virtual int getRange() const
    {
      return granulatity;
    }
    
    virtual bool select(const Record *r, int &index) const
    {
      double d = r.get(selector);
      int days = (int)(d / (60 * 60 * 24));
      index = MathMin(days, granulatity - 1);
      return true;
    }
    
    virtual string getLabel(const int index) const
    {
      return index < granulatity - 1 ? ((index < 10 ? " ": "") + (string)index + "D") : ((string)index + "D+");
    }
};


class OLAPWrapper
{
  protected:
    Selector<TRADE_RECORD_FIELDS> *createSelector(const SELECTORS selector, const TRADE_RECORD_FIELDS field)
    {
      switch(selector)
      {
        case SELECTOR_TYPE:
          return new TypeSelector();
        case SELECTOR_SYMBOL:
          return new SymbolSelector();
        case SELECTOR_SERIAL:
          return new SerialNumberSelector();
        case SELECTOR_MAGIC:
          return new MagicSelector();
        case SELECTOR_PROFITABLE:
          return new ProfitableSelector();
        case SELECTOR_DURATION:
          return new DaysRangeSelector(15); // up to 14 days
        case SELECTOR_WEEKDAY:
          return field != FIELD_NONE ? new WeekDaySelector(field) : NULL;
        case SELECTOR_DAYHOUR:
          return field != FIELD_NONE ? new DayHourSelector(field) : NULL;
        case SELECTOR_HOURMINUTE:
          return field != FIELD_NONE ? new DayHourSelector(field) : NULL;
        case SELECTOR_SCALAR:
          return field != FIELD_NONE ? new TradeSelector(field) : NULL;
        case SELECTOR_QUANTS:
          return field != FIELD_NONE ? new QuantizationSelector(field) : NULL;
      }
      return NULL;
    }

  public:
    void process(
        const SELECTORS &selectorArray[], const TRADE_RECORD_FIELDS &selectorField[],
        const AGGREGATORS AggregatorType, const TRADE_RECORD_FIELDS AggregatorField, Display &display,
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
        return;
      }
      
      // filter section not used yet >>>
      SELECTORS Filter1 = SELECTOR_NONE;
      TRADE_RECORD_FIELDS Filter1Field = FIELD_NONE;
      
      if(ArraySize(selectorArray) > 3)
      {
        Filter1 = selectorArray[3];
      }

      if(ArraySize(selectorField) > 3)
      {
        Filter1Field = selectorField[3];
      }
      // <<< filter section not used
      
      HistoryDataAdapter<CustomTradeRecord> history;
      HTMLReportAdapter<CustomTradeRecord> report;
      CSVReportAdapter<CustomTradeRecord> external;
      
      DataAdapter *adapter = &history;
      
      if(ReportFile != "")
      {
        if(StringFind(ReportFile, ".htm") > 0 && report.load(ReportFile))
        {
          adapter = &report;
        }
        else
        if(StringFind(ReportFile, ".csv") > 0 && external.load(ReportFile))
        {
          adapter = &external;
        }
        else
        {
          Alert("Unknown file format: ", ReportFile);
          return;
        }
      }
      else
      {
        Print("Analyzing account history");
      }
      
      Analyst<TRADE_RECORD_FIELDS> *analyst;
      
      Selector<TRADE_RECORD_FIELDS> *selectors[];
      ArrayResize(selectors, selectorCount);
      
      for(int i = 0; i < selectorCount; i++)
      {
        selectors[i] = createSelector(selectorArray[i], selectorField[i]);
        if(selectors[i] == NULL)
        {
          Print("Selector ", i, " is empty. Setup selectors successively (don't leave a hole in-between), specify a field when required");
          return;
        }
      }

      // filter section not used yet >>>
      Filter<TRADE_RECORD_FIELDS> *filters[];
      if(Filter1 != SELECTOR_NONE)
      {
        ArrayResize(filters, 1);
        Selector<TRADE_RECORD_FIELDS> *filterSelector = createSelector(Filter1, Filter1Field);
        if(Filter1value1 != Filter1value2)
        {
          filters[0] = new FilterRange<TRADE_RECORD_FIELDS>(filterSelector, Filter1value1, Filter1value2);
        }
        else
        {
          filters[0] = new Filter<TRADE_RECORD_FIELDS>(filterSelector, Filter1value1);
        }
      }
      // <<< filter section not used
      
      Aggregator<TRADE_RECORD_FIELDS> *aggregator;
      
      // MQL does not support a 'class info' metaclass.
      // Otherwise we could use an array of classes instead of the switch
      switch(AggregatorType)
      {
        case AGGREGATOR_SUM:
          aggregator = new SumAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_AVERAGE:
          aggregator = new AverageAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_MAX:
          aggregator = new MaxAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_MIN:
          aggregator = new MinAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_COUNT:
          aggregator = new CountAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_PROFITFACTOR:
          aggregator = new ProfitFactorAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_PROGRESSIVE:
          aggregator = new ProgressiveTotalAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
        case AGGREGATOR_IDENTITY:
          aggregator = new IdentityAggregator<TRADE_RECORD_FIELDS>(AggregatorField, selectors, filters);
          break;
      }
      
      analyst = new Analyst<TRADE_RECORD_FIELDS>(adapter, aggregator, display);
      
      analyst.acquireData();
      
      Print("Symbol number: ", TradeRecord::getSymbolCount());
      for(int i = 0; i < TradeRecord::getSymbolCount(); i++)
      {
        Print(i, "] ", TradeRecord::getSymbol(i));
      }
    
      Print("Magic number: ", TradeRecord::getMagicCount());
      for(int i = 0; i < TradeRecord::getMagicCount(); i++)
      {
        Print(i, "] ", TradeRecord::getMagic(i));
      }
      
      Print("Filters: ", aggregator.getFilterTitles());
      
      Print("Selectors: ", selectorCount);
      
      analyst.build();
      analyst.display(SortBy, AggregatorType == AGGREGATOR_IDENTITY);

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
    }

};
