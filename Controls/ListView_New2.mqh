//+------------------------------------------------------------------+
//|                                                ListView_New2.mqh |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Scrolls.mqh"
#include "Edit.mqh"
#include <ChartObjects/ChartObjectsTxtControls.mqh>



class CListView : public CElement
{
private:
    CWindow          *m_wnd;
   //---   ,   
   CElement         *m_combobox;
   //---    
   CRectLabel        m_area;
   CEdit             m_items[];
   CScrollV          m_scrollv;
   //---   
   string            m_value_items[];
   //---      
   int               m_items_total;
   int               m_visible_items_total;
   //--- (1)   (2)   
   int               m_selected_item_index;
   string            m_selected_item_text;
   //---   
   int               m_area_zorder;
   color             m_area_border_color;
   //---   
   int               m_item_zorder;
   int               m_item_y_size;
   color             m_item_color;
   color             m_item_color_hover;
   color             m_item_color_selected;
   color             m_item_text_color;
   color             m_item_text_color_hover;
   color             m_item_text_color_selected;
   //---     
   ENUM_ALIGN_MODE   m_align_mode;
   //---     
   bool              m_lights_hover;
   //---     (/)
   bool              m_mouse_state;
   //---     
   int               m_timer_counter;
public:
    CListView(void);
    ~CListView(void);

    bool              CreateListView(const long chart_id,const int window,const int x,const int y);

};

CListView::CListView()
{
}

CListView::~CListView()
{
}




























