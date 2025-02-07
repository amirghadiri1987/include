#include "String.mqh"

#define UINT64 ulong
#define INT64 datetime
#define UINT uint

//+------------------------------------------------------------------+
//| ��������� ��������� ������                                       |
//+------------------------------------------------------------------+
struct TradeOrder
{
private:
  ENUM_ORDER_REASON ReasonToInteger( const ENUM_ORDER_REASON Reason ) const
  {
    int Res = 1;

    switch (Reason)
    {
    case ORDER_REASON_SL:
      Res = 3;

      break;
    case ORDER_REASON_TP:
      Res = 4;

      break;
    }

    return((ENUM_ORDER_REASON)Res);
  }

  ENUM_ORDER_REASON IntegerToReason( const int Reason ) const
  {
    ENUM_ORDER_REASON Res = ORDER_REASON_CLIENT;

    switch (Reason)
    {
    case 3:
      Res = ORDER_REASON_SL;

      break;
    case 4:
      Res = ORDER_REASON_TP;

      break;
    }

    return((ENUM_ORDER_REASON)Res);
  }

public:
  UINT64            order;                   // ���������� ������������� ������
//  wchar_t           symbol[32];              // ������ �� �������� ��������� �����
  STRING32          symbol;                  // ������ �� �������� ��������� �����
  INT64             time_setup;              // ����� ����� ������ �� ������� � �������
  INT64             time_done;               // ����� ������ �����
  ENUM_ORDER_TYPE   type;                    // ��� ������
  ENUM_ORDER_REASON type_reason;             // ������� ������������ ������
  double            price_order;             // ���� ������
  double            price_trigger;           // ���� ���������� ������
  double            price_sl;                // ���� SL � ������
  double            price_tp;                // ���� TP � ������
  UINT64            volume_initial;          // ��������� ����� ������
  UINT64            volume_current;          // ������� ����� ������
//  wchar_t           comment[32];             // ����������� � ������
  STRING32          comment;                 // ����������� � ������
  ENUM_ORDER_STATE  state;                   // ������� ��������� ������
  UINT              digits;                  // ���������� ������ � ��������� �������
  double            contract_size;           // ������ ���������

  bool Set( const ulong Ticket )
  {
    const bool Res = (::HistoryOrderGetInteger(Ticket, ORDER_TICKET) == Ticket);

    if (Res)
    {
      this.order = Ticket;                                                                                                     // ���������� ������������� ������

      string Str = ::HistoryOrderGetString(Ticket, ORDER_SYMBOL);
      this.symbol = Str;                                                                                                       // ������ �� �������� ��������� �����

      this.contract_size = ::SymbolInfoDouble(Str, SYMBOL_TRADE_CONTRACT_SIZE);                                                // ������ ���������
      this.digits = (UINT)::SymbolInfoInteger(Str, SYMBOL_DIGITS);                                                             // ���������� ������ � ��������� �������

      Str = ::HistoryOrderGetString(Ticket, ORDER_COMMENT);
      this.comment = Str;                                                                                                      // ����������� � ������

      this.time_setup = (INT64)::HistoryOrderGetInteger(Ticket, ORDER_TIME_SETUP);                                             // ����� ����� ������ �� ������� � �������
      this.time_done = (INT64)::HistoryOrderGetInteger(Ticket, ORDER_TIME_DONE);                                               // ����� ������ �����

      this.type = (ENUM_ORDER_TYPE)::HistoryOrderGetInteger(Ticket, ORDER_TYPE);                                               // ��� ������
      this.type_reason = this.ReasonToInteger((ENUM_ORDER_REASON)::HistoryOrderGetInteger(Ticket, ORDER_REASON));              // ������� ������������ ������
      this.state = (ENUM_ORDER_STATE)::HistoryOrderGetInteger(Ticket, ORDER_STATE);                                            // ������� ��������� ������

      this.price_order = ::HistoryOrderGetDouble(Ticket, ORDER_PRICE_OPEN);                                                    // ���� ������
      this.price_trigger = 0;                                                                                                  // ���� ���������� ������
      this.price_sl = ::HistoryOrderGetDouble(Ticket, ORDER_SL);                                                               // ���� SL � ������
      this.price_tp = ::HistoryOrderGetDouble(Ticket, ORDER_TP);                                                               // ���� TP � ������

      this.volume_initial = (UINT64)(::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_INITIAL) * this.contract_size * 1000 + 0.1); // ��������� ����� ������
      this.volume_current = (UINT64)(::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT) * this.contract_size * 1000 + 0.1); // ������� ����� ������
    }

    return(Res);
  }

  long GetProperty( const ENUM_ORDER_PROPERTY_INTEGER Property ) const
  {
    long Res = 0;

    switch (Property)
    {
      case ORDER_TICKET:
        Res = (long)this.order;

        break;
      case ORDER_TIME_SETUP:
        Res = this.time_setup;

        break;
      case ORDER_TYPE:
        Res = this.type;

        break;
      case ORDER_STATE:
        Res = this.state;

        break;
      case ORDER_TIME_DONE:
        Res = this.time_done;

        break;
      case ORDER_TIME_SETUP_MSC:
        Res = (long)this.time_setup * 1000;

        break;
      case ORDER_TIME_DONE_MSC:
        Res = (long)this.time_done * 1000;

        break;
      case ORDER_REASON:
        Res = this.IntegerToReason(this.type_reason);

        break;
      case ORDER_POSITION_ID:
        Res = (long)this.order;

        break;
    }

    return(Res);
  }

  double GetProperty( const ENUM_ORDER_PROPERTY_DOUBLE Property ) const
  {
    double Res = 0;

    switch (Property)
    {
      case ORDER_VOLUME_INITIAL:
        Res = (double)this.volume_initial / (this.contract_size ? this.contract_size * 1000 : 1e8);

        break;
      case ORDER_VOLUME_CURRENT:
        Res = (double)this.volume_current / (this.contract_size ? this.contract_size * 1000 : 1e8);

        break;
      case ORDER_PRICE_OPEN:
        Res = this.price_order;

        break;
      case ORDER_SL:
        Res = this.price_sl;

        break;
      case ORDER_TP:
        Res = this.price_tp;

        break;
    }

    return(Res);
  }

  string GetProperty( const ENUM_ORDER_PROPERTY_STRING Property ) const
  {
    string Res = NULL;

    switch (Property)
    {
      case ORDER_SYMBOL:
        Res = this.symbol[];

        break;
      case ORDER_COMMENT:
        Res = this.comment[];

        break;
    }

    return(Res);
  }

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"
#define TOSTRING2(A) #A + " = " + ::EnumToString(this.A) + " (" + (string)(this.A) + ")\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(order) +                   // ���������� ������������� ������
           TOSTRING3(symbol) +                 // ������ �� �������� ��������� �����
           TOSTRING(time_setup) +              // ����� ����� ������ �� ������� � �������
           TOSTRING(time_done) +               // ����� ������ �����
           TOSTRING2(type) +                   // ��� ������
           TOSTRING2(type_reason) +            // ������� ������������ ������
           TOSTRING(price_order) +             // ���� ������
           TOSTRING(price_trigger) +           // ���� ���������� ������
           TOSTRING(price_sl) +                // ���� SL � ������
           TOSTRING(price_tp) +                // ���� TP � ������
           TOSTRING(volume_initial) +          // ��������� ����� ������
           TOSTRING(volume_current) +          // ������� ����� ������
           TOSTRING3(comment) +                // ����������� � ������
           TOSTRING2(state) +                  // ������� ��������� ������
           TOSTRING(digits) +                  // ���������� ������ � ��������� �������
           TOSTRING(contract_size)             // ������ ���������
          );
  }

#undef TOSTRING3
#undef TOSTRING2
#undef TOSTRING
};

#undef UINT
#undef INT64
#undef UINT64