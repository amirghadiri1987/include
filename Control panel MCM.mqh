//+------------------------------------------------------------------+
//|                                            Control panel MCM.mq5 |
//|                                            Copyright 2010, Lizar |
//|                            https://login.mql5.com/ru/users/Lizar |
//|                                              Revision 2010.12.09 |
//+------------------------------------------------------------------+

enum ENUM_CHART_EVENT_SYMBOL
  {
   CHARTEVENT_NEWBAR_NO =0, // No events
   
   CHARTEVENT_NEWBAR_M1 =0x00000001, // "New bar" event on M1 chart
   CHARTEVENT_NEWBAR_M2 =0x00000002, // "New bar" event on M2 chart
   CHARTEVENT_NEWBAR_M3 =0x00000004, // "New bar" event on M3 chart
   CHARTEVENT_NEWBAR_M4 =0x00000008, // "New bar" event on M4 chart
   
   CHARTEVENT_NEWBAR_M5 =0x00000010, // "New bar" event on M5 chart
   CHARTEVENT_NEWBAR_M6 =0x00000020, // "New bar" event on M6 chart
   CHARTEVENT_NEWBAR_M10=0x00000040, // "New bar" event on M10 chart
   CHARTEVENT_NEWBAR_M12=0x00000080, // "New bar" event on M12 chart
   
   CHARTEVENT_NEWBAR_M15=0x00000100, // "New bar" event on M15 chart
   CHARTEVENT_NEWBAR_M20=0x00000200, // "New bar" event on M20 chart
   CHARTEVENT_NEWBAR_M30=0x00000400, // "New bar" event on M30 chart
   CHARTEVENT_NEWBAR_H1 =0x00000800, // "New bar" event on H1 chart
   
   CHARTEVENT_NEWBAR_H2 =0x00001000, // "New bar" event on H2 chart
   CHARTEVENT_NEWBAR_H3 =0x00002000, // "New bar" event on H3 chart
   CHARTEVENT_NEWBAR_H4 =0x00004000, // "New bar" event on H4 chart
   CHARTEVENT_NEWBAR_H6 =0x00008000, // "New bar" event on H6 chart
   
   CHARTEVENT_NEWBAR_H8 =0x00010000, // "New bar" event on H8 chart
   CHARTEVENT_NEWBAR_H12=0x00020000, // "New bar" event on H12 chart
   CHARTEVENT_NEWBAR_D1 =0x00040000, // "New bar" event on D1 chart
   CHARTEVENT_NEWBAR_W1 =0x00080000, // "New bar" event on W1 chart
     
   CHARTEVENT_NEWBAR_MN1=0x00100000, // "New bar" event on MN chart
   CHARTEVENT_TICK      =0x00200000, // "New tick" event
   
   CHARTEVENT_ALL       =0xFFFFFFFF, // All events
  };

string EventDescription(long event)
  {
   ENUM_CHART_EVENT_SYMBOL event_current=(ENUM_CHART_EVENT_SYMBOL)event;
   
   switch(event_current)
     {
      case CHARTEVENT_NEWBAR_NO: return(" Initialization "); // Initialization
      
      case CHARTEVENT_NEWBAR_M1: return(" M1 ");  // "New bar" event on M1 chart
      case CHARTEVENT_NEWBAR_M2: return(" M2 ");  // "New bar" event on M2 chart
      case CHARTEVENT_NEWBAR_M3: return(" M3 ");  // "New bar" event on M3 chart
      case CHARTEVENT_NEWBAR_M4: return(" M4 ");  // "New bar" event on M4 chart
      
      case CHARTEVENT_NEWBAR_M5: return(" M5 ");  // "New bar" event on M5 chart
      case CHARTEVENT_NEWBAR_M6: return(" M6 ");  // "New bar" event on M6 chart
      case CHARTEVENT_NEWBAR_M10:return(" M10 "); // "New bar" event on M10 chart
      case CHARTEVENT_NEWBAR_M12:return(" M12 "); // "New bar" event on M12 chart
      
      case CHARTEVENT_NEWBAR_M15:return(" M15 "); // "New bar" event on M15 chart
      case CHARTEVENT_NEWBAR_M20:return(" M20 "); // "New bar" event on M20 chart
      case CHARTEVENT_NEWBAR_M30:return(" M30 "); // "New bar" event on M30 chart
      case CHARTEVENT_NEWBAR_H1: return(" H1 ");  // "New bar" event on H1 chart
      
      case CHARTEVENT_NEWBAR_H2: return(" H2 ");  // "New bar" event on H2 chart
      case CHARTEVENT_NEWBAR_H3: return(" H3 ");  // "New bar" event on H3 chart
      case CHARTEVENT_NEWBAR_H4: return(" H4 ");  // "New bar" event on H4 chart
      case CHARTEVENT_NEWBAR_H6: return(" H6 ");  // "New bar" event on H6 chart
      
      case CHARTEVENT_NEWBAR_H8: return(" H8 ");  // "New bar" event on H8 chart
      case CHARTEVENT_NEWBAR_H12:return(" H12 "); // "New bar" event on H12 chart
      case CHARTEVENT_NEWBAR_D1: return(" D1 ");  // "New bar" event on D1 chart
      case CHARTEVENT_NEWBAR_W1: return(" W1 ");  // "New bar" event on W1 chart
        
      case CHARTEVENT_NEWBAR_MN1:return(" MN1 ");  // "New bar" event on MN chart
      case CHARTEVENT_TICK      :return(" tick "); // "New tick" event
      default: return(" Unknown event "); 
     }
   return(" Unknown event ");     
  }
  
ENUM_TIMEFRAMES EventToPeriod(long event)
  {
   ENUM_CHART_EVENT_SYMBOL event_current=(ENUM_CHART_EVENT_SYMBOL)event;
   
   switch(event_current)
     {
      case CHARTEVENT_NEWBAR_M1: return(PERIOD_M1);  
      case CHARTEVENT_NEWBAR_M2: return(PERIOD_M2);  
      case CHARTEVENT_NEWBAR_M3: return(PERIOD_M3);  
      case CHARTEVENT_NEWBAR_M4: return(PERIOD_M4);  
      
      case CHARTEVENT_NEWBAR_M5: return(PERIOD_M5);  
      case CHARTEVENT_NEWBAR_M6: return(PERIOD_M6);  
      case CHARTEVENT_NEWBAR_M10:return(PERIOD_M10); 
      case CHARTEVENT_NEWBAR_M12:return(PERIOD_M12); 
      
      case CHARTEVENT_NEWBAR_M15:return(PERIOD_M15); 
      case CHARTEVENT_NEWBAR_M20:return(PERIOD_M20); 
      case CHARTEVENT_NEWBAR_M30:return(PERIOD_M30);
      case CHARTEVENT_NEWBAR_H1: return(PERIOD_H1);  
      
      case CHARTEVENT_NEWBAR_H2: return(PERIOD_H2);  
      case CHARTEVENT_NEWBAR_H3: return(PERIOD_H3); 
      case CHARTEVENT_NEWBAR_H4: return(PERIOD_H4); 
      case CHARTEVENT_NEWBAR_H6: return(PERIOD_H6); 
      
      case CHARTEVENT_NEWBAR_H8: return(PERIOD_H8);  
      case CHARTEVENT_NEWBAR_H12:return(PERIOD_H12); 
      case CHARTEVENT_NEWBAR_D1: return(PERIOD_D1); 
      case CHARTEVENT_NEWBAR_W1: return(PERIOD_W1); 
        
      case CHARTEVENT_NEWBAR_MN1:return(PERIOD_MN1);
      default: return(PERIOD_CURRENT); 
     }
   return(PERIOD_CURRENT);     
  }

  
#define MSG_CONTROL_PANEL_MCM "MCM Control panel for multicurrency mode "
#define MSG_EVENT             "Waiting for event... "
#define MSG_SELECT_SYMBOL     "Select symbols for multicurrency mode "
#define MSG_SYMBOL_CHANGE     "The number of symbols in Market Watch has changed "
#define MSG_HELP              "Help - brief information about program "
#define MSG_SYMBOL_PERIOD     "Set symbol and period for the currenct chart "
#define MSG_ESTABLISH_EVENTS  "Set event for selected symbol "

#include <ChartObjects\ChartObjectsTxtControls.mqh> 
//+------------------------------------------------------------------+
//| Class CControlElement.                                           |
//| Purpose: A set of functions for menu                             | 
//+------------------------------------------------------------------+
class CControlElement : public CChartObjectButton
  {
   protected:
      //--- 
      int               m_intparam;
      uint              m_uintparam;
      //--- 
   
      //--- Button parameters:
      ENUM_BASE_CORNER  m_corner;       // corner
      int               m_coord_x;      // X coordinate
      int               m_coord_y;      // Y coordinate
      //---
      
      //--- Control panel parameters:
      string            m_description;  // description
      int               m_size_x;       // X size
      int               m_size_y;       // Y size
      int               m_state;        // status
      int               m_state_select; // is selected
      int               m_flag_visibility;
      
      color             m_col_bg;       // background color
      color             m_col_font;     // text color
      color             m_col_select;
      string            m_font;         // font name
      int               m_size_font;    // font size
      ENUM_OBJECT       m_type;         // object type
      //---

   public:
      void CControlElement();
      bool CreateElement(
         ENUM_OBJECT type,     // object type
         string  name,         // object name (button name)
         string  description,  // description or button text
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         int     size_x,       // X size
         int     size_y,       // Y size
         color   col_bg,       // background color
         color   col_font,     // text color
         color   col_select,   
         string  font="Segoe UI Semibold", // font name
         int     size_font=8,  // font size
         int     state=0,      // button status
         long    chart_id=0,   // chart ID
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // chart binding corner
         );
      bool DisplayElement();
      bool Display(int coord_x, int coord_y, int size_x, int size_y);

      bool CreateButton(       // Creates a button
         string  name,         // Button name
         string  description,  // Description or button text
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         int     size_x,       // X size
         int     size_y,       // Y size
         color   col_bg,       // background color
         color   col_font,     // text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=8,  // font size
         int     state=0,      // button status
         long    chart_id=0,   // chart ID
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner

         );
      bool DisplayButton();    // Show button
      
      bool CreateEdit(   // Creates an Edit
         string  name,         // name
         string  text,         // text
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         int     size_x,       // X size
         int     size_y,       // Y size
         color   col_bg,       // background color
         color   col_font,     // text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=8,  // font size
         long    chart_id=0,   // chart ID
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
         );
      bool DisplayBackground();// Show background on the chart
      
      bool CreateLabel(        // Creates a Label
         string  name,         // object name (text label)
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         color   col_font,     // font color
         string  font="Segoe UI Semibold", // font name
         int     size_font=8,  // font size
         long    chart_id=0,   // chart ID
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding color
         );
      bool DisplayLabel();     // Show label
      int  Type() const        { return(m_type); }
      bool Hide();             // Hide object
      bool Coord_x(int coord_x);
      int  Coord_x() {return(m_coord_x);}
      bool Coord_y(int coord_y);
      int  Coord_y() {return(m_coord_y);}
      bool Descript(string description); 
      void StateElement(bool state) {m_state=state;}
      void ColorElement(color col_font) {m_col_font=col_font; Color(col_font);}
      bool StateElement() { return(m_state);}
      void FlagVisibility(int flag) {m_flag_visibility=flag;}
      int  FlagVisibility() {return(m_flag_visibility);}
      void ChangeStateSelect() {m_state_select=m_state;}
      void ChangeState() {m_state=m_state_select;}
      void IntParam(int param) {m_intparam=param;}
      int  IntParam() {return(m_intparam);}
      void UIntParam(int param) {m_uintparam=param;}
      int  UIntParam() {return(m_uintparam);}

  };
void CControlElement :: CControlElement()
  {
   m_intparam=-1;
   m_uintparam=0;

   
   //--- Chart paramters:
   m_corner    =CORNER_LEFT_LOWER;  // binding corner
   m_chart_id  =ChartID();          // chart ID
   m_window    =0;                  // chart window
   m_num_points=1;                  // number of anchor points of object
   
   //--- Control element parameters:
   m_state=false;                   // status
   m_col_bg=(color)ChartGetInteger(m_chart_id,CHART_COLOR_BACKGROUND);
   m_col_font=(color)ChartGetInteger(m_chart_id,CHART_COLOR_FOREGROUND); 
   m_flag_visibility=OBJ_ALL_PERIODS;
   
   m_font="Segoe UI Semibold";      // font name
   m_size_font=10;                  // font size
   //---

  }



bool CControlElement :: Descript(string description)
  {
   m_description=description;
   if(!Description(description)) return(false);
   return(true);
  }

bool CControlElement :: Coord_x(int coord_x)
  {
   m_coord_x=coord_x;
   if(!X_Distance(coord_x)) return(false);
   return(true);
  }
  
bool CControlElement :: Coord_y(int coord_y)
  {
   m_coord_y=coord_y;
   if(!Y_Distance(coord_y)) return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Show control element                                             |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CControlElement :: DisplayButton()
  {
     if(!Create(m_chart_id,m_name,m_window,m_coord_x,m_coord_y,m_size_x,m_size_y)) return(false);  // Create button
     if(!Description(m_description)) return(false);   // description or button text
     if(!BackColor (m_col_bg)) return(false);         // background color
     if(!Font(m_font)) return(false);                 // font name
     if(!FontSize(m_size_font)) return(false);        // font size
     if(!Color(m_col_font)) return(false);            // text color
     if(!State(m_state)) return(false);               // state
     if(!Corner(m_corner)) return(false);             // binding corner

     return(true);     
  }
   
bool CControlElement :: DisplayElement()
  {     
     if(!Create(m_chart_id,m_name,m_window,m_coord_x,m_coord_y,m_size_x,m_size_y)) return(false);  // Create element
     if(!Description(m_description)) return(false);   // description of text
     if(!BackColor (m_col_bg)) return(false);         // background color
     if(!Font(m_font)) return(false);                 // font name
     if(!FontSize(m_size_font)) return(false);        // font size
     if(m_state) { if(!Color(m_col_select)) return(false); }// selected text color
     else        { if(!Color(m_col_font)) return(false);   }// text color
     if(!State(m_state)) return(false);               // state
     if(!Corner(m_corner)) return(false);             // binding corner
     if(!SetInteger(OBJPROP_READONLY,true)) return(false);
     if(!Timeframes(m_flag_visibility)) return(false);
     return(true);     
  }
  
bool CControlElement :: Display(int coord_x, int coord_y, int size_x, int size_y)
  {
     m_coord_x=coord_x;
     m_coord_y=coord_y;
     m_size_x=size_x;
     m_size_y=size_y;
     if(!DisplayElement()) return(false);
     return(true);     
  }

bool CControlElement :: CreateElement(
   ENUM_OBJECT type,     // object type
   string  name,         // object name
   string  description,  // description of button text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   int     size_x,       // X size
   int     size_y,       // Y size
   color   col_bg,       // background color
   color   col_font,     // text color
   color   col_select,   // selected text color
   string  font="Segoe UI Semibold", // font name
   int     size_font=8,  // font size
   int     state=0,      // state
   long    chart_id=0,   // chart ID
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
     m_chart_id=chart_id;     // chart ID
     m_name=name;             // object name
     m_window=window;         // chart window
     m_num_points=1;          // number of anchor points of object
     
     //--- Button parameters:
     m_corner=corner;         // binding corner
     m_coord_x=coord_x;       // X coordinate
     m_coord_y=coord_y;       // Y coordinate
     //---
      
     //--- Button parameters:
     m_type=type;
     m_description=description;  // description
     m_size_x=size_x;         // X size
     m_size_y=size_y;         // Y size
     m_state=state;           // state
      
     m_col_bg=col_bg;         // background color
     m_col_font=col_font;     // text color
     m_col_select=col_select;
     m_font=font;             // font name
     m_size_font=size_font;   // font size
     //---
     return(true);     
  }

//+------------------------------------------------------------------+
//| Create a button                                                  |
//| INPUT:  ...                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+  
bool CControlElement :: CreateButton(
   string  name,         // object name
   string  description,  // description or text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   int     size_x,       // X size
   int     size_y,       // Y size
   color   col_bg,       // background color
   color   col_font,     // text color
   string  font="Segoe UI Semibold", // font name
   int     size_font=8,  // font size
   int     state=0,      // state
   long    chart_id=0,   // chart ID
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
     m_chart_id=chart_id;     // chart ID
     m_name=name;             // object name
     m_window=window;         // chart window
     m_num_points=1;          // number of anchor points of object
     
     //--- Button parameters:
     m_corner=corner;         // binding corner
     m_coord_x=coord_x;       // X coordinate 
     m_coord_y=coord_y;       // Y coordinate
     //---
      
     //--- Button parameters:
     m_type=OBJ_BUTTON;
     m_description=description;  // object description or text
     m_size_x=size_x;         // X size
     m_size_y=size_y;         // Y size
     m_state=state;           // state
      
     m_col_bg=col_bg;         // background color
     m_col_font=col_font;     // text color
     m_font=font;             // font name
     m_size_font=size_font;   // font size
     //---
     
     if(!DisplayButton()) return(false);
     
     return(true);     
  }
  
//+------------------------------------------------------------------+
//| Create an Edit                                                   |
//| INPUT:  ...                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+  
bool CControlElement :: CreateEdit(
   string  name,         // object name
   string  text,         // text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   int     size_x,       // X size
   int     size_y,       // Y size
   color   col_bg,       // background color
   color   col_font,     // border color
   string  font="Segoe UI Semibold", // font name
   int     size_font=8,  // font size
   long    chart_id=0,   // chart id
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
     m_chart_id=chart_id;     // chart id
     m_name=name;             // name
     m_description=text;
     m_window=window;         // chart window
     m_num_points=1;          // number of anchor points of object
     
     //--- Parameters:
     m_corner=corner;         // binding corner
     m_coord_x=coord_x;       // X coordinate
     m_coord_y=coord_y;       // Y coordinate
     //---
      
     //--- Edit field parameters:
     m_type=OBJ_EDIT;
     m_size_x=size_x;         // X size
     m_size_y=size_y;         // Y size
      
     m_col_bg=col_bg;         // background color
     m_col_font=col_font;     // border color
     m_font=font;             // font name
     m_size_font=size_font;   // font size
     //---
     
     return(true);     
  }
//+------------------------------------------------------------------+
//| Show Edit field                                                  |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CControlElement :: DisplayBackground()
  {
     if(!Create(m_chart_id,m_name,m_window,m_coord_x,m_coord_y,m_size_x,m_size_y)) return(false);  // Create edit
     if(!BackColor (m_col_bg)) return(false);   // background color
     if(!Color(m_col_font)) return(false);      // text color
     if(!Corner(m_corner)) return(false);       // binding corner
     if(!Description(m_description)) return(false);  // description
     if(!Font(m_font)) return(false);                // font name
     if(!FontSize(m_size_font)) return(false);       // font size
     if(!SetInteger(OBJPROP_READONLY,true)) return(false);
     return(true);     
  }
  
  
bool CControlElement :: CreateLabel(
   string  name,         // object name
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   color   col_font,     // text color
   string  font="Segoe UI Semibold", // font name
   int     size_font=8,  // font size
   long    chart_id=0,   // chart id
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
     m_chart_id=chart_id;     // chart id
     m_name=name;             // object name
     m_window=window;         // chart window
     m_num_points=1;          // number of anchor points of object
     
     //--- label parameters:
     m_corner=corner;         // binding corner
     m_coord_x=coord_x;       // X coordinate
     m_coord_y=coord_y;       // Y coordinate
     //---
      
     //--- label parameters:
     m_type=OBJ_LABEL;
     m_col_font=col_font;     // text color
     m_font=font;             // font name
     m_size_font=size_font;   // font size
     //---
     
//     if(!DisplayLabel()) return(false);
     return(true);     
  }
  
//+------------------------------------------------------------------+
//| Show label                                                       |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CControlElement :: DisplayLabel()
  {
     if(!Create(m_chart_id,m_name,m_window,m_coord_x,m_coord_y)) return(false);  // Create label
     if(!Font(m_font)) return(false);           // font name
     if(!Color(m_col_font)) return(false);      // text color
     if(!FontSize(m_size_font)) return(false);  // font size
     if(!Corner(m_corner)) return(false);       // binding corner
     return(true);     
  }

//+------------------------------------------------------------------+
//| Hide element                                                     |
//| The hidden element can be show using Display method              |
//| Display()                                                        |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CControlElement :: Hide()
  {
   if(!ObjectDelete(m_chart_id,m_name)) return(false);   
   return(true);
  }

#include <Arrays\List.mqh>
class CMenuHorizontal : public CList
  {
   protected:
      long     m_chart_id;
      string   m_name[];
      string   m_description[];
      int      m_chart_width;
      int      m_size_x[];
      int      m_coord_y;
      int      m_coord_x;
      int      m_width;
      int      m_height;
      int      m_quantity_buttons;
      bool     m_flag_status_message;
      bool     m_flag_menu_horizontal;

   public:
      void CMenuHorizontal();
      CObject  *CreateElement(   
         string  name,         // object name
         string  description,  // description or text
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         int     size_x,       // X size
         int     size_y,       // Y size
         color   col_bg,       // background color
         color   col_font,     // text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=8,  // font size
         int     state=0,      // state
         long    chart_id=0,   // chart id
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
         );
      bool Create(
         string& name_buttom[],// button names
         color   col_bg,       // background color
         color   col_font,     // text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=10, // font size
         long    chart_id=0,   // chart id
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
         );
      bool Delete();
      void StatusMessage(string Message);
      bool GetFlagStatusMessage()   {return(m_flag_status_message);}
      bool GetFlagMenuHorizontal()   {return(m_flag_menu_horizontal);}
      int  GetChartWidth()          {return(m_chart_width);}
      bool AlignmentCenter();
      bool Shift_x(int shift=0);
      bool Shift_y(int shift=0);
      bool HideStatusMessage();
      bool DisplayStatusMessage();
      bool HideMenuHorizontal();
      bool DisplayMenuHorizontal();
  };

void CMenuHorizontal :: CMenuHorizontal()
  {
   m_flag_status_message=true;
   m_flag_menu_horizontal=true;
  }

bool CMenuHorizontal :: AlignmentCenter()
  {
   m_chart_width=(int)ChartGetInteger(m_chart_id,CHART_WIDTH_IN_PIXELS);   
   int menu_x=(m_chart_width>(m_width+5))?(m_chart_width-m_width)/2:5;
   int shift=0;
   
   if (m_coord_x!=menu_x) 
     {
      shift=menu_x-m_coord_x;
      m_coord_x=menu_x;
      Shift_x(shift);
     }
        
   return(true);
  }

bool CMenuHorizontal :: Shift_x(int shift=0)
  {
   int total=Total();      
   CControlElement *element;
   for(int i=0;i<total;i++)
     {
      element=GetNodeAtIndex(i);
      int coord_x=element.Coord_x();
      if(!element.Coord_x(coord_x+shift)) return(false);
     }
   return(true);
  }
  
bool CMenuHorizontal :: Shift_y(int shift=0)
  {
   int total=Total();      
   CControlElement *element;
   for(int i=0;i<total;i++)
     {
      element=GetNodeAtIndex(i);
      int coord_y=element.Coord_y();
      if(!element.Coord_y(coord_y+shift)) return(false);
     }
   return(true);
  }

 
CObject* CMenuHorizontal :: CreateElement(   
   string  name,         // object name
   string  description,  // description or text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   int     size_x,       // X size
   int     size_y,       // Y size
   color   col_bg,       // background color
   color   col_font,     // text color
   string  font="Segoe UI Semibold", // font name
   int     size_font=8,  // font size
   int     state=0,      // state
   long    chart_id=0,   // chart id
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
   {
      CControlElement *button=new CControlElement; 
      if(!button.CreateButton(name,description,coord_x,coord_y,size_x,size_y,col_bg,col_font,font,size_font,state,chart_id,window,corner))
        {
         Print(__FUNCTION__," Error in creation of button ",GetLastError());
         delete button;
         button=NULL;
        }
      return(button);
   }

bool CMenuHorizontal :: Create(
   string& name_buttom[],// names
   color   col_bg,       // background color
   color   col_font,     // text color
   string  font="Segoe UI Semibold", // font color
   int     size_font=10, // font size
   long    chart_id=0,   // chart id
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
   //--- Menu colors:
   if(col_bg==CLR_NONE) col_bg=(color)ChartGetInteger(chart_id,CHART_COLOR_BACKGROUND);
   if(col_font==CLR_NONE) col_font=(color)ChartGetInteger(chart_id,CHART_COLOR_FOREGROUND);  
   
   m_chart_id=chart_id;
   m_width=0;
   m_height=(size_font+1)*2;
   m_coord_y=m_height*2;
   m_quantity_buttons=ArraySize(name_buttom);
   
   ArrayResize(m_name,m_quantity_buttons);
   ArrayResize(m_description,m_quantity_buttons);
   ArrayResize(m_size_x,m_quantity_buttons);

   for(int i=0; i<m_quantity_buttons; i++) 
     {
      m_name[i]=name_buttom[i];
      m_description[i]=name_buttom[i];      
      m_size_x[i]=StringLen(m_description[i])*size_font+2;
//      Print(StringLen(m_description[i]),"  ",m_size_x[i]);
      m_width+=m_size_x[i]+1;
     }
   
   int width_chart=(int)ChartGetInteger(chart_id,CHART_WIDTH_IN_PIXELS);
   
   m_coord_x=(width_chart>(m_width+5))?(width_chart-m_width)/2:5;

   CControlElement *background=new CControlElement; 
   if(!background.CreateEdit("background","",m_coord_x,m_coord_y-m_height-1,m_width,m_height-1,col_bg,col_bg,font,size_font))//col_font))
     {
      Print(__FUNCTION__," Erro in creation of menu backround ",GetLastError());
      delete background;
      return(false);
     }
   Add(background); 
   if(!background.DisplayBackground()) return(false);
   
   for(int i=0,buttom_x=m_coord_x; i<m_quantity_buttons; i++)
     {
      CObject *button_object=CreateElement(m_name[i],m_description[i],buttom_x,m_coord_y,m_size_x[i],m_height,col_bg,col_font,font,size_font,0,chart_id,window,corner);
      if(button_object==NULL) return(false); 
      Add(button_object); 
      buttom_x+=m_size_x[i]+1;
     }
   
   CControlElement *status_control_panel=new CControlElement; 
   if(!status_control_panel.CreateLabel("● "+MSG_CONTROL_PANEL_MCM,m_coord_x,m_coord_y-m_height-2,col_font,font,size_font,chart_id,window,corner))
     {
      Print(__FUNCTION__," Error in creation of text label ",GetLastError());
      delete status_control_panel;
      return(false);
     }
   Add(status_control_panel); 
   if(!status_control_panel.DisplayLabel()) return(false);
     
   return(true);
  }

bool CMenuHorizontal :: Delete()
  {   
   Clear();
   return(true);
  }

void CMenuHorizontal :: StatusMessage(string Message)
  {
   CControlElement *message=GetLastNode();
   message.Description(" ● "+Message);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Hide horizontal menu in the lower bottom corner                  |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMenuHorizontal :: HideMenuHorizontal()
  {
   m_flag_menu_horizontal=false;
   
   CControlElement *element;
   
   int total=Total();
      
   for(int i=0;i<total;i++)
     {
//      if(i!=2)
      if(i!=1 && i!=2)
        {
         element=GetNodeAtIndex(i);
         if(!ObjectDelete(m_chart_id,element.Name())) return(false);   
        }
      else if(i==2) 
        {
         element=GetNodeAtIndex(i);
         element.Descript("˃");
        }
     }

//   element=GetNodeAtIndex(2);
//   Shift_x(1-element.Coord_x());
   Shift_x(1-m_coord_x);
   if(GetFlagStatusMessage()) Shift_y(-m_height);

   m_coord_x=1;

   return(true);
  }
  
//+------------------------------------------------------------------+
//| Show horizontal menu                                             |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMenuHorizontal :: DisplayMenuHorizontal()
  {
   m_flag_menu_horizontal=true;

   if(GetFlagStatusMessage()) Shift_y(m_height);
   
   CControlElement *element;
   
   int total=Total();
      
   element=GetFirstNode();
   if(!element.DisplayBackground()) return(false);  
    
   for(int i=1;i<total-1;i++)
     {
      if(i!=1 && i!=2)
        {
         element=GetNodeAtIndex(i);
         if(!element.DisplayButton()) return(false);   
        }
      else if(i==2) 
        {
         element=GetNodeAtIndex(i);
         element.Descript("˂");
        }
     }
     
   element=GetLastNode();
   if(!element.DisplayLabel()) return(false);  

   AlignmentCenter();

   return(true);
  }  
//+------------------------------------------------------------------+
//| Hide status string                                               |
//| The hidden status string can be shown using Display method       |
//| Display()                                                        |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMenuHorizontal :: HideStatusMessage()
  {
   m_flag_status_message=false;
   
   CControlElement *element;
   
   element=GetFirstNode();
   if(!ObjectDelete(m_chart_id,element.Name())) return(false);   
   element=GetLastNode();
   if(!ObjectDelete(m_chart_id,element.Name())) return(false);   
   element=GetPrevNode();
   element.Descript("˄");

   Shift_y(-m_height);
   
   return(true);
  }

bool CMenuHorizontal :: DisplayStatusMessage()
  {
   m_flag_status_message=true;   
   CControlElement *element;
   
   Shift_y(m_height);
   
   element=GetFirstNode();
   if(!element.DisplayBackground()) return(false);   
   element=GetLastNode();
   if(!element.DisplayLabel()) return(false);   
   element=GetPrevNode();
   element.Descript("˅");
   
   return(true);
  }
  
// Symbol events structure
struct stEventSymbol
{
   string symbol;                   // Symbol
   ENUM_CHART_EVENT_SYMBOL event;   // Event flag
};

//+------------------------------------------------------------------+
//| MCM Control panel initalization method.                          |
//| It shoul be called from OnInit() function only.                  |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
#define INDICATOR_NAME  "iControl panel MCM"
int _handle_control_panel=INVALID_HANDLE;
bool InitControlPanelMCM(color init_bg_color=Gray,       // Menu background color
                         color init_font_color=Gainsboro,// Text color
                         color init_select_color=Yellow, // Selected text color
                         int   init_font_size=10)        // Font size
  {
   
   //--- check if it already exist
   int window=-1;
   window=ChartWindowFind(0,"Control panel MCM");
   if(window!=-1) 
     {
      Print(__FUNCTION__+"  "+INDICATOR_NAME," already installed");
      return(true);
     }
   
   //--- launch the iControl panel MCM.mq5 custom indicator 
   _handle_control_panel=iCustom(_Symbol,_Period,INDICATOR_NAME,init_bg_color,init_font_color,init_select_color,init_font_size);

   if(_handle_control_panel==INVALID_HANDLE)
      { Print("Error in "+INDICATOR_NAME); return(false);}

   bool Testing=((bool)MQL5InfoInteger(MQL5_TESTING) || (bool)MQL5InfoInteger(MQL5_OPTIMIZATION));
   if(!Testing)
      if(!ChartIndicatorAdd(ChartID(),0,_handle_control_panel))
         {
          Alert(__FUNCTION__," Error in attaching of MCM panel to the chart, error N: ",GetLastError());
          return(false);
         }
   return(true);
  }
  
//+------------------------------------------------------------------+
//| MCM Control panel deinitialization function                      |
//| It should be called from OnDeinit() function only                |
//| INPUT:  no.                                                      |
//| OUTPUT: true  - if successful                                    |
//|         false - if error                                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool DeinitControlPanelMCM()
  {

   //--- Release iControl panel MCA.mq5
   if(_handle_control_panel!=INVALID_HANDLE)
      if(IndicatorRelease(_handle_control_panel)) Print("Deinitialization of MCM Control panel: Successful");
      else 
        {
         Print("Error in deinitialization of MCM Control Panel");
         return(false);
        }
//   Print("Number of indicators ", ChartIndicatorsTotal(ChartID(),0));
//   Print("Indicator name  ", ChartIndicatorName(ChartID(),0,0),"  -----  ","Control panel MCM");
        
   //--- check if it already installed:
   int window=-1;
   window=ChartWindowFind(0,"Control panel MCM");
   if(window!=-1) 
     {
      if(!ChartIndicatorDelete(ChartID(),0,"Control panel MCM"))
        {
         Print(__FUNCTION__+"  Error in detaching of "+INDICATOR_NAME+" from chart");
         return(false);
        }

      Print(__FUNCTION__+":  "+INDICATOR_NAME+" removed from chart");
      return(true);
     }

   return(true);
  }
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
class CVertical_scrolled_menus : public CList
  {
   protected:
      long     m_chart_id;
      int      m_window;
      ENUM_BASE_CORNER  m_corner;
      
      
      string   m_menu_name;
      string   m_name_save_buttom;
      int      m_menu_coord_y;
      int      m_menu_coord_x;
      int      m_menu_width;
      int      m_menu_height;
      color    m_menu_col_bg;
      color    m_menu_col_font;
      color    m_menu_col_select;
      int      m_size_font;
      string   m_font;
      int      m_width_scrolling_line;
      bool     m_save_buttom;
      bool     m_menu_visibility;
      
      
      string   m_element_text[];
      int      m_element_quantity;
      int      m_element_min;
      int      m_element_max;
      int      m_element_width;
      int      m_element_height;
      int      m_element_begin;
      
      bool     m_flag_status_message;
      bool     m_flag_menu_horizontal;

   public:
      void     CVertical_scrolled_menus();
      CObject* CreateElement(   
         string  text,         // text color
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         color   col_font,     // text color
         color   col_select,   // selected text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=10, // font size
         long    chart_id=0,   // chart ID
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
         );
      bool Create(
         string  name,         // vertical menu color
         string  name_save_buttom, // "Save" button name
         string& text_lebel[], // text of the labels
         int     coord_x,      // X coordinate
         int     coord_y,      // Y coordinate
         color   col_bg,       // background color
         color   col_font,     // text color
         color   col_select,   // selected text color
         string  font="Segoe UI Semibold", // font name
         int     size_font=10, // font size
         long    chart_id=0,   // chart id
         int     window=0,     // chart window
         ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
         );
      bool CreateScrollingLine();
      int SelectOneElement(string name);
      int SelectMuchElement(string name);
      int  GetMenuWidth() {return(m_menu_width+m_width_scrolling_line);}
      string  Name() {return(m_menu_name);}
      void Name(string name) {m_menu_name=name;}
      bool Scrolling(string button_scroll);
      bool Display(int coord_x,int coord_y);
      bool Hide();
      bool Visibility() {return(m_menu_visibility);}
      bool ChangeState();
      bool ChangeStateSelect();
      void Quantity(int quantity) {m_element_quantity=quantity;}
      bool SynchronizationTradingTools();
  };
  
void CVertical_scrolled_menus :: CVertical_scrolled_menus()
  {
   m_chart_id=ChartID();
   m_width_scrolling_line=4;
   //--- Colors of menu:
   m_menu_col_bg=(color)ChartGetInteger(m_chart_id,CHART_COLOR_BACKGROUND);
   m_menu_col_font=(color)ChartGetInteger(m_chart_id,CHART_COLOR_FOREGROUND); 
   m_menu_col_select=m_menu_col_font;
   m_menu_name="??????";
   m_element_begin=0;
   m_menu_visibility=false;
  }   

CObject* CVertical_scrolled_menus :: CreateElement(   
   string  text,         // text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   color   col_font,     // text color
   color   col_select,   // selected color
   string  font="Segoe UI Semibold", // font name
   int     size_font=10, // font size
   long    chart_id=0,   // chart id
   int     window=0,     // chart window
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
   CControlElement *lebel=new CControlElement; 
   if(!lebel.CreateElement(OBJ_LABEL,text,text,coord_x,coord_y,0,0,col_font,col_font,col_select,font,size_font,0,chart_id,window,corner))
     {
      Print(__FUNCTION__," Error in creation of text label ",GetLastError());
      delete lebel;
      lebel=NULL;
     }

   return(lebel);
  }


bool CVertical_scrolled_menus :: Display(int coord_x,int coord_y)
  {
   bool result=true;   
   m_element_begin=0;
   
   //--- Height
   long height_chart;
   result&=ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS,m_window,height_chart);

   m_element_max=(int)((height_chart-coord_y)/m_element_height-3+m_save_buttom);
   m_element_max=MathMin(m_element_quantity,m_element_max);
   m_element_max=MathMax(m_element_min,m_element_max);
   
   m_menu_height=(m_element_max+2-m_save_buttom)*m_element_height;
   //---
   
   m_width_scrolling_line=((m_element_quantity>m_element_max)?4:2)*m_size_font;
        
   m_menu_coord_x=coord_x;
   m_menu_coord_y=coord_y+m_menu_height+1;   
   
   CControlElement *element=GetFirstNode();
   element.Display(m_menu_coord_x,m_menu_coord_y,m_menu_width+m_width_scrolling_line,m_menu_height);
   
   element=GetNextNode();
   element.Display(m_menu_coord_x+m_size_font/2, m_menu_coord_y, m_menu_width+m_size_font, m_element_height-2);

   int element_quantity=ArraySize(m_element_text);
   for(int i=0,lebel_y=m_menu_coord_y-m_element_height; i<m_element_quantity; i++)
     {
      element=GetNextNode();
         element.Coord_x(m_menu_coord_x+m_size_font);
         element.Coord_y(lebel_y);
         if(i<m_element_max) element.Display(m_menu_coord_x+m_size_font,lebel_y,m_menu_width+m_width_scrolling_line,m_menu_height);
         else element.Hide();
         lebel_y-=m_element_height;
     }
/*   int element_quantity=ArraySize(m_element_text);
   for(int i=0, j=0,lebel_y=m_menu_coord_y-m_element_height; i<element_quantity; i++)
     {
      element=GetNextNode();
      string name=element.Name();
      int visibility=element.FlagVisibility();
      if(element.FlagVisibility()==OBJ_ALL_PERIODS)
        {
         element.Coord_x(m_menu_coord_x+m_size_font);
         element.Coord_y(lebel_y);
         if(j<m_element_max) element.Display(m_menu_coord_x+m_size_font,lebel_y,m_menu_width+m_width_scrolling_line,m_menu_height);
         else element.Hide();
         MoveToIndex(j+2);
         lebel_y-=m_element_height;
         j++;
        }
     }
*/
      element=GetNodeAtIndex(element_quantity+2);
      element.Display(m_menu_coord_x,m_menu_coord_y,m_menu_width+m_width_scrolling_line,m_element_height);
      
      element=GetNextNode();
      if(m_element_quantity>m_element_max) element.FlagVisibility(OBJ_ALL_PERIODS); else element.FlagVisibility(OBJ_NO_PERIODS);
      element.Display(m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-2*m_element_height,m_size_font+4,m_element_height*(m_element_max-2));
           
      element=GetNextNode();
      if(m_element_quantity>m_element_max) element.FlagVisibility(OBJ_ALL_PERIODS); else element.FlagVisibility(OBJ_NO_PERIODS);
      element.Display(m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-m_element_height-5,m_size_font+4,m_element_height-5);
           
      element=GetNextNode();
      if(m_element_quantity>m_element_max) element.FlagVisibility(OBJ_ALL_PERIODS); else element.FlagVisibility(OBJ_NO_PERIODS);
      element.Display(m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-m_element_height*(m_element_max),m_size_font+4,m_element_height-5);
                      
      element=GetNextNode();
      if(m_save_buttom) element.FlagVisibility(OBJ_NO_PERIODS); else element.FlagVisibility(OBJ_ALL_PERIODS);
      element.Display(m_menu_coord_x+1,m_menu_coord_y-m_element_height*(m_element_max+1),m_menu_width+m_width_scrolling_line-2,m_element_height-1);
      
      m_menu_visibility=true;        

   return(true);
  }
  
bool CVertical_scrolled_menus :: Hide()
  {
      
   CControlElement *element=GetFirstNode();

   for(int i=0; i<Total(); i++)
     {
      element.Hide();
      element=GetNextNode();
     }
   m_menu_visibility=false;        
   return(true);
  }
  
bool CVertical_scrolled_menus :: ChangeStateSelect()
  {
      
   CControlElement *element=GetFirstNode();

   for(int i=0; i<Total(); i++)
     {
      element.ChangeStateSelect();
      element=GetNextNode();
     }
   return(true);
  }
  
bool CVertical_scrolled_menus :: ChangeState()
  {
      
   CControlElement *element=GetFirstNode();

   for(int i=0; i<Total(); i++)
     {
      element.ChangeState();
      element=GetNextNode();
     }
   return(true);
  }

bool CVertical_scrolled_menus :: Create(
   string  name,         // name of the vertical menu
   string  name_save_buttom, // "save" button name, set "" if isn't necessary
   string& text[],       // menu button text
   int     coord_x,      // X coordinate
   int     coord_y,      // Y coordinate
   color   col_bg,       // background color
   color   col_font,     // text color
   color   col_select,   // selected text color
   string  font="Segoe UI Semibold", // font name
   int     size_font=10, // font size
   long    chart_id=0,   // chart id
   int     window=0,     // char windowо
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER  // binding corner
   )
  {
   bool result=true;
      
   //--- Menu colors:
//   if(col_bg==CLR_NONE) result&=ChartGetInteger(chart_id,CHART_COLOR_BACKGROUND,m_menu_col_bg);
//   else m_menu_col_bg=col_bg;
//   if(col_font==CLR_NONE) result&=ChartGetInteger(chart_id,CHART_COLOR_FOREGROUND,m_menu_col_font);  
//   else m_menu_col_font=col_font;
   if(col_bg!=CLR_NONE) m_menu_col_bg=col_bg;
   if(col_font!=CLR_NONE) m_menu_col_font=col_font;
   if(col_select!=CLR_NONE) m_menu_col_select=col_select;
   //---  
   
   m_menu_name=name;
   m_name_save_buttom=name_save_buttom;
   m_chart_id=chart_id; 
   m_window=window;
   m_corner=corner;
   m_size_font=size_font;
   m_font=font;
   m_element_begin=0;
   
   
   m_menu_width=0;
   m_element_quantity=ArraySize(text);
   if(ArrayResize(m_element_text,m_element_quantity)==-1) result=false;
   m_save_buttom=(m_name_save_buttom=="");


   //--- Menu height
   long height_chart;
   result&=ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS,m_window,height_chart);

   m_element_height=m_size_font*2;
   m_element_min=2;
   m_element_max=(int)((height_chart-coord_y)/m_element_height-3+m_save_buttom);
   m_element_max=MathMin(m_element_quantity,m_element_max);
   m_element_max=MathMax(m_element_min,m_element_max);
   
   m_menu_height=(m_element_max+2-m_save_buttom)*m_element_height;
   //---
   
   m_width_scrolling_line=((m_element_quantity>m_element_max)?m_width_scrolling_line:2)*m_size_font;
   
   //--- Menu width
   for(int i=0; i<m_element_quantity; i++) 
     {
      m_element_text[i]=text[i];
      m_element_width=(StringLen(m_element_text[i]))*(size_font);
      m_menu_width=(m_menu_width>m_element_width)?m_menu_width:m_element_width;
     }
   //---
     
   m_menu_coord_x=coord_x;
   m_menu_coord_y=coord_y+m_menu_height+1;   
      
   CControlElement *element=new CControlElement; 
   if(!element.CreateElement(OBJ_EDIT,m_menu_name+"background_chart","",m_menu_coord_x,m_menu_coord_y,m_menu_width+m_width_scrolling_line,m_menu_height,m_menu_col_bg,m_menu_col_font,m_menu_col_select,font,size_font))
     {
      Print(__FUNCTION__," Error in creation of menu background ",GetLastError());
      delete element;
      return(false);
     }
   Add(element); 
   
   element=new CControlElement;
   if(!element.CreateElement(OBJ_EDIT,m_menu_name+"select","",m_menu_coord_x+size_font/2, m_menu_coord_y, m_menu_width+size_font, m_element_height-2,m_menu_col_bg,m_menu_col_select,m_menu_col_select,font,size_font))   
     {
      Print(__FUNCTION__," Error in creation of menu backround ",GetLastError());
      delete element;
      return(false);
     }
   Add(element); 
   
   for(int i=0,lebel_y=m_menu_coord_y-m_element_height; i<m_element_quantity; i++)
     {
      CObject *lebel=CreateElement(m_element_text[i],m_menu_coord_x+size_font,lebel_y,col_font,m_menu_col_select,font,size_font,chart_id,window,corner);
      if(lebel==NULL) return(false); 
      Add(lebel); 
      lebel_y-=m_element_height;
     }

   element=new CControlElement; 
   if(!element.CreateElement(OBJ_EDIT,m_menu_name,m_menu_name,m_menu_coord_x,m_menu_coord_y,m_menu_width+m_width_scrolling_line,m_element_height,m_menu_col_bg,m_menu_col_font,m_menu_col_select,font,size_font))
     {
      Print(__FUNCTION__," Error in creation of menu item ",GetLastError());
      delete element;
      return(false);
     }
   Add(element); 

   CreateScrollingLine(); 
     
   element=new CControlElement; 
   if(!element.CreateElement(OBJ_BUTTON,m_menu_name+"_button_save",m_name_save_buttom,m_menu_coord_x+1,m_menu_coord_y-m_element_height*(m_element_max+1),m_menu_width+m_width_scrolling_line-2,m_element_height-1,m_menu_col_bg,m_menu_col_font,m_menu_col_select,m_font,m_size_font,0,m_chart_id,m_window,m_corner))
     {
      Print(__FUNCTION__," Error in creation of menu button ",GetLastError());
      delete element;
      return(false);
     }
   Add(element); 
   if(m_save_buttom) element.FlagVisibility(OBJ_NO_PERIODS); else element.FlagVisibility(OBJ_ALL_PERIODS);

//   Display(coord_x,coord_y);   
   return(true);
  }
  
bool CVertical_scrolled_menus :: CreateScrollingLine()
  {
   CControlElement *scrolling_line=new CControlElement; 
   if(!scrolling_line.CreateElement(OBJ_BUTTON,m_menu_name+"scrolling_line"," ",m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-2*m_element_height,m_size_font+4,m_element_height*(m_element_max-2),m_menu_col_bg,m_menu_col_font,m_menu_col_select,m_font,m_size_font,0,m_chart_id,m_window,m_corner))
     {
      Print(__FUNCTION__," Error in creation of menu button ",GetLastError());
      delete scrolling_line;
      return(false);
     }
   Add(scrolling_line); 
   if(m_element_quantity>m_element_max) scrolling_line.FlagVisibility(OBJ_ALL_PERIODS); else scrolling_line.FlagVisibility(OBJ_NO_PERIODS);

   CControlElement *button_up=new CControlElement; 
   if(!button_up.CreateElement(OBJ_BUTTON,m_menu_name+"▲","▲",m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-m_element_height-5,m_size_font+4,m_element_height-5,m_menu_col_bg,m_menu_col_font,m_menu_col_select,m_font,m_size_font,0,m_chart_id,m_window,m_corner))
     {
      Print(__FUNCTION__," Error in creation of menu button ",GetLastError());
      delete button_up;
      return(false);
     }
   Add(button_up);
   if(m_element_quantity>m_element_max) button_up.FlagVisibility(OBJ_ALL_PERIODS); else button_up.FlagVisibility(OBJ_NO_PERIODS);
    

   CControlElement *button_dn=new CControlElement; 
   if(!button_dn.CreateElement(OBJ_BUTTON,m_menu_name+"▼","▼",m_menu_coord_x+m_menu_width+m_width_scrolling_line-5-m_size_font-5,m_menu_coord_y-m_element_height*(m_element_max),m_size_font+4,m_element_height-5,m_menu_col_bg,m_menu_col_font,m_menu_col_select,m_font,m_size_font,0,m_chart_id,m_window,m_corner))
     {
      Print(__FUNCTION__," Error in creation of menu button ",GetLastError());
      delete button_dn;
      return(false);
     }
   Add(button_dn); 
   if(m_element_quantity>m_element_max) button_dn.FlagVisibility(OBJ_ALL_PERIODS); else button_dn.FlagVisibility(OBJ_NO_PERIODS);
   
   return(true);
  }  
  
int CVertical_scrolled_menus :: SelectMuchElement(string name)
  {
   int prev_id_select=0;
   CControlElement *element;
   
   element=GetNodeAtIndex(1);
   int coord_y=element.Coord_y()+1;
   element.Coord_y(m_menu_coord_y);
   
   for(int i=0;i<m_element_quantity;i++)
     {
      element=GetNodeAtIndex(i+2);
      
//      if(name==m_element_text[i])
      if(name==element.Name())
        {         
         if(coord_y==element.Coord_y()) element.StateElement(element.StateElement()^true);  
         color cur_color=element.StateElement()? m_menu_col_select:m_menu_col_font;
         element.Color(cur_color);
         
         coord_y=element.Coord_y()-1;
         element=GetNodeAtIndex(1);
         element.Coord_y(coord_y);
         element.Color(cur_color);
                     
         return(i);
        }
     }
   return(-1);
  }

int CVertical_scrolled_menus :: SelectOneElement(string name="")
  {
   int prev_id_select=0;
   CControlElement *element;
   
   element=GetNodeAtIndex(1);
   element.Coord_y(m_menu_coord_y);
   
   for(int i=0;i<m_element_quantity;i++)
     {
      element=GetNodeAtIndex(i+2);
      if(element.StateElement())
        {
         prev_id_select=i+1; 
         if(name=="") name=element.Name(); 
         break;      
        }
     }
     
   for(int i=0;i<m_element_quantity;i++)
     {
      element=GetNodeAtIndex(i+2);
//      if(name==m_element_text[i])
      if(name==element.Name())
        {
         element.StateElement(true);       
         element.Color(m_menu_col_select);  
         
         int coord_y=element.Coord_y()-1;
         element=GetNodeAtIndex(1);
         element.Coord_y(coord_y);
                     
         if(prev_id_select!=0 && prev_id_select!=i+1)
           {    
            element=GetNodeAtIndex(prev_id_select+1);
            element.StateElement(false);       
            element.Color(m_menu_col_font); 
           }     
         
         return(i);;
        }
     }
   return(prev_id_select-1);
  }


bool CVertical_scrolled_menus :: Scrolling(string button_scroll)
  {
   CControlElement *element;

   if(button_scroll==m_menu_name+"scrolling_line") 
     {
      element=GetNodeAtIndex(Total()-4);
      element.State(false);      
     }

   if(button_scroll==m_menu_name+"▲") 
     {
      if(m_element_begin==0) 
        {
         element=GetNodeAtIndex(Total()-2);
         element.State(false);
         element=GetPrevNode();
         element.State(true);

         return(true);      
        }
                
      element=GetNodeAtIndex(m_element_begin+1);
      element.Coord_y(m_menu_coord_y-m_element_height);
      element.DisplayElement();
      
      for(int i=0,lebel_y=m_menu_coord_y-2*m_element_height; i<m_element_max-1; i++)
       {
        element=GetNodeAtIndex(m_element_begin+i+2);
        string name=element.Name();
        element.Coord_y(lebel_y);
        lebel_y-=m_element_height;
       }
      element=GetNodeAtIndex(m_element_begin+m_element_max+1);
      element.Coord_y(m_menu_coord_y);
      element.Hide();
      m_element_begin--;

      element=GetNodeAtIndex(Total()-2);
      element.State(false);
      element=GetPrevNode();
      element.State(false);
      
      return(true);
     }
       
   if(button_scroll==m_menu_name+"▼") 
     {
      if(m_element_begin>=m_element_quantity-m_element_max) 
        {
         element=GetNodeAtIndex(Total()-2);
         element.State(true);
         element=GetPrevNode();
         element.State(false);

         return(true);      
        }

      element=GetNodeAtIndex(m_element_begin+2);
      element.Coord_y(m_menu_coord_y);
      element.Hide();
      
      for(int i=1,lebel_y=m_menu_coord_y-m_element_height; i<m_element_max; i++)
       {
        element=GetNodeAtIndex(m_element_begin+i+2);
        string name=element.Name();
        element.Coord_y(lebel_y);
        lebel_y-=m_element_height;
       }
      element=GetNodeAtIndex(m_element_begin+m_element_max+2);
      element.Coord_y(m_menu_coord_y-m_menu_height+m_element_height*(2-m_save_buttom));
      element.DisplayElement();
      m_element_begin++;

      element=GetNodeAtIndex(Total()-2);
      element.State(false);
      element=GetPrevNode();
      element.State(false);
      return(true);
     }
     
//     SelectOneElement();     
   return(true);
  }
  
bool CVertical_scrolled_menus :: SynchronizationTradingTools()
  {
   Quantity(SymbolsTotal(true));
   for(int j=0;j<SymbolsTotal(true);j++)
     {
      for(int pos=0;pos<SymbolsTotal(false);pos++) // loop on all symbols
        {
         CControlElement *element=GetNodeAtIndex(pos+2);
         if(SymbolName(j,true)==element.Name())
           {
            Exchange(GetNodeAtIndex(pos+2),GetNodeAtIndex(j+2));
            break;
           }
        }
     }  
   return(true);
  }
  