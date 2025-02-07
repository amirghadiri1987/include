//+------------------------------------------------------------------+
//| Class CProgressBar                                               |
//| Purpose: Creates a customizable progress bar using the           |
//|          CChartObjectRectLabel as the underlying object.         |
//+------------------------------------------------------------------+
#include <Controls/Panel.mqh>


class CProgressBar : public CPanel
{
private:
  CChartObjectRectLabel m_ProgressForm;
  CChartObjectRectLabel m_ProgressBars;

public:
  CProgressBar();
  ~CProgressBar();

  bool      CreateProgressBars(const long id, const string name, const int subwin, const int x, const int y, const int width, const int height,const color Bcg);
  bool      CreateArea(const long id, const string name, const int subwin, const int x, const int y, const int width, const int height,const color Fg);
  void SetSize(int x) {m_ProgressBars.X_Size(x);}

protected:
  virtual bool OnResize();
  virtual bool OnMove();
};

CProgressBar::CProgressBar()
{
}

CProgressBar::~CProgressBar()
{
}



bool CProgressBar::CreateProgressBars(const long id, const string name, const int subwin, const int x, const int y, const int width, const int height,const color Bcg)
{
  if (!CPanel::Create(id, name, subwin, x+2, y+2, width-4, height-4))
    return false;
  if (!m_ProgressBars.Create(id,name,subwin,x+2, y+2, width-4, height-4))
    return false;
  if(!m_ProgressBars.Color(clrNONE))
    return false;
  if(!m_ProgressBars.BackColor(Bcg))
    return false;
  if(!m_ProgressBars.BorderType(BORDER_FLAT))
    return false;
  
  return true;
}


bool CProgressBar::CreateArea(const long id, const string name, const int subwin, const int x, const int y, const int width, const int height,const color Fg)
{
  if (!CPanel::Create(id, name, subwin, x, y, width, height))
    return false;

  if (!m_ProgressForm.Create(id,name,subwin,x,y,width,height))
    return false;

  if(!m_ProgressForm.Color(Fg))
    return false;
  if(!m_ProgressForm.BackColor(clrNONE))
    return false;
  if(!m_ProgressForm.BorderType(BORDER_FLAT))
    return false;
  if(!m_ProgressForm.Style(STYLE_SOLID))
    return false;
  return true;
}


//+------------------------------------------------------------------+
//| Absolute movement of the chart object                            |
//+------------------------------------------------------------------+
bool CProgressBar::OnMove() {
  m_ProgressBars.X_Distance(m_rect.left);
  m_ProgressBars.Y_Distance(m_rect.top);
  return(m_ProgressForm.X_Distance(m_rect.left) && m_ProgressForm.Y_Distance(m_rect.top));
}

//+------------------------------------------------------------------+
//| Resize the chart object                                          |
//+------------------------------------------------------------------+
bool CProgressBar::OnResize() {

  m_ProgressBars.X_Size(m_rect.Width());
  m_ProgressBars.Y_Size(m_rect.Height());
  return(m_ProgressForm.X_Size(m_rect.Width()) && m_ProgressForm.Y_Size(m_rect.Height()));
}











