//+------------------------------------------------------------------+
//|                                         HistoryDealGetTicket.mq5 |
//|                         Copyright © 2016-2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016-2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.004"
#property script_show_inputs
//---
input datetime from_date=D'2017.02.07 11:11:00';
input datetime to_date=D'2019.09.20 11:40:00';
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   ulong    deal_ticket;            // ticket deal 
   ulong    order_ticket;           // deal order number
   datetime deal_transaction_time;  // deal time  
   long     deal_type;              // deal type
   long     deal_entry;             // deal entry - entry in, entry out, reverse
   long     deal_position_ID;       // identifier of a position, in the opening, modification or closing of which this deal took part
   string   deal_description;       // string to form description 
   double   deal_volume;            // deal volume 
   double   deal_commission;        // deal commission
   double   deal_swap;              // cumulative swap on close
   double   deal_profit;            // deal profit
   string   deal_symbol;            // deal symbol
//--- request trade history 
   HistorySelect(from_date,to_date);
//--- number of deal in history
   int deals=HistoryDealsTotal();
//--- for all deals 
   for(int i=0;i<deals;i++)
     {
      deal_ticket          = HistoryDealGetTicket(i);
      deal_volume          = HistoryDealGetDouble(deal_ticket,DEAL_VOLUME);
      deal_commission      = HistoryDealGetDouble(deal_ticket,DEAL_COMMISSION);
      deal_swap            = HistoryDealGetDouble(deal_ticket,DEAL_SWAP);
      deal_profit          = HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
      deal_transaction_time= (datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
      order_ticket         = HistoryDealGetInteger(deal_ticket,DEAL_ORDER);
      deal_type            = HistoryDealGetInteger(deal_ticket,DEAL_TYPE);
      deal_entry           = HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
      deal_symbol          = HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
      deal_position_ID     = HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
      deal_description=GetDealDescription(deal_entry,deal_type,deal_volume,deal_commission,
                                          deal_swap,deal_profit,deal_symbol,order_ticket,deal_position_ID);
      //--- make beautiful formatting for number of the deal
      string print_index=StringFormat("% 3d",i);
      //--- output information on the deal
      Print(print_index+": deal #",deal_ticket," at ",deal_transaction_time," ",deal_description);
     }
  }
//+------------------------------------------------------------------+ 
//| Returns the line description of operation                        | 
//+------------------------------------------------------------------+ 
string GetDealDescription(const long entry,const long type,const double volume,const double commission,
                          const double swap,const double profit,const string symbol,const long ticket,const long pos_ID)
  {
   string descr;                          // description
//---
   switch((int)entry)
     {
      case DEAL_ENTRY_IN:     descr="Entry in, "; break;
      case DEAL_ENTRY_OUT:    descr="Entry out, "; break;
      case DEAL_ENTRY_INOUT:  descr="Reverse, "; break;
      case DEAL_ENTRY_OUT_BY: descr="Сlose a position by an opposite one, "; break;
     }
//--- 
   switch((int)type)
     {
      case DEAL_TYPE_BALANCE:                  descr+="\"balance\""; break;
      case DEAL_TYPE_CREDIT:                   descr+="\"credit\""; break;
      case DEAL_TYPE_CHARGE:                   descr+="\"charge\""; break;
      case DEAL_TYPE_CORRECTION:               descr+="\"correction\""; break;
      case DEAL_TYPE_BUY:                      descr+="buy"; break;
      case DEAL_TYPE_SELL:                     descr+="sell"; break;
      case DEAL_TYPE_BONUS:                    descr+="\"bonus\""; break;
      case DEAL_TYPE_COMMISSION:               descr+="\"additional commission\""; break;
      case DEAL_TYPE_COMMISSION_DAILY:         descr+="\"daily commission\""; break;
      case DEAL_TYPE_COMMISSION_MONTHLY:       descr+="\"monthly commission\""; break;
      case DEAL_TYPE_COMMISSION_AGENT_DAILY:   descr+="\"daily agent commission\""; break;
      case DEAL_TYPE_COMMISSION_AGENT_MONTHLY: descr+="\"monthly agent commission\""; break;
      case DEAL_TYPE_INTEREST:                 descr+="\"interest rate\""; break;
      case DEAL_TYPE_BUY_CANCELED:             descr+="cancelled buy deal\""; break;
      case DEAL_TYPE_SELL_CANCELED:            descr+="cancelled sell deal\""; break;
     }
   descr=StringFormat("%s vol: %G comm: %G swap: %G profit: %G %s (order #%d, position ID %d)",
                      descr,     // description
                      volume,    // deal volume  
                      commission,// deal commission
                      swap,      // cumulative swap on close
                      profit,    // deal profit
                      symbol,    // deal symbol
                      ticket,    // deal order number
                      pos_ID     // identifier of a position, in the opening, modification or closing of which this deal took part
                      );
   return(descr);
//--- 
  }
//+------------------------------------------------------------------+
