//+------------------------------------------------------------------+
//|                                                  ElementBase.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Mouse.mqh"
#include "ObjectsGraphic.mqh"


#include "Common.mqh"

//+------------------------------------------------------------------+
//| Базовый класс элемента управления                                |
//+------------------------------------------------------------------+
class CElementBase
  {
protected:
   //--- Экземпляр класса для получения параметров мыши
   CMouse           *m_mouse;
   //--- Экземпляр класса для работы с цветом
   CColors           m_clr;
   //--- Экземпляр класса для работы с графиком
   CChart            m_chart;
   //--- (1) Имя класса и (2) программы, (3) тип программы
   string            m_class_name;
   string            m_program_name;
   ENUM_PROGRAM_TYPE m_program_type;
   //--- (1) Часть имени (тип элемента), (2) имя элемента
   string            m_name_part;
   string            m_element_name;
   //--- Идентификатор и номер окна графика
   long              m_chart_id;
   int               m_subwin;
   //--- Идентификатор последнего созданного элемента управления
   int               m_last_id;
   //--- Идентификатор и индекс элемента
   int               m_id;
   int               m_index;
   //--- Координаты и границы
   int               m_x;
   int               m_y;
   //--- Размер
   int               m_x_size;
   int               m_y_size;
   //--- Отступы
   int               m_x_gap;
   int               m_y_gap;
   //--- Состояния элемента:
   bool              m_is_tooltip;     // всплывающая подсказка
   bool              m_is_visible;     // видимость
   bool              m_is_dropdown;    // выпадающий элемент
   bool              m_is_locked;      // блокировка
   bool              m_is_available;   // доступность
   bool              m_is_pressed;     // нажат/отжат
   bool              m_is_highlighted; // подсветка при наведении
   //--- Фокус курсора мыши
   bool              m_mouse_focus;
   //--- Для определения момента пересечения курсором мыши границ элемента
   bool              m_is_mouse_focus;
   //--- Угол графика и точка привязки объектов
   ENUM_BASE_CORNER  m_corner;
   ENUM_ANCHOR_POINT m_anchor;
   //--- Режим автоматического изменения размеров элемента
   bool              m_auto_xresize_mode;
   bool              m_auto_yresize_mode;
   //--- Отступ от правого/нижнего края формы в режиме авто-изменения ширины/высоты элемента
   int               m_auto_xresize_right_offset;
   int               m_auto_yresize_bottom_offset;
   //--- Точки привязки элемента в правой и нижней стороне окна
   bool              m_anchor_right_window_side;
   bool              m_anchor_bottom_window_side;
   //---
public:
                     CElementBase(void);
                    ~CElementBase(void);
   //--- (1) Сохраняет и (2) возвращает указатель мыши
   void              MousePointer(CMouse &object)                    { m_mouse=::GetPointer(object);         }
   CMouse           *MousePointer(void)                        const { return(::GetPointer(m_mouse));        }
   //--- (1) Сохраняет и (2) возвращает имя класса
   void              ClassName(const string class_name)              { m_class_name=class_name;              }
   string            ClassName(void)                           const { return(m_class_name);                 }
   //--- (1) Сохраняет и (2) возвращает часть имени элемента
   void              NamePart(const string name_part)                { m_name_part=name_part;                }
   string            NamePart(void)                            const { return(m_name_part);                  }
   //--- (1) Формирование имени объекта, (2) проверка строки на содержание значимой части имени элемента
   string            ElementName(const string name_part="");
   bool              CheckElementName(const string object_name);
   //--- (1) Получение имени программы, (2) получение типа программы
   string            ProgramName(void)                         const { return(m_program_name);               }
   ENUM_PROGRAM_TYPE ProgramType(void)                         const { return(m_program_type);               }
   //--- (1) Установка/получение номера окна графика, (2) получение идентификатора графика
   void              SubwindowNumber(const int number)               { m_subwin=number;                      }
   int               SubwindowNumber(void)                     const { return(m_subwin);                     }
   long              ChartId(void)                             const { return(m_chart_id);                   }
   //--- Методы для сохранения и получения id последнего созданного элемента
   int               LastId(void)                              const { return(m_last_id);                    }
   void              LastId(const int id)                            { m_last_id=id;                         }
   //--- Установка и получение идентификатора элемента
   void              Id(const int id)                                { m_id=id;                              }
   int               Id(void)                                  const { return(m_id);                         }
   //--- Установка и получение индекса элемента
   void              Index(const int index)                          { m_index=index;                        }
   int               Index(void)                               const { return(m_index);                      }
   //--- Координаты и границы
   int               X(void)                                   const { return(m_x);                          }
   void              X(const int x)                                  { m_x=x;                                }
   int               Y(void)                                   const { return(m_y);                          }
   void              Y(const int y)                                  { m_y=y;                                }
   int               X2(void)                                  const { return(m_x+m_x_size);                 }
   int               Y2(void)                                  const { return(m_y+m_y_size);                 }
   //--- Размер
   int               XSize(void)                               const { return(m_x_size);                     }
   void              XSize(const int x_size)                         { m_x_size=x_size;                      }
   int               YSize(void)                               const { return(m_y_size);                     }
   void              YSize(const int y_size)                         { m_y_size=y_size;                      }
   //--- Отступы от крайней точки (xy)
   int               XGap(void)                                const { return(m_x_gap);                      }
   void              XGap(const int x_gap)                           { m_x_gap=x_gap;                        }
   int               YGap(void)                                const { return(m_y_gap);                      }
   void              YGap(const int y_gap)                           { m_y_gap=y_gap;                        }
   //--- Угол графика и точка привязки объектов
   ENUM_BASE_CORNER  Corner(void)                              const { return(m_corner);                     }
   void              Corner(const ENUM_BASE_CORNER corner)           { m_corner=corner;                      }
   ENUM_ANCHOR_POINT Anchor(void)                              const { return(m_anchor);                     }
   void              Anchor(const ENUM_ANCHOR_POINT anchor)          { m_anchor=anchor;                      }
   //--- Всплывающая подсказка
   void              IsTooltip(const bool state)                     { m_is_tooltip=state;                   }
   bool              IsTooltip(void)                           const { return(m_is_tooltip);                 }
   //--- Состояние видимости элемента
   void              IsVisible(const bool state)                     { m_is_visible=state;                   }
   bool              IsVisible(void)                           const { return(m_is_visible);                 }
   //--- Признак выпадающего элемента
   void              IsDropdown(const bool state)                    { m_is_dropdown=state;                  }
   bool              IsDropdown(void)                          const { return(m_is_dropdown);                }
   //--- Снятие и блокировка элемента
   virtual void      IsLocked(const bool state)                      { m_is_locked=state;                    }
   bool              IsLocked(void)                            const { return(m_is_locked);                  }
   //--- Признак доступного элемента
   virtual void      IsAvailable(const bool state)                   { m_is_available=state;                 }
   bool              IsAvailable(void)                         const { return(m_is_available);               }
   //--- Признак нажатого элемента
   virtual void      IsPressed(const bool state)                     { m_is_pressed=state;                   }
   bool              IsPressed(void)                           const { return(m_is_pressed);                 }
   //--- Признак подсвечиваемого элемента
   void              IsHighlighted(const bool state)                 { m_is_highlighted=state;               }
   bool              IsHighlighted(void)                       const { return(m_is_highlighted);             }
   //--- (1) Фокус, (2) момент входа/выхода в/из фокуса
   bool              MouseFocus(void)                          const { return(m_mouse_focus);                }
   void              MouseFocus(const bool focus)                    { m_mouse_focus=focus;                  }
   bool              IsMouseFocus(void)                        const { return(m_is_mouse_focus);             }
   void              IsMouseFocus(const bool focus)                  { m_is_mouse_focus=focus;               }
   //--- (1) Режим авто-изменения ширины элемента, (2) получение/установка отступа от правого края формы
   bool              AutoXResizeMode(void)                     const { return(m_auto_xresize_mode);          }
   void              AutoXResizeMode(const bool flag)                { m_auto_xresize_mode=flag;             }
   int               AutoXResizeRightOffset(void)              const { return(m_auto_xresize_right_offset);  }
   void              AutoXResizeRightOffset(const int offset)        { m_auto_xresize_right_offset=offset;   }
   //--- (1) Режим авто-изменения высоты элемента, (2) получение/установка отступа от нижнего края формы
   bool              AutoYResizeMode(void)                     const { return(m_auto_yresize_mode);          }
   void              AutoYResizeMode(const bool flag)                { m_auto_yresize_mode=flag;             }
   int               AutoYResizeBottomOffset(void)             const { return(m_auto_yresize_bottom_offset); }
   void              AutoYResizeBottomOffset(const int offset)       { m_auto_yresize_bottom_offset=offset;  }
   //--- Режим (получение/установка) привязки элемента к (1) правому и (2) нижнему краю окна
   bool              AnchorRightWindowSide(void)               const { return(m_anchor_right_window_side);   }
   void              AnchorRightWindowSide(const bool flag)          { m_anchor_right_window_side=flag;      }
   bool              AnchorBottomWindowSide(void)              const { return(m_anchor_bottom_window_side);  }
   void              AnchorBottomWindowSide(const bool flag)         { m_anchor_bottom_window_side=flag;     }
   //---
public:
   //--- Обработчик событий графика
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Таймер
   virtual void      OnEventTimer(void) {}
   //--- Перемещение элемента
   virtual void      Moving(const bool only_visible=true) {}
   //--- (1) Показ, (2) скрытие, (3) перемещение на верхний слой, (4) удаление
   virtual void      Show(void) {}
   virtual void      Hide(void) {}
   virtual void      Reset(void) {}
   virtual void      Delete(void) {}
   //--- (1) Установка, (2) сброс приоритетов на нажитие левой кнопки мыши
   virtual void      SetZorders(void) {}
   virtual void      ResetZorders(void) {}
   //--- Сброс цвета элемента
   virtual void      ResetColors(void) {}
   //--- Обновляет элемент для отображения последних изменений
   virtual void      Update(const bool redraw=false) {}
   //--- Обновляет элемент для отображения последних изменений
   virtual void      Draw(void) {}
   //--- Изменить ширину по правому краю окна
   virtual void      ChangeWidthByRightWindowSide(void) {}
   //--- Изменить высоту по нижнему краю окна
   virtual void      ChangeHeightByBottomWindowSide(void) {}

   //--- Проверка расположения курсора мыши в подокне программы
   bool              CheckSubwindowNumber(void);
   //--- Проверка расположения курсора мыши над элементом
   void              CheckMouseFocus(void);
   //--- Проверка пересечения границ элемента
   bool              CheckCrossingBorder(void);
   //---
protected:
   //--- Получение идентификатора из имени кнопки
   int               IdFromObjectName(const string object_name);
   //--- Получение индекса из имени пункта меню
   int               IndexFromObjectName(const string object_name);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElementBase::CElementBase(void) : m_program_name(PROGRAM_NAME),
                                   m_program_type(PROGRAM_TYPE),
                                   m_class_name(""),
                                   m_name_part(""),
                                   m_last_id(0),
                                   m_x(0),
                                   m_y(0),
                                   m_x_size(0),
                                   m_y_size(0),
                                   m_x_gap(0),
                                   m_y_gap(0),
                                   m_is_tooltip(false),
                                   m_is_visible(true),
                                   m_is_dropdown(false),
                                   m_is_locked(false),
                                   m_is_pressed(false),
                                   m_is_available(true),
                                   m_is_highlighted(true),
                                   m_mouse_focus(false),
                                   m_is_mouse_focus(false),
                                   m_id(WRONG_VALUE),
                                   m_index(WRONG_VALUE),
                                   m_corner(CORNER_LEFT_UPPER),
                                   m_anchor(ANCHOR_LEFT_UPPER),
                                   m_auto_xresize_mode(false),
                                   m_auto_yresize_mode(false),
                                   m_auto_xresize_right_offset(0),
                                   m_auto_yresize_bottom_offset(0),
                                   m_anchor_right_window_side(false),
                                   m_anchor_bottom_window_side(false)
  {
//--- Получим ID текущего графика
   m_chart.Attach();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElementBase::~CElementBase(void)
  {
//--- Отсоединиться от графика
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Возвращает сформированное имя элемента                           |
//+------------------------------------------------------------------+
string CElementBase::ElementName(const string name_part="")
  {
   m_name_part=(m_name_part!="")? m_name_part : name_part;
//--- Формирование имени объекта
   string name="";
   if(m_index==WRONG_VALUE)
      name=m_program_name+"_"+m_name_part+"_"+(string)CElementBase::Id();
   else
      name=m_program_name+"_"+m_name_part+"_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//---
   return(name);
  }
//+------------------------------------------------------------------+
//| Возвращает сформированное имя элемента                           |
//+------------------------------------------------------------------+
bool CElementBase::CheckElementName(const string object_name)
  {
//--- Если нажатие было не на этом элементе
   if(::StringFind(object_name,m_program_name+"_"+m_name_part+"_")<0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Проверка расположения курсора мыши в подокне программы           |
//+------------------------------------------------------------------+
bool CElementBase::CheckSubwindowNumber(void)
  {
   return(m_subwin==m_mouse.SubWindowNumber());
  }
//+------------------------------------------------------------------+
//| Проверка расположения курсора мыши над элементом                 |
//+------------------------------------------------------------------+
void CElementBase::CheckMouseFocus(void)
  {
   m_mouse_focus=m_mouse.X()>X() && m_mouse.X()<=X2() && m_mouse.Y()>Y() && m_mouse.Y()<=Y2();
  }
//+------------------------------------------------------------------+
//| Проверка пересечения границ элемента                             |
//+------------------------------------------------------------------+
bool CElementBase::CheckCrossingBorder(void)
  {
//--- Если это момент пересечения границ элемента
   if((MouseFocus() && !IsMouseFocus()) || (!MouseFocus() && IsMouseFocus()))
     {
      IsMouseFocus(MouseFocus());
      //--- Сообщение о пересечении в элемент
      if(MouseFocus())
         ::EventChartCustom(m_chart_id,ON_MOUSE_FOCUS,m_id,m_index,m_class_name);
      //--- Сообщение о пересечении из элемента
      else
         ::EventChartCustom(m_chart_id,ON_MOUSE_BLUR,m_id,m_index,m_class_name);
      //---
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Извлекает идентификатор из имени объекта                         |
//+------------------------------------------------------------------+
int CElementBase::IdFromObjectName(const string object_name)
  {
//--- Получим id из имени объекта
   int    length =::StringLen(object_name);
   int    pos    =::StringFind(object_name,"__",0);
   string id     =::StringSubstr(object_name,pos+2,length-1);
//--- Вернуть id пункта
   return((int)id);
  }
//+------------------------------------------------------------------+
//| Извлекает индекс из имени объекта                                |
//+------------------------------------------------------------------+
int CElementBase::IndexFromObjectName(const string object_name)
  {
   ushort u_sep=0;
   string result[];
   int    array_size=0;
//--- Получим код разделителя
   u_sep=::StringGetCharacter("_",0);
//--- Разобьём строку
   ::StringSplit(object_name,u_sep,result);
   array_size=::ArraySize(result)-1;
//--- Проверка выхода за диапазон массива
   if(array_size-2<0)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Вернуть индекс пункта
   return((int)result[array_size-2]);
  }
//+------------------------------------------------------------------+
