//+------------------------------------------------------------------+
//|                                                        Mouse.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Definesgraphic.mqh"
#include "ObjectsGraphic.mqh"

#include <Charts\Chart.mqh>
//+------------------------------------------------------------------+
//| Класс для получения параметров мыши                              |
//+------------------------------------------------------------------+
class CMouse
  {
private:
   //--- Экземпляр класса для управления графиком
   CChart            m_chart;
   //--- Координаты
   int               m_x;
   int               m_y;
   //--- Номер окна, в котором находится курсор
   int               m_subwin;
   //--- Время соответствующее координате X
   datetime          m_time;
   //--- Уровень (цена) соответствующий координате Y
   double            m_level;
   //--- Состояние левой кнопки мыши (зажата/отжата)
   bool              m_left_button_state;
   //--- Счётчик вызовов
   ulong             m_call_counter;
   //--- Пауза между кликами левой кнопкой мыши (для определения двойного нажатия)
   uint              m_pause_between_clicks;
   //---
public:
                     CMouse(void);
                    ~CMouse(void);
   //--- Обработчик событий
   void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- Возвращает абсолютные координаты курсора мыши
   int               X(void)               const { return(m_x);                             }
   int               Y(void)               const { return(m_y);                             }
   //--- (1) Возвращает номер окна, в котором находится курсор, (2) время соответствующее координате X, 
   //    (3) уровень (цена) соответствующий координате Y
   int               SubWindowNumber(void) const { return(m_subwin);                        }
   datetime          Time(void)            const { return(m_time);                          }
   double            Level(void)           const { return(m_level);                         }
   //--- Возвращает состояние левой кнопки мыши (зажата/отжата)
   bool              LeftButtonState(void) const { return(m_left_button_state);             }

   //--- Возвращает (1) сохранённое при последнем вызове значение счётчика (ms) и 
   //    (2) разницу (ms) между вызовами обработчика события перемещения курсора мыши
   ulong             CallCounter(void)     const { return(m_call_counter);                  }
   ulong             GapBetweenCalls(void) const { return(::GetTickCount()-m_call_counter); }

   //--- Возвращает относительные координаты курсора мыши от переданного объекта-холста для рисования
   int               RelativeX(CRectCanvas &object);
   int               RelativeY(CRectCanvas &object);
   //---
private:
   //--- Проверка изменения состояния левой кнопки мыши
   bool              CheckChangeLeftButtonState(const string mouse_state);
   //--- Проверка двойного нажатия левой кнопки мыши
   void              CheckDoubleClick(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMouse::CMouse(void) : m_x(0),
                       m_y(0),
                       m_subwin(WRONG_VALUE),
                       m_time(NULL),
                       m_level(0.0),
                       m_left_button_state(false),
                       m_call_counter(::GetTickCount()),
                       m_pause_between_clicks(300)
  {
//--- Получим ID текущего графика
   m_chart.Attach();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMouse::~CMouse(void)
  {
//--- Отсоединиться от графика
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Обработка событий мыши                                           |
//+------------------------------------------------------------------+
void CMouse::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Обработка события перемещения курсора
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Координаты и состояние левой кнопки мыши
      m_x                 =(int)lparam;
      m_y                 =(int)dparam;
      m_left_button_state =CheckChangeLeftButtonState(sparam);
      //--- Сохраним значение счётчика вызовов
      m_call_counter=::GetTickCount();
      //--- Получим местоположение курсора
      if(!::ChartXYToTimePrice(m_chart.ChartId(),m_x,m_y,m_subwin,m_time,m_level))
         return;
      //--- Получим относительную координату Y
      if(m_subwin>0)
         m_y=m_y-m_chart.SubwindowY(m_subwin);
      return;
     }
//--- Обработка события нажатия на графике
   if(id==CHARTEVENT_CLICK)
     {
      //--- Проверим двойное нажатие левой кнопкой мыши
      CheckDoubleClick();
      return;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает относительную X-координату курсора мыши               |
//| от переданного объекта-холста для рисования                      |
//+------------------------------------------------------------------+
int CMouse::RelativeX(CRectCanvas &object)
  {
   return(m_x-object.X()+(int)ObjectGetInteger(0,object.ChartObjectName(),OBJPROP_XOFFSET));
  }
//+------------------------------------------------------------------+
//| Возвращает относительную Y-координату курсора мыши               |
//| от переданного объекта-холста для рисования                      |
//+------------------------------------------------------------------+
int CMouse::RelativeY(CRectCanvas &object)
  {
   return(m_y-object.Y()+(int)ObjectGetInteger(0,object.ChartObjectName(),OBJPROP_YOFFSET));
  }
//+------------------------------------------------------------------+
//| Проверка изменения состояния левой кнопки мыши                   |
//+------------------------------------------------------------------+
bool CMouse::CheckChangeLeftButtonState(const string mouse_state)
  {
   bool left_button_state=(bool)int(mouse_state);
//--- Отправим сообщение об изменении состояния левой кнопки мыши
   if(m_left_button_state!=left_button_state)
      ::EventChartCustom(m_chart.ChartId(),ON_CHANGE_MOUSE_LEFT_BUTTON,0,0.0,"");
//--- Вернуть текущее состояние левой кнопки мыши
   return(left_button_state);
  }
//+------------------------------------------------------------------+
//| Проверка двойного нажатия левой кнопки мыши                      |
//+------------------------------------------------------------------+
void CMouse::CheckDoubleClick(void)
  {
   static uint prev_depressed =0;
   static uint curr_depressed =::GetTickCount();
//--- Обновим значения
   prev_depressed =curr_depressed;
   curr_depressed =::GetTickCount();
//--- Определим время между нажатиями
   uint counter = curr_depressed - prev_depressed;
//--- Если между кликами прошло меньше времени, чем указано, отправим сообщение о двойном нажатии
   if(counter < m_pause_between_clicks)
     {
      ::EventChartCustom(m_chart.ChartId(),ON_DOUBLE_CLICK,counter,0.0,"");
     }
  }
//+------------------------------------------------------------------+
