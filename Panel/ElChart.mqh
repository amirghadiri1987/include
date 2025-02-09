//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "Node.mqh"
#include <Panel\Events\EventChartEndEdit.mqh>
//+------------------------------------------------------------------+
//| The basic element of the panel graphic element. Includes         |
//| the most common properties of an element.                        |
//+------------------------------------------------------------------+
class CElChart : public CNode
{
private:
   ENUM_OBJECT           m_obj_type;      // The underlying graphic type of the element
   
   long                  m_x;             // The X coordinate of the anchor point
   long                  m_y;             // The Y coordinate of the anchor point
   long                  m_height;        // The length of the element in pixels 
   long                  m_width;         // The width of the element in pixels
   
   string                m_text;          // Text on the element
   int                   m_text_size;     // Font size of the element text
   color                 m_text_color;    // Font color of the element text
   string                m_text_font;     // Text font name
   bool                  m_read_only;     // Read-only mode
   ENUM_ALIGN_MODE       m_align;         // Alignment type for OBJ_EDIT
   
   color                 m_bground_color; // Element background color
   color                 m_border_color;  // Element frame color
   ENUM_BORDER_TYPE      m_border_type;   // Element frame type
   ENUM_BASE_CORNER      m_corner;        // Graphic object binding type
   
protected:
   virtual void OnXCoordChange(void);
   virtual void OnYCoordChange(void);
   virtual void OnWidthChange(void);
   virtual void OnHeightChange(void);
public:
                     CElChart(ENUM_OBJECT obj_type);
   virtual void      Show();
   virtual void      Event(CEvent* event);
            /* Set methods */
   void              Text(string text);
   void              TextSize(int size);
   void              TextFont(string font);
   void              TextColor(color clr);
   void              ReadOnly(bool read_only);
   void              Align(ENUM_ALIGN_MODE align);
   
   void              BackgroundColor(color clr);
   void              BorderColor(color clr);
   void              BorderType(ENUM_BORDER_TYPE type);
   
   void              XCoord(long x);
   void              YCoord(long y);
   void              Width(long width);
   void              Height(long height);
   void              Corner(ENUM_BASE_CORNER corner);
   
            /* Get methods */
   string            Text(void);
   int               TextSize(void);
   color             TextColor(void);
   string            TextFont(void);
   bool              ReadOnly(void);
   ENUM_ALIGN_MODE   Align(void);
   
   color             BackgroundColor(void);
   color             BorderColor(void);
   ENUM_BORDER_TYPE  BorderType(void);
   
   long              XCoord(void);
   long              YCoord(void);
   long              Width(void);
   long              Height(void);
   ENUM_BASE_CORNER  Corner(void);
   
   ENUM_OBJECT       TypeElement(void);
   
};
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
CElChart::CElChart(ENUM_OBJECT obj_type)
{
   m_obj_type = obj_type;
   XCoord(20);
   YCoord(20);
   Height(20);
   Width(120);
   Text("");
   TextFont("Arial");
   TextColor(clrBlack);
   TextSize(10);
   ReadOnly(true);
   BorderColor(clrBlack);
   BackgroundColor(clrWhite);
   BorderType(BORDER_FLAT);
   Align(ALIGN_LEFT);
}
//+------------------------------------------------------------------+
//| Creates an element on a chart and configures its main properties:|
//| Element type- TypeElement;                                       |
//| X coordinate= XCoord()                                           |
//| Y coordinate = YCoord()                                          |
//| Height = Height()                                                |
//| Width = Width()                                                  |
//| Font size = FontSize()                                           |
//+------------------------------------------------------------------+
void CElChart::Show(void)
{
   if(ObjectFind(ChartID(), m_name)<0)
      m_showed = ObjectCreate(ChartID(), m_name, m_obj_type, 0, 0, 0);
   XCoord(XCoord());
   YCoord(YCoord());
   Height(Height());
   Width(Width());
   if(m_obj_type == OBJ_BITMAP_LABEL)
   {
      OnShow();
      return;
   }
   if(m_obj_type == OBJ_EDIT)
      Align(Align());
   Text(Text());
   TextColor(TextColor());
   TextSize(TextSize());
   TextFont(TextFont());
   ReadOnly(ReadOnly());
   Corner(Corner());   
   BorderType(BorderType());
   if(BorderType() == BORDER_FLAT)
      BorderColor(BorderColor());
   BackgroundColor(BackgroundColor());
   OnShow();
}

void CElChart::Event(CEvent *event)
{
   CNode::Event(event);
   if(event.EventType() == EVENT_CHART_END_EDIT)
   {
      CEventChartEndEdit* endEdit = event;
      if(endEdit.ObjectName() == Name())
         m_text = ObjectGetString(ChartID(), Name(), OBJPROP_TEXT);
   }
}
//+------------------------------------------------------------------+
//| Sets the X coordinate of the element on chart                    |
//+------------------------------------------------------------------+
void CElChart::XCoord(long x)
{
   m_x = x;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_XDISTANCE, m_x);
   OnXCoordChange();
}
//+------------------------------------------------------------------+
//| Returns the X coordinate of the element on chart                 |
//+------------------------------------------------------------------+
long CElChart::XCoord(void)
{
   return m_x;
}
//+------------------------------------------------------------------+
//| Sets the Y coordinate of the element on chart                    |
//+------------------------------------------------------------------+
void CElChart::YCoord(long y)
{
   m_y = y;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_YDISTANCE, m_y);
   OnYCoordChange();
}
//+------------------------------------------------------------------+
//| Returns the Y coordinate of the element on chart                 |
//+------------------------------------------------------------------+
long CElChart::YCoord(void)
{
   return m_y;
}
//+------------------------------------------------------------------+
//| Sets the element width in pixels                                 |
//+------------------------------------------------------------------+
void CElChart::Width(long width)
{
   m_width = width;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_XSIZE, m_width);
   OnWidthChange();
}
//+------------------------------------------------------------------+
//| Returns the element height in pixels                             |
//+------------------------------------------------------------------+
long CElChart::Width(void)
{
   return m_width;
}
//+------------------------------------------------------------------+
//| Sets the element width in pixels                                 |
//+------------------------------------------------------------------+
void CElChart::Height(long height)
{
   m_height = height;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_YSIZE, m_height);
   OnHeightChange();
}
//+------------------------------------------------------------------+
//| Returns the element width in pixels                              |
//+------------------------------------------------------------------+
long CElChart::Height(void)
{
   return m_height;
}
//+------------------------------------------------------------------+
//| Sets the text of the element                                     |
//+------------------------------------------------------------------+
void CElChart::Text(string text)
{
   m_text = text;
   if(IsShowed())
      ObjectSetString(ChartID(), m_name, OBJPROP_TEXT, m_text);
      //ObjectSetString(ChartID(), m_name, OBJPROP_, m_text);
}
//+------------------------------------------------------------------+
//| Returns the text of the element                                  |
//+------------------------------------------------------------------+
string CElChart::Text(void)
{
   return m_text;
}
//+------------------------------------------------------------------+
//| Sets the font size of the element text                           |
//+------------------------------------------------------------------+
void CElChart::TextSize(int text_size)
{
   m_text_size = text_size;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_FONTSIZE, m_text_size);
}
//+------------------------------------------------------------------+
//| Returns the font size of the element text                        |
//+------------------------------------------------------------------+
int CElChart::TextSize(void)
{
   return m_text_size;
}
//+------------------------------------------------------------------+
//| Sets the color of the text on the element                        |
//+------------------------------------------------------------------+
void CElChart::TextColor(color clr)
{
   m_text_color = clr;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_COLOR, m_text_color);
}
//+------------------------------------------------------------------+
//| Returns the color of the text on the element                     |
//+------------------------------------------------------------------+
color CElChart::TextColor(void)
{
   return m_text_color;
}
//+------------------------------------------------------------------+
//| Sets the text of the element                                     |
//+------------------------------------------------------------------+
void CElChart::TextFont(string text_font)
{
   m_text_font = text_font;
   if(IsShowed())
      ObjectSetString(ChartID(), m_name, OBJPROP_FONT, m_text_font);
}
//+------------------------------------------------------------------+
//| Returns the font name.                                           |
//+------------------------------------------------------------------+
string CElChart::TextFont(void)
{
   return m_text_font;
}
//+------------------------------------------------------------------+
//| Sets the background color of the element                         |
//+------------------------------------------------------------------+
void CElChart::BackgroundColor(color clr)
{
   m_bground_color = clr;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BGCOLOR, m_bground_color);
}
//+------------------------------------------------------------------+
//| Returns the background color of the element                      |
//+------------------------------------------------------------------+
color CElChart::BackgroundColor(void)
{
   return m_bground_color;
}
//+------------------------------------------------------------------+
//| Sets the color of the element borders                            |
//+------------------------------------------------------------------+
void CElChart::BorderColor(color clr)
{
   m_border_color = clr;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BORDER_COLOR, m_border_color);
}
//+------------------------------------------------------------------+
//| Returns the color of the element borders                         |
//+------------------------------------------------------------------+
color CElChart::BorderColor(void)
{
   return m_border_color;
}
//+------------------------------------------------------------------+
//| Sets the type of the element borders                             |
//+------------------------------------------------------------------+
void CElChart::BorderType(ENUM_BORDER_TYPE type)
{
   m_border_type = type;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_BORDER_TYPE, m_border_type);
}
//+------------------------------------------------------------------+
//| Returns the type of the element borders                          |
//+------------------------------------------------------------------+
ENUM_BORDER_TYPE CElChart::BorderType(void)
{
   return m_border_type;
}
//+------------------------------------------------------------------+
//| Enables or disables the read-only mode                           |
//+------------------------------------------------------------------+
void CElChart::ReadOnly(bool read_only)
{
   if(m_obj_type == OBJ_EDIT)
   {
      m_read_only = read_only;
      if(IsShowed())
         ObjectSetInteger(ChartID(), m_name, OBJPROP_READONLY, m_read_only);
   }
}
//+------------------------------------------------------------------+
//| Returns the chart cornet for binding the graphical object        |
//+------------------------------------------------------------------+
ENUM_BASE_CORNER CElChart::Corner(void)
{
   return m_corner;
}
//+------------------------------------------------------------------+
//| Sets the chart cornet for binding the graphical object           |
//+------------------------------------------------------------------+
void CElChart::Corner(ENUM_BASE_CORNER corner)
{
   m_corner = corner;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_CORNER, corner);
   for(int i = 0; i < m_elements.Total(); i++)
   {
      CNode* node = m_elements.At(i);
      CElChart* el = m_elements.At(i);
      el.Corner(corner);
   }
}
//+------------------------------------------------------------------+
//| Returns text alignment for OBJ_EDIT                              |
//+------------------------------------------------------------------+
ENUM_ALIGN_MODE CElChart::Align(void)
{
   return m_align;
}
//+------------------------------------------------------------------+
//| Text alignment for OBJ_EDIT                                      |
//+------------------------------------------------------------------+
void CElChart::Align(ENUM_ALIGN_MODE align)
{
   m_align = align;
   if(IsShowed())
      ObjectSetInteger(ChartID(), m_name, OBJPROP_ALIGN, m_align);
}
//+------------------------------------------------------------------+
//| Enables or disables the read-only mode                           |
//+------------------------------------------------------------------+
bool CElChart::ReadOnly(void)
{
   return m_read_only;
}
//+------------------------------------------------------------------+
//| This event occurs after editing element binding along the X axis |
//+------------------------------------------------------------------+
void CElChart::OnXCoordChange(void)
{
}
//+------------------------------------------------------------------+
//| This event occurs after editing element binding along the Y axis |
//+------------------------------------------------------------------+
void CElChart::OnYCoordChange(void)
{
}
//+------------------------------------------------------------------+
//| This event occurs after editing the element height               |
//+------------------------------------------------------------------+
void CElChart::OnHeightChange(void)
{
}
//+------------------------------------------------------------------+
//| This event occurs after editing the element width                |
//+------------------------------------------------------------------+
void CElChart::OnWidthChange(void)
{
}