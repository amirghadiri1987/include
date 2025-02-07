//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//--- Class name
#define CLASS_NAME ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
//--- Program name
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
//--- Program type
#define PROGRAM_TYPE (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
//--- Prevention of exceeding the array size
#define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Prevention of exceeding the array size."

//--- Font
#define FONT      ("Calibri")
#define FONT_SIZE (8)

//--- Timer step (milliseconds)
#define TIMER_STEP_MSC (16)
//+------------------------------------------------------------------+
