//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Prevents processing this includes file for the second time.
#ifndef TICKER_MQH
#define TICKER_MQH

// Forward declaration.
class Chart;

// Includes.
#include "Chart.mqh"
#include "Log.mqh"
#include "SymbolInfo.mqh"
//#include "Market.mqh"

// Define an assert macros.
#define PROCESS_METHOD(method, no) ((method & (1<<no)) == 1<<no)

/**
 * Class to provide methods handling ticks.
 */
class Ticker {

  // Structs.
  struct TTick {
    datetime dt;
    double bid, ask;
    double vol;
  };

  protected:
    ulong total_added, total_ignored, total_processed, total_saved;
    // Struct variables.
    TTick data[];
    // Class variables.
    SymbolInfo *symbol;
    Log *logger;

  public:

    // Public variables.
    int index;

    /**
     * Class constructor.
     */
    void Ticker(SymbolInfo *_symbol, Log  *_logger = NULL, int size = 1000) :
      symbol(Object::IsValid(_symbol) ? _symbol : new SymbolInfo),
      logger(Object::IsValid(_logger) ? _logger : new Log),
      total_added(0),
      total_ignored(0),
      total_processed(0),
      total_saved(0) {
        index = 0;
        ArrayResize(data, size, size);
    }

    /**
     * Class deconstructor.
     */
    void ~Ticker() {
      Object::Delete(logger);
      Object::Delete(symbol);
    }

    /* Getters */

    /**
     * Get number of added ticks.
     */
    ulong GetTotalAdded() {
      return total_added;
    }

    /**
     * Get number of ignored ticks.
     */
    ulong GetTotalIgnored() {
      return total_ignored;
    }

    /**
     * Get number of parsed ticks.
     */
    ulong GetTotalProcessed() {
      return total_processed;
    }


    /**
     * Get number of saved ticks.
     */
    ulong GetTotalSaved() {
      return total_saved;
    }

    /* Other methods */

    /**
     * Processes tick.
     *
     * @param
     * _method Ignore method (0-15).
     * _tf Timeframe to use.
     * @return
     * Returns true when tick should be parsed, otherwise ignored.
     */
    bool Process(Chart *_chart, uint _method) {
      total_processed++;
      if (_method == 0 || total_processed == 1) {
        return true;
      }
      double _last_bid = symbol.GetLastBid();
      double _bid = symbol.GetBid();
      bool _res = _last_bid != _bid;
      if (PROCESS_METHOD(_method, 0)) _res &= (_chart.GetOpen() == _bid); // 1
      if (PROCESS_METHOD(_method, 1)) _res &= (_chart.iTime() == TimeCurrent()); // 2
      if (PROCESS_METHOD(_method, 2)) _res &= (_bid >= _chart.GetHigh()) || (_bid <= _chart.GetLow()); // 4
      if (!_res) {
        total_ignored++;
      }
      return _res;
    }

    /**
     * Append a new tick to an array.
     */
    bool Add() {
      if (index++ >= ArraySize(data) - 1) {
        if (ArrayResize(data, index + 100, 1000) < 0) {
          logger.Error(StringFormat("Cannot resize array (index: %d)!", index), __FUNCTION__);
          return false;
        }
      }
      data[index].dt        = TimeCurrent();
      data[index].bid       = symbol.GetBid();
      data[index].ask       = symbol.GetAsk();
      data[index].vol       = symbol.GetSessionVolume();
      total_added++;
      return true;
    }

    /**
     * Empties the tick array.
     */
    void Reset() {
      total_added = 0;
      index = 0;
    }

    /**
     * Save ticks into CSV file.
     */
    bool SaveToCSV(string filename = NULL, bool verbose = true) {
      ResetLastError();
      datetime _dt = index > 0 ? data[0].dt : TimeCurrent();
      filename = filename != NULL ? filename : StringFormat("ticks_%s.csv", DateTime::TimeToStr(_dt, TIME_DATE));
      int _handle = FileOpen(filename, FILE_WRITE|FILE_CSV, ",");
      if (_handle != INVALID_HANDLE) {
        total_saved = 0;
        FileWrite(_handle, "Datatime", "Bid", "Ask", "Volume");
        for (int i = 0; i < index; i++) {
          if (data[i].dt > 0) {
            FileWrite(_handle,
                DateTime::TimeToStr(data[i].dt, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                data[i].bid,
                data[i].ask,
                data[i].vol);
            total_saved++;
          }
        }
        FileClose(_handle);
        if (verbose) {
          logger.Info(StringFormat("%s: %d ticks written to '%s' file.", __FUNCTION__, total_saved, filename));
        }
        return true;
      }
      else {
        if (verbose) {
          logger.Error(StringFormat("%s: Cannot open file for writting, error: %s", __FUNCTION__, GetLastError()));
        }
        return false;
      }
    }

  /**
   * Returns textual representation of the Market class.
   */
  string ToString() {
    return StringFormat(
      "Processed: %d; Ignored: %d; Added: %d; Saved: %d;",
      GetTotalProcessed(),
      GetTotalIgnored(),
      GetTotalAdded(),
      GetTotalSaved()
    );
  }

};

#endif // TICKER_MQH