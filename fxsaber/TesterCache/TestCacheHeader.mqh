#include "String.mqh"

#define UINT uint
#define DWORD int
#define INT64 datetime
#define UINT16 short

//+------------------------------------------------------------------+
//| Cache header                                                     |
//+------------------------------------------------------------------+
struct TestCacheHeader
{
  UINT              version;                // cache version
  //   wchar_t           copyright[64];          // copyright
  STRING64           copyright;             // copyright
//  wchar_t           name[16];               // "TesterOptCache" cache name
  STRING16           name   ;               // "TesterOptCache" cache name
  int               head_reserve[66];
   //---
  UINT              header_size;            // header size
  UINT              record_size;            // cached record size (TestCacheRecord with the buffer of parameters)
  //---
  //   wchar_t           expert_name[64];        // Expert Advisor name
  STRING64           expert_name;           // Expert Advisor name
  //   wchar_t           expert_path[128];       // Expert Advisor name with a path starting at MQL5
  STRING128           expert_path;            // Expert Advisor name with a path starting at MQL5
  //   wchar_t           server[64];             // history source (trade server)
  STRING64           server;                 // history source (trade server)
  //   wchar_t           symbol[32];             // testing symbol
  STRING32           symbol;                // testing symbol
  UINT16            period;                 // chart period
  INT64             date_from;              // starting date of data in test settings
  INT64             date_to;                // ending date of data in test settings
  INT64             date_forward;           // ending date of the appropriate forward period
  int               opt_mode;               // optimization mode (0-full, 1-genetic, 2 or 3-forward)
  int               ticks_mode;             // tick generation mode
  int               last_criterion;         // optimization criterion in the last session
  DWORD             msc_min;                // minimum execution time in milliseconds
  DWORD             msc_max;                // maximum execution time in milliseconds
  DWORD             msc_avg;                // average execution time in milliseconds
  int               common_reserve[16];
  //---
  //   wchar_t           group[80];              // group name + hedging/netting
  STRING80           group;                 // group name + hedging/netting
  //   wchar_t           trade_currency[32];     // deposit currency
  STRING32           trade_currency;        // deposit currency
  int               trade_deposit;          // initial deposit
  int               trade_condition;        // trading operation mode (0-no delays, -1-arbitrary delay, nnn-number of milliseconds)
  int               trade_leverage;         // leverage
  int               trade_hedging;          // 1 - netting, 2 - hedging
  int               trade_currency_digits; // number of decimal places after in deposit currency calculations
  int               trade_pips;             // calculation in pips
  int               trade_reserve[5];
  //---
  char              hash_ex5[16];           // compiled Expert Advisor hash
  UINT              parameters_size;        // buffer size for EA parameters
  UINT              parameters_total;       // the number of parameters
  UINT              opt_params_size;        // buffer size for EA parameters
  UINT              opt_params_total;       // the number of parameters
  UINT              dwords_cnt;             // the size of the pass number during large genetic
  UINT              snapshot_size;          // the size of the snapshot for total optimization and for a forward after a total optimization
  UINT              passes_total;           // the total number of optimization passes (0 for genetic optimization)
  UINT              passes_passed;          // the number of completed passes
  // the set EA parameters follow next (including string parameter) in the TestCacheInput structure
  //--- end of the header. followed by records of each pass

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"
#define TOSTRING2(A) #A + " = " + ::EnumToString(A) + "\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(version) +                // cache version
           TOSTRING3(copyright) +             // copyright
           TOSTRING3(name) +                  // "TesterOptCache" cache name
           TOSTRING(header_size) +            // header size
           TOSTRING(record_size) +            // cached record size (TestCacheRecord with the buffer of parameters)
           TOSTRING3(expert_name) +           // Expert Advisor name
           TOSTRING3(expert_path) +           // Expert Advisor name with a path starting at MQL5
           TOSTRING3(server) +                // history source (trade server)
           TOSTRING3(symbol) +                // testing symbol
           TOSTRING2((ENUM_TIMEFRAMES)period) +                // chart period
           TOSTRING(date_from) +              // starting date of data in test settings
           TOSTRING(date_to) +                // ending date of data in test settings
           TOSTRING(date_forward) +           // ending date of the appropriate forward period
           TOSTRING(opt_mode) +               // optimization mode (0-full, 1-genetic, 2 or 3-forward)
           TOSTRING(ticks_mode) +             // tick generation mode
           TOSTRING(last_criterion) +         // optimization criterion in the last session
           TOSTRING(msc_min) +                // minimum execution time in milliseconds
           TOSTRING(msc_max) +                // maximum execution time in milliseconds
           TOSTRING(msc_max) +                // average execution time in milliseconds
           TOSTRING3(group) +                 // group name + hedging/netting
           TOSTRING3(trade_currency) +        // deposit currency
           TOSTRING(trade_deposit) +          // initial deposit
           TOSTRING(trade_condition) +        // trading operation mode (0-no delays, -1-arbitrary delay, nnn-number of milliseconds)
           TOSTRING(trade_leverage) +         // leverage
           TOSTRING(trade_hedging) +          // 1 - netting, 2 - hedging
           TOSTRING(trade_currency_digits) +  // number of decimal places after in deposit currency calculations
           TOSTRING(trade_pips) +             // calculation in pips
           TOSTRING(parameters_size) +        // buffer size for EA parameters
           TOSTRING(parameters_total) +       // number of parameters
           TOSTRING(opt_params_size) +        // buffer size for EA parameters
           TOSTRING(opt_params_total) +       // the number of parameters
           TOSTRING(dwords_cnt) +             // the size of the pass number during large genetic
           TOSTRING(snapshot_size) +          // the size of the snapshot for total optimization and for a forward after a total optimization
           TOSTRING(passes_total) +           // the total number of optimization passes (0 for genetic optimization)
           TOSTRING(passes_passed)            // the number of completed passes
          );
  }
#undef TOSTRING3
#undef TOSTRING2
#undef TOSTRING
};

/*
   m_header.header_size=sizeof(TestCacheHeader)+m_inputs.Total()*sizeof(TestCacheInput)+m_header.parameters_size;
//--- the cached record contains the pass number (for genetic optimization it is the ordinal number), the structure of testing results (1 double if math calculations), the buffer of optimized parameters and the genetic pass
   m_header.record_size=sizeof(INT64)+m_header.opt_params_size;
   if(m_mathematics)
      m_header.record_size+=sizeof(double);
   else
      m_header.record_size+=sizeof(ExpTradeSummary);
   if(m_header.dwords_cnt>1)
      m_header.record_size+=m_header.dwords_cnt*sizeof(DWORD);
   else
     {
      if(m_genetics)
         m_header.record_size+=sizeof(INT64);
     }
*/

#undef UINT16
#undef INT64
#undef DWORD
#undef UINT