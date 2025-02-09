#include "String.mqh"

#define UINT64 ulong
#define INT64 datetime
#define UINT uint

//+------------------------------------------------------------------+
//| Структура торговой сделки                                        |
//+------------------------------------------------------------------+
struct TradeDeal
{
  UINT64            deal;                    // уникальный идентификатор записи
  UINT64            order;                   // идентификатор ордера которому соответствует запись
  INT64             time_create;             // время создания записи
  //   wchar_t           symbol[32];              // символ по которому выставлен ордер
  STRING32          symbol;                  // символ по которому выставлен ордер
  double            price_open;              // цена открытия\исполнения
  double            price_close;             // цена закрытия
  double            sl;                      // стоп-лосс позиции
  double            tp;                      // тейк-профит позиции
  UINT64            volume;                  // объём исполнения
  double            profit;                  // финансовый результат
  double            commission;              // коммиссия за выполнение
  double            reserve;                 // резерв
  double            storage;                 // активы
  //   wchar_t           comment[32];             // комментарий к ордеру
  STRING32          comment;                 // комментарий к ордеру
  ENUM_DEAL_TYPE    action;                  // идентификатор события
  ENUM_DEAL_ENTRY   entry;                   // вход в позицию или выход
  UINT              digits;                  // количество знаков у торгового символа
  UINT              digits_currency;         // количество знаков у валюты группы
  double            contract_size;           // размер контракта
  UINT64            position_id;

  bool Set( const ulong Ticket )
  {
    const bool Res = (::HistoryDealGetInteger(Ticket, DEAL_TICKET) == Ticket);

    if (Res)
    {
      this.deal = Ticket;                                                                                    // уникальный идентификатор записи

      string Str = ::HistoryDealGetString(Ticket, DEAL_SYMBOL);;
      this.symbol = Str;                                                                                     // символ по которому выставлен ордер

      this.contract_size = ::SymbolInfoDouble(Str, SYMBOL_TRADE_CONTRACT_SIZE);                              // размер контракта
      this.digits = (UINT)::SymbolInfoInteger(Str, SYMBOL_DIGITS);                                           // количество знаков у торгового символа

      Str = ::HistoryDealGetString(Ticket, DEAL_COMMENT);
      this.comment = Str;                                                                                    // комментарий к ордеру

      this.order = ::HistoryDealGetInteger(Ticket, DEAL_ORDER);                                              // идентификатор ордера которому соответствует запись
      this.time_create = (INT64)::HistoryDealGetInteger(Ticket, DEAL_TIME);                                  // время создания записи
      this.price_open = ::HistoryDealGetDouble(Ticket, DEAL_PRICE);                                          // цена открытия\исполнения
      this.price_close = 0;                                                                                  // цена закрытия
      this.sl = ::HistoryDealGetDouble(Ticket, DEAL_SL);                                                     // стоп-лосс позиции
      this.tp = ::HistoryDealGetDouble(Ticket, DEAL_TP);                                                     // тейк-профит позиции
      this.volume = (UINT64)(::HistoryDealGetDouble(Ticket, DEAL_VOLUME) * this.contract_size * 1000 + 0.1); // объём исполнения
      this.profit = ::HistoryDealGetDouble(Ticket, DEAL_PROFIT);                                             // финансовый результат
      this.commission = ::HistoryDealGetDouble(Ticket, DEAL_COMMISSION);                                     // коммиссия за выполнение
      this.reserve = 0;                                                                                      // резерв
      this.storage = ::HistoryDealGetDouble(Ticket, DEAL_SWAP);                                              // активы
      this.action = (ENUM_DEAL_TYPE)::HistoryDealGetInteger(Ticket, DEAL_TYPE);                              // идентификатор события
      this.entry = (ENUM_DEAL_ENTRY)::HistoryDealGetInteger(Ticket, DEAL_ENTRY);                             // вход в позицию или выход
      this.digits_currency = (UINT)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);                            // количество знаков у валюты группы
      this.position_id = ::HistoryDealGetInteger(Ticket, DEAL_POSITION_ID);
    }

    return(Res);
  }

  long GetProperty( const ENUM_DEAL_PROPERTY_INTEGER Property ) const
  {
    long Res = 0;

    switch (Property)
    {
      case DEAL_TICKET:
        Res = (long)this.deal;

        break;
      case DEAL_ORDER:
        Res = (long)this.order;

        break;
      case DEAL_TIME:
        Res = this.time_create;

        break;
      case DEAL_TIME_MSC:
        Res = (long)this.time_create * 1000;

        break;
      case DEAL_TYPE:
        Res = this.action;

        break;
      case DEAL_ENTRY:
        Res = this.entry;

        break;
      case DEAL_POSITION_ID:
        Res = (long)this.position_id;

        break;
    }

    return(Res);
  }

  double GetProperty( const ENUM_DEAL_PROPERTY_DOUBLE Property ) const
  {
    double Res = 0;

    switch (Property)
    {
      case DEAL_VOLUME:
        Res = (double)this.volume / (this.contract_size ? this.contract_size * 1000 : 1e8);

        break;
      case DEAL_PRICE:
        Res = this.price_open;

        break;
      case DEAL_COMMISSION:
        Res = this.commission;

        break;
      case DEAL_SWAP:
        Res = this.storage;

        break;
      case DEAL_PROFIT:
        Res = this.profit;

        break;
      case DEAL_SL:
        Res = this.sl;

        break;
      case DEAL_TP:
        Res = this.tp;

        break;
    }

    return(Res);
  }

  string GetProperty( const ENUM_DEAL_PROPERTY_STRING Property ) const
  {
    string Res = NULL;

    switch (Property)
    {
      case DEAL_SYMBOL:
        Res = this.symbol[];

        break;
      case DEAL_COMMENT:
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
           TOSTRING(deal) +                    // уникальный идентификатор записи
           TOSTRING(order) +                   // идентификатор ордера которому соответствует запись
           TOSTRING(time_create) +             // время создания записи
           TOSTRING3(symbol) +                 // символ по которому выставлен ордер
           TOSTRING(price_open) +              // цена открытия\исполнения
           TOSTRING(price_close) +             // цена закрытия
           TOSTRING(sl) +                      // стоп-лосс позиции
           TOSTRING(tp) +                      // тейк-профит позиции
           TOSTRING(volume) +                  // объём исполнения
           TOSTRING(profit) +                  // финансовый результат
           TOSTRING(commission) +              // коммиссия за выполнение
           TOSTRING(reserve) +                 // резерв
           TOSTRING(storage) +                 // активы
           TOSTRING3(comment) +                // комментарий к ордеру
           TOSTRING2(action) +                 // идентификатор события
           TOSTRING2(entry) +                  // вход в позицию или выход
           TOSTRING(digits) +                  // количество знаков у торгового символа
           TOSTRING(digits_currency) +         // количество знаков у валюты группы
           TOSTRING(contract_size) +           // размер контракта
           TOSTRING(position_id)
          );
  }

#undef TOSTRING3
#undef TOSTRING2
#undef TOSTRING
};

#undef UINT
#undef INT64
#undef UINT64