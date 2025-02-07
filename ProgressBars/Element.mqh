//+------------------------------------------------------------------+
//|                                                      Element.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Objects.mqh"
#include "Colors.mqh"

//+------------------------------------------------------------------+
//| Base class of control                                            |
//+------------------------------------------------------------------+
class CElement
  {
protected:
   //--- Class instance for working with the color
   CColors           m_clr;
   //--- (1) Name of class and (2) program, (3) program type
   string            m_class_name;
   string            m_program_name;
   ENUM_PROGRAM_TYPE m_program_type;
   //--- Identifier and window number of the chart
   long              m_chart_id;
   int               m_subwin;
   //--- Identifier and index of control
   int               m_id;
   int               m_index;
   //--- Coordinates and boundaries
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_size;
   int               m_y_size;
   int               m_x_gap;
   int               m_y_gap;
   //--- Control states
   bool              m_is_visible;
   bool              m_is_dropdown;
   int               m_is_object_tabs;
   //--- Focus
   bool              m_mouse_focus;
   //--- Chart corner and anchor point of objects
   ENUM_BASE_CORNER  m_corner;
   ENUM_ANCHOR_POINT m_anchor;
   //--- Number of colors in the gradient
   int               m_gradient_colors_total;
   //--- Common array of pointers to all objects in this control
   CChartObject     *m_objects[];
   //---
public:
                     CElement(void);
                    ~CElement(void);
   //--- (1) Obtaining and setting the class name, (2) obtaining the program name, 
   //    (3) obtaining the program type, (4) setting the number of the chart window
   string            ClassName(void)                    const { return(m_class_name);           }
   void              ClassName(const string class_name)       { m_class_name=class_name;        }
   string            ProgramName(void)                  const { return(m_program_name);         }
   ENUM_PROGRAM_TYPE ProgramType(void)                  const { return(m_program_type);         }
   void              SubwindowNumber(const int number)        { m_subwin=number;                }
   //--- Obtaining the object pointer by the specified index
   CChartObject     *Object(const int index);
   //--- (1) Obtaining the number of the control objects, (2) emptying the object array
   int               ObjectsElementTotal(void)          const { return(::ArraySize(m_objects)); }
   void              FreeObjectsArray(void)                   { ::ArrayFree(m_objects);         }
   //--- Setting and obtaining the control identifier
   void              Id(const int id)                         { m_id=id;                        }
   int               Id(void)                           const { return(m_id);                   }
   //--- Setting and obtaining the control index
   void              Index(const int index)                   { m_index=index;                  }
   int               Index(void)                        const { return(m_index);                }
   //--- Boundaries
   int               X(void)                            const { return(m_x);                    }
   void              X(const int x)                           { m_x=x;                          }
   int               Y(void)                            const { return(m_y);                    }
   void              Y(const int y)                           { m_y=y;                          }
   int               X2(void)                           const { return(m_x+m_x_size);           }
   int               Y2(void)                           const { return(m_y+m_y_size);           }
   //--- Size
   int               XSize(void)                        const { return(m_x_size);               }
   void              XSize(const int x_size)                  { m_x_size=x_size;                }
   int               YSize(void)                        const { return(m_y_size);               }
   void              YSize(const int y_size)                  { m_y_size=y_size;                }
   //--- Indents from the edge point (xy)
   int               XGap(void)                         const { return(m_x_gap);                }
   void              XGap(const int x_gap)                    { m_x_gap=x_gap;                  }
   int               YGap(void)                         const { return(m_y_gap);                }
   void              YGap(const int y_gap)                    { m_y_gap=y_gap;                  }
   //--- Control states
   void              IsVisible(const bool flag)               { m_is_visible=flag;              }
   bool              IsVisible(void)                    const { return(m_is_visible);           }
   void              IsDropdown(const bool flag)              { m_is_dropdown=flag;             }
   bool              IsDropdown(void)                   const { return(m_is_dropdown);          }
   void              IsObjectTabs(const int index)            { m_is_object_tabs=index;         }
   int               IsObjectTabs(void)                 const { return(m_is_object_tabs);       }
   //--- (1) Focus, (2) setting the gradient size
   bool              MouseFocus(void)                   const { return(m_mouse_focus);          }
   void              MouseFocus(const bool focus)             { m_mouse_focus=focus;            }
   void              GradientColorsTotal(const int total)     { m_gradient_colors_total=total;  }
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the control
   virtual void      Moving(const int x,const int y) {}
   //--- (1) Showing, (2) hiding, (3) resetting, (4) deleting
   virtual void      Show(void) {}
   virtual void      Hide(void) {}
   virtual void      Reset(void) {}
   virtual void      Delete(void) {}
   //--- (1) Setting, (2) resetting of priorities for left clicking on mouse
   virtual void      SetZorders(void) {}
   virtual void      ResetZorders(void) {}
   //---
protected:
   //--- Method to add pointers of primitive objects to the common array
   void              AddToArray(CChartObject &object);
   //--- Initializing the array gradient
   void              InitColorArray(const color outer_color,const color hover_color,color &color_array[]);
   //--- Changing the object color
   void              ChangeObjectColor(const string name,const bool mouse_focus,const ENUM_OBJECT_PROPERTY_INTEGER property,
                                       const color outer_color,const color hover_color,const color &color_array[]);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElement::CElement(void) : m_x(0),
                           m_y(0),
                           m_x2(0),
                           m_y2(0),
                           m_x_size(0),
                           m_y_size(0),
                           m_x_gap(0),
                           m_y_gap(0),
                           m_is_visible(true),
                           m_is_dropdown(false),
                           m_mouse_focus(false),
                           m_id(WRONG_VALUE),
                           m_index(WRONG_VALUE),
                           m_gradient_colors_total(3),
                           m_is_object_tabs(WRONG_VALUE),
                           m_corner(CORNER_LEFT_UPPER),
                           m_anchor(ANCHOR_LEFT_UPPER),
                           m_program_name(PROGRAM_NAME),
                           m_program_type(PROGRAM_TYPE),
                           m_class_name("")
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElement::~CElement(void)
  {
  }
//+------------------------------------------------------------------+
//| Returns the object pointer of the control by index               |
//+------------------------------------------------------------------+
CChartObject *CElement::Object(const int index)
  {
   int array_size=::ArraySize(m_objects);
//--- Verifying the size of the object array
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > No ("+m_class_name+") objects in this control!");
      return(NULL);
     }
//--- Correction in case the size was exceeded
   int i=(index>=array_size)? array_size-1 :(index<0)? 0 : index;
//--- Return the object pointer
   return(m_objects[i]);
  }
//+------------------------------------------------------------------+
//| Adds object pointer to an array                                  |
//+------------------------------------------------------------------+
void CElement::AddToArray(CChartObject &object)
  {
   int size=ObjectsElementTotal();
   ::ArrayResize(m_objects,size+1);
   m_objects[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
//| Initialization of the gradient array                             |
//+------------------------------------------------------------------+
void CElement::InitColorArray(const color outer_color,const color hover_color,color &color_array[])
  {
//--- Array of the gradient colors
   color colors[2];
   colors[0]=outer_color;
   colors[1]=hover_color;
//--- Formation of the color array
   m_clr.Gradient(colors,color_array,m_gradient_colors_total);
  }
//+------------------------------------------------------------------+
//| Changing of object color when hovering the cursor over it        |
//+------------------------------------------------------------------+
void CElement::ChangeObjectColor(const string name,const bool mouse_focus,const ENUM_OBJECT_PROPERTY_INTEGER property,
                                 const color outer_color,const color hover_color,const color &color_array[])
  {
   if(::ArraySize(color_array)<1)
      return;
//--- Obtain the current object color
   color current_color=(color)::ObjectGetInteger(m_chart_id,name,property);
//--- If the cursor is over the object
   if(mouse_focus)
     {
      //--- Leave, if the specified color has been reached
      if(current_color==hover_color)
         return;
      //--- Move from the first to the last one
      for(int i=0; i<m_gradient_colors_total; i++)
        {
         //--- If colors do not match, move to the following
         if(color_array[i]!=current_color)
            continue;
         //---
         color new_color=(i+1==m_gradient_colors_total)? color_array[i]: color_array[i+1];
         //--- Change color
         ::ObjectSetInteger(m_chart_id,name,property,new_color);
         break;
        }
     }
//--- If the cursor is not in the area of the object
   else
     {
      //--- Leave, if the specified color has been reached
      if(current_color==outer_color)
         return;
      //--- Move from the last to the first one
      for(int i=m_gradient_colors_total-1; i>=0; i--)
        {
         //--- If colors do not match, move to the following
         if(color_array[i]!=current_color)
            continue;
         //---
         color new_color=(i-1<0)? color_array[i]: color_array[i-1];
         //--- Change color
         ::ObjectSetInteger(m_chart_id,name,property,new_color);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
