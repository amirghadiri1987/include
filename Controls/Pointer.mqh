//+------------------------------------------------------------------+
//|                                                      Pointer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
//+------------------------------------------------------------------+
//| Класс для создания указателя курсора мыши                        |
//+------------------------------------------------------------------+
class CPointer : public CElement
  {
private:
   //--- Картинки для указателя
   string            m_file_on;
   string            m_file_off;
   //--- Тип указателя
   ENUM_MOUSE_POINTER m_type;
   //--- Состояние указателя
   bool              m_state;
   //---
public:
                     CPointer(void);
                    ~CPointer(void);
   //--- Создаёт ярлык указателя
   bool              CreatePointer(const long chart_id,const int subwin);
   //---
private:
   bool              CreateCanvas(void);
   //---
public:
   //--- Установка ярлыков для указателя
   void              FileOn(const string file_path)       { m_file_on=file_path;  }
   void              FileOff(const string file_path)      { m_file_off=file_path; }
   //--- Возвращение и установка (1) типа указателя, (2) состояния указателя
   ENUM_MOUSE_POINTER Type(void)                    const { return(m_type);       }
   void              Type(ENUM_MOUSE_POINTER type)        { m_type=type;          }
   bool              State(void)                    const { return(m_state);      }
   void              State(const bool state);
   //--- Обновление координат
   void              UpdateX(const int mouse_x)           { ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,mouse_x-CElementBase::XGap()); }
   void              UpdateY(const int mouse_y)           { ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,mouse_y-CElementBase::YGap()); }
   //---
public:
   //--- Перемещение элемента
   virtual void      Moving(const int mouse_x,const int mouse_y);
   //--- Управление
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- Рисует элемент
   virtual void      Draw(void);
   //---
private:
   //--- Установка картинок для указателя курсора мыши
   void              SetPointerBmp(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPointer::CPointer(void) : m_state(true),
                           m_file_on(""),
                           m_file_off(""),
                           m_type(MP_X_RESIZE)
  {
//--- Сохраним имя класса элемента в базовом классе
   CElementBase::ClassName(CLASS_NAME);
//--- Значение индекса элемента по умолчанию
   CElement::Index(0);
//--- Прозрачный фон
   m_alpha=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPointer::~CPointer(void)
  {
   Delete();
  }
//+------------------------------------------------------------------+
//| Создаёт указатель                                                |
//+------------------------------------------------------------------+
bool CPointer::CreatePointer(const long chart_id,const int subwin)
  {
//--- Свойства
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x_size   =(m_x_size<1)? 16 : m_x_size;
   m_y_size   =(m_y_size<1)? 16 : m_y_size;
//--- Сохранить указатель на себя
   CElement::MainPointer(this);
//--- Установка картинок для указателя
   SetPointerBmp();
//--- Создаёт элемент
   if(!CreateCanvas())
      return(false);
//--- Скрыть элемент
   Hide();
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт объект для рисования                                     |
//+------------------------------------------------------------------+
bool CPointer::CreateCanvas(void)
  {
//--- Формирование имени объекта
   string name=CElementBase::ElementName("pointer");
//--- Создание объекта
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- По умолчанию отключено
   State(false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Установка состояния указателя                                    |
//+------------------------------------------------------------------+
void CPointer::State(const bool state)
  {
//--- Выйти, если повтор
   if(state==m_state)
      return;
//--- Сохранить состояние
   m_state=state;
//--- Сохранить индекс выбранного изображения
   CElement::ChangeImage(0,CElement::SelectedImage());
//--- Рисуем картинку
   Draw();
//--- Применить
   CElement::Update(true);
  }
//+------------------------------------------------------------------+
//| Перемещение элемента                                             |
//+------------------------------------------------------------------+
void CPointer::Moving(const int mouse_x,const int mouse_y)
  {
   UpdateX(mouse_x);
   UpdateY(mouse_y);
  }
//+------------------------------------------------------------------+
//| Показывает элемент                                               |
//+------------------------------------------------------------------+
void CPointer::Show(void)
  {
//--- Выйти, если элемент уже видим
   if(CElementBase::IsVisible())
      return;
//--- Сделать видимыми все объекты
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
//--- Состояние видимости
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Скрывает элемент                                                 |
//+------------------------------------------------------------------+
void CPointer::Hide(void)
  {
//--- Выйти, если элемент скрыт
   if(!CElementBase::IsVisible())
      return;
//--- Скрыть объекты
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
//--- Состояние видимости
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Перерисовка                                                      |
//+------------------------------------------------------------------+
void CPointer::Reset(void)
  {
//--- Скрыть и показать
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Удаление                                                         |
//+------------------------------------------------------------------+
void CPointer::Delete(void)
  {
   m_canvas.Destroy();
//--- Сохранить состояние
   m_state=true;
//--- Состояние видимости
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Рисует элемент                                                   |
//+------------------------------------------------------------------+
void CPointer::Draw(void)
  {
//--- Нарисовать задний фон
   CElement::DrawBackground();
//--- Нарисовать картинку
   CElement::DrawImage();
  }
//+------------------------------------------------------------------+
//| Установка картинок для указателя по типу указателя               |
//+------------------------------------------------------------------+
void CPointer::SetPointerBmp(void)
  {
   switch(m_type)
     {
      case MP_X_RESIZE :
         m_file_on  =(string)RESOURCE_POINTER_X_RS;
         m_file_off =(string)RESOURCE_POINTER_X_RS_BLUE;
         break;
      case MP_Y_RESIZE :
         m_file_on  =(string)RESOURCE_POINTER_Y_RS;
         m_file_off =(string)RESOURCE_POINTER_Y_RS_BLUE;
         break;
      case MP_XY1_RESIZE :
         m_file_on  =(string)RESOURCE_POINTER_XY1_RS;
         m_file_off =(string)RESOURCE_POINTER_XY1_RS_BLUE;
         break;
      case MP_XY2_RESIZE :
         m_file_on  =(string)RESOURCE_POINTER_XY2_RS;
         m_file_off =(string)RESOURCE_POINTER_XY2_RS_BLUE;
         break;
      case MP_WINDOW_RESIZE :
        {
         CElement::AddImagesGroup(0,0);
         CElement::AddImage(0,(string)RESOURCE_POINTER_X_RS);
         CElement::AddImage(0,(string)RESOURCE_POINTER_Y_RS);
         break;
        }
      case MP_X_RESIZE_RELATIVE :
         m_file_on  =(string)RESOURCE_POINTER_X_RS_REL;
         m_file_off =(string)RESOURCE_POINTER_X_RS_REL;
         break;
      case MP_Y_RESIZE_RELATIVE :
         m_file_on  =(string)RESOURCE_POINTER_Y_RS_REL;
         m_file_off =(string)RESOURCE_POINTER_Y_RS_REL;
         break;
      case MP_X_SCROLL :
         m_file_on  =(string)RESOURCE_POINTER_X_SCROLL;
         m_file_off =(string)RESOURCE_POINTER_X_SCROLL_BLUE;
         break;
      case MP_Y_SCROLL :
         m_file_on  =(string)RESOURCE_POINTER_Y_SCROLL;
         m_file_off =(string)RESOURCE_POINTER_Y_SCROLL_BLUE;
         break;
      case MP_TEXT_SELECT :
         m_file_on  =(string)RESOURCE_POINTER_TEXT_SELECT;
         m_file_off =(string)RESOURCE_POINTER_TEXT_SELECT;
         break;
     }
//--- Если указан пользовательский тип (MP_CUSTOM)
   if(m_type==MP_CUSTOM)
      if(m_file_on=="" || m_file_off=="")
         ::Print(__FUNCTION__," > Для указателя курсора нужно установить картинки!");
//--- Установить картинку
   if(m_type!=MP_WINDOW_RESIZE)
     {
      CElement::IconFile((uint)m_file_on);
      CElement::IconFileLocked((uint)m_file_off);
     }
  }
//+------------------------------------------------------------------+
