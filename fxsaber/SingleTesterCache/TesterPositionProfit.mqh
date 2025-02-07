#define UINT64 ulong
#define INT64 datetime

//+------------------------------------------------------------------+
//| ��������� ����������� ��� �������                                |
//+------------------------------------------------------------------+
struct TesterPositionProfit
{
private:
  string LengthToString( const datetime Length ) const
  {
    const int Days = (int)(Length / (24 * 3600));

    return(((Days) ? (string)Days + "d ": "") + ::TimeToString(Length, TIME_SECONDS));
  }

public:
  UINT64            id;                     // id �������
  double            mfe;                    // MFE
  double            mae;                    // MAE
  double            profit;                 // �������
  INT64             lifetime;               // ����� ����� ������� � ��������
  UINT64            reserve[3];

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"
#define TOSTRING2(A) #A + " = " + this.LengthToString(A) + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(id) +                     // id �������
           TOSTRING(mfe) +                    // MFE
           TOSTRING(mae) +                    // MAE
           TOSTRING(profit) +                 // �������
           TOSTRING2(lifetime)                // ����� ����� ������� � ��������
          );
  }

#undef TOSTRING2
#undef TOSTRING
};

#undef INT64
#undef UINT64