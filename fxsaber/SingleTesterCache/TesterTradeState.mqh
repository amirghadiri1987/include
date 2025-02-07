#define __int64 datetime

//+------------------------------------------------------------------+
//| ��������� ��� ������� ������������                               |
//+------------------------------------------------------------------+
struct TesterTradeState
{
//  __int64           datetime;            // ������� �������� �����
  __int64           time;                // ������� �������� �����
  double            balance;             // ������� ������
  double            equity;              // ������� equity
  double            value;               // ������� ������������ �������� �������� �� �������

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(time) +                // ������� �������� �����
           TOSTRING(balance) +             // ������� ������
           TOSTRING(equity) +              // ������� equity
           TOSTRING(value)                 // ������� ������������ �������� �������� �� �������
          );
  }

#undef TOSTRING
};

#undef __int64