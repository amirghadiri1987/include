#include "ExpTradeSummarySingle.mqh"

#define UINT uint
#define INT64 datetime

//+------------------------------------------------------------------+
//| Структура для статистики торговли - доп показатели               |
//+------------------------------------------------------------------+
struct ExpTradeSummaryExt : public ExpTradeSummarySingle
{
private:
  string LengthToString( const datetime Length ) const
  {
    const int Days = (int)(Length / (24 * 3600));

    return(((Days) ? (string)Days + "d ": "") + ::TimeToString(Length, TIME_SECONDS));
  }

public:
  int               Offset2[18];
  double            ghpr;                    // среднее геометрическое сделки
  double            ghprpercent;             // среднее геометрическое сделки в процентах
  double            ahpr;                    // среднее арифметическое сделки
  double            ahprpercent;             // среднее арифметическое сделки в процентах
  double            zscore;                  // серийный тест
  double            zscorepercent;           // серийный тест в процентах
  double            lrcorr;                  // коэффициент корреляции линейной регрессии
  double            lrstderror;              // стандартная ошибка отклонения баланса от линейной регрессии
  UINT              symbols;                 // количество инструментов участвовавших в торговле
  int               Offset3;
  double            corr_prf_mfe;            // корреляция между mfe и profit
  double            corr_prf_mae;            // корреляция между mae и profit
  double            corr_mfe_mae;            // корреляция между mae и mfe
  double            mfe_a;                   // корреляция между mfe и profit, коэф. для линии линейной регрессии
  double            mfe_b;                   // корреляция между mfe и profit, коэф. для линии линейной регрессии
  double            mae_a;                   // корреляция между mae и profit, коэф. для линии линейной регрессии
  double            mae_b;                   // корреляция между mae и profit, коэф. для линии линейной регрессии
  UINT              in_per_hours[24];        // распределение входов по часам
  UINT              in_per_week_days[7];     // распределение входов по дням недели
  UINT              in_per_months[12];       // распределение входов по месяцам
  int               Offset4;
  double            out_per_hours[24][2];    // распределение входов по часам
  double            out_per_week_days[7][2]; // распределение входов по дням недели
  double            out_per_months[12][2];   // распределение входов по месяцам
  INT64             holding_time_min;        // минимальное время удержания позиции
  INT64             holding_time_max;        // максимальное время удержания позиции
  INT64             holding_time_avr;        // среднее время удержания позиции

  // https://www.mql5.com/ru/forum/444094/page13#comment_46162559
  double            in_commission; 
  int               reserve[40];

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
#define TOSTRING2(A) #A + " = " + this.LengthToString(A) + "\n"

  string ToString( void ) const
  {
    return(ExpTradeSummarySingle::ToString() +
           TOSTRING(ghpr) +                  // среднее геометрическое сделки
           TOSTRING(ghprpercent) +           // среднее геометрическое сделки в процентах
           TOSTRING(ahpr) +                  // среднее арифметическое сделки
           TOSTRING(ahprpercent) +           // среднее арифметическое сделки в процентах
           TOSTRING(zscore) +                // серийный тест
           TOSTRING(zscorepercent) +         // серийный тест в процентах
           TOSTRING(lrcorr) +                // коэффициент корреляции линейной регрессии
           TOSTRING(lrstderror) +            // стандартная ошибка отклонения баланса от линейной регрессии
           TOSTRING(symbols) +               // количество инструментов участвовавших в торговле
           TOSTRING(corr_prf_mfe) +          // корреляция между mfe и profit
           TOSTRING(corr_prf_mae) +          // корреляция между mae и profit
           TOSTRING(corr_mfe_mae) +          // корреляция между mae и mfe
           TOSTRING(mfe_a) +                 // корреляция между mfe и profit, коэф. для линии линейной регрессии
           TOSTRING(mfe_b) +                 // корреляция между mfe и profit, коэф. для линии линейной регрессии
           TOSTRING(mae_a) +                 // корреляция между mae и profit, коэф. для линии линейной регрессии
           TOSTRING(mae_b) +                 // корреляция между mae и profit, коэф. для линии линейной регрессии
           TOSTRING2(holding_time_min) +     // минимальное время удержания позиции
           TOSTRING2(holding_time_max) +     // максимальное время удержания позиции
           TOSTRING2(holding_time_avr) +     // среднее время удержания позиции
           TOSTRING(in_commission));         // https://www.mql5.com/ru/forum/444094/page13#comment_46162559           
  }

#undef TOSTRING2
#undef TOSTRING
};

#undef INT64
#undef UINT