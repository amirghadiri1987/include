#include "String.mqh"

//+------------------------------------------------------------------+
//| ��������� ��� ���������� ��������                                |
//+------------------------------------------------------------------+
struct ExpTradeSummarySingle
{
public:
  int               Offset1[10];
  int               bars;
  int               ticks;
  STRING32          symbol;
  double            initial_deposit;     // ��������� �������
  double            withdrawal;          // ����� �������
  double            profit;              // ����� ������� (+)
  double            grossprofit;         // ����� ����
  double            grossloss;           // ����� �����
  double            maxprofit;           // ����������� ���������� ������
  double            minprofit;           // ����������� ��������� ������
  double            conprofitmax;        // ������� ������������ ������������������ ���������� ������
  double            maxconprofit;        // ������������ ������� ����� �������������������
  double            conlossmax;          // ������ ������������ ������������������ ��������� ������
  double            maxconloss;          // ������������ ������ ����� �������������������
  double            balance_min;         // ����������� �������� ������� (��� ������� ���������� ��������)
  double            maxdrawdown;         // ������������ �������� �� �������
  double            drawdownpercent;     // ��������� ������������ �������� �� ������� � � ����
  double            reldrawdown;         // ������������ ������������� �������� �� ������� � �������
  double            reldrawdownpercent;  // ������������ ������������� �������� �� ������� � ���������
  double            equity_min;          // ����������� �������� equity (��� ������� ���������� �������� �� equity)
  double            maxdrawdown_e;       // ������������ �������� �� equity
  double            drawdownpercent_e;   // ��������� ������������ �������� �� equity � � ���� (+)
  double            reldrawdown_e;       // ������������ ������������� �������� �� equity � �������
  double            reldrawdownpercnt_e; // ������������ ������������� �������� �� equity � ���������
  double            expected_payoff;     // ����������� �������� (+)
  double            profit_factor;       // ���������� ������������ (+)
  double            recovery_factor;     // ������ �������������� (+)
  double            sharpe_ratio;        // ����������� ����� (+)
  double            margin_level;        // ����������� ������� �����
  double            custom_fitness;      // ���������������� ������� - ��������� OnTester (+)
  int               deals;               // ����� ���������� ������
  int               trades;              // ���������� ������ out/inout
  int               profittrades;        // ���������� ����������
  int               losstrades;          // ���������� ���������
  int               shorttrades;         // ���������� ������
  int               longtrades;          // ���������� ������
  int               winshorttrades;      // ���������� ���������� ������
  int               winlongtrades;       // ���������� ���������� ������
  int               conprofitmax_trades; // ������������ ������������������ ���������� ������
  int               maxconprofit_trades; // ������������������ ������������ �������
  int               conlossmax_trades;   // ������������ ������������������ ��������� ������
  int               maxconloss_trades;   // ������������������ ������������� ������
  int               avgconwinners;       // ������� ���������� ���������������� ���������� ������
  int               avgconloosers;       // ������� ���������� ���������������� ��������� ������

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(bars) +
           TOSTRING(ticks) +
           TOSTRING3(symbol) +
           TOSTRING(initial_deposit) +      // ��������� �������
           TOSTRING(withdrawal) +           // ����� �������
           TOSTRING(profit) +               // ����� ������� (+)
           TOSTRING(grossprofit) +          // ����� ����
           TOSTRING(grossloss) +            // ����� �����
           TOSTRING(maxprofit) +            // ����������� ���������� ������
           TOSTRING(minprofit) +            // ����������� ��������� ������
           TOSTRING(conprofitmax) +         // ������� ������������ ������������������ ���������� ������
           TOSTRING(maxconprofit) +         // ������������ ������� ����� �������������������
           TOSTRING(conlossmax) +           // ������ ������������ ������������������ ��������� ������
           TOSTRING(maxconloss) +           // ������������ ������ ����� �������������������
           TOSTRING(balance_min) +          // ����������� �������� ������� (��� ������� ���������� ��������)
           TOSTRING(maxdrawdown) +          // ������������ �������� �� �������
           TOSTRING(drawdownpercent) +      // ��������� ������������ �������� �� ������� � � ����
           TOSTRING(reldrawdown) +          // ������������ ������������� �������� �� ������� � �������
           TOSTRING(reldrawdownpercent) +   // ������������ ������������� �������� �� ������� � ���������
           TOSTRING(equity_min) +           // ����������� �������� equity (��� ������� ���������� �������� �� equity)
           TOSTRING(maxdrawdown_e) +        // ������������ �������� �� equity
           TOSTRING(drawdownpercent_e) +    // ��������� ������������ �������� �� equity � � ���� (+)
           TOSTRING(reldrawdown_e) +        // ������������ ������������� �������� �� equity � �������
           TOSTRING(reldrawdownpercnt_e) +  // ������������ ������������� �������� �� equity � ���������
           TOSTRING(expected_payoff) +      // ����������� �������� (+)
           TOSTRING(profit_factor) +        // ���������� ������������ (+)
           TOSTRING(recovery_factor) +      // ������ �������������� (+)
           TOSTRING(sharpe_ratio) +         // ����������� ����� (+)
           TOSTRING(margin_level) +         // ����������� ������� �����
           TOSTRING(custom_fitness) +       // ���������������� ������� - ��������� OnTester (+)
           TOSTRING(deals) +                // ����� ���������� ������
           TOSTRING(trades) +               // ���������� ������ out/inout
           TOSTRING(profittrades) +         // ���������� ����������
           TOSTRING(losstrades) +           // ���������� ���������
           TOSTRING(shorttrades) +          // ���������� ������
           TOSTRING(longtrades) +           // ���������� ������
           TOSTRING(winshorttrades) +       // ���������� ���������� ������
           TOSTRING(winlongtrades) +        // ���������� ���������� ������
           TOSTRING(conprofitmax_trades) +  // ������������ ������������������ ���������� ������
           TOSTRING(maxconprofit_trades) +  // ������������������ ������������ �������
           TOSTRING(conlossmax_trades) +    // ������������ ������������������ ��������� ������
           TOSTRING(maxconloss_trades) +    // ������������������ ������������� ������
           TOSTRING(avgconwinners) +        // ������� ���������� ���������������� ���������� ������
           TOSTRING(avgconloosers)          // ������� ���������� ���������������� ��������� ������
          );
  }

#undef TOSTRING3
#undef TOSTRING

  double TesterStatistics( const ENUM_STATISTICS Statistic_ID ) const
  {
    switch (Statistic_ID)
    {
      case STAT_INITIAL_DEPOSIT:
        return(this.initial_deposit);
      case STAT_WITHDRAWAL:
        return(this.withdrawal);
      case STAT_PROFIT:
        return(this.profit);
      case STAT_GROSS_PROFIT:
        return(this.grossprofit);
      case STAT_GROSS_LOSS:
        return(-this.grossloss);
      case STAT_MAX_PROFITTRADE:
        return(this.maxprofit);
      case STAT_MAX_LOSSTRADE:
        return(-this.minprofit);
      case STAT_CONPROFITMAX:
        return(this.maxconprofit);
      case STAT_CONPROFITMAX_TRADES:
        return(this.maxconprofit_trades);
      case STAT_MAX_CONWINS:
        return(this.conprofitmax);
      case STAT_MAX_CONPROFIT_TRADES:
        return(this.conprofitmax_trades);
      case STAT_CONLOSSMAX:
        return(-this.conlossmax);
      case STAT_CONLOSSMAX_TRADES:
        return(this.conlossmax_trades);
      case STAT_MAX_CONLOSSES:
        return(-this.maxconloss);
      case STAT_MAX_CONLOSS_TRADES:
        return(this.maxconloss_trades);
      case STAT_BALANCEMIN:
        return(this.balance_min);
      case STAT_BALANCE_DD:
        return(this.maxdrawdown);
      case STAT_BALANCEDD_PERCENT:
        return(this.drawdownpercent);
      case STAT_BALANCE_DDREL_PERCENT:
        return(this.reldrawdownpercent);
      case STAT_BALANCE_DD_RELATIVE:
        return(this.reldrawdown);
      case STAT_EQUITYMIN:
        return(this.equity_min);
      case STAT_EQUITY_DD:
        return(this.maxdrawdown_e);
      case STAT_EQUITYDD_PERCENT:
        return(this.drawdownpercent_e);
      case STAT_EQUITY_DDREL_PERCENT:
        return(this.reldrawdownpercnt_e);
      case STAT_EQUITY_DD_RELATIVE:
        return(this.reldrawdown_e);
      case STAT_EXPECTED_PAYOFF:
        return(this.expected_payoff);
      case STAT_PROFIT_FACTOR:
        return(this.profit_factor);
      case STAT_RECOVERY_FACTOR:
        return(this.recovery_factor);
      case STAT_SHARPE_RATIO:
        return(this.sharpe_ratio);
      case STAT_MIN_MARGINLEVEL:
        return(this.margin_level);
      case STAT_CUSTOM_ONTESTER:
        return(this.custom_fitness);
      case STAT_DEALS:
        return(this.deals);
      case STAT_TRADES:
        return(this.trades);
      case STAT_PROFIT_TRADES:
        return(this.profittrades);
      case STAT_LOSS_TRADES:
        return(this.losstrades);
      case STAT_SHORT_TRADES:
        return(this.shorttrades);
      case STAT_LONG_TRADES:
        return(this.longtrades);
      case STAT_PROFIT_SHORTTRADES:
        return(this.winshorttrades);
      case STAT_PROFIT_LONGTRADES:
        return(this.winlongtrades);
      case STAT_PROFITTRADES_AVGCON:
        return(this.avgconwinners);
      case STAT_LOSSTRADES_AVGCON:
        return(this.avgconloosers);
    }

    return(0);
  }
};