//+------------------------------------------------------------------+
//|                                                 ComboBox_New.mqh |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "WndContainer.mqh"
#include "Edit.mqh"
#include "BmpButton.mqh"
#include "ListView_New.mqh"
//+------------------------------------------------------------------+
//| Resources                                                        |
//+------------------------------------------------------------------+
//--- Can not place the same file into resource twice
#resource "res\\DropOn.bmp"                 // image file
#resource "res\\DropOff.bmp"                // image file
//+------------------------------------------------------------------+
//| Class CComboBox                                                  |
//| Usage: drop-down list                                            |
//+------------------------------------------------------------------+
class CCombo : public CWndContainer
{
private:
    //--- dependent controls
   CEdit             m_edit;                // the entry field object
   CBmpButton        m_drop;                // the button object
   CListView         m_list;                // the drop-down list object

   int               m_area_zorder;
   int               m_button_zorder;
   int               m_zorder;
   bool              m_combobox_state;
   bool              m_mouse_state;
   int               m_item_height;         // height of visible row
   int               m_view_items;          // number of visible rows in the drop-down list
   bool              flage;                 // hidhe or show combobox

public:
    CCombo(void);
    ~CCombo(void);
    //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- fill
   bool              AddItem(const string item,const long value=0);
   //--- set up
   void              ListViewItems(const int value) { m_view_items=value; }
   //--- data
   virtual bool      ItemAdd(const string item,const long value=0)                    { return(m_list.ItemAdd(item,value));          }
   virtual bool      ItemInsert(const int index,const string item,const long value=0) { return(m_list.ItemInsert(index,item,value)); }
   virtual bool      ItemUpdate(const int index,const string item,const long value=0) { return(m_list.ItemUpdate(index,item,value)); }
   virtual bool      ItemDelete(const int index)                                      { return(m_list.ItemDelete(index));            }
   virtual bool      ItemsClear(void)                                                 { return(m_list.ItemsClear());                 }
   virtual void      SetBacgroundItem(color BcGI, color BcGITS) {m_list.SetBackGroundItem(BcGI,BcGITS);}
   CListView        *GetListViewPointer(void)                         { return(::GetPointer(m_list));                }
   bool              ComboBoxState(void)                        const { return(m_combobox_state);                        }
   void              ComboBoxState(const bool state);
   void              ChangeComboBoxListState(void);
   
   //--- data
   string            Select(void) { return(m_edit.Text()); }
   bool              Select(const int index);
   bool              SelectByText(const string text);
   bool              SelectByValue(const long value);
   //--- data (read only)
   long              Value(void) { return(m_list.Value()); }
   //--- state
   virtual bool      Show(void);
   virtual bool      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- (1) , (2)       
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);

protected:
   //--- create dependent controls
   virtual bool      CreateEdit(void);
   virtual bool      CreateButton(void);
   virtual bool      CreateList(void);
   //--- handlers of the dependent controls events
   virtual bool      OnClickEdit(void);
   virtual bool      OnClickButton(void);
   virtual bool      OnChangeList(void);
   //--- show drop-down list
   bool              ListShow(void);
   bool              ListHide(void);
   void              CheckListHide(const int id,int x,int y);

private:
    bool              OnClickButton(const string clicked_object);
    void              CheckPressedOverButton(void);
};

CCombo::CCombo(void) :  m_combobox_state(true)
{
    m_zorder        =0;
    m_area_zorder   =1;
    m_button_zorder =2;
}

CCombo::~CCombo(void)
{
}

bool CCombo::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{


    return true;
}