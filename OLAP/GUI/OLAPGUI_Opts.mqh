//+------------------------------------------------------------------+
//|                                                 OLAPGUI_Opts.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//+------------------------------------------------------------------+
#include <OLAP/GUI/OLAPGUI.mqh>


#define MAX_ALGO_CHOICES 9 // NB: this is the number of aggregators (most lengthy row in settings)


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
    // enum RECORD_FIELDS 1:1, default - profit amount
    {""},
    // enum SORT_BY, default - none
    {"none", "value ascending", "value descending", "label ascending", "label descending"},
    // enum ENUM_CURVE_TYPE partially, default - points
    {"points", "lines", "points/lines", "steps", "histogram"}
  };
  
  static const int _defaults[ALGO_NUMBER] = {0, FIELD_PROFIT, 0, 0};

  const int std = EnumSize<F,PackedEnum>(0);
  const int fields = std + customFieldCount;

  ArrayResize(settings, fields);
  ArrayResize(selectors, fields);
  selectors[0] = "(<selector>/field)"; // none
  selectors[1] = "<serial number>"; // the only selector, which can be chosen explicitly, it correspods to the 'index' field

  for(int i = 0; i < ALGO_NUMBER; i++)
  {
    if(i == 1) // pure fields
    {
      for(int j = 0; j < fields; j++)
      {
        settings[j][i] = j < std ? Record::legendFromEnum((F)j) : customFields[j - std];
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

  for(int j = 2; j < fields; j++) // 0-th is none
  {
    selectors[j] = j < std ? Record::legendFromEnum((F)j) : customFields[j - std];
  }
  
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
  
  if(at == AGGREGATOR_IDENTITY)
  {
    Print("Sorting is disabled for Identity");
    sb = SORT_BY_NONE;
  }

  ArrayInitialize(Selectors, SELECTOR_NONE);
  ArrayInitialize(Fields, FIELD_NONE);

  int matches[2] =
  {
    SELECTOR_NONE,
    SELECTOR_INDEX
  };
  
  for(int i = 0; i < AXES_NUMBER; i++)
  {
    if(!m_axis[i].IsVisible()) continue;
    int v = (int)m_axis[i].Value();
    if(v < 2) // selectors (which is specialized for a field already)
    {
      Selectors[i] = (SELECTORS)matches[v];
    }
    else // pure fields
    {
      Selectors[i] = at == AGGREGATOR_IDENTITY ? SELECTOR_SCALAR : SELECTOR_QUANTS;
      Fields[i] = (ENUM_FIELDS)(v);
    }
  }
  
  m_plot.CurvesRemoveAll();

  if(at == AGGREGATOR_IDENTITY || at == AGGREGATOR_COUNT) af = FIELD_NONE;

  m_plot.InitXAxis(at != AGGREGATOR_PROGRESSIVE ? new AxisCustomizer(m_plot.getGraphic(), false, false, false, at == AGGREGATOR_IDENTITY) : NULL);
  m_plot.InitYAxis(at == AGGREGATOR_IDENTITY ? new AxisCustomizer(m_plot.getGraphic(), true, false, false, true) : NULL);

  m_button_ok.Text("Processing...");
  return olapcore.process(Selectors, Fields, at, af, olapdisplay, sb);
}
