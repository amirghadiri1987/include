//+------------------------------------------------------------------+
//|                                                         Plot.mqh |
//|                                    Copyright (c) 2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2019, Marketeer"
#property link "https://www.mql5.com/en/users/marketeer"
#property version "1.0"

#include <Controls\WndClient.mqh>
#include <Graphics\Graphic.mqh>
#include <OLAP/PairArray.mqh>

class CurveSubtitles
{
  public:
    CCurve *curve;
    PairArray *data;

    void assign(const CCurve *c, const PairArray *d)
    {
      curve = (CCurve *)c;
      data = (PairArray *)d;
    }
};

class CGraphicInPlot: public CGraphic
{
  protected:
    long m_chart_id; // chart ID
    CurveSubtitles curvecache[];

    void CGraphicInPlot::Customize(CCurve *c, const int points);
    CCurve *CGraphicInPlot::CacheIt(const CCurve *c, const PairArray *data = NULL);

  public:
    CGraphicInPlot();
    ~CGraphicInPlot();

    virtual bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
    
    CCurve *CurveAdd(const PairArray *data, ENUM_CURVE_TYPE type, const string name = NULL); // overload
    CCurve *CurveAdd(const double &x[], const double &y[], ENUM_CURVE_TYPE type, const string name = NULL); // overload

    void CurvesRemoveAll(void);
    
    virtual bool Shift(const int dx, const int dy);

    virtual bool Show(void);
    virtual bool Hide(void);

    void Destroy(void);
    void ResetColors(void);
    CCurve *CurveDetach(const int index);
    bool CurveAttach(CCurve *curve);

    int getIndexInCache(CCurve *c);
    void replaceInCache(const int index, CCurve *c);
    
    int cacheSize() const
    {
      return ArraySize(curvecache);
    }
    
    const CurveSubtitles *cacheItem(const int index) const
    {
      return &curvecache[index];
    }
    
    void InitXAxis(const bool custom);
    void InitYAxis(const bool custom);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string CustomDoubleToStringFunction(double value, void *ptr)
{
  CGraphicInPlot *self = dynamic_cast<CGraphicInPlot *>(ptr);
  if(self != NULL)
  {
    if(self.cacheSize() > 0)
    {
      const int index = (int)value;
      if(MathAbs(((double)index) - value) <= DBL_EPSILON)
      {
        const CurveSubtitles *s = self.cacheItem(0);
        if(index < 0 || index >= ArraySize(s.data.array)) return NULL; // (string)(float)value; // debug
        return s.data.array[index].title;
      }
    }
  }
  return NULL;
}

CGraphicInPlot::CGraphicInPlot()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGraphicInPlot::~CGraphicInPlot()
{
  CurvesRemoveAll();
}

void CGraphicInPlot::Destroy(void)
{
  m_generator.Reset();
  m_canvas.Destroy();
}

void CGraphicInPlot::ResetColors(void)
{
  m_generator.Reset();
}

/* TODO: enable this to support Y marks customization
class AxisCustomizer
{
  public:
    const bool Y; // true for Y, false for X (default)
    const CGraphicInPlot *parent;
    AxisCustomizer(const bool axisY, CGraphicInPlot *p): Y(axisY), parent(p) {}
};
*/

void CGraphicInPlot::InitXAxis(const bool custom)
{
  if(custom)
  {
    m_x.Type(AXIS_TYPE_CUSTOM);
    m_x.ValuesFunctionFormat(CustomDoubleToStringFunction);
    m_x.ValuesFunctionFormatCBData(&this);
  }
  else
  {
    m_x.Type(AXIS_TYPE_DOUBLE);
  }
}

void CGraphicInPlot::InitYAxis(const bool custom)
{
  if(custom)
  {
    m_y.Type(AXIS_TYPE_CUSTOM);
    m_y.ValuesFunctionFormat(CustomDoubleToStringFunction);
    m_y.ValuesFunctionFormatCBData(&this);
  }
  else
  {
    m_y.Type(AXIS_TYPE_DOUBLE);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicInPlot::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
    if(!CGraphic::Create(chart, name, subwin, x1, y1, x2, y2)) return false;
    m_chart_id = chart;
    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicInPlot::Show(void)
{
    string obj_name = ChartObjectName();
    if(obj_name == NULL || ObjectFind(m_chart_id, obj_name) < 0) return false;
    if(!ObjectSetInteger(m_chart_id, obj_name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS)) return false;
    Update(false);
    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicInPlot::Hide(void)
{
    string obj_name = ChartObjectName();
    if(obj_name == NULL || ObjectFind(m_chart_id, obj_name) < 0) return false;
    return ObjectSetInteger(m_chart_id, obj_name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicInPlot::Shift(const int dx, const int dy)
{
    string obj_name = ChartObjectName();
    if(obj_name == NULL || ObjectFind(m_chart_id, obj_name) < 0) return false;

    int x = (int)ObjectGetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE) + dx;
    int y = (int)ObjectGetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE) + dy;
    if(!ObjectSetInteger(m_chart_id, obj_name, OBJPROP_XDISTANCE, x)) return false;
    if(!ObjectSetInteger(m_chart_id, obj_name, OBJPROP_YDISTANCE, y)) return false;

    return true;
}

CCurve *CGraphicInPlot::CurveDetach(const int index)
{
  return m_arr_curves.Detach(index);
}

bool CGraphicInPlot::CurveAttach(CCurve *curve)
{
  return m_arr_curves.Add(curve);
}

void CGraphicInPlot::Customize(CCurve *c, const int points)
{
  int w = MathMax(Width() / points / 4, 1);
  c.HistogramWidth(w);
  c.LinesWidth(3);
  c.PointsFill(true);
}

CCurve *CGraphicInPlot::CacheIt(const CCurve *c, const PairArray *data = NULL)
{
  int n = ArraySize(curvecache);
  ArrayResize(curvecache, n + 1);
  curvecache[n].assign(c, data);
  return (CCurve *)c;
}

CCurve *CGraphicInPlot::CurveAdd(const PairArray *data, ENUM_CURVE_TYPE type, const string name = NULL)
{
  double y[];
  string s[];
  data.convert(y, s);
  CCurve *c = CGraphic::CurveAdd(y, type, name);
  Customize(c, ArraySize(y));
  
  return CacheIt(c, data);
}

CCurve *CGraphicInPlot::CurveAdd(const double &x[], const double &y[], ENUM_CURVE_TYPE type, const string name = NULL)
{
  CCurve *c = CGraphic::CurveAdd(x, y, type, name);
  Customize(c, ArraySize(x));

  return CacheIt(c);
}

int CGraphicInPlot::getIndexInCache(CCurve *c)
{
  int n = ArraySize(curvecache);
  for(int i = 0; i < n; i++)
  {
    if(curvecache[i].curve == c) return i;
  }
  return -1;
}

void CGraphicInPlot::replaceInCache(const int index, CCurve *c)
{
  curvecache[index].curve = c;
}

void CGraphicInPlot::CurvesRemoveAll(void)
{
  int n = m_arr_curves.Total();
  for(int i = n - 1; i >= 0; i--)
  {
    CurveRemoveByIndex(i);
  }
  n = ArraySize(curvecache);
  for(int i = n - 1; i >= 0; i--)
  {
    if(CheckPointer(curvecache[i].data) == POINTER_DYNAMIC) delete curvecache[i].data;
  }
  ArrayResize(curvecache, 0);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPlot: public CWndClient
{
  private:
    CGraphicInPlot *m_graphic;
    ENUM_CURVE_TYPE type;
    uint i_text_color;
    CCurve *temp[];

  public:
    CPlot();
    ~CPlot();

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2, const ENUM_CURVE_TYPE t = CURVE_HISTOGRAM);
    virtual void Destroy(const int reason = 0) override;
    bool Refresh(const bool enforce = false);
    bool SetTextColor(color value);

    virtual bool Shift(const int dx, const int dy) override;

    virtual bool Show(void);
    virtual bool Hide(void);
    
    bool Resize(const int x1, const int y1, const int x2, const int y2);
    
    CCurve *CurveAdd(const PairArray *data, const string name = NULL);
    CCurve *CurveAdd(const double &x[], const double &y[], const string name = NULL);

    void CurvesRemoveAll(void);
    
    void SetDefaultCurveType(ENUM_CURVE_TYPE t)
    {
      type = t;
    }

    void InitXAxis(const bool custom)
    {
      if(CheckPointer(m_graphic) != POINTER_INVALID)
      {
        m_graphic.InitXAxis(custom);
      }
    }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPlot::CPlot():
    type(CURVE_HISTOGRAM), i_text_color(ColorToARGB(clrBlack, 255))
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPlot::~CPlot()
{
    if(CheckPointer(m_graphic) != POINTER_INVALID)
    {
        m_graphic.Destroy();
        delete m_graphic;
    }
}

void CPlot::Destroy(const int reason = 0)
{
  if(CheckPointer(m_graphic) != POINTER_INVALID)
  {
      m_graphic.Destroy();
      delete m_graphic;
      m_graphic = NULL;
  }
  CWndClient::Destroy(reason);
}

CCurve *CPlot::CurveAdd(const PairArray *data, const string name = NULL)
{
  if(CheckPointer(m_graphic) == POINTER_INVALID) return NULL;
  return m_graphic.CurveAdd(data, type, name);
}

CCurve *CPlot::CurveAdd(const double &x[], const double &y[], const string name = NULL)
{
  if(CheckPointer(m_graphic) == POINTER_INVALID) return NULL;
  return m_graphic.CurveAdd(x, y, type, name);
}

void CPlot::CurvesRemoveAll(void)
{
  m_graphic.CurvesRemoveAll();
  m_graphic.ResetColors();
}

bool CPlot::Resize(const int x1, const int y1, const int x2, const int y2)
{
    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;

    int width = Width();
    int height = Height();
    Size(x2 - x1, y2 - y1);
    
    string obj_name = m_name + "_0_0";
    int obj_x1 = m_rect.left;
    int obj_x2 = obj_x1 + width;
    int obj_y1 = m_rect.top;
    int obj_y2 = obj_y1 + height;

    m_graphic.Destroy();
    if(!m_graphic.Create(m_chart_id, obj_name, m_subwin, obj_x1, obj_y1, obj_x2, obj_y2))
    {
        Print(GetLastError());
        return false;
    }
    
    for(int i = 0; i < ArraySize(temp); ++i)
    {
      if(CheckPointer(temp[i]) == POINTER_DYNAMIC) delete temp[i];
    }
    
    ArrayResize(temp, m_graphic.CurvesTotal());

    // Graphic library does not provide a method to update curve without array copying
    for(int i = m_graphic.CurvesTotal() - 1; i >= 0; --i)
    {
      temp[i] = m_graphic.CurveDetach(i);
    }

    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlot::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2, const ENUM_CURVE_TYPE t = CURVE_HISTOGRAM)
{
    if(!CWndClient::Create(chart, name, subwin, x1, y1, x2, y2)) return false;
    type = t;

    int width = Width();
    int height = Height();

    string obj_name = m_name + "_0_0";
    int obj_x1 = m_rect.left;
    int obj_x2 = obj_x1 + width;
    int obj_y1 = m_rect.top;
    int obj_y2 = obj_y1 + height;

    m_graphic = new CGraphicInPlot();
    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;
    if(!m_graphic.Create(m_chart_id, obj_name, m_subwin, obj_x1, obj_y1, obj_x2, obj_y2)) return false;

    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlot::Hide(void)
{
    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;
    if(!m_graphic.Hide()) return false;

    return CWndClient::Hide();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlot::Show(void)
{
    if(!CWndClient::Show()) return false;

    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;
    if(m_graphic.Show()) return false;

    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CPlot::Shift(const int dx, const int dy)
{
    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;
    if(!m_graphic.Shift(dx, dy)) return false;

    return CWndClient::Shift(dx, dy);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPlot::Refresh(const bool enforce = false)
{
    if(CheckPointer(m_graphic) == POINTER_INVALID) return false;
    
    if(ArraySize(temp) == 0 && enforce)
    {
      m_graphic.ResetColors();
      ArrayResize(temp, m_graphic.CurvesTotal());
      for(int i = m_graphic.CurvesTotal() - 1; i >= 0; --i)
      {
        temp[i] = m_graphic.CurveDetach(i);
      }
    }
    
    for(int i = 0; i < ArraySize(temp); ++i)
    {
      if(CheckPointer(temp[i]) == POINTER_DYNAMIC)
      {
        double x[], y[];
        temp[i].GetX(x);
        temp[i].GetY(y);
        string name = temp[i].Name();
        
        int index = m_graphic.getIndexInCache(temp[i]);
        
        delete temp[i];
        CCurve *curve = NULL;
        if(ArraySize(x) > 0)
        {
          if(ArraySize(y) > 0)
          {
            curve = m_graphic.CurveAdd(x, y, type, name);
          }
          else
          {
            curve = m_graphic.CurveAdd(x, type, name);
          }
        }
        
        m_graphic.replaceInCache(index, curve);
        
        // axis does not yet calculated, it's done only during CurvePlotAll
        // so we can't automatically adjust histogram width
        // double range = (m_graphic.XAxis().Max() - m_graphic.XAxis().Min());
        // double data = (x[ArrayMaximum(x)] - x[ArrayMinimum(x)]);
        // int downsize =  (int)(range / data);
        curve.HistogramWidth(Width() / ArraySize(x) / 4);
        curve.LinesWidth(3);
      }
    }
    ArrayResize(temp, 0);

    if(!m_graphic.CurvePlotAll()) return false;
    
    m_graphic.Update(false);

    ChartRedraw(m_chart_id);
    return true;
}
