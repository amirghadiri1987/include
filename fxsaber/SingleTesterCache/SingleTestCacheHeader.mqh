#include "String.mqh"

#define UINT uint
#define DWORD int
#define INT64 datetime

//+------------------------------------------------------------------+
//| заголовок кеша                                                   |
//+------------------------------------------------------------------+
struct SingleTestCacheHeader
{
  UINT              version;                // версия кеша 502
//  wchar_t           copyright[64];          // копирайт
  STRING64          copyright    ;          // копирайт
//  wchar_t           name[16];               // наименование кеша "SingleTestCache"
  STRING16          name;                   // наименование кеша "SingleTestCache"
  int               head_reserve[66];
  //---
  UINT              header_size;            // размер заголовка от поля header_size до конца заголовка
  //---
//  wchar_t           expert_name[64];        // имя эксперта
  STRING64          expert_name;            // имя эксперта
//  wchar_t           expert_path[128];       // имя эксперта с путём от MQL5
  STRING128         expert_path;            // имя эксперта с путём от MQL5
//  wchar_t           server[64];             // источник истории (торговый сервер)
  STRING64          server;                 // источник истории (торговый сервер)
//  wchar_t           symbol[32];             // символ тестирования
  STRING32          symbol    ;             // символ тестирования
  int               period;                 // период чарта
  int               ticks_mode;             // режим генерации тиков
  INT64             date_from;              // дата начала данных в настройках тестирования
  INT64             date_to;                // конечная дата в настройках тестирования
  INT64             date_forward;           // конечная дата соответствующего форварда
  DWORD             msc_last;               // время выполнения в миллисекундах
  DWORD             msc_min;                // минимальное время выполнения в миллисекундах
  DWORD             msc_max;                // максимальное время выполнения в миллисекундах
  DWORD             msc_avg;                // среднее время выполнения в миллисекундах
  UINT              tests_passed;           // количество пройденных тестов
  int               common_reserve[16];
  //---
//  wchar_t           group[80];              // имя группы + hedging/netting
  STRING80          group;                  // имя группы + hedging/netting
//  wchar_t           trade_currency[32];     // валюта депозита
  STRING32          trade_currency    ;     // валюта депозита
  int               trade_deposit;          // начальный депозит
  int               trade_condition;        // режим работы торговли (0-без задержек, -1-произвольная задержка, nnn-количество миллисекунд)
  int               trade_leverage;         // плечо
  int               trade_hedging;          // 1 - netting, 2 - hedging
  int               trade_currency_digits;  // количество знаков после запятой в расчётах валюты депозита
  int               trade_pips;             // расчёт в пипсах
  int               trade_reserve[8];
  //---
  UINT              deals_total;
  UINT              orders_total;
  UINT              positions_total;
  UINT              equities_total;
  int               results_reserve[3];
  //---
  char              hash_ex5[16];           // контрольная сумма скомпилированного эксперта
  UINT              parameters_size;        // размер буфера параметров эксперта
  UINT              parameters_total;       // количество параметров
  // далее следуют выставленные параметры эксперта
  //--- конец заголовка. далее следуют ExpTradeSummary, ExpTradeSummaryExt, сделки, ордера и позиции, изменения эквити (график тестирования)

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"
#define TOSTRING2(A) #A + " = " + ::EnumToString(A) + "\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(version) +                // версия кеша
           TOSTRING3(copyright) +             // копирайт
           TOSTRING3(name) +                  // наименование кеша "SingleTestCache"
           TOSTRING(header_size) +            // размер заголовка
           TOSTRING3(expert_name) +           // имя эксперта
           TOSTRING3(expert_path) +           // имя эксперта с путём от MQL5
           TOSTRING3(server) +                // источник истории (торговый сервер)
           TOSTRING3(symbol) +                // символ тестирования
           TOSTRING2((ENUM_TIMEFRAMES)period) +                // период чарта
           TOSTRING(ticks_mode) +             // режим генерации тиков
           TOSTRING(date_from) +              // дата начала данных в настройках тестирования
           TOSTRING(date_to) +                // конечная дата в настройках тестирования
           TOSTRING(date_forward) +           // конечная дата соответствующего форварда
           TOSTRING(msc_last) +               // время выполнения в миллисекундах
           TOSTRING(msc_min) +                // минимальное время выполнения в миллисекундах
           TOSTRING(msc_max) +                // максимальное время выполнения в миллисекундах
           TOSTRING(msc_avg) +                // среднее время выполнения в миллисекундах
           TOSTRING(tests_passed) +           // количество пройденных тестов
           TOSTRING3(group) +                 // имя группы + hedging/netting
           TOSTRING3(trade_currency) +        // валюта депозита
           TOSTRING(trade_deposit) +          // начальный депозит
           TOSTRING(trade_condition) +        // режим работы торговли (0-без задержек, -1-произвольная задержка, nnn-количество миллисекунд)
           TOSTRING(trade_leverage) +         // плечо
           TOSTRING(trade_hedging) +          // 1 - netting, 2 - hedging
           TOSTRING(trade_currency_digits) +  // количество знаков после запятой в расчётах валюты депозита
           TOSTRING(trade_pips) +             // расчёт в пипсах
           TOSTRING(deals_total) +
           TOSTRING(orders_total) +
           TOSTRING(positions_total) +
           TOSTRING(equities_total) +
           TOSTRING(parameters_size) +        // размер буфера параметров эксперта
           TOSTRING(parameters_total)         // количество параметров
          );
  }
#undef TOSTRING3
#undef TOSTRING2
#undef TOSTRING

  string TesterString( void ) const
  {

    return("[Tester]" +
           "\nExpert=" + ::StringSubstr(this.expert_path[], ::StringLen("Experts\\")) +
           "\nSymbol=" + this.symbol[] +
           "\nPeriod=" + ::StringSubstr(::EnumToString((ENUM_TIMEFRAMES)period), ::StringLen("PERIOD_")) +
           "\nOptimization=0" +
           "\nModel=" + (string)ticks_mode +
           "\nFromDate=" + ::TimeToString(this.date_from, TIME_DATE) +
           "\nToDate=" + ::TimeToString(this.date_to, TIME_DATE) +
           "\nForwardMode=0" +
           "\nDeposit=" + (string)this.trade_deposit +
           "\nCurrency=" + trade_currency[] +
           "\nProfitInPips=" + (string)this.trade_pips +
           "\nLeverage=" + (string)this.trade_leverage +
           "\nExecutionMode=" + (string)this.trade_condition +
           "\nOptimizationCriterion=0" +
           "\nVisual=0");
  }
};

#undef INT64
#undef DWORD
#undef UINT