#include <Trade/DealInfo.mqh>
#include <Arrays/ArrayDouble.mqh>
#include <Generic/HashSet.mqh>
#include "FileSave.mqh"
#include "Translations/English.mqh"

enum deal_result
{
   NO_VALUE=0,
   WIN=1,
   LOSS
};
enum ENUM_HISTORY_SORT
{
   HISTORY_SORT_OPENTIME,   // Open time
   HISTORY_SORT_CLOSETIME   // Close time
};

class CHistory
{
private:
    CFileSaving       m_FileSave;
    CDealInfo         m_deal;
    CArrayDouble      m_profit_data;    
    CArrayDouble      m_balance_data;   
    CArrayDouble      m_sharp_balance;
    CArrayDouble      m_balance_line; 

    double            m_max_lot;
    double            m_initial_deposit;
    double            m_withdrawal;
    double            m_volume;
    double            m_swap;
    double            m_commission;
    double            m_profit;
    double            m_gross_profit;
    double            m_gross_loss;

    double            m_profit_factor;

    double            m_expected_payoff;

    double            m_balance;
    double            m_maxdraw_MDD;
    double            m_maxdraw_percent;
    // double            m_balance_min;
    // double            m_balance_dd;
    // double            m_balance_dd_percent;
    // double            m_balance_dd_relative;
    // double            m_balance_dd_relative_percent;
    // double            m_balance_dd_absolute;

    double            m_min_peak;
    double            m_max_peak;

    long              arr_Positions[];
    long              m_type;
    long              m_magic;

    int               m_deals;
    int               m_trades;
    int               m_profit_trades;
    double            m_profit_trades_percent;
    int               m_loss_trades;

    string            m_symbol;
    string            m_comment;
    string            m_openTime_str;
    string            m_closeTime_str;

    datetime          m_openTime_dt;
    datetime          m_closeTime_dt;

    string            m_mqlName;
    
public:
    CHistory(void);
    ~CHistory(void);


    bool                Calculate(const string Symbl,const long Mgc,datetime time_start,datetime time_end);
    double              MaxLots() {return(m_max_lot);}
    // double            InitialDeposit() {return(m_initial_deposit);}
    // double            Withdrawal()      {return(m_withdrawal);}
    double              Profit() {return(m_profit);};
    double              GrossProfit() {return(m_gross_profit);}
    double              GrossLoss() {return(m_gross_loss);}
    double              MDD() {return(m_maxdraw_MDD);}
    double              ProfitFactor() {return(m_profit_factor);}
    int                 Trades() {return(m_trades);}
    int                 ProfitTrades() {return(m_profit_trades);};
    double              ExpectedPayoff() {return(m_expected_payoff);}

    string              OpenTime()        {return(m_openTime_str);}
    string              CloseTime()       {return(m_closeTime_str);}

    double              Percent(double value,double divider);

    bool                AppendDataToCSV(datetime open_time, string symbol, ulong magic, string posType, double volume, double openPric, double Sl, double Tp, double closePrice, datetime close_time, double Commis, double Swp, double profit);
    bool                CheckIsFileBot() {return(FileIsExist(m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) +"\\"+ IntegerToString(GenerateMagicNumbers())+"\\AnalysisOutput\\"+"Transaction11209.csv"));}
    string              AnalyzePathFile() {return(m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) +"\\"+ IntegerToString(GenerateMagicNumbers())+"\\AnalysisOutput\\"+"Transaction11209.csv");}

protected:
    bool                HistorySelectByPositionProcess(const long position_id);
    
};
//m_withdrawal(0.0), m_max_lot(0.0), m_symbol(NULL), m_type(-1), m_magic(-1), m_volume(0.0),
//                           m_openTime_str("-"), m_closeTime_str("-"), m_profit(0.0), m_gross_loss(0.0), m_gross_profit(0.0)
CHistory::CHistory(void) : m_max_lot(0.0), m_openTime_str("-"), m_closeTime_str("-"), m_balance(0.0), m_max_peak(0.0), m_min_peak(0.0), m_trades(0), 
                           m_expected_payoff(0.0)
{
    m_mqlName   = MQLInfoString(MQL_PROGRAM_NAME);
    // datetime timestart = D'2024.12.24';
    // if(!CheckIsFileBot())
    // {
    //     Calculate(Symbol(), GenerateMagicNumbers(), timestart, TimeCurrent());
    //     AppendDataToCSV(OpenTime(), Symbol(), GenerateMagicNumbers(), )
    // }
}

CHistory::~CHistory(void)
{
}

bool CHistory::Calculate(const string Symbl, const long Mgc,datetime time_start,datetime time_end)
{
    deal_result result = NO_VALUE;
    
    int sort_by = HISTORY_SORT_OPENTIME;

    datetime first_entry_time = 0; 
    datetime overall_first_entry_time = 0;
    
    m_profit=0;
    m_gross_profit=0;
    m_gross_loss=0;

    if(!HistorySelect(time_start,time_end))
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_HISTORY_GET_TRADE + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_FileSave.IniFileSaveRun(txt,false);
        return(false);
    }

    int deals_total = HistoryDealsTotal();

    if(sort_by==HISTORY_SORT_OPENTIME)
    {
        for(int i = 0; i < deals_total && !IsStopped(); i++)
            if(m_deal.SelectByIndex(i))
            if(m_deal.Entry()==DEAL_ENTRY_IN)
                if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
                {
                    if(m_deal.Symbol() != Symbl)
                        continue;
                    if(m_deal.Magic() != Mgc)
                        continue;
                    //--- save position ids to the array
                    long position_id=m_deal.PositionId();
                    int arr_size=ArraySize(arr_Positions);
                    if(ArrayResize(arr_Positions,arr_size+1)==arr_size+1)
                        arr_Positions[arr_size]=position_id;
                    
                    m_trades++;
                    
                    if (first_entry_time == 0 || m_deal.Time() < first_entry_time) {first_entry_time = m_deal.Time();}
                }
    }
    if(sort_by==HISTORY_SORT_CLOSETIME)
    {
        //--- define a hashset to collect position IDs (with no duplicates)
        CHashSet<long>hashset;

        //--- handle the case when a position has multiple deals out.
        for(int i = deals_total-1; i >= 0 && !IsStopped(); i--)
            if(m_deal.SelectByIndex(i))
                if(m_deal.Entry()==DEAL_ENTRY_OUT || m_deal.Entry()==DEAL_ENTRY_OUT_BY)
                    if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
                    {
                        if(m_deal.Symbol() != Symbl)
                            continue;
                        if(m_deal.Magic() != Mgc)
                            continue;

                        hashset.Add(m_deal.PositionId());
                    }
                        

        //--- copy the elements from the set to a compatible one-dimensional array
        hashset.CopyTo(arr_Positions,0);
        //ArrayReverse(arr_Positions);
        ArraySetAsSeries(arr_Positions,true);
    }
    
    deals_total = ArraySize(arr_Positions);
    for(int i=0; i<deals_total; i++)
    {
        long position_id = arr_Positions[i];
        HistorySelectByPositionProcess(position_id);
    }
    if (first_entry_time > 0)
    {
        if (overall_first_entry_time == 0 || first_entry_time < overall_first_entry_time)
        {
            overall_first_entry_time = first_entry_time;
            m_openTime_dt = overall_first_entry_time;
            m_openTime_str = TimeToString(overall_first_entry_time, TIME_DATE);
        }
    }
    
    return true;
}


//+------------------------------------------------------------------+
//| Select history of orders and deals by position ID and            |
//| prints a list of orders and deals for the position in the journal|
//+------------------------------------------------------------------+
bool CHistory::HistorySelectByPositionProcess(const long position_id)
{
    

    double profit=0, profit_close=0;
    m_profit_factor = 0;
    

    datetime last_exit_time = 0;
    datetime overall_last_exit_time = 0;

    if(!HistorySelectByPosition(position_id))
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_HISTORY_SELECTPOSITION_ERR + "(#"+IntegerToString(position_id,0)+") " + TRANSLATION_HISTORY_SELECTPOSITION_FAILED + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_FileSave.IniFileSaveRun(txt,false);
        return(false);
    }

    int orders_total=HistoryOrdersTotal();
    for(int i=0; i<orders_total; i++)
    {
        ulong ticket = HistoryOrderGetTicket(i);
        string ordersymbol = HistoryOrderGetString(ticket, ORDER_SYMBOL);
        long ordermagic = HistoryOrderGetInteger(ticket, ORDER_MAGIC);
        if(ticket==0)
            continue;
        
    }

    int deals_total =HistoryDealsTotal();
    for(int i=0; i<deals_total; i++)
    {
        ulong ticket=HistoryDealGetTicket(i);
        double dealprofit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
        string dealsymbl = HistoryDealGetString(ticket, DEAL_SYMBOL);
        ulong dealmagic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
        double dealswap = HistoryDealGetDouble(ticket, DEAL_SWAP);
        double dealcomision = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
        double dealvolume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
        datetime dealtimeClose = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
        
        if(ticket==0)
            continue;
        ENUM_DEAL_ENTRY deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
        ENUM_DEAL_TYPE  deal_type= (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
        if(deal_type == DEAL_TYPE_BUY || deal_type == DEAL_TYPE_SELL)
        {
        
            profit = NormalizeDouble(dealprofit + dealswap + dealcomision, 2);
            if(profit >= 0.0) {m_gross_profit += profit;}
            else {m_gross_loss += profit;}

            // Print(dealprofit,"  |in| ",dealswap,"  |in| ",dealcomision);
            
            if(dealvolume > m_max_lot) {m_max_lot = dealvolume;}

            if (last_exit_time < dealtimeClose) {last_exit_time = dealtimeClose;}
        }

        if(deal_entry == DEAL_ENTRY_OUT || deal_entry == DEAL_ENTRY_OUT_BY || deal_entry == DEAL_ENTRY_IN || deal_entry == DEAL_ENTRY_INOUT)
        {
            profit_close = NormalizeDouble(dealprofit + dealswap + dealcomision,2);
            m_balance += profit_close; 
            // m_trades++;
            // Print(dealprofit,"  |out| ",dealswap,"  |out| ",dealcomision);
            
            if(profit >= 0.0)
            {
                m_profit_trades++;
            }
            
        }

                        
    }
    if (last_exit_time > 0)
    {
        if (overall_last_exit_time == 0 || last_exit_time > overall_last_exit_time)
        {
            overall_last_exit_time = last_exit_time;
            m_closeTime_dt = overall_last_exit_time;
            m_closeTime_str = TimeToString(overall_last_exit_time, TIME_DATE);
        }
    }
    if (m_balance > max_balance)
    {
        max_balance = m_balance;
    }
    drawdown = NormalizeDouble(max_balance - m_balance, 2);
    if(drawdown > m_maxdraw_MDD) {m_maxdraw_MDD = drawdown;}
    // Print("balance ",m_balance," | ",max_balance," | ",drawdown," | ",m_maxdraw_MDD);
    m_profit = m_gross_profit+m_gross_loss;

    if(MathAbs(m_gross_loss) > FLT_EPSILON) {m_profit_factor = MathAbs(m_gross_profit/m_gross_loss);}

    if(m_trades > 0)
    {
        m_expected_payoff=m_profit/m_trades;
        m_profit_trades_percent = (double)m_profit_trades / m_trades * 100;
    }
    return true;
}

double CHistory::Percent(double value,double divider)
{
    if(MathAbs(value)<=FLT_EPSILON)
      return(0);
    return(100*value/divider);
}

bool CHistory::AppendDataToCSV(datetime open_time, string symbol, ulong magic, string posType, double volume, double openPric, double Sl, double Tp, double closePrice, datetime close_time, double Commis, double Swp, double profit)
{
    
    int fh;
    // Save to new format only.
    fh = FileOpen(AnalyzePathFile(), FILE_WRITE|FILE_CSV|FILE_ANSI,',');
    if (fh == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = TRANSLATION_FILED_TO_OPEN_FILE_WRITING + AnalyzePathFile() + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSaveRun(txt,false);
        m_FileSave.IniFileSave(__FUNCTION__+":: "+ txt, false);
        return false;
    }
    FileWrite(fh, "Open Time", "Symbol", "Magic Number", "Type", "Volume", "Open Price", "S/L", "T/P", "Close Price", "Close Time", "Commission", "Swap", "Profit");
    FileWrite(fh, open_time, symbol, magic, posType, volume, openPric, Sl, Tp, closePrice, close_time, Commis, Swp, profit);

    FileClose(fh);
    


    return true;
}
//--- global variable
double max_balance = -DBL_MAX;
double drawdown = 0.0;
/*
bool CHistory::Calculate(const string Symbl, const long Mgc,datetime time_start,datetime time_end,double initial_deposit=0.0)
{
    
    if(!HistorySelect(time_start,time_end))
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_HISTORY_GET_TRADE + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_FileSave.IniFileSaveRun(txt,false);
        return(false);
    }
    for(int i = HistoryDealsTotal()-1; i >=0; i--)
    {
        // deals
        ulong dealticket = HistoryDealGetTicket(i);
        if (dealticket <= 0)  {
            ResetLastError();
            string txt = " ⚠ "+ TRANSLATION_DEAL_ERROR_TICKT + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
            m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
            m_FileSave.IniFileSaveRun(txt,false);
            return(false);
        }
        datetime first_entry_time = 0; 
        datetime last_exit_time = 0;
        datetime overall_first_entry_time = 0;
        datetime overall_last_exit_time = 0;

        long dealID = 0;
        double dealprice = HistoryDealGetDouble(dealticket,DEAL_PRICE);
        double dealvolume = HistoryDealGetDouble(dealticket,DEAL_VOLUME);
        double dealprofit = HistoryDealGetDouble(dealticket,DEAL_PROFIT);
        double dealcommision = HistoryDealGetDouble(dealticket,DEAL_COMMISSION);
        double dealswap = HistoryDealGetDouble(dealticket,DEAL_SWAP);
        ulong dealmagic   = HistoryDealGetInteger(dealticket,DEAL_MAGIC);
        string dealcomment = HistoryDealGetString(dealticket,DEAL_COMMENT);
        datetime dealtimed = (datetime)HistoryDealGetInteger(dealticket, DEAL_TIME);
        string dealDate = TimeToString(dealtimed, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
        string dealsymbol = HistoryDealGetString(dealticket,DEAL_SYMBOL);
        ENUM_DEAL_ENTRY dealentry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealticket,DEAL_ENTRY);
        ENUM_DEAL_TYPE dealtype = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealticket,DEAL_TYPE);
        long dealreason = HistoryDealGetInteger(dealticket,DEAL_REASON);

        long posID = 0;
      
        // orders
        ulong orderticket = HistoryDealGetInteger(dealticket,DEAL_ORDER);    
        long orderID = HistoryOrderGetInteger(orderticket, ORDER_POSITION_ID);
        double orderprice = HistoryOrderGetDouble(orderticket,ORDER_PRICE_OPEN);
        double ordervolume = HistoryOrderGetDouble(dealticket,ORDER_VOLUME_INITIAL);
        datetime ordertimed = (datetime)HistoryOrderGetInteger(orderticket,ORDER_TIME_DONE);
        string orderDate = TimeToString(ordertimed, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
        string ordersymbol = HistoryOrderGetString(orderticket,ORDER_SYMBOL);
        ENUM_ORDER_TYPE ordertype = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(orderticket,ORDER_TYPE);

        if((dealsymbol == Symbl) && (dealmagic == Mgc))
        {
            if(dealentry == DEAL_ENTRY_IN)
            {
                if(dealvolume > m_max_lot) {m_max_lot = dealvolume;}
                if (first_entry_time == 0 || dealtimed < first_entry_time) {first_entry_time = dealtimed;}

                dealID = HistoryDealGetInteger(dealticket,DEAL_POSITION_ID);
                posID = dealID;    
                // Print(dealsymbol," in| ",dealcommision," | ",dealprofit," | ",dealmagic," | ",dealticket," | ",dealvolume," |id| ",dealID);
                // Print(ordersymbol," in| ",0," | ",0," | ",0," | ",orderticket," | ",ordervolume," |id| ",orderID);
                
            }
            // else if (dealentry == DEAL_ENTRY_OUT)
            // {
            //     if(orderticket == dealID)
            //     {
            //         Print("tick  ",dealticket, " | ",orderticket);
            //     }
            //     // Print(dealsymbol," | ",dealcommision," | ",dealprofit," | ",dealmagic," | ",dealticket," | ",dealvolume);
            //     // Print(ordersymbol," | ",0," | ",0," | ",0," | ",orderticket," | ",ordervolume);
            // }
            
            // Print(dealsymbol," in| ",dealcommision," | ",dealprofit," | ",dealmagic," | ",dealticket," | ",dealvolume," |id| ",dealID);
            // Print(ordersymbol," in| ",0," | ",0," | ",0," | ",orderticket," | ",ordervolume," |id| ",orderID);
        }
        
        if(dealticket == posID)
        {
            Print(dealticket," | ",orderticket);
            // Print(dealsymbol," in| ",dealcommision," | ",dealprofit," | ",dealmagic," | ",dealticket," | ",dealvolume," |id| ",dealID);
            // Print(ordersymbol," in| ",0," | ",0," | ",0," | ",orderticket," | ",ordervolume," |id| ",orderID);
        }
        
   
        // if(dealID == posID)
        // {
        //     Print(dealsymbol," in| ",dealcommision," | ",dealprofit," | ",dealmagic," | ",dealticket," | ",dealvolume," |id| ",dealID);
        //     Print(ordersymbol," in| ",0," | ",0," | ",0," | ",orderticket," | ",ordervolume," |id| ",orderID);
        // }
        if (first_entry_time > 0)
        {
            if (overall_first_entry_time == 0 || first_entry_time < overall_first_entry_time)
            {
                overall_first_entry_time = first_entry_time;
                m_openTime_str = TimeToString(overall_first_entry_time, TIME_DATE);
            }
        }
    }

    
    // Print("maxlot  ",m_max_lot," open time  ",m_openTime_str," close time  ",m_closeTime_str);
    return true;
}