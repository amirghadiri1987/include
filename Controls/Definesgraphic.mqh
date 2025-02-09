//+------------------------------------------------------------------+
//|                                               Definesgraphic.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//--- Режим "Эксперт в окне"
#define EXPERT_IN_SUBWINDOW false
//--- Имя класса
#define CLASS_NAME ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
//--- Имя программы
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
//--- Тип программы
#define PROGRAM_TYPE (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
//--- Предотвращение выхода из диапазона
#define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Предотвращение выхода за пределы массива."

//--- Шаг таймера (миллисекунды)
#define TIMER_STEP_MSC (16)
//--- Задержка перед включением перемотки счётчика (миллисекунды)
#define SPIN_DELAY_MSC (-450)
//--- Символ пробела
#define SPACE          (" ")

//--- Для представления любых названий в строковом формате
#define TO_STRING(A) #A
//--- Распечатка данных события
#define PRINT_EVENT(SID,ID,L,D,S) \
::Print(__FUNCTION__," > id: ",TO_STRING(SID)," (",ID,"); lparam: ",L,"; dparam: ",D,"; sparam: ",S);

//--- Идентификаторы событий
#define ON_WINDOW_EXPAND            (1)  // Разворачивание формы
#define ON_WINDOW_COLLAPSE          (2)  // Сворачивание формы
#define ON_WINDOW_CHANGE_XSIZE      (3)  // Изменение размеров окна по оси X
#define ON_WINDOW_CHANGE_YSIZE      (4)  // Изменение размеров окна по оси Y
#define ON_WINDOW_TOOLTIPS          (5)  // Нажатие на кнопке "Всплывающие подсказки"
//---
#define ON_CLICK_LABEL              (6)  // Нажатие на текстовой метке
#define ON_CLICK_BUTTON             (7)  // Нажатие на кнопке
#define ON_CLICK_MENU_ITEM          (8)  // Нажатие на пункте меню
#define ON_CLICK_CONTEXTMENU_ITEM   (9)  // Нажатие на пункте меню в контекстном меню
#define ON_CLICK_FREEMENU_ITEM      (10) // Нажатие на пункте свободного контекстного меню
#define ON_CLICK_CHECKBOX           (11) // Нажатие на чекбоксе
#define ON_CLICK_GROUP_BUTTON       (12) // Нажатие на кнопке в группе
#define ON_CLICK_ELEMENT            (13) // Нажатие на элементе
#define ON_CLICK_TAB                (14) // Переключение вкладки
#define ON_CLICK_SUB_CHART          (15) // Нажатие на объекте-графике
#define ON_CLICK_INC                (16) // Изменение счётчика вверх
#define ON_CLICK_DEC                (17) // Изменение счётчика вниз
#define ON_CLICK_COMBOBOX_BUTTON    (18) // Нажатие на кнопке комбо-бокса
#define ON_CLICK_LIST_ITEM          (19) // Выбор пункта в списке
#define ON_CLICK_COMBOBOX_ITEM      (20) // Выбор пункта в списке комбобокса
#define ON_CLICK_TEXT_BOX           (21) // Активация текстового поля ввода
//---
#define ON_DOUBLE_CLICK             (22) // Двойной клик левой кнопки мыши
#define ON_END_EDIT                 (23) // Окончание редактирования значения в поле ввода
//---
#define ON_OPEN_DIALOG_BOX          (24) // Событие открытия диалогового окна
#define ON_CLOSE_DIALOG_BOX         (25) // Событие закрытия диалогового окна
#define ON_HIDE_CONTEXTMENUS        (26) // Скрыть все контекстные меню
#define ON_HIDE_BACK_CONTEXTMENUS   (27) // Скрыть контекстные меню от текущего пункта меню
//---
#define ON_CHANGE_GUI               (28) // Графический интерфейс изменился
#define ON_CHANGE_DATE              (29) // Изменение даты в календаре
#define ON_CHANGE_COLOR             (30) // Изменение цвета посредством цветовой палитры
#define ON_CHANGE_TREE_PATH         (31) // Путь в древовидном списке изменён
#define ON_CHANGE_MOUSE_LEFT_BUTTON (32) // Изменение состояния левой кнопки мыши
//---
#define ON_SORT_DATA                (33) // Сортировка данных
#define ON_MOUSE_BLUR               (34) // Курсор мыши вышел из области элемента
#define ON_MOUSE_FOCUS              (35) // Курсор мыши зашёл в область элемента
#define ON_REDRAW_ELEMENT           (36) // Перерисовка элемента
#define ON_MOVE_TEXT_CURSOR         (37) // Перемещение текстового курсора
#define ON_SUBWINDOW_CHANGE_HEIGHT  (38) // Изменение высоты подокна
//---
#define ON_SET_AVAILABLE            (39) // Установить доступные элементы
#define ON_SET_LOCKED               (40) // Установить заблокированные элементы
//---
#define ON_WINDOW_DRAG_END          (41) // Перетаскивание формы завершено
//---
#define ON_END_CREATE_GUI           (42) // Графический интерфейс создан
//+------------------------------------------------------------------+
