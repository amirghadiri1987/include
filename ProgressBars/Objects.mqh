//+------------------------------------------------------------------+
//|                                                      Objects.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Enums.mqh"
#include "Defines.mqh"
#include <ChartObjects/ChartObjectsBmpControls.mqh>
#include <ChartObjects/ChartObjectsTxtControls.mqh>
//--- List of classes in file for a quick navigation (Alt+G)
class CRectLabel;
class CEdit;
class CLabel;
class CBmpLabel;
class CButton;
//+------------------------------------------------------------------+
//| Class with additional properties for the Rectangle Label object  |
//+------------------------------------------------------------------+
class CRectLabel : public CChartObjectRectLabel
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
public:
                     CRectLabel(void);
                    ~CRectLabel(void);
   //--- Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Indents from the edge point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Sizes
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRectLabel::CRectLabel(void) : m_x(0),
                               m_y(0),
                               m_x2(0),
                               m_y2(0),
                               m_x_gap(0),
                               m_y_gap(0),
                               m_x_size(0),
                               m_y_size(0),
                               m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRectLabel::~CRectLabel(void)
  {
  }
//+------------------------------------------------------------------+
//| Class with additional properties for the Edit object             |
//+------------------------------------------------------------------+
class CEdit : public CChartObjectEdit
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
public:
                     CEdit(void);
                    ~CEdit(void);
   //--- Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Indents from the edge point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Sizes
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEdit::CEdit(void) : m_x(0),
                     m_y(0),
                     m_x2(0),
                     m_y2(0),
                     m_x_gap(0),
                     m_y_gap(0),
                     m_x_size(0),
                     m_y_size(0),
                     m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CEdit::~CEdit(void)
  {
  }
//+------------------------------------------------------------------+
//| Class with additional properties for the Label object            |
//+------------------------------------------------------------------+
class CLabel : public CChartObjectLabel
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
public:
                     CLabel(void);
                    ~CLabel(void);
   //--- Coordinates
   int               X(void)                 { return(m_x);           }
   void              X(const int x)          { m_x=x;                 }
   int               Y(void)                 { return(m_y);           }
   void              Y(const int y)          { m_y=y;                 }
   int               X2(void)                { return(m_x+m_x_size);  }
   int               Y2(void)                { return(m_y+m_y_size);  }
   //--- Indents from the edge point (xy)
   int               XGap(void)              { return(m_x_gap);       }
   void              XGap(const int x_gap)   { m_x_gap=x_gap;         }
   int               YGap(void)              { return(m_y_gap);       }
   void              YGap(const int y_gap)   { m_y_gap=y_gap;         }
   //--- Sizes
   int               XSize(void)             { return(m_x_size);      }
   void              XSize(const int x_size) { m_x_size=x_size;       }
   int               YSize(void)             { return(m_y_size);      }
   void              YSize(const int y_size) { m_y_size=y_size;       }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLabel::CLabel(void) : m_x(0),
                       m_y(0),
                       m_x2(0),
                       m_y2(0),
                       m_x_gap(0),
                       m_y_gap(0),
                       m_x_size(0),
                       m_y_size(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLabel::~CLabel(void)
  {
  }
//+------------------------------------------------------------------+
//| Class with additional properties for the Bmp Label object        |
//+------------------------------------------------------------------+
class CBmpLabel : public CChartObjectBmpLabel
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
public:
                     CBmpLabel(void);
                    ~CBmpLabel(void);
   //--- Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Indents from the edge point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Sizes
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBmpLabel::CBmpLabel(void) : m_x(0),
                             m_y(0),
                             m_x2(0),
                             m_y2(0),
                             m_x_gap(0),
                             m_y_gap(0),
                             m_x_size(0),
                             m_y_size(0),
                             m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBmpLabel::~CBmpLabel(void)
  {
  }
//+------------------------------------------------------------------+
//| Class with additional properties for the Edit object             |
//+------------------------------------------------------------------+
class CButton : public CChartObjectButton
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
public:
                     CButton(void);
                    ~CButton(void);
   //--- Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Indents from the edge point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Sizes
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CButton::CButton(void) : m_x(0),
                         m_y(0),
                         m_x2(0),
                         m_y2(0),
                         m_x_gap(0),
                         m_y_gap(0),
                         m_x_size(0),
                         m_y_size(0),
                         m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CButton::~CButton(void)
  {
  }
//+------------------------------------------------------------------+
