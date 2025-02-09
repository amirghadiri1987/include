//+------------------------------------------------------------------+
//|                                                      OLAPGUI.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|               Online Analytical Processing of trading hypercubes |
//|                            https://www.mql5.com/en/articles/6602 |
//|                            https://www.mql5.com/en/articles/6603 |
//|                            https://www.mql5.com/en/articles/7656 |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2019-2020, Marketeer"
#property link "https://www.mql5.com/en/users/marketeer"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Layouts/Box.mqh>
#include <Layouts/ComboBoxResizable.mqh>
#include <PairPlot/Plot.mqh>
#include <Layouts/MaximizableAppDialog.mqh>
#include <OLAP/OLAPCommon.mqh>

#define BUTTON_WIDTH (100)
#define BUTTON_HEIGHT (20)

#define EDIT_HEIGHT (20)

#define GROUP_WIDTH (150)
#define LIST_HEIGHT (179)
#define RADIO_HEIGHT (56)
#define CHECK_HEIGHT (93)

#define AXES_NUMBER 3

#define ALGO_NUMBER     4
#define ALGO_AGGREGATOR 0
#define ALGO_FIELD      1
#define ALGO_SORTING    2
#define ALGO_GRAPHTYPE  3


class OLAPDialogBase: public MaximizableAppDialog
{
  protected:
    string selectors[/*MAX_AXES_CHOICES*/];
    string settings[/*MAX_ALGO_CHOICES*/][ALGO_NUMBER];
    int defaults[ALGO_NUMBER];
    
    CBox m_main;

    CBox m_row_1;
    ComboBoxResizable m_axis[AXES_NUMBER];
    CButton m_button_ok;

    CBox m_row_2;
    ComboBoxResizable m_algo[ALGO_NUMBER]; // aggregator, field, graph type, sort by

    CBox m_row_plot;
    CPlot m_plot;
    
    ENUM_CURVE_TYPE curveType;

    bool processing;

    // 3-d dimension handling
    bool browsing;
    int currentZ;
    int maxZ;
    string titlesZ[];
    void validateZ();

    int customFieldCount;
    string customFields[];

  public:
    virtual bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2) override;
    virtual bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) override;
    virtual int process() = 0;
    virtual void setup() = 0;

    virtual void setCustomFields(const DataAdapter &adapter)
    {
      string names[];
      if(adapter.getCustomFields(names) > 0)
      {
        customFieldCount = ArrayCopy(customFields, names);
      }
    }

    // data callbacks    
    void accept1D(const PairArray *data, const string title);
    void accept2D(const double &x[], const double &y[], const string title);
    void finalize();
    void registerZ(const string &titles[]);
    int getCurrentZ() const
    {
      return currentZ;
    }

  protected:
    CWnd *CreateAxisComboBox(const int i);
    CWnd *CreateAlgoComboBox(const int i);
    CWnd *CreatePlot(const long chart, const string name, const int subwin);
    CWnd *CreateButton(const long chart, const string name, const int subwin);

    bool OnChangeComboBoxAxis(const int i);
    bool OnChangeComboBoxAlgo(const int i);
    void OnClickButton(void);

    virtual CWnd *CreateMain(const long chart, const string name, const int subwin);
    virtual CWnd *CreateAxesRow(const long chart, const string name, const int subwin);
    virtual CWnd *CreateAlgoRow(const long chart, const string name, const int subwin);
    virtual CWnd *CreatePlotRow(const long chart, const string name, const int subwin);

    virtual void SelfAdjustment(const bool restore = false) override;
  
};

// since MQL5 does not support multiple inheritence we need this delegate object
class OLAPDisplay: public Display
{
  private:
    OLAPDialogBase *parent;
    bool printout;

  public:
    OLAPDisplay(OLAPDialogBase *ptr, const bool printLog = true): parent(ptr), printout(printLog) {}
    void setPrintLog(const bool printLog) {printout = printLog;}
    virtual void display(MetaCube *metaData, const SORT_BY sortby = SORT_BY_NONE, const bool identity = false) override;
};


EVENT_MAP_BEGIN(OLAPDialogBase)
  ON_INDEXED_EVENT(ON_CHANGE, m_axis, OnChangeComboBoxAxis)
  ON_INDEXED_EVENT(ON_CHANGE, m_algo, OnChangeComboBoxAlgo)
  ON_EVENT(ON_CLICK, m_button_ok, OnClickButton)
EVENT_MAP_END(MaximizableAppDialog)


bool OLAPDialogBase::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
  setup();

  const int maxw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
  const int maxh = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
  int _x1 = x1;
  int _y1 = y1;
  int _x2 = x2;
  int _y2 = y2;
  if(x2 - x1 > maxw || x2 > maxw)
  {
    _x1 = 0;
    _x2 = _x1 + maxw - 0;
  }
  if(y2 - y1 > maxh || y2 > maxh)
  {
    _y1 = 0;
    _y2 = _y1 + maxh - 1;
  }

  if(MaximizableAppDialog::Create(chart, name, subwin, _x1, _y1, _x2, _y2)
  && Add(CreateMain(chart, name, subwin))
  && m_main.Pack())
  {
      SelfAdjustment();
      m_axis[1].Disable();
      m_axis[2].Disable();
      return true;
  }
  return false;
}

CWnd *OLAPDialogBase::CreateMain(const long chart, const string name, const int subwin)
{
  m_main.LayoutStyle(LAYOUT_STYLE_VERTICAL);

  if(m_main.Create(chart, name + "main", subwin, 0, 0, ClientAreaWidth(), ClientAreaHeight())
  && m_main.Add(CreateAxesRow(chart, name, subwin))
  && m_main.Add(CreateAlgoRow(chart, name, subwin))
  && m_main.Add(CreatePlotRow(chart, name, subwin)))
  { 
      return &m_main;
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreateAxesRow(const long chart, const string name, const int subwin)
{
  if(m_row_1.Create(chart, name + "axesrow", subwin, 0, 0, ClientAreaWidth(), BUTTON_HEIGHT * 1.5))
  {
    m_row_1.Alignment(WND_ALIGN_LEFT|WND_ALIGN_RIGHT, 2, 0, 2, 0);
    for(int i = 0; i < AXES_NUMBER; i++)
    {
      if(!m_row_1.Add(CreateAxisComboBox(i))) return NULL;
    }
    if(!m_row_1.Add(CreateButton(chart, name, subwin))) return NULL;
    return &m_row_1;
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreateAxisComboBox(const int x)
{
  if(m_axis[x].Create(m_chart_id, m_name + "axis" + (string)x, m_subwin, 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT))
  {
    for(int i = 0; i < ArraySize(selectors); i++)
    {
      string prefix = i == 0 ? CharToString((uchar)('X' + x)) + ": " : "";
      if(!m_axis[x].ItemAdd(prefix + selectors[i]))
          return NULL;
    }
    m_axis[x].Select(0);
    return &m_axis[x];
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreateButton(const long chart, const string name, const int subwin)
{
  if(m_button_ok.Create(chart, name + "ok", subwin, 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
  && m_button_ok.Text("Process"))
  {
    return &m_button_ok;
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreateAlgoRow(const long chart, const string name, const int subwin)
{
  if(m_row_2.Create(chart, name + "algorow", subwin, 0, 0, ClientAreaWidth(), BUTTON_HEIGHT * 1.5))
  {
    m_row_2.Alignment(WND_ALIGN_LEFT|WND_ALIGN_RIGHT, 2, 0, 2, 0);
    for(int i = 0; i < ALGO_NUMBER; i++)
    {
      if(!m_row_2.Add(CreateAlgoComboBox(i))) return NULL;
    }
    return &m_row_2;
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreateAlgoComboBox(const int x)
{
  if(m_algo[x].Create(m_chart_id, m_name + "algo" + (string)x, m_subwin, 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT))
  {
    for(int i = 0; i < ArrayRange(settings, 0); i++)
    {
      if(settings[i][x] != NULL)
      {
        if(!m_algo[x].ItemAdd(settings[i][x])) return NULL;
      }
    }
    m_algo[x].Select(defaults[x]);
    return &m_algo[x];
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreatePlotRow(const long chart, const string name, const int subwin)
{
  m_row_plot.PaddingLeft(0);
  m_row_plot.PaddingRight(0);
  const int h = m_row_1.Height() + m_row_2.Height() + CONTROLS_BORDER_WIDTH * 4;
  m_row_plot.Alignment(WND_ALIGN_CLIENT, CONTROLS_BORDER_WIDTH * 2, h, CONTROLS_BORDER_WIDTH * 2, CONTROLS_BORDER_WIDTH * 2);

  if(m_row_plot.Create(chart, name + "plotrow", subwin, 0, 0, ClientAreaWidth(), LIST_HEIGHT)
  && m_row_plot.Add(CreatePlot(chart, name, subwin)))
  {
    return &m_row_plot;
  }
  return NULL;
}

CWnd *OLAPDialogBase::CreatePlot(const long chart, const string name, const int subwin)
{
  if(m_plot.Create(chart, name + "Plot", subwin, 0, 0, ClientAreaWidth(), ClientAreaHeight(), curveType))
  {
    return &m_plot;
  }
  return NULL;
}

bool OLAPDialogBase::OnChangeComboBoxAxis(const int x)
{
  if(browsing)
  {
    maxZ = 0;
    validateZ();
  }

  int selection = (int)m_axis[x].Value();
  for(int i = x + 1; i < AXES_NUMBER; i++)
  {
    if(selection > 0)
    {
      m_axis[i].Enable();
    }
    else
    {
      m_axis[i].Disable();
    }
    selection = (int)MathMin(selection, m_axis[i].Value());
  }

  /* Sorting is now enabled for ever, but sorting by _values_ for multidimensional data
     is not coherent (each curve is sorted on its own, so X marks mean nothing)
  int count = 0;
  for(int i = 0; i < AXES_NUMBER; i++)
  {
    count += ((int)m_axis[i].Value() > 0 ? 1 : 0) * (i + 1);
  }
  if(count == 1) m_algo[2].Enable(); // sorting
  else m_algo[2].Disable();
  */
  return true;
}

bool OLAPDialogBase::OnChangeComboBoxAlgo(const int i)
{
  if(browsing && i < 3)
  {
    maxZ = 0;
    validateZ();
  }

  if(i == ALGO_GRAPHTYPE)
  {
    curveType = (ENUM_CURVE_TYPE)(m_algo[i].Value());
    m_plot.SetDefaultCurveType(curveType);
    m_plot.Refresh(true);
  }
  else
  if(i == ALGO_AGGREGATOR)
  {
    AGGREGATORS a = (AGGREGATORS)(m_algo[i].Value());
    
    if(a == AGGREGATOR_IDENTITY || a == AGGREGATOR_COUNT)
    {
      m_algo[1].Disable();
    }
    else
    {
      m_algo[1].Enable();
    }
  }
  return true;
}

void OLAPDialogBase::OnClickButton(void)
{
  if(processing) return;
  
  if(browsing)
  {
    currentZ = (currentZ + 1) % maxZ;
    validateZ();
  }

  processing = true;
  const int n = process();
  if(n == 0 && processing)
  {
    finalize();
  }
}

void OLAPDialogBase::SelfAdjustment(const bool restore = false)
{
  CSize min = m_main.GetMinSize();
  CSize size;
  size.cx = ClientAreaWidth();
  size.cy = ClientAreaHeight();
  if(restore)
  {
    if(min.cx > size.cx) size.cx = min.cx;
    if(min.cy > size.cy) size.cy = min.cy;
  }
  m_main.Size(size);
  int w = (m_row_1.Width() - 2 * 2 * 2 * 3) / 4;
  for(int i = 0; i < AXES_NUMBER; i++)
  {
    m_axis[i].Width(w);
  }
  m_button_ok.Width(w);
  for(int i = 0; i < ALGO_NUMBER; i++)
  {
    m_algo[i].Width(w);
  }

  if(!restore)
  {
    m_plot.Size(size.cx - CONTROLS_BORDER_WIDTH * 16, size.cy - m_row_1.Height() - m_row_2.Height() - CONTROLS_BORDER_WIDTH * 16);
    m_plot.Resize(0, 0, size.cx - CONTROLS_BORDER_WIDTH * 16, size.cy - m_row_1.Height() - m_row_2.Height() - CONTROLS_BORDER_WIDTH * 16);
  }

  m_main.Pack();
  m_plot.Refresh();
}

void OLAPDisplay::display(MetaCube *metaData, const SORT_BY sortby = SORT_BY_NONE, const bool identity = false) override
{
  int consts[];
  const int selectorCount = metaData.getDimension();
  ArrayResize(consts, selectorCount);
  ArrayInitialize(consts, 0);

  if(selectorCount == 1)
  {
    PairArray *result;
    if(metaData.getVector(0, consts, result, sortby))
    {
      string title = metaData.getDimensionTitle(0);
      if(printout)
      {
        Print("===== " + title + " =====");
        ArrayPrint(result.array);
      }
      parent.accept1D(result, title);
    }
    parent.finalize();
    return;
  }
  
  int dimensions[];
  ArrayResize(dimensions, selectorCount);
  for(int i = 0; i < selectorCount; i++)
  {
    dimensions[i] = metaData.getDimensionRange(i);
  }

  if(selectorCount == 3)
  {
    PairArray *result;
    consts[0] = 0;
    consts[1] = 0;
    string s[];
    if(metaData.getVector(2, consts, result, SORT_BY_LABEL_ASCENDING))
    {
      result.convert(s);
      parent.registerZ(s);
      delete result;
    }

    ArrayInitialize(consts, 0);
  }
  
  if(selectorCount >= 2)
  {
    int z = parent.getCurrentZ();
    if((dimensions[1] == 2) && identity)
    {
      double x[];
      double y[];
      PairArray *result;
      consts[1] = 0;
      if(selectorCount == 3) consts[2] = z; // this has no effect yet because of identity
      if(metaData.getVector(0, consts, result, sortby)) // SORT_BY_NONE
      {
        if(printout)
        {
          Print("===== " + metaData.getDimensionTitle(-(1)) + " =====");
          ArrayPrint(result.array);
        }
        result.convert(x);
        delete result;
      }
      consts[1] = 1;
      if(selectorCount == 3) consts[2] = z; // this has no effect yet because of identity
      if(metaData.getVector(0, consts, result, sortby)) // SORT_BY_NONE
      {
        if(printout)
        {
          Print("===== " + metaData.getDimensionTitle(-(2)) + " =====");
          ArrayPrint(result.array);
        }
        result.convert(y);
        delete result;
      }
      parent.accept2D(x, y, metaData.getDimensionTitle(-(1)) + " vs " + metaData.getDimensionTitle(-(2)));
    }
    else
    {
      // NB: identity aggregator is always 2D cube: [record number][selected fields number]
      // we need special handling for it
      if(selectorCount == 3)
      {
        consts[2] = z;
      }
      for(int j = 0; j < dimensions[1]; j++)
      {
        consts[1] = j;
        PairArray *result;
        if(metaData.getVector(0, consts, result, sortby)) // SORT_BY_NONE - only labels sorting is valid!
        {
          string title = NULL;
          if(identity)
          {
            title = metaData.getDimensionTitle(-(j + 1));
          }
          if(printout)
          {
            Print("===== " + (identity ? title : metaData.getDimensionIndexLabel(1, j)) + " =====");
            ArrayPrint(result.array);
          }
          parent.accept1D(result, (identity ? title : metaData.getDimensionIndexLabel(1, j)));
        }
      }
    }
    parent.finalize();
  }
}


void OLAPDialogBase::registerZ(const string &titles[])
{
  if(!browsing)
  {
    maxZ = ArraySize(titles);
    ArrayResize(titlesZ, maxZ); // shrink if necessary
    ArrayCopy(titlesZ, titles);
    currentZ = 0;
  }
}

void OLAPDialogBase::validateZ()
{
  if(maxZ > 0)
  {
    string switcher = StringFormat("%d/%d %s >>", currentZ + 1, maxZ, titlesZ[currentZ]);
    Print("Current Z: ", switcher);
    m_button_ok.Text(switcher);
    browsing = true;
  }
  else
  {
    m_button_ok.Text("Process");
    browsing = false;
  }
}

void OLAPDialogBase::accept1D(const PairArray *data, const string title)
{
  m_plot.CurveAdd(data, title);
}

void OLAPDialogBase::accept2D(const double &x[], const double &y[], const string title)
{
  m_plot.CurveAdd(x, y, title);
}

void OLAPDialogBase::finalize()
{
  m_plot.Refresh();
  processing = false;
  m_button_ok.Text("Process");
  validateZ();
}
