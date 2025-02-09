#include <TypeToBytes.mqh> // https://www.mql5.com/ru/code/16280

#include "SingleTestCacheHeader.mqh"
#include "ExpTradeSummaryExt.mqh"
#include "TradeDeal.mqh"
#include "TradeOrder.mqh"
#include "TesterPositionProfit.mqh"
#include "TesterTradeState.mqh"

#define __SINGLETESTERCACHE__

class SINGLETESTERCACHE
{
private:
  template <typename T>
  static void ToNull( T &Value )
  {
    uchar Bytes[sizeof(T)];
    ::ArrayInitialize(Bytes, 0);

    _W(Value) = Bytes;

    return;
  }

  bool SaveSettings( string FileName, const string StrMain, const bool Details = true,
                     string AddInformationBefore = NULL, const int Common_Flag = 0, string AddInformationAfter = NULL ) const
  {
    const int handle = ::FileOpen(FileName, FILE_WRITE | FILE_UNICODE | FILE_TXT | Common_Flag);
    const bool Res= (handle != INVALID_HANDLE);

    if (Res)
    {
      if (AddInformationBefore != NULL)
      {
        AddInformationBefore += "\n";

        ::StringReplace(AddInformationBefore, "\n", "\n; ");

        ::FileWriteString(handle, "; " + AddInformationBefore + (Details ? NULL : "\n"));
      }

      if (Details)
        ::FileWriteString(handle, ((AddInformationBefore == NULL) ? NULL : "\n") + "; saved on " + (string)::TimeLocal() + "\n; " + this.ToString() + "\n;\n");

      if (::StringLen(StrMain))
      {
        string StrArray[];

        const int Size = ::StringSplit(StrMain, '\n', StrArray);

        for (int i = 0; i < Size; i++)
          ::FileWriteString(handle, ::StringSubstr(StrArray[i], 0, ::StringLen(StrArray[i]) - (i != Size - 1)) +
                                    (::StringFind(StrArray[i], "||") > 0 ? "||Y" : NULL) + "\n");
      }

      if (Details)
      {
        string Str = ";\n" + this.Summary.ToString() + "\n" + this.Header.ToString();

        ::StringReplace(Str, "\n", "\n; ");

        ::FileWriteString(handle, Str);
      }

      if (AddInformationAfter != NULL)
      {
        AddInformationAfter = "\n" + AddInformationAfter;

        ::StringReplace(AddInformationAfter, "\n", "\n; ");

        ::FileWriteString(handle, AddInformationAfter);
      }

      ::FileClose(handle);
    }

    return(Res);
  }

public:
  SingleTestCacheHeader Header;
  ExpTradeSummaryExt Summary;
  string Inputs;
  TradeDeal Deals[];
  TradeOrder Orders[];
  TesterPositionProfit Positions[];
  TesterTradeState TradeState[];

  bool Load( const string FileName, const int Common_Flag = 0 )
  {
    const int handle = ::FileOpen(FileName, FILE_READ | FILE_BIN | Common_Flag);
    bool Res = (handle != INVALID_HANDLE);

    if (Res)
    {
      ::ArrayFree(this.Deals);
      ::ArrayFree(this.Orders);
      ::ArrayFree(this.Positions);
      ::ArrayFree(this.TradeState);

      this.Inputs = NULL;

      if (Res = ::FileReadStruct(handle, this.Header))
      {
        if (this.Header.parameters_size)
        {
          short Words[];
          ::FileReadArray(handle, Words, 0, this.Header.parameters_size);

          this.Inputs = ::ShortArrayToString(Words);
        }

        ::FileReadStruct(handle, this.Summary);

        ::FileReadArray(handle, this.Deals, 0, ::FileReadInteger(handle));
        ::FileReadArray(handle, this.Orders, 0, ::FileReadInteger(handle));

        if (this.Header.positions_total)
          ::FileReadArray(handle, this.Positions, 0, ::FileReadInteger(handle));

        ::FileReadArray(handle, this.TradeState, 0, ::FileReadInteger(handle));
      }

      ::FileClose(handle);
    }

    return(Res);
  }

  template <typename T>
  bool Load( const T &Array[] )
  {
    bool Res = ::ArraySize(Array);

    if (Res)
    {
      ::ArrayFree(this.Deals);
      ::ArrayFree(this.Orders);
      ::ArrayFree(this.Positions);
      ::ArrayFree(this.TradeState);

      this.Inputs = NULL;

      _W(this.Header) = Array;

      int Pos = sizeof(this.Header);

      if (this.Header.parameters_size)
      {
        short Words[];

        Pos += ::_ArrayCopy(Words, Array, 0, Pos, this.Header.parameters_size * sizeof(short));
        this.Inputs = ::ShortArrayToString(Words);
      }

      uchar Bytes[];

      Pos += ::_ArrayCopy(Bytes, Array, 0, Pos, sizeof(ExpTradeSummaryExt));
      _W(this.Summary) = Bytes;

      Pos += ::_ArrayCopy(this.Deals, Array, 0, Pos + sizeof(int), _R(Array)[Pos] * sizeof(TradeDeal)) + sizeof(int);
      Pos += ::_ArrayCopy(this.Orders, Array, 0, Pos + sizeof(int), _R(Array)[Pos] * sizeof(TradeOrder)) + sizeof(int);

      if (this.Header.positions_total)
        Pos += ::_ArrayCopy(this.Positions, Array, 0, Pos + sizeof(int), _R(Array)[Pos] * sizeof(TesterPositionProfit)) + sizeof(int);

//      if (Pos + sizeof(int) < ::ArraySize(Array))
        Pos += ::_ArrayCopy(this.TradeState, Array, 0, Pos + sizeof(int), _R(Array)[Pos] * sizeof(TesterTradeState)) + sizeof(int);
    }

    return(Res);
  }

  SINGLETESTERCACHE( void )
  {
  }

  SINGLETESTERCACHE( const string FileName, const int Common_Flag = 0 )
  {
    this.Load(FileName, Common_Flag);
  }

  template <typename T>
  SINGLETESTERCACHE( const T &Array[] )
  {
    this.Load(Array);
  }

  bool Save( const string FileName, const int Common_Flag = 0 )
  {
    const int handle = ::FileOpen(FileName, FILE_WRITE | FILE_BIN | Common_Flag);
    bool Res = (handle != INVALID_HANDLE);

    if (Res)
    {
      this.Header.version = ::MathMax(this.Header.version, 502);

      const string Name = "SingleTestCache";
      this.Header.name = Name;

      this.Header.period = ::MathMax(this.Header.period, PERIOD_M1);

      this.Header.deals_total = ::ArraySize(this.Deals);
      this.Header.orders_total = ::ArraySize(this.Orders);
      this.Header.positions_total = ::ArraySize(this.Positions);
      this.Header.equities_total = ::ArraySize(this.TradeState);

      if (!::StringLen(this.Header.symbol[]))
      {
        const string Str = this.Header.orders_total ? this.Orders[0].symbol[] : _Symbol;

        this.Header.symbol = Str;
      }

      short Words[];

      if (!::StringLen(this.Inputs))
      {
        this.Header.parameters_size = 0;
        this.Header.parameters_total = 0;
      }
      else
      {
        this.Header.parameters_size = ::ArrayResize(Words, ::StringLen(this.Inputs) + 2);
        ::ArrayInitialize(Words, 0);
        ::StringToShortArray(this.Inputs, Words);

        string StrTmp[];
        this.Header.parameters_total = ::StringSplit(this.Inputs, '\n', StrTmp);
      }

      ::FileWriteStruct(handle, this.Header);

      ::FileWriteArray(handle, Words);

      ::FileWriteStruct(handle, this.Summary);

      ::FileWriteInteger(handle, this.Header.deals_total);
      ::FileWriteArray(handle, this.Deals);

      ::FileWriteInteger(handle, this.Header.orders_total);
      ::FileWriteArray(handle, this.Orders);

      if (this.Header.positions_total)
      {
        ::FileWriteInteger(handle, this.Header.positions_total);
        ::FileWriteArray(handle, this.Positions);
      }

      ::FileWriteInteger(handle, this.Header.equities_total);
      ::FileWriteArray(handle, this.TradeState);

      ::FileClose(handle);
    }

    return(Res);
  }

  void ToNull( void )
  {
    SINGLETESTERCACHE::ToNull(this.Header);
    SINGLETESTERCACHE::ToNull(this.Summary);

    this.Inputs = NULL;

    ::ArrayFree(this.Deals);
    ::ArrayFree(this.Orders);
    ::ArrayFree(this.Positions);
    ::ArrayFree(this.TradeState);

    return;
  }

  bool Set( const datetime FromDate = 0, const datetime ToDate = INT_MAX )
  {
    const bool Res = ::HistorySelect(FromDate, ToDate);

    if (Res)
    {
      this.ToNull();

      for (int i = ::ArrayResize(this.Orders, ::HistoryOrdersTotal()) - 1; i >= 0; i--)
        this.Orders[i].Set(::HistoryOrderGetTicket(i));

      double Profit = 0;
      const int Size = ::ArrayResize(this.TradeState, ::ArrayResize(this.Deals, ::HistoryDealsTotal()));

    #define POS_ID 0
    #define POS_INDEX 1

    #define MAXTIME_VALUE 0
    #define MAXTIME_INDEX 1

      ulong PosID[][2];

      ::ArrayResize(PosID, Size + 1);
      PosID[Size][POS_ID] = ULONG_MAX;

      for (int i = 0; i < Size; i++)
      {
        const ulong Ticket = ::HistoryDealGetTicket(i);

        if (this.Deals[i].Set(Ticket))
        {
          Profit += this.Deals[i].profit + this.Deals[i].storage + this.Deals[i].commission;

          this.Deals[i].reserve = Profit;

          this.TradeState[i].balance = Profit;
          this.TradeState[i].equity = Profit;

          this.TradeState[i].time = this.Deals[i].time_create;

          this.Deals[i].time_create = (datetime)::HistoryDealGetInteger(Ticket, DEAL_TIME_MSC); // Для большей точности.
        }

        PosID[i][POS_ID] = ::HistoryDealGetInteger(Ticket, DEAL_POSITION_ID);
        PosID[i][POS_INDEX] = i;
      }

      ::ArraySort(PosID);

      TesterPositionProfit NewPositions[];
      ::ArrayResize(NewPositions, Size);

      long MaxTimes[][2];
      ::ArrayResize(MaxTimes, Size);

      int Amount = 0;
      ulong PrevPosID = 0;

      int Pos = 0;

      for (int i = 0; i <= Size; i++)
        if (PrevPosID != PosID[i][POS_ID])
        {
          if (PrevPosID)
          {
            int PosMinTime = -1;

            datetime MinTime = LONG_MAX;
            datetime MaxTime = 0;

            Profit = 0;

            for (int j = Pos; j < i; j++)
            {
              const int k = (int)PosID[j][POS_INDEX];

              Profit += this.Deals[k].profit + this.Deals[k].storage + this.Deals[k].commission;

              const datetime time = this.Deals[k].time_create;

              if (time > MaxTime)
                MaxTime = time;

              if ((time < MinTime) && (this.Deals[k].entry == DEAL_ENTRY_IN))
              {
                MinTime = time;

                PosMinTime = k;
              }
            }

            SINGLETESTERCACHE::ToNull(NewPositions[Amount]);

            if (PosMinTime != -1)
            {
              const double Price = this.Deals[PosMinTime].price_open;

              for (int j = Pos; j < i; j++)
              {
                const int k = (int)PosID[j][POS_INDEX];

                if (k != PosMinTime)
                  this.Deals[k].price_close = Price;
              }

              NewPositions[Amount].lifetime = (MaxTime - MinTime) / 1000;
            }

            NewPositions[Amount].id = PrevPosID;
            NewPositions[Amount].profit = Profit;

            MaxTimes[Amount][MAXTIME_VALUE] = MaxTime;
            MaxTimes[Amount][MAXTIME_INDEX] = Amount;

            Amount++;
          }

          Pos = i;
          PrevPosID = PosID[Pos][POS_ID];
        }

      ::ArrayResize(NewPositions, Amount);
      ::ArrayResize(MaxTimes, Amount);

      // Сортировка позиций по времени закрытия
      ::ArraySort(MaxTimes);

      for (int i = ::ArrayResize(this.Positions, Amount) - 1; i >= 0; i--)
        this.Positions[i] = NewPositions[(int)MaxTimes[i][MAXTIME_INDEX]];

      for (int i = 0; i < Size; i++)
        this.Deals[i].time_create /= 1000;

    #undef MAXTIME_INDEX
    #undef MAXTIME_VALUE

    #undef POS_INDEX
    #undef POS_ID
    }

    return(Res);
  }

  static void ChangeArray( double &Array[], const int Pos )
  {
    if (Pos >= 0)
    {
      const double Min = Array[::ArrayMinimum(Array)];
      const double Max = Array[::ArrayMaximum(Array)];

      if (Pos != -1)
        Array[Pos] = (Array[Pos] > (Min + Max) / 2) ? Min : Max;
    }

    return;
  }

  int GetBalance( double &Balance[], const datetime From = 0, const datetime To = 0, const bool WithoutDeposit = false ) const
  {
    const int Size = ::ArrayResize(Balance, ::ArraySize(this.TradeState));

    int PosFrom = -1;
    int PosTo = -1;

    const double Deposit = (WithoutDeposit && Size) ? this.TradeState[0].balance : 0;

    for (int i = 0; i < Size; i++)
    {
      Balance[i] = this.TradeState[i].balance - Deposit;

      if (From && i && (this.TradeState[i - 1].time < From) && (this.TradeState[i].time >= From))
        PosFrom = i;

      if (To && i && (this.TradeState[i - 1].time < To) && (this.TradeState[i].time >= To))
        PosTo = i;
    }

    SINGLETESTERCACHE::ChangeArray(Balance, PosFrom);
    SINGLETESTERCACHE::ChangeArray(Balance, PosTo);

    return(Size);
  }

  int GetEquity( double &Equity[], const datetime From = 0, const datetime To = 0, const bool WithoutDeposit = false ) const
  {
    const int Size = ::ArrayResize(Equity, ::ArraySize(this.TradeState));

    int PosFrom = -1;
    int PosTo = -1;

    const double Deposit = (WithoutDeposit && Size) ? this.TradeState[0].equity : 0;

    for (int i = 0; i < Size; i++)
    {
      Equity[i] = this.TradeState[i].equity - Deposit;

      if (From && i && (this.TradeState[i - 1].time < From) && (this.TradeState[i].time >= From))
        PosFrom = i;

      if (To && i && (this.TradeState[i - 1].time < To) && (this.TradeState[i].time >= To))
        PosTo = i;
    }

    SINGLETESTERCACHE::ChangeArray(Equity, PosFrom);
    SINGLETESTERCACHE::ChangeArray(Equity, PosTo);

    return(Size);
  }

  int GetTradeSymbols( string &Symbols[] ) const
  {
    int Size = 0;

    ::ArrayFree(Symbols);

    for (int i = ::ArraySize(this.Deals) - 1; i >= 0; i--)
    {
      const string Symb = this.Deals[i].GetProperty(DEAL_SYMBOL);

      if (Symb != "")
      {
        int j = 0;

        for (; (j < Size) && (Symbols[j] != Symb); j++)
          ;

        if (j == Size)
        {
          Size = ::ArrayResize(Symbols, Size + 1);

          Symbols[Size - 1] = Symb;
        }
      }
    }

    return(Size);
  }

  bool SaveSet( string FileName = NULL, const bool Details = true,
                string AddInformationBefore = NULL, const int Common_Flag = 0, string AddInformationAfter = NULL ) const
  {
    if (FileName == NULL)
      FileName = this.Header.expert_name[] + ".set";

    return(this.SaveSettings(FileName, this.Inputs, Details, AddInformationBefore, Common_Flag, AddInformationAfter));
  }

  string ToString( void ) const
  {
    return(this.Header.expert_path[] + "\n; " +
           this.Header.symbol[] + "\n; " +
           ::TimeToString(this.Header.date_from, TIME_DATE) + " - " + ::TimeToString(this.Header.date_to, TIME_DATE) + "\n; " +
           ::DoubleToString(this.Summary.TesterStatistics(STAT_PROFIT), 0) + ", " +
           ::DoubleToString(this.Summary.TesterStatistics(STAT_TRADES), 0) + ", " +
           ::DoubleToString(this.Summary.TesterStatistics(STAT_PROFIT_FACTOR), 2) + ", " +
           ::DoubleToString(this.Summary.TesterStatistics(STAT_EXPECTED_PAYOFF), 2) +  ", -" +
           ::DoubleToString(this.Summary.TesterStatistics(STAT_EQUITY_DD), 2));
  }

  string TesterString( void ) const
  {
    return(this.Header.TesterString() + "\n[TesterInputs]\n" + this.Inputs);
  }

  bool SaveIni( string FileName = NULL, const bool Details = true,
                string AddInformationBefore = NULL, const int Common_Flag = 0, string AddInformationAfter = NULL ) const
  {

    if (FileName == NULL)
      FileName = this.Header.expert_name[] + ".ini";

    string Str = this.TesterString();

    ::StringReplace(Str, "\r\n", "\n");
    ::StringReplace(Str, "\n", "\r\n");

    return(this.SaveSettings(FileName, Str, Details, AddInformationBefore, Common_Flag, AddInformationAfter));
  }

  // Максимальная продолжительность просадки с заданного времени.
  int GetMaxLengthDD( datetime &BeginDD, datetime &EndDD, const datetime From = 0 ) const
  {
    const int Total = ::ArraySize(this.Deals);

    double Profit = 0;
    double MaxProfit = 0;
    datetime Begin = 0;

    BeginDD = 0;
    EndDD = 0;

    for (int i = 0; i < Total; i++)
      if (this.Deals[i].GetProperty(DEAL_TYPE) <= DEAL_TYPE_SELL)
      {
        if (!Begin && (this.Deals[i].GetProperty(DEAL_TIME) > From))
          Begin = (datetime)this.Deals[i].GetProperty(DEAL_TIME);

        Profit += this.Deals[i].GetProperty(DEAL_PROFIT) +
                  this.Deals[i].GetProperty(DEAL_COMMISSION) +
                  this.Deals[i].GetProperty(DEAL_SWAP);

        if ((Profit > MaxProfit) || (i == Total - 1))
        {
          MaxProfit = Profit;

          const datetime End = (datetime)this.Deals[i].GetProperty(DEAL_TIME);

          if (Begin && i && (Begin != this.Deals[i - 1].GetProperty(DEAL_TIME)) &&
                       (End - Begin > EndDD - BeginDD))
          {
            BeginDD = Begin;
            EndDD = End;
          }

          if (Begin)
            Begin = End;
        }
      }

    return((int)(EndDD - BeginDD));
  }
};