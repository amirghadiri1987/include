//+------------------------------------------------------------------+
//|                                               ObjectsGraphic.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#include "Enums.mqh"
#include "Definesgraphic.mqh"
#include "Fonts.mqh"
#include "Colors.mqh"
#include <Graphics\Graphic.mqh>
#include <ChartObjects\ChartObjectSubChart.mqh>



#include "Resources.mqh"



//--- Список классов в файле для быстрого перехода (Alt+G)
class CImage;
class CRectCanvas;
class CSubChart;
//+------------------------------------------------------------------+
//| Класс для хранения данных изображения                            |
//+------------------------------------------------------------------+
class CImage
  {
protected:
   CResources        m_resources;
   
   uint              m_image_data[];   // Массив пикселей картинки (цвета)
   uint              m_image_width;    // Ширина изображения
   uint              m_image_height;   // Высота изображения
   string            m_bmp_path;       // Путь к файлу изображения
   uint              m_resource_index; // Индекс к ресурсу
   //---
public:
                     CImage(void);
                    ~CImage(void);
   //--- (1) Размер массива данных, (2) установить/вернуть данные (цвет пикселя)
   uint              DataTotal(void)                             { return(::ArraySize(m_image_data)); }
   uint              Data(const uint data_index)                 { return(m_image_data[data_index]);  }
   void              Data(const uint data_index,const uint data) { m_image_data[data_index]=data;     }
   //--- Установить/вернуть ширину изображения
   void              Width(const uint width)                     { m_image_width=width;               }
   uint              Width(void)                                 { return(m_image_width);             }
   //--- Установить/вернуть высоту изображения
   void              Height(const uint height)                   { m_image_height=height;             }
   uint              Height(void)                                { return(m_image_height);            }
   //--- Установить/вернуть путь к изображению
   void              BmpPath(const string bmp_file_path)         { m_bmp_path=bmp_file_path;          }
   string            BmpPath(void)                               { return(m_bmp_path);                }
   //--- Установить/вернуть индекс к изображению
   void              ResourceIndex(const uint resource_index)    { m_resource_index=resource_index;   }
   uint              ResourceIndex(void)                         { return(m_resource_index);          }
   
   //--- Читает и сохраняет данные переданного изображения (путь к ресурсу)
   bool              ReadImageData(const string bmp_file_path);
   //--- Читает и сохраняет данные переданного изображения (индекс к ресурсу)
   bool              ReadImageData(const uint resource_index);
   //--- Копирует данные переданного изображения
   void              CopyImageData(CImage &array_source);
   //--- Удаляет данные изображения
   void              DeleteImageData(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CImage::CImage(void) : m_image_width(0),
                       m_image_height(0),
                       m_bmp_path(""),
                       m_resource_index(INT_MAX)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CImage::~CImage(void)
  {
   DeleteImageData();
  }
//+------------------------------------------------------------------+
//| Сохраняет переданную картинку (путь к ресурсу) в массив          |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const string bmp_file_path)
  {
//--- Выйти, если пустая строка
   if(bmp_file_path=="")
      return(false);
//--- Сохраним путь к изображению
   m_bmp_path=bmp_file_path;
//--- Сбросить последнюю ошибку
   ::ResetLastError();
//--- Прочитать и сохранить данные изображения
   if(!::ResourceReadImage("::"+m_bmp_path,m_image_data,m_image_width,m_image_height))
     {
      ::Print(__FUNCTION__," > Ошибка при чтении изображения ("+m_bmp_path+"): ",::GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Сохраняет переданную картинку (индекс к ресурсу) в массив        |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const uint resource_index)
  {
//--- Выйти, если пустая строка
   if(resource_index == INT_MAX)
      return(false);
//--- Сохраним индекс к ресурсу
   m_resource_index=resource_index;
//--- Сбросить последнюю ошибку
   ::ResetLastError();
//--- Прочитать и сохранить данные изображения
   if(m_resources.GetData(resource_index, m_image_data, m_image_width, m_image_height) == "")
     return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Копирует данные переданного изображения                          |
//+------------------------------------------------------------------+
void CImage::CopyImageData(CImage &array_source)
  {
//--- Получим размер массива-источника
   uint source_data_total =array_source.DataTotal();
//--- Изменить размер массива-приёмника
   ::ArrayResize(m_image_data,source_data_total);
//--- Копируем данные
   for(uint i=0; i<source_data_total; i++)
      m_image_data[i]=array_source.Data(i);
  }
//+------------------------------------------------------------------+
//| Удаляет данные изображения                                       |
//+------------------------------------------------------------------+
void CImage::DeleteImageData(void)
  {
   ::ArrayFree(m_image_data);
   m_image_width  =0;
   m_image_height =0;
   m_bmp_path     ="";
  }
//+------------------------------------------------------------------+
//| Класс с дополнительными свойствами для объекта Rectangle Canvas  |
//+------------------------------------------------------------------+
class CRectCanvas : public CCanvas
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
   //---
public:
                     CRectCanvas(void);
                    ~CRectCanvas(void);
   //--- Координаты
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Отступы от крайней точки (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Размеры
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Фокус
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRectCanvas::CRectCanvas(void) : m_x(0),
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
CRectCanvas::~CRectCanvas(void)
  {
  }
//+------------------------------------------------------------------+
//| Класс с дополнительными свойствами для объекта Sub Chart         |
//+------------------------------------------------------------------+
class CSubChart : public CChartObjectSubChart
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
   //---
public:
                     CSubChart(void);
                    ~CSubChart(void);
   //--- Координаты
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   //--- Отступы от крайней точки (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   //--- Размеры
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   //--- Фокус
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSubChart::CSubChart(void) : m_x(0),
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
CSubChart::~CSubChart(void)
  {
  }
//+------------------------------------------------------------------+
