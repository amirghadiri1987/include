#include <Trade/DealInfo.mqh>
#include <Arrays/ArrayDouble.mqh>
#include <Generic/HashSet.mqh>
#include <Retrace/FileSave.mqh>
#include <Retrace/Translations/English.mqh>

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
    CDealInfo         m_deal;
    CFileSaving       m_FileSave;
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

    // only to save file CSV
    datetime         c_opTime;
    datetime         c_clTime;
    string           c_type;
    long             c_magic;
    double           c_volume;
    double           c_opPrice;
    double           c_sl;
    double           c_tp;
    double           c_clPrice;
    double           c_commission;
    double           c_swap;
    double           c_profit;
    double           c_profitPoint;
    string           c_duration;
    string           c_opComment;
    string           c_clComment;
    
public:
    CHistory(void);
    ~CHistory(void);

    bool                ExportHistoryPositions(const string Cmment);
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

    int                 CountRowsInCSV();
    bool                AppendDataToCSV();
    bool                CheckIsFileBot() {return(FileIsExist(m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) +"\\"+ "Trade_Transaction.csv"));}
    string              AnalyzePathFile() {return(m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) +"\\"+"Trade_Transaction.csv");}

    bool                Calculate(const string Symbl,const long Mgc,datetime time_start,datetime time_end);
    bool                HistorySelectByPositionProcess(const long position_id, const bool saveCsv);
    string              GetExpertNameWithSum();
    
};

CHistory::CHistory(void) 
{
    m_mqlName   = MQLInfoString(MQL_PROGRAM_NAME);
    c_magic = 1;
    
}

CHistory::~CHistory(void)
{
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::ExportHistoryPositions(const string Cmment)
{
    datetime time_start = D'2024.12.24';
    int handle= FileOpen(AnalyzePathFile(),FILE_WRITE|FILE_CSV|FILE_ANSI,',');// |FILE_ANSI,','
    if(handle == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = TRANSLATION_FILED_TO_OPEN_FILE_WRITING + AnalyzePathFile() + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSaveRun(txt,false);
        m_FileSave.IniFileSave(__FUNCTION__+":: "+ txt, false);
        return false;
    }

    FileWrite(handle, "Open Time", "Symbol", "Magic Number", "Type", "Volume", "Open Price", "S/L", "T/P", "Close Price", "Close Time", "Commission", "Swap", "Profit",
              "Profit Points", "Duration", "Open Comment", "Close Comment");

    ulong s_time=GetMicrosecondCount();
    double Balanc=0;


    if(!HistorySelect(time_start,TimeCurrent()))
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_HISTORY_GET_TRADE + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_FileSave.IniFileSaveRun(txt,false);
        return(false);
    }

    int deals = HistoryDealsTotal();
    int sort_by = HISTORY_SORT_CLOSETIME;

    if(sort_by==HISTORY_SORT_OPENTIME)
    {
        for(int i = 0; i < deals && !IsStopped(); i++)
        {
            if(m_deal.SelectByIndex(i))
                if(m_deal.Entry()==DEAL_ENTRY_IN)
                {
                    if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
                    {
                        //--- save position ids to the array
                        long position_id=m_deal.PositionId();
                        int arr_size=ArraySize(arr_Positions);
                        ArrayResize(arr_Positions,arr_size+1,100);
                        arr_Positions[arr_size]=position_id;
                    }
                }
        }
    }    
    //---
    if(sort_by==HISTORY_SORT_CLOSETIME)
    {
        //--- define a hashset to collect position IDs (with no duplicates)
        CHashSet<long>hashset;

        //--- handle the case when a position has multiple deals out.
        for(int i = deals-1; i >= 0 && !IsStopped(); i--)
            if(m_deal.SelectByIndex(i))
            {
                if(m_deal.Entry() == DEAL_ENTRY_IN && StringFind(m_deal.Comment(), Cmment) != -1)
                {
                    if(m_deal.DealType() == DEAL_TYPE_BUY || m_deal.DealType() == DEAL_TYPE_SELL)
                    {
                        hashset.Add(m_deal.PositionId());
                    }
                }
                // if(m_deal.Entry()==DEAL_ENTRY_OUT || m_deal.Entry()==DEAL_ENTRY_OUT_BY)
                //     if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
                //         hashset.Add(m_deal.PositionId());
            }
        //--- copy the elements from the set to a compatible one-dimensional array
        hashset.CopyTo(arr_Positions,0);
        //ArrayReverse(arr_Positions);
        ArraySetAsSeries(arr_Positions,true);
    }

    //--- now process the list of positions stored in the array
    int positions=ArraySize(arr_Positions);
    for(int i=0; i<positions && !IsStopped(); i++)
    {
        string   pos_symbol=NULL;
        long     pos_id=-1;
        long     pos_type=-1;
        long     pos_magic=-1;
        double   pos_open_price=0;
        double   pos_close_price=0;
        double   pos_sl = 0;
        double   pos_tp = 0;
        double   pos_commission = 0;
        double   pos_swap=0;
        double   pos_profit=0;
        double   pos_open_volume= 0;
        double   pos_close_volume=0;
        datetime pos_open_time=0;
        datetime pos_close_time=0;
        double   pos_sum_cost=0;
        long     pos_open_reason=-1;
        long     pos_close_reason=-1;
        string   pos_open_comment = NULL;
        string   pos_close_comment = NULL;

        
        //--- request the history of deals and orders for the specified position
        if(HistorySelectByPosition(arr_Positions[i]) && HistoryDealsTotal()>1)
        {
            //--- now process the list of received deals for the specified position
            deals=HistoryDealsTotal();
            for(int j=0; j<deals && !IsStopped(); j++)
            {
                //--- select deal ticket by its position in the list
                if(m_deal.SelectByIndex(j))
                {
                    pos_id                 = m_deal.PositionId();
                    pos_symbol             = m_deal.Symbol();
                    pos_commission        += m_deal.Commission();
                    pos_swap              += m_deal.Swap();
                    pos_profit            += m_deal.Profit();

                    //--- Entry deal for position
                    if(m_deal.Entry()==DEAL_ENTRY_IN)
                    {
                        pos_magic           = m_deal.Magic();
                        pos_type            = m_deal.DealType();
                        pos_open_time       = m_deal.Time();
                        pos_open_price      = m_deal.Price();
                        pos_open_volume     = m_deal.Volume();
                        //---
                        pos_open_comment    = m_deal.Comment();
                        pos_open_reason     = HistoryDealGetInteger(m_deal.Ticket(), DEAL_REASON);
                    }

                    //--- Exit deal(s) for position
                    else if(m_deal.Entry()==DEAL_ENTRY_OUT || m_deal.Entry()==DEAL_ENTRY_OUT_BY)
                    {
                        pos_close_time      = m_deal.Time();
                        pos_sum_cost       += m_deal.Volume() * m_deal.Price();
                        pos_close_volume   += m_deal.Volume();
                        pos_close_price     = pos_sum_cost / pos_close_volume;
                        pos_sl              = HistoryDealGetDouble(m_deal.Ticket(), DEAL_SL);
                        pos_tp              = HistoryDealGetDouble(m_deal.Ticket(), DEAL_TP);
                        //---
                        pos_close_comment  += m_deal.Comment() + " ";
                        pos_close_reason    = HistoryDealGetInteger(m_deal.Ticket(), DEAL_REASON);
                    }
              
                }
            }

            //--- If the position is still open, it will not be displayed in the history.
            if(MathAbs(pos_open_volume-pos_close_volume)>0.00001)
                continue;

            //--- Closed position is reconstructed
            StringTrimLeft(pos_close_comment);
            StringTrimRight(pos_close_comment);

            //--- sums
            Balanc+=pos_profit+pos_swap+pos_commission;

            //---
            SymbolSelect(pos_symbol,true);
            int digits=(int)SymbolInfoInteger(pos_symbol,SYMBOL_DIGITS);
            double point=SymbolInfoDouble(pos_symbol,SYMBOL_POINT);

            FileWrite(handle,
                        (string)pos_open_time,
                        pos_symbol,
                        pos_magic,
                        (pos_type==DEAL_TYPE_BUY) ? "buy" : (pos_type==DEAL_TYPE_SELL) ? "sell" : "other",
                        DoubleToString(pos_close_volume,2),
                        DoubleToString(pos_open_price,digits),
                        (pos_sl ? DoubleToString(pos_sl,digits) : ""),
                        (pos_tp ? DoubleToString(pos_tp,digits) : ""),
                        DoubleToString(pos_close_price,(deals==2 ? digits : digits+3)),
                        (string)pos_close_time,
                        DoubleToString(pos_commission,2),
                        DoubleToString(pos_swap,2),
                        DoubleToString(pos_profit,2),
                        MathRound((pos_type == DEAL_TYPE_BUY ? pos_close_price - pos_open_price : pos_open_price - pos_close_price) / point),
                        //
                        // (sort_by == HISTORY_SORT_CLOSETIME ? DoubleToString(Balanc,2) : ""),
                        //
                        
                        TimeElapsedToString(pos_close_time - pos_open_time),
                        pos_open_comment,
                        pos_close_comment
                    );
        
        }
    }

    FileClose(handle);


    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeElapsedToString(const datetime pElapsedSeconds)
{
   const long days = pElapsedSeconds / PeriodSeconds(PERIOD_D1);

   return((days ? (string)days + "d " : "") + TimeToString(pElapsedSeconds,TIME_SECONDS));
}

bool CHistory::Calculate(const string Symbl, const long Mgc,datetime time_start,datetime time_end)
{
    deal_result result = NO_VALUE;
    
    int sort_by = HISTORY_SORT_OPENTIME;

    datetime first_entry_time = 0; 
    datetime overall_first_entry_time = 0;
    
    datetime open_times[];

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
        {
            if(m_deal.SelectByIndex(i))
                if(m_deal.Entry()==DEAL_ENTRY_IN)
                {
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
        HistorySelectByPositionProcess(position_id, false);
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
bool CHistory::HistorySelectByPositionProcess(const long position_id, const bool saveCsv)
{
    

    double profit=0, profit_close=0;
    m_profit_factor = 0;
    c_commission = 0.0;

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
        
        ulong c_dealticket = HistoryDealGetInteger(ticket, DEAL_TICKET);
        ENUM_DEAL_ENTRY c_dealentry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(c_dealticket, DEAL_ENTRY);
        ENUM_DEAL_TYPE c_dealTyp = (ENUM_DEAL_TYPE)HistoryDealGetInteger(c_dealticket, DEAL_TYPE);
        string c_symbol = HistoryDealGetString(c_dealticket, DEAL_SYMBOL);
        double c_point  = SymbolInfoDouble(c_symbol, SYMBOL_POINT);

        if(ticket==0)
            continue;

        if(c_dealentry == DEAL_ENTRY_IN || c_dealentry == DEAL_ENTRY_INOUT)
        {
            c_opTime    = (datetime)HistoryDealGetInteger(c_dealticket, DEAL_TIME);
            c_type      = HistoryDealGetInteger(c_dealticket, DEAL_TYPE) == 0 ? "Buy" : "Sell";
            c_volume    = HistoryDealGetDouble(c_dealticket, DEAL_VOLUME);
            c_opPrice   = HistoryDealGetDouble(c_dealticket, DEAL_PRICE);
            c_commission += HistoryDealGetDouble(c_dealticket, DEAL_COMMISSION);
            c_opComment   = HistoryDealGetString(c_dealticket, DEAL_COMMENT);
        }
        if(c_dealentry == DEAL_ENTRY_OUT || c_dealentry == DEAL_ENTRY_OUT_BY)
        {
            c_sl        = HistoryDealGetDouble(c_dealticket, DEAL_SL);
            c_tp        = HistoryDealGetDouble(c_dealticket, DEAL_TP);
            c_clPrice   = HistoryDealGetDouble(c_dealticket, DEAL_PRICE);
            c_clTime    = (datetime)HistoryDealGetInteger(c_dealticket, DEAL_TIME);
            c_commission += HistoryDealGetDouble(c_dealticket, DEAL_COMMISSION);
            c_swap      = HistoryDealGetDouble(c_dealticket, DEAL_SWAP);
            c_profit    = HistoryDealGetDouble(c_dealticket, DEAL_PROFIT);
            c_profitPoint = MathRound((c_dealTyp == DEAL_TYPE_BUY ? c_clPrice - c_opPrice : c_opPrice - c_clPrice) / c_point);
            c_duration    = TimeElapsedToString(c_clTime - c_opTime);
            c_clComment   = HistoryDealGetString(c_dealticket, DEAL_COMMENT);
            c_magic       = HistoryDealGetInteger(c_dealticket, DEAL_MAGIC);
        }
        
        
        ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
        ENUM_DEAL_TYPE  deal_type  = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
        
        if(deal_type == DEAL_TYPE_BUY || deal_type == DEAL_TYPE_SELL)
        {
        
            profit = NormalizeDouble(dealprofit + dealswap + dealcomision, 2);
            if(profit >= 0.0) {m_gross_profit += profit;}
            else {m_gross_loss += profit;}

            
            if(dealvolume > m_max_lot) {m_max_lot = dealvolume;}

            if (last_exit_time < dealtimeClose) {last_exit_time = dealtimeClose;}
        }

        if(deal_entry == DEAL_ENTRY_OUT || deal_entry == DEAL_ENTRY_OUT_BY || deal_entry == DEAL_ENTRY_IN || deal_entry == DEAL_ENTRY_INOUT)
        {
            profit_close = NormalizeDouble(dealprofit + dealswap + dealcomision,2);
            m_balance += profit_close; 
            
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

    // Print("c_optime: ", TimeToString(c_opTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
    //           " c_type: ", c_type,
    //           " c_volume: ", c_volume,
    //           " c_opPrice: ", c_opPrice,
    //           " c_sl: ", c_sl,
    //           " c_tp: ", c_tp,
    //           " c_clPrice: ", c_clPrice,"\n",
    //           " c_clTime: ", TimeToString(c_clTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
    //           " commis: " ,c_commission,
    //           " swap: ", c_swap,
    //           " profit: ", c_profit,"\n",
    //           " profit point: ", c_profitPoint,
    //           " duration: ", c_duration,
    //           " opcoment: ", c_opComment," cclcom ",c_clComment);
    if(saveCsv) {AppendDataToCSV();}
    return true;
}

double CHistory::Percent(double value,double divider)
{
    if(MathAbs(value)<=FLT_EPSILON)
      return(0);
    return(100*value/divider);
}

bool CHistory::AppendDataToCSV()
{
    int retryCount = 0;                   // Initialize the retry counter
    const int maxRetries = 3;            // Maximum allowed retries

    while (retryCount < maxRetries)
    {
        int handle = FileOpen(AnalyzePathFile(), FILE_READ | FILE_WRITE | FILE_CSV|FILE_ANSI,','); //  | FILE_ANSI, ','
        if (handle != INVALID_HANDLE)
        {
            // File opened successfully, append data
            FileSeek(handle, 0, SEEK_END);
            FileWrite(handle,
                      c_opTime, Symbol(), c_magic, c_type, c_volume, c_opPrice, c_sl, c_tp,
                      c_clPrice, c_clTime, c_commission, c_swap, c_profit, c_profitPoint,
                      c_duration, c_opComment, c_clComment);
            FileClose(handle);

            return true; // Successfully written to the file
        }
        else
        {
            // Handle the file open error
            retryCount++;
            ResetLastError();
            string errorDetails = TRANSLATION_FILED_TO_OPEN_FILE_WRITING + AnalyzePathFile() +
                                  TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
            m_FileSave.IniFileSaveRun(errorDetails, false);
            m_FileSave.IniFileSave(__FUNCTION__ + ":: " + errorDetails, false);

            // Prepare warning message for the user
            string caption = TRANSLATION_FILED_TO_OPEN_FILE_WRITING2;
            string warning = StringFormat(
                "%s\n%s\n\n%s\n%s (%d/%d)%s%d%s",
                TRANSLATION_SAVE_ERR_MESSAG_FILE, AnalyzePathFile(),
                TRANSLATION_SAVE_ERR_MESSAG_FILE_OPEN, TRANSLATION_SAVE_ERR_MESSAG_ATTEMPT,
                retryCount, maxRetries, TRANSLATION_SAVE_ERR_MESSAG_WILL, maxRetries,
                TRANSLATION_SAVE_ERR_MESSAG_ATTEMPTS
            );

            // Show the warning message
            int ret = MessageBox(warning, caption, MB_OK | MB_ICONWARNING);
            if (ret == IDOK)
            {
                ExportHistoryPositions("Break EA 651"); // GetExpertNameWithSum()
                // continue; // User clicked OK, retry file access
            }
        }
    }

    // Final warning after maximum retries exceeded
    string finalWarning = StringFormat(
        "%s\n%s\n\n%s%d%s\n%s",
        TRANSLATION_SAVE_ERR_MESSAG_FILE, AnalyzePathFile(),
        TRANSLATION_SAVE_ERR_MESSAG_AFFTER, maxRetries,
        TRANSLATION_SAVE_ERR_MESSAG_ATTEMPTS, TRANSLATION_SAVE_ERR_MESSAG_STOP
    );
    MessageBox(finalWarning, "Error", MB_OK | MB_ICONERROR);

    ExpertRemove(); // Stop the expert after exceeding retries

    return false;
}

string CHistory::GetExpertNameWithSum()
{
    string result;
    string expName = MQLInfoString(MQL_PROGRAM_NAME);
    int totalSum = 0;
   
    // Loop through each character in the expert name
    for (int i = 0; i < StringLen(expName); i++)
    {
        int charValue = StringGetCharacter(expName, i);
        totalSum += charValue;
    }

    result = expName +" EA_"+ IntegerToString(totalSum);
    
    return result;
}


string baseSymbol = "";


void GetMatchingSymbols(string &matchingSymbols[])
{
   string currentSymbol = Symbol(); // Get the current chart symbol

   if (baseSymbol == "")
   {
      baseSymbol = currentSymbol; // Set base symbol globally
      ArrayResize(matchingSymbols, 1); 
      matchingSymbols[0] = currentSymbol; // Store the first matching symbol
      Print("Base symbol initialized: ", baseSymbol);
      return; // Return early with the base symbol
   }

   int minLength = MathMin(StringLen(baseSymbol), StringLen(currentSymbol));
   int commonLength = 0;

   for (int i = 0; i < minLength; i++)
   {
      if (StringGetCharacter(baseSymbol, i) == StringGetCharacter(currentSymbol, i))
         commonLength++;
      else
         break;
   }

   string baseCore = StringSubstr(baseSymbol, 0, commonLength);
   string currentCore = StringSubstr(currentSymbol, 0, commonLength);

   if (baseCore != currentCore)
   {
      baseSymbol = currentSymbol;
      ArrayResize(matchingSymbols, 1);
      matchingSymbols[0] = currentSymbol; 
      Print("Symbol change detected: Previous Base = ", baseSymbol, ", New Core = ", currentCore);
   }
   else
   {
      ArrayResize(matchingSymbols, ArraySize(matchingSymbols) + 1);
      matchingSymbols[ArraySize(matchingSymbols) - 1] = currentSymbol; 
   }
}

// Function to count rows in a CSV file
int CHistory::CountRowsInCSV() {
    int row_count = 0;
    string filename = AnalyzePathFile();
    int file_handle = FileOpen(filename, FILE_READ | FILE_CSV | FILE_ANSI);

    if (file_handle == INVALID_HANDLE) {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_FILED_TO_OPEN_FILE_WRITING3 + AnalyzePathFile() + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_FileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_FileSave.IniFileSaveRun(txt,false);
        return(-1);
    }

    // Read the file line by line
    while (!FileIsEnding(file_handle)) // Loop until the end of the file
    {
        string firstColumn = FileReadString(file_handle); // Read the first column
        if (firstColumn != "") // If the first column is not empty, increment the row count
        {
            row_count++;
        }
        // Skip the rest of the columns in the current row
        while (!FileIsLineEnding(file_handle) && !FileIsEnding(file_handle))
        {
            FileReadString(file_handle); // Read and discard the remaining columns
        }
    }


    FileClose(file_handle); // Close the file
    return row_count - 1;
}



//--- global variable
double max_balance = -DBL_MAX;
double drawdown = 0.0;








