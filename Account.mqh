//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Prevents processing this includes file for the second time.
#ifndef ACCOUNT_MQH
#define ACCOUNT_MQH

// Forward class declaration.
class Account;

// Includes.
#include "Array.mqh"
#include "Chart.mqh"
#include "Convert.mqh"
#include "Orders.mqh"
#include "SymbolInfo.mqh"

// Enums.
enum ENUM_ACC_STAT_VALUE {
  ACC_BALANCE               = 0,
  ACC_CREDIT                = 1,
  ACC_EQUITY                = 2,
  ACC_PROFIT                = 3,
  ACC_MARGIN_USED           = 4,
  ACC_MARGIN_FREE           = 5,
  FINAL_ENUM_ACC_STAT_VALUE = 6
};

enum ENUM_ACC_STAT_PERIOD {
  ACC_DAILY                  = 0,
  ACC_WEEKLY                 = 1,
  ACC_MONTHLY                = 2,
  FINAL_ENUM_ACC_STAT_PERIOD = 3
};

enum ENUM_ACC_STAT_TYPE {
  ACC_VALUE_MIN            = 0,
  ACC_VALUE_MAX            = 1,
  ACC_VALUE_AVG            = 2,
  FINAL_ENUM_ACC_STAT_TYPE = 3
};

enum ENUM_ACC_STAT_INDEX {
  ACC_VALUE_CURR            = 0,
  ACC_VALUE_PREV            = 1,
  FINAL_ENUM_ACC_STAT_INDEX = 2
};

// Class structs.
// Struct for making a snapshot of user account values.
struct AccountSnapshot {
  datetime dtime;
  double balance;
  double credit;
  double equity;
  double profit;
  double margin_used;
  double margin_free;
  double margin_avail;
};

/**
 * Class to provide functions that return parameters of the current account.
 */
class Account {
 protected:
  // Struct variables.
  AccountSnapshot snapshots[];

  // Variables.
  double init_balance, start_balance, start_credit;
  // Store daily, weekly and monthly account statistics.
  double acc_stats[FINAL_ENUM_ACC_STAT_VALUE][FINAL_ENUM_ACC_STAT_PERIOD][FINAL_ENUM_ACC_STAT_TYPE][FINAL_ENUM_ACC_STAT_INDEX];

  // Class variables.
  Orders *trades;
  Orders *history;
  Orders *dummy;

  public:

  // Defines.
  #define ACC_OP_BALANCE 6 // Undocumented balance history statement entry.
  #define ACC_OP_CREDIT  7 // Undocumented credit history statement entry.

  /**
   * Class constructor.
   */
  Account() :
    init_balance(CalcInitDeposit()),
    start_balance(GetBalance()),
    start_credit(GetCredit()),
    trades(new Orders(ORDERS_POOL_TRADES)),
    history(new Orders(ORDERS_POOL_HISTORY)),
    dummy(new Orders(ORDERS_POOL_DUMMY))
  {}

  /**
   * Class deconstructor.
   */
  ~Account() {
    delete trades;
    delete history;
    delete dummy;
  }

  /* MT account methods */

  /**
   * Returns the current account name.
   */
  static string AccountName() {
    return AccountInfoString(ACCOUNT_NAME);
  }
  string GetAccountName() {
    return AccountName();
  }

  /**
   * Returns the connected server name.
   */
  static string AccountServer() {
    return AccountInfoString(ACCOUNT_SERVER);
  }
  static string GetServerName() {
    return AccountServer();
  }

  /**
   * Returns currency name of the current account.
   */
  static string AccountCurrency() {
    return AccountInfoString(ACCOUNT_CURRENCY);
  }
  string GetCurrency() {
    return AccountCurrency();
  }

  /**
   * Returns the brokerage company name where the current account was registered.
   */
  static string AccountCompany() {
    return AccountInfoString(ACCOUNT_COMPANY);
  }
  string GetCompanyName() {
    return AccountCompany();
  }

  /* Double getters */

  /**
   * Returns balance value of the current account.
   */
  static double AccountBalance() {
    return AccountInfoDouble(ACCOUNT_BALANCE);
  }
  double GetBalance() {
    return UpdateStats(ACC_BALANCE, AccountBalance());
  }

  /**
   * Returns credit value of the current account.
   */
  static double AccountCredit() {
    return AccountInfoDouble(ACCOUNT_CREDIT);
  }
  double GetCredit() {
    return UpdateStats(ACC_CREDIT, AccountCredit());
  }

  /**
   * Returns profit value of the current account.
   */
  static double AccountProfit() {
    return AccountInfoDouble(ACCOUNT_PROFIT);
  }
  double GetProfit() {
    return UpdateStats(ACC_PROFIT, AccountProfit());
  }

  /**
   * Returns equity value of the current account.
   */
  static double AccountEquity() {
    return AccountInfoDouble(ACCOUNT_EQUITY);
  }
  double GetEquity() {
    return UpdateStats(ACC_EQUITY, AccountEquity());
  }

  /**
   * Returns margin value of the current account.
   */
  static double AccountMargin() {
    return AccountInfoDouble(ACCOUNT_MARGIN);
  }
  double GetMarginUsed() {
    return UpdateStats(ACC_MARGIN_USED, AccountMargin());
  }

  /**
   * Returns free margin value of the current account.
   */
  static double AccountFreeMargin() {
    return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
  }
  double GetMarginFree() {
    return UpdateStats(ACC_MARGIN_FREE, AccountFreeMargin());
  }

  /**
   * Returns the current account number.
   */
  static long AccountNumber() {
    return AccountInfoInteger(ACCOUNT_LOGIN);
  }
  long GetLogin() {
    return AccountNumber();
  }

  /**
   * Returns leverage of the current account.
   */
  static long AccountLeverage() {
    return AccountInfoInteger(ACCOUNT_LEVERAGE);
  }
  long GetLeverage() {
    return AccountLeverage();
  }

  /**
   * Returns the calculation mode for the Stop Out level.
   */
  static int AccountStopoutMode() {
    return (int) AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
  }
  int GetStopoutMode() {
    return AccountStopoutMode();
  }

  /**
   * Returns the value of the Stop Out level.
   *
   * Depending on the set ACCOUNT_MARGIN_SO_MODE,
   * is expressed in percents or in the deposit currency.
   */
  static double AccountStopoutLevel() {
    return AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
  }
  double GetStopoutLevel() {
    return AccountStopoutLevel();
  }

  /**
   * Get a maximum allowed number of active pending orders set by broker.
   *
   * @return
   *   Returns the limit orders (0 for unlimited).
   */
  static long AccountLimitOrders() {
    return AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
  }
  long GetLimitOrders(uint _max = 999) {
    long _limit = AccountLimitOrders();
    return _limit > 0 ? _limit : _max;
  }

  /* Other account methods */

  /**
   * Get account total balance (including credit).
   */
  static double AccountTotalBalance() {
    return AccountBalance() + AccountCredit();
  }
  double GetTotalBalance() {
    return GetBalance() + GetCredit();
  }

  /**
   * Get account available margin.
   */
  static double AccountAvailMargin() {
    return fmin(AccountFreeMargin(), AccountTotalBalance());
  }
  double GetMarginAvail() {
    return AccountAvailMargin();
  }

  /**
   * Returns the calculation mode of free margin allowed to open orders on the current account.
   */
  static double AccountFreeMarginMode() {
    #ifdef __MQL4__
    /*
     *  The calculation mode can take the following values:
     *  0 - floating profit/loss is not used for calculation;
     *  1 - both floating profit and loss on opened orders on the current account are used for free margin calculation;
     *  2 - only profit value is used for calculation, the current loss on opened orders is not considered;
     *  3 - only loss value is used for calculation, the current loss on opened orders is not considered.
     */
    return ::AccountFreeMarginMode();
    #else
    // @todo: Not implemented yet.
    return NULL;
    #endif
  }
  static double GetAccountFreeMarginMode() {
    return Account::AccountFreeMarginMode();
  }

  /* State checkers */

  /**
   * Indicates if an Expert Advisor is allowed to trade on the account.
   */
  static bool IsExpertEnabled() {
    return (bool) AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  }

  /**
   * Check the permission to trade for the current account.
   */
  static bool IsTradeAllowed() {
    return (bool) AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  }

  /**
   * Check if the Expert Advisor runs on a demo account.
   */
  static bool IsDemo() {
    #ifdef __MQL4__
    return ::IsDemo();
    #else // __MQL5__
    return AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
    #endif
  }

  /**
   * Returns type of account (Demo or Live).
   */
  static string GetType() {
    return Account::GetServerName() != "" ? (IsDemo() ? "Demo" : "Live") : "Off-line";
  }

  /* Setters */

  double UpdateStats(ENUM_ACC_STAT_VALUE _type, double _value) {
    static datetime _last_check = TimeCurrent();
    bool _stats_rotate = false;
    for (uint _pindex = 0; _pindex < FINAL_ENUM_ACC_STAT_PERIOD; _pindex++) {
      acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR] = fmin(acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR], _value);
      acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR] = fmin(acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR], _value);
      acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] = (acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] + _value) / 2;
      switch (_pindex) {
        case ACC_DAILY:   _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_D1); break;
        case ACC_WEEKLY:  _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_W1); break;
        case ACC_MONTHLY: _stats_rotate = _last_check < Chart::iTime(_Symbol, PERIOD_MN1); break;
      }
      if (_stats_rotate) {
        acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_PREV] = acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR];
        acc_stats[_type][_pindex][ACC_VALUE_MIN][ACC_VALUE_CURR] = _value;
        acc_stats[_type][_pindex][ACC_VALUE_MAX][ACC_VALUE_CURR] = _value;
        acc_stats[_type][_pindex][ACC_VALUE_AVG][ACC_VALUE_CURR] = _value;
        _last_check = TimeCurrent();
      }
    }
    return _value;
  }

  /* Class getters */

  /**
   * Get account init balance.
   */
  double GetInitBalance() {
    return init_balance;
  }

  /**
   * Get account start balance.
   */
  double GetStartBalance() {
    return start_balance;
  }

  /**
   * Get account init credit.
   */
  double GetStartCredit() {
    return start_credit;
  }

  /* Calculation methods */

  /**
   * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
   *
   * Note:
   *  - if(AccountEquity()/AccountMargin()*100 < AccountStopoutLevel()) { BrokerClosesOrders(); }
   */
  static double GetAccountStopoutLevel() {
    int mode = AccountStopoutMode();
    double level = AccountStopoutLevel();
    if (mode == 0 && level > 0) {
       // Calculation of percentage ratio between margin and equity.
       return (double) level / 100;
    } else if (mode == 1) {
      // Comparison of the free margin level to the absolute value.
      return 1.0;
    } else {
      // @todo: Add logging.
      //if (verbose) PrintFormat("%s(): Not supported mode (%d).", __FUNCTION__, mode);
    }
    return 1.0;
  }

  /**
   * Returns free margin that remains after the specified order has been opened at the current price on the current account.
   *
   * @return
   * Free margin that remains after the specified order has been opened at the current price on the current account.
   * If the free margin is insufficient, an error 134 (ERR_NOT_ENOUGH_MONEY) will be generated.
   */
  static double AccountFreeMarginCheck(string _symbol, ENUM_ORDER_TYPE _cmd, double _volume) {
    // Notes:
    // AccountFreeMarginCheck =  FreeMargin - Margin1Lot * Lot;
    // FreeMargin = Equity - Margin;
    // Equity = Balance + Profit;
    // FreeMargin =  Balance + Profit - Margin;
    // AccountFreeMarginCheck = Balance + Profit - Margin - Margin1Lot * Lot;
    #ifdef __MQL4__
    return ::AccountFreeMarginCheck(_symbol, _cmd, _volume);
    #else
    // @see: CAccountInfo::FreeMarginCheck
    double _margin;
    return (::OrderCalcMargin(_cmd, _symbol, _volume,
      SymbolInfo::SymbolInfoDouble(_symbol, (_cmd == ORDER_TYPE_BUY) ? SYMBOL_ASK : SYMBOL_BID), _margin) ?
      AccountInfoDouble(ACCOUNT_MARGIN_FREE) - _margin : -1);
    #endif
  }
  double GetAccountFreeMarginCheck(ENUM_ORDER_TYPE _cmd, double _volume) {
    return AccountFreeMarginCheck(_Symbol, _cmd, _volume);
  }

  /**
   * Get current account drawdown in percent.
   */
  static double GetDrawdownInPct() {
    return (100 / AccountTotalBalance()) * (AccountTotalBalance() - AccountEquity());
  }

  /**
   * Get current account risk margin level.
   *
   * The risk is calculated based on the stop loss sum of opened orders.
   *
   * @return
   *   Returns value from 0.0 (no risk) and 1.0 (100% risk).
   *   The risk higher than 1.0 means that the risk is extremely high.
   */
  double GetRiskMarginLevel(ENUM_ORDER_TYPE _cmd = NULL) {
    double _avail_margin = AccountAvailMargin() * Convert::ValueToMoney(trades.TotalSL(_cmd));
    return _avail_margin > 0 ? 1 / _avail_margin : 0;
  }

  /**
   * Calculates initial deposit based on the current balance and previous orders.
   */
  static double CalcInitDeposit() {
    double deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    for (int i = Account::OrdersHistoryTotal() - 1; i >= 0; i--) {
      if (!Order::TryOrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      int type = Order::OrderType();
      // Initial balance not considered.
      if (i == 0 && type == ACC_OP_BALANCE) break;
      if (type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL) {
        // Calculate profit.
        double profit = Order::OrderProfit() + Order::OrderCommission() + Order::OrderSwap();
        // Calculate decrease balance.
        deposit -= profit;
      }
      if (type == ACC_OP_BALANCE || type == ACC_OP_CREDIT) {
        deposit -= Order::OrderProfit();
      }
    }
    return deposit;
  }

  /**
   * Returns the number of closed orders in the account history loaded into the terminal.
   */
  static int OrdersHistoryTotal() {
    #ifdef __MQL4__
      return ::OrdersHistoryTotal();
    #else
       ::HistorySelect(0, TimeCurrent());
       return ::HistoryOrdersTotal();
    #endif
  }

  /**
   * Calculate total profit.
   */
  double GetTotalProfit() {
  /* @todo
    double total_profit = 0;
    for (int id = 0; id < ArrayRange(stats, 0); id++) {
      total_profit += stats[id][TOTAL_NET_PROFIT];
    }
    return total_profit;
  */
    return 0;
  }

  /**
   * Returns min/max/avg daily/weekly/monthly account balance/equity/margin.
   */
  double GetStatValue(ENUM_ACC_STAT_VALUE _value_type, ENUM_ACC_STAT_PERIOD _period, ENUM_ACC_STAT_TYPE _stat_type, ENUM_ACC_STAT_INDEX _shift = ACC_VALUE_CURR) {
    // @fixme
    return acc_stats[_value_type][_period][_stat_type][_shift];
  }

  /* State checkers */

  /**
   * Check account free margin.
   *
   * @return
   *   Returns true, when free margin is sufficient, false when insufficient or on error.
   */
  bool IsFreeMargin(ENUM_ORDER_TYPE _cmd, double size_of_lot, string _symbol = NULL) {
    bool _res = true;
    double margin = AccountFreeMarginCheck(_symbol, _cmd, size_of_lot);
    if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) _res = false;
    return (_res);
  }

  /* Conditions */

  /**
   * Checks for account condition.
   *
   * @param ENUM_ACCOUNT_CONDITION _cond
   *   Account condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_ACCOUNT_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      /* @todo
      case ACCOUNT_COND_BALM_GT_YEARLY:
        // @todo
        return false;
      case ACCOUNT_COND_BALM_LT_YEARLY:
        // @todo
        return false;
      case ACCOUNT_COND_BALT_GT_WEEKLY:
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_DAILY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) >
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case ACCOUNT_COND_BALT_IN_LOSS:
        // @todo
        return false;
      case ACCOUNT_COND_BALT_IN_PROFIT:
        // @todo
        return false;
      case ACCOUNT_COND_BALT_LT_WEEKLY:
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_DAILY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) <
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case ACCOUNT_COND_BALW_GT_MONTHLY:
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) >
          trade.Account().GetStatValue(ACC_BALANCE, ACC_MONTHLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case ACCOUNT_COND_BALW_LT_MONTHLY:
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) <
          trade.Account().GetStatValue(ACC_BALANCE, ACC_MONTHLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, 1))));
      case ACCOUNT_COND_BALY_IN_LOSS:
        return trade.Account().GetProfit() < trade.Account().GetProfit() / 100 * (100 - GetArg(_index, 0, 10));
      case ACCOUNT_COND_BALY_IN_PROFIT:
        return trade.Account().GetProfit() > trade.Account().GetProfit() / 100 * (100 + GetArg(_index, 0, 10));
      */
      case ACCOUNT_COND_BAL_IN_LOSS:
        return GetBalance() < start_balance;
      case ACCOUNT_COND_BAL_IN_PROFIT:
        return GetBalance() > start_balance;
      case ACCOUNT_COND_EQUITY_01PC_HIGH:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 101;
      case ACCOUNT_COND_EQUITY_01PC_LOW:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 99;
      case ACCOUNT_COND_EQUITY_05PC_HIGH:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 105;
      case ACCOUNT_COND_EQUITY_05PC_LOW:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 95;
      case ACCOUNT_COND_EQUITY_10PC_HIGH:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 110;
      case ACCOUNT_COND_EQUITY_10PC_LOW:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 90;
      case ACCOUNT_COND_EQUITY_20PC_HIGH:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 120;
      case ACCOUNT_COND_EQUITY_20PC_LOW:
        return AccountEquity() > (AccountBalance() + AccountCredit()) / 100 * 80;
      case ACCOUNT_COND_EQUITY_IN_LOSS:
        return GetEquity() < GetTotalBalance();
      case ACCOUNT_COND_EQUITY_IN_PROFIT:
        return GetEquity() > GetTotalBalance();
      /*
      case ACCOUNT_COND_MARGIN_CALL_10PC:
        // @todo
        return false;
      case ACCOUNT_COND_MARGIN_CALL_20PC:
        // @todo
        return false;
      */
      case ACCOUNT_COND_MARGIN_USED_10PC:
        return AccountMargin() >= AccountEquity() / 100 * 10;
      case ACCOUNT_COND_MARGIN_USED_20PC:
        return AccountMargin() >= AccountEquity() / 100 * 20;
      case ACCOUNT_COND_MARGIN_USED_50PC:
        return AccountMargin() >= AccountEquity() / 100 * 50;
      case ACCOUNT_COND_MARGIN_USED_80PC:
        return AccountMargin() >= AccountEquity() / 100 * 80;
      case ACCOUNT_COND_MARGIN_USED_99PC:
        return AccountMargin() >= AccountEquity() / 100 * 99;
      default:
        //logger.Error(StringFormat("Invalid account condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
#ifdef __debug__
        Print(StringFormat("%s: Error: Invalid account condition: %d!", __FUNCTION__, _cond));
#endif
        return false;
    }
  }
  bool CheckCondition(ENUM_ACCOUNT_CONDITION _cond) {
    MqlParam _args[] = {};
    return Account::CheckCondition(_cond, _args);
  }

  /* Printers */

  /**
   * Returns text info about the account.
   */
  string ToString() {
    return StringFormat(
      "Type: %s, Server/Company/Name: %s/%s/%s, Currency: %s, Balance: %g, Credit: %g, Equity: %g, Profit: %g, Margin Used/Free/Avail: %g/%g/%g, Orders limit: %g: Leverage: 1:%d, StopOut Level: %d (Mode: %d)",
      GetType(), GetServerName(),GetCompanyName(), GetAccountName(),  GetCurrency(), GetBalance(), GetCredit(), GetEquity(),
      GetProfit(), GetMarginUsed(), GetMarginFree(), GetMarginAvail(), GetLimitOrders(), GetLeverage(), GetStopoutLevel(), GetStopoutMode()
      );
  }

  /**
   * Returns info about the account in CSV format.
   */
  string ToCSV() {
    return StringFormat(
      "%g,%g,%g,%g,%g,%g",
      GetTotalBalance(), GetEquity(), GetProfit(), GetMarginUsed(), GetMarginFree(), GetMarginAvail()
      );
  }

  /* Snapshots */

  /**
   * Create a market snapshot.
   */
  bool MakeSnapshot() {
    uint _size = Array::ArraySize(snapshots);
    if (ArrayResize(snapshots, _size + 1, 100)) {
      snapshots[_size].dtime = TimeCurrent();
      snapshots[_size].balance = GetBalance();
      snapshots[_size].credit = GetCredit();
      snapshots[_size].equity = GetEquity();
      snapshots[_size].profit = GetProfit();
      snapshots[_size].margin_used = GetMarginUsed();
      snapshots[_size].margin_free = GetMarginFree();
      snapshots[_size].margin_avail = GetMarginAvail();
      return true;
    } else {
      return false;
    }
  }

  /* Class access methods */

  /**
   * Returns Orders class to access the current trades.
   */
  Orders *Trades() {
    return trades;
  }
  Orders *History() {
    return history;
  }
  Orders *Dummy() {
    return dummy;
  }

};
#endif // ACCOUNT_MQH
