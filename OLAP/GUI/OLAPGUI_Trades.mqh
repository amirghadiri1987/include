//+------------------------------------------------------------------+
//|                                               OLAPGUI_Trades.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//+------------------------------------------------------------------+

#include <OLAP/GUI/OLAPGUI.mqh>


#define MAX_ALGO_CHOICES 19 // NB: this is TRADE_RECORD_FIELDS_LAST, which is most lengthy one in this row
#define MAX_AXES_CHOICES 18 // a combination of selectors and trade fields


template<typename S, typename F>
class OLAPDialog: public OLAPDialogBase
{
  private:
    OLAPEngine<S,F> *olapcore;
    OLAPDisplay *olapdisplay;

  public:
    OLAPDialog(OLAPEngine<S,F> &olapimpl);
    ~OLAPDialog(void);
    virtual int process() override;
    virtual void setup() override;
    void setPrintLog(const bool printLog)
    {
      if(CheckPointer(olapdisplay) != POINTER_INVALID) olapdisplay.setPrintLog(printLog);
    }
};


template<typename S, typename F>
OLAPDialog::OLAPDialog(OLAPEngine<S,F> &olapimpl)
{
  curveType = CURVE_POINTS;
  olapcore = &olapimpl;
  olapdisplay = new OLAPDisplay(&this);
}

template<typename S, typename F>
OLAPDialog::~OLAPDialog(void)
{
  delete olapdisplay;
}


template<typename S, typename F>
void OLAPDialog::setup() override
{
  static const string _settings[ALGO_NUMBER][MAX_ALGO_CHOICES] =
  {
    // enum AGGREGATORS 1:1, default - sum
    {"sum", "average", "max", "min", "count", "profit factor", "progressive total", "identity", "variance"},
    // enum TRADE_RECORD_FIELDS 1:1, default - profit amount
    {"none", "ordinal", "ticket", "symbol", "type",
     "open datetime", "close datetime", "duration", "open price", "close price",
     "magic number", "lot", "profit amount", "profit percent", "profit points",
     "commission", "swap", "custom 1", "custom 2"},
    // enum SORT_BY, default - none
    {"none", "value ascending", "value descending", "label ascending", "label descending"},
    // enum ENUM_CURVE_TYPE partially, default - points
    {"points", "lines", "points/lines", "steps", "histogram"}
  };
  
  static const int _defaults[ALGO_NUMBER] = {0, 12, 0, 0};

  static const string _selectors[MAX_AXES_CHOICES] =
  {
    "(«selector»/field)", "«ordinal»", "«symbol»", "«type»", "«magic number»",
    "«day of week open»", "«day of week close»", "«hour of day open»", "«hour of day close»", "«duration»",
    "lot", "profit amount", "profit percent", "profit points", "commission",
    "swap", "custom 1", "custom 2"
  };

  ArrayResize(settings, MAX_ALGO_CHOICES);
  
  for(int i = 0; i < ALGO_NUMBER; i++)
  {
    if(i == 1)
    {
      TradeRecord r;
      for(int j = 0; j < MAX_ALGO_CHOICES; j++)
      {
        settings[j][i] = r.legend(j);
      }
    }
    else
    {
      for(int j = 0; j < MAX_ALGO_CHOICES; j++)
      {
        settings[j][i] = _settings[i][j];
      }
    }
  }

  ArrayCopy(selectors, _selectors);
  ArrayCopy(defaults, _defaults);
}

template<typename S, typename F>
int OLAPDialog::process() override
{
  SELECTORS Selectors[4];
  ENUM_FIELDS Fields[4];
  AGGREGATORS at = (AGGREGATORS)m_algo[0].Value();
  ENUM_FIELDS af = (ENUM_FIELDS)(AGGREGATORS)m_algo[1].Value();
  SORT_BY sb = (SORT_BY)m_algo[2].Value();

  ArrayInitialize(Selectors, SELECTOR_NONE);
  ArrayInitialize(Fields, FIELD_NONE);

  int matches[10] =
  {
    SELECTOR_NONE,
    SELECTOR_SERIAL,
    SELECTOR_SYMBOL,
    SELECTOR_TYPE,
    SELECTOR_MAGIC,
    SELECTOR_WEEKDAY,
    SELECTOR_WEEKDAY,
    SELECTOR_DAYHOUR,
    SELECTOR_DAYHOUR,
    SELECTOR_DURATION
  };
  
  int subfields[] =
  {
    FIELD_LOT,
    FIELD_PROFIT_AMOUNT,
    FIELD_PROFIT_PERCENT,
    FIELD_PROFIT_POINT,
    FIELD_COMMISSION,
    FIELD_SWAP,
    FIELD_CUSTOM_1,
    FIELD_CUSTOM_2
  };
  
  for(int i = 0; i < AXES_NUMBER; i++)
  {
    if(!m_axis[i].IsVisible()) continue;
    int v = (int)m_axis[i].Value();
    if(v < 10) // selectors (every one is specialized for a field already)
    {
      Selectors[i] = (SELECTORS)matches[v];
      if(v == 5 || v == 7) Fields[i] = FIELD_OPEN_DATETIME;
      else if(v == 6 || v == 8) Fields[i] = FIELD_CLOSE_DATETIME;
    }
    else // pure fields
    {
      Selectors[i] = at == AGGREGATOR_IDENTITY ? SELECTOR_SCALAR : SELECTOR_QUANTS;
      Fields[i] = (TRADE_RECORD_FIELDS)subfields[v - 10];
    }
  }
  
  int dimension = 0;
  for(int i = 0; i < AXES_NUMBER; i++)
  {
    if(Selectors[i] != SELECTOR_NONE) dimension++;
  }

  m_plot.CurvesRemoveAll();
  AxisCustomizer *customX = NULL;
  AxisCustomizer *customY = NULL;

  if(at == AGGREGATOR_IDENTITY || at == AGGREGATOR_COUNT) af = FIELD_NONE;
  
  if(at != AGGREGATOR_PROGRESSIVE)
  {
    customX = new AxisCustomizer(m_plot.getGraphic(), false, Selectors[0] == SELECTOR_DURATION, (dimension > 1 && SORT_VALUE(sb)));//, (dimension > 1 && SORT_VALUE(sb))
  }
  
  if((af == FIELD_DURATION)
  || (at == AGGREGATOR_IDENTITY
  && (Selectors[1] == SELECTOR_DURATION
  || (Selectors[0] == SELECTOR_DURATION && Selectors[1] == SELECTOR_NONE))))
  {
    customY = new AxisCustomizer(m_plot.getGraphic(), true, true);
  }
  
  m_plot.InitXAxis(customX);
  m_plot.InitYAxis(customY);
  m_button_ok.Text("Processing...");
  return olapcore.process(Selectors, Fields, at, af, olapdisplay, sb);
}
