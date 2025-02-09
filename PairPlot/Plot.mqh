//+------------------------------------------------------------------+
//|                                                         Plot.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2019-2020, Marketeer"
#property link "https://www.mql5.com/en/users/marketeer"
#property version "1.1"

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

class AxisCustomizer;

class CGraphicInPlot: public CGraphic
{
  protected:
    long m_chart_id; // chart ID
    CurveSubtitles curvecache[];

    void Customize(CCurve *c, const int points);
    CCurve *CacheIt(const CCurve *c, const PairArray *data = NULL);
    bool isZero(const string &value);
    void InitAxes(CAxis &axe, const AxisCustomizer *custom = NULL);

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
    
    void InitXAxis(const AxisCustomizer *custom = NULL); // const bool custom
    void InitYAxis(const AxisCustomizer *custom = NULL); // const bool custom
    
    virtual void HistogramPlot(CCurve *curve) override;
    virtual void LinesPlot(CCurve *curve) override;
    virtual void CreateGrid(void) override;
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/* use this to support X/Y marks customization */
class AxisCustomizer
{
  public:
    const CGraphicInPlot *parent;
    const bool y; // true for Y, false for X
    const bool periodDivider;
    const bool hide;
    const bool identity;
    AxisCustomizer(const CGraphicInPlot *p, const bool axisY,
      const bool pd = false, const bool h = false, const bool id = false):
      parent(p), y(axisY), periodDivider(pd), hide(h), identity(id) {}
};

string CustomDoubleToStringFunction(double value, void *ptr)
{
  AxisCustomizer *custom = dynamic_cast<AxisCustomizer *>(ptr);
  if(custom == NULL) return NULL;
  
  if(!custom.y && custom.hide) return NULL; // hide X marks
  if(custom.y) return (string)(float)value;

  const CGraphicInPlot *self = custom.parent;
  if(self != NULL)
  {
    if(self.cacheSize() > 0)
    {
      const int index = (int)NormalizeDouble(value, 0);
      if(MathAbs(NormalizeDouble(index, 8) - NormalizeDouble(value, 8)) <= 0.0000001)
      {
        const CurveSubtitles *s = self.cacheItem(0);
        if(s.data == NULL)
        {
          return (string)index;
        }
        if(index < 0 || index >= ArraySize(s.data.array)) return NULL;
        return s.data.array[index].title;
      }
    }
  }
  if(custom.identity) return (string)(float)value;
  return NULL;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGraphicInPlot::CGraphicInPlot()
{
}

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

void CGraphicInPlot::InitAxes(CAxis &axe, const AxisCustomizer *custom = NULL)
{
  if(custom)
  {
    axe.Type(AXIS_TYPE_CUSTOM);
    axe.ValuesFunctionFormat(CustomDoubleToStringFunction);
    axe.ValuesFunctionFormatCBData((AxisCustomizer *)custom);
  }
  else
  {
    axe.Type(AXIS_TYPE_DOUBLE);
  }
}

void CGraphicInPlot::InitXAxis(const AxisCustomizer *custom = NULL)
{
  InitAxes(m_x, custom);
}

void CGraphicInPlot::InitYAxis(const AxisCustomizer *custom = NULL)
{
  InitAxes(m_y, custom);
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
  int w = MathMax(Width() / points / (points > 2 ? 4 : 8), 1);
  c.HistogramWidth(w);
  c.LinesWidth(3);
  c.PointsFill(true);
  c.LinesSmoothStep((int)CGraphic::CurvesTotal());
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
  data.convert(y, s); // , true - skip NaNs
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
    CArrayObj         m_arr_curves;
    CGraphicInPlot *m_graphic;
    ENUM_CURVE_TYPE type;
    uint i_text_color;
    CCurve *temp[];
    AxisCustomizer *m_customX;
    AxisCustomizer *m_customY;
  CAxis             m_x;                    // x axis
  CAxis             m_y;                    // y axis   

  public:
    CPlot();
    ~CPlot();

     CAxis            *XAxis(void) { return GetPointer(m_x); }
     CAxis            *YAxis(void) { return GetPointer(m_y); }

    bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2, const ENUM_CURVE_TYPE t = CURVE_HISTOGRAM);
    virtual void Destroy(const int reason = 0) override;
    bool Refresh(const bool enforce = false);
    bool SetTextColor(color value);
    const CGraphicInPlot *getGraphic(void) const
    {
      return m_graphic;
    }

    virtual bool Shift(const int dx, const int dy) override;

    virtual void GetSize(const int Sizename, const int symbolSiz, const int xAxis, const int yAxis) {
      m_graphic.HistoryNameWidth(Sizename); 
      m_graphic.HistorySymbolSize(symbolSiz); 
      m_graphic.GetSizeAxis(xAxis,yAxis);
      // m_graphic.GetSizStepXAxix(minX, maxX, stepX);
      // m_graphic.GetSizStepYAxix(minY, maxY, stepY);
      m_graphic.Redraw();
    };

    
    void SetXAxisStep(double minX, double maxX, double stepX) {m_graphic.GetSizStepXAxix(minX, maxX, stepX); m_graphic.Redraw();}
    void SetYAxisStep(double minY, double maxY, double stepY) {m_graphic.GetSizStepYAxix(minY, maxY, stepY); m_graphic.Redraw();}

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

    void InitXAxis(const AxisCustomizer *custom = NULL)
    {
      if(CheckPointer(m_graphic) != POINTER_INVALID)
      {
        if(CheckPointer(m_customX) != POINTER_INVALID) delete m_customX;
        m_customX = (AxisCustomizer *)custom;
        m_graphic.InitXAxis(custom);
      }
    }

    void InitYAxis(const AxisCustomizer *custom = NULL)
    {
      if(CheckPointer(m_graphic) != POINTER_INVALID)
      {
        if(CheckPointer(m_customY) != POINTER_INVALID) delete m_customY;
        m_customY = (AxisCustomizer *)custom;
        m_graphic.InitYAxis(custom);
      }
    }
protected:
  bool              m_xupdate;
  bool              m_yupdate;
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
  if(CheckPointer(m_customX) != POINTER_INVALID)
  {
    delete m_customX;
  }
  if(CheckPointer(m_customY) != POINTER_INVALID)
  {
    delete m_customY;
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
  if((CheckPointer(m_customY) != POINTER_INVALID) && m_customY.periodDivider)
  {
    for(int i = 0; i < ArraySize(data.array); i++)
    {
      data.array[i].value /= PeriodSeconds();
    }
  }
  
  return m_graphic.CurveAdd(data, type, name);
}

CCurve *CPlot::CurveAdd(const double &x[], const double &y[], const string name = NULL)
{
  if(CheckPointer(m_graphic) == POINTER_INVALID) return NULL;

  double _x[], _y[];
  bool subX = false, subY = false;
  
  if((CheckPointer(m_customX) != POINTER_INVALID) && m_customX.periodDivider)
  {
    ArrayCopy(_x, x);
    for(int i = 0; i < ArraySize(x); i++)
    {
      _x[i] /= PeriodSeconds();
    }
    subX = true;
  }

  if((CheckPointer(m_customY) != POINTER_INVALID) && m_customY.periodDivider)
  {
    ArrayCopy(_y, y);
    for(int i = 0; i < ArraySize(y); i++)
    {
      _y[i] /= PeriodSeconds();
    }
    subY = true;
  }
  
  if(subX)
  {
    if(subY)
    {
      return m_graphic.CurveAdd(_x, _y, type, name);
    }
    else
    {
      return m_graphic.CurveAdd(_x, y, type, name);
    }
  }
  else
  {
    if(subY)
    {
      return m_graphic.CurveAdd(x, _y, type, name);
    }
  }
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
            curve = m_graphic.CGraphic::CurveAdd(x, type, name);
          }
        }
        
        m_graphic.replaceInCache(index, curve);
        
        // axis does not yet calculated, it's done only during CurvePlotAll
        // so we can't automatically adjust histogram width
        // double range = (m_graphic.XAxis().Max() - m_graphic.XAxis().Min());
        // double data = (x[ArrayMaximum(x)] - x[ArrayMinimum(x)]);
        // int downsize =  (int)(range / data);
        const int points = ArraySize(x);
        curve.HistogramWidth(Width() / points / (points > 2 ? 4 : 8));
        curve.LinesWidth(3);
      }
    }
    ArrayResize(temp, 0);

    if(!m_graphic.CurvePlotAll()) return false;
    
    m_graphic.Update(false);

    ChartRedraw(m_chart_id);
    return true;
}

void CGraphicInPlot::HistogramPlot(CCurve *curve) override
{
    const int size = curve.Size();
    const double offset = curve.LinesSmoothStep() - 1;
    double x[], y[];

    int histogram_width = curve.HistogramWidth();
    if(histogram_width <= 0) return;
    
    curve.GetX(x);
    curve.GetY(y);

    if(ArraySize(x) == 0 || ArraySize(y) == 0) return;
    
    // this is a hack because CAxis::SelectAxisScale does not make proper adjustment
    // of "grace" margins when very few points are drawn, so points placed tightly
    // to boundaries and a lot of empty space left in the center
    const int w = m_width / size / (size > 2 ? 2 : 4) / CGraphic::CurvesTotal();
    const int t = CGraphic::CurvesTotal() / 2;
    const int half = ((CGraphic::CurvesTotal() + 1) % 2) * (w / 2);

    int originalY = m_height - m_down;
    int yc0 = ScaleY(0.0);

    uint clr = curve.Color();

    for(int i = 0; i < size; i++)
    {
      if(!MathIsValidNumber(x[i]) || !MathIsValidNumber(y[i])) continue;
      int xc = ScaleX(x[i]);
      int yc = ScaleY(y[i]);
      int xc1 = xc - histogram_width / 2 + (int)(offset - t) * w + half;
      int xc2 = xc + histogram_width / 2 + (int)(offset - t) * w + half;
      int yc1 = yc;
      int yc2 = (originalY > yc0 && yc0 > 0) ? yc0 : originalY;

      if(yc1 > yc2) yc2++;
      else yc2--;

      m_canvas.FillRectangle(xc1,yc1,xc2,yc2,clr);
    }
}

void CGraphicInPlot::LinesPlot(CCurve *curve) override
{
  int size;
  double x[],y[];

  size = curve.Size();
  curve.GetX(x);
  curve.GetY(y);
  if(ArraySize(x) == 0 || ArraySize(y) == 0) return;

  int xc[];
  int yc[];
  
  double tension = curve.LinesSmoothTension();
  ArrayResize(xc, size);
  ArrayResize(yc, size);
  int k = 0;
  for(int i = 0; i < size; i++)
  {
    if(!MathIsValidNumber(x[i]) || !MathIsValidNumber(y[i])) continue;
    xc[k] = ScaleX(x[i]);
    yc[k] = ScaleY(y[i]);
    k++;
  }
  
  size = k;
  ArrayResize(xc, size);
  ArrayResize(yc, size);

  if(curve.LinesSmooth() && size > 2 && tension > 0.0 && tension <= 1.0)
    m_canvas.PolylineSmooth(xc, yc, curve.Color(), curve.LinesWidth(), curve.LinesStyle(), curve.LinesEndStyle(), tension, curve.LinesSmoothStep());
  else
  if(size > 1)
    m_canvas.PolylineThick(xc, yc, curve.Color(), curve.LinesWidth(), curve.LinesStyle(), curve.LinesEndStyle());
  else
  if(size == 1)
     m_canvas.PixelSet(xc[0], yc[0], curve.Color());
}

bool CGraphicInPlot::isZero(const string &value)
{
    if(value == NULL) return false;
    double y = StringToDouble(value);
    if(y != 0.0) return false;
    string temp = value;
    StringReplace(temp, "0", "");
    ushort c = StringGetCharacter(temp, 0);
    return c == 0 || c == '.';
}

void CGraphicInPlot::CreateGrid(void) override
{
    int xc0 = -1.0;
    int yc0 = -1.0;
    for(int i = 1; i < m_ysize - 1; i++)
    {
      m_canvas.LineHorizontal(m_left + 1, m_width - m_right, m_yc[i], m_grid.clr_line);
      if(isZero(m_yvalues[i])) yc0 = m_yc[i];

      for(int j = 1; j < m_xsize - 1; j++)
      {
        if(i == 1)
        {
          m_canvas.LineVertical(m_xc[j], m_height - m_down - 1, m_up + 1, m_grid.clr_line);
          if(isZero(m_xvalues[j])) xc0 = m_xc[j];
        }

        if(m_grid.has_circle)
        {
          m_canvas.FillCircle(m_xc[j], m_yc[i], m_grid.r_circle, m_grid.clr_circle);
          m_canvas.CircleWu(m_xc[j], m_yc[i], m_grid.r_circle, m_grid.clr_circle);
        }
      }
    }

    if(yc0 > 0) m_canvas.LineHorizontal(m_left + 1, m_width - m_right, yc0, m_grid.clr_axis_line);
    if(xc0 > 0) m_canvas.LineVertical(xc0, m_height - m_down - 1, m_up + 1, m_grid.clr_axis_line);
}
