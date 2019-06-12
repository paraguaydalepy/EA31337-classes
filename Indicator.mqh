//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Ignore processing of this file if already included.
#ifndef INDICATOR_MQH
#define INDICATOR_MQH

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "Chart.mqh"

// Globals enums.
// Define type of indicators.
enum ENUM_INDICATOR_TYPE {
  INDI_AC         = 01, // Accelerator Oscillator
  INDI_AD         = 02, // Accumulation/Distribution
  INDI_ADX        = 03, // Average Directional Index
  INDI_ADXW       = 04, // ADX by Welles Wilder
  INDI_ALLIGATOR  = 05, // Alligator
  INDI_AMA        = 06, // Adaptive Moving Average
  INDI_AO         = 07, // Awesome Oscillator
  INDI_ATR        = 08, // Average True Range
  INDI_BANDS      = 09, // Bollinger Bands
  INDI_BEARS      = 10, // Bears Power
  INDI_BULLS      = 11, // Bulls Power
  INDI_BWMFI      = 12, // Market Facilitation Index
  INDI_CCI        = 13, // Commodity Channel Index
  INDI_CHAIKIN    = 14, // Chaikin Oscillator
  INDI_CUSTOM     = 15, // Custom indicator
  INDI_DEMA       = 16, // Double Exponential Moving Average
  INDI_DEMARKER   = 17, // DeMarker
  INDI_ENVELOPES  = 18, // Envelopes
  INDI_FORCE      = 19, // Force Index
  INDI_FRACTALS   = 20, // Fractals
  INDI_FRAMA      = 21, // Fractal Adaptive Moving Average
  INDI_GATOR      = 22, // Gator Oscillator
  INDI_ICHIMOKU   = 23, // Ichimoku Kinko Hyo
  INDI_MA         = 24, // Moving Average
  INDI_MACD       = 25, // MACD
  INDI_MFI        = 26, // Money Flow Index
  INDI_MOMENTUM   = 27, // Momentum
  INDI_OBV        = 28, // On Balance Volume
  INDI_OSMA       = 29, // OsMA
  INDI_RSI        = 30, // Relative Strength Index
  INDI_RVI        = 31, // Relative Vigor Index
  INDI_SAR        = 32, // Parabolic SAR
  INDI_STDDEV     = 33, // Standard Deviation
  INDI_STOCHASTIC = 34, // Stochastic Oscillator
  INDI_TEMA       = 35, // Triple Exponential Moving Average
  INDI_TRIX       = 36, // Triple Exponential Moving Averages Oscillator
  INDI_VIDYA      = 37, // Variable Index Dynamic Average
  INDI_VOLUMES    = 38, // Volumes
  INDI_WPR        = 39, // Williams' Percent Range
  INDI_ZIGZAG     = 40, // ZigZag
  INDI_NONE       = 41  // (None)
};

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size) \
  ArraySetAsSeries(_arr, true); \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { return false; } \
  ArraySetAsSeries(_arr, false);

/**
 * Class to deal with indicators.
 */
class Indicator : public Chart {

protected:

  // Enums.
  enum ENUM_DATA_TYPE { DT_BOOL = 0, DT_DBL = 1, DT_INT = 2 };

  // Structs.
  struct IndicatorParams {
    int max_buffers;          // Max buffers to store.
    int handle;               // Indicator handle.
    ENUM_INDICATOR_TYPE type; // Type of indicator.
    // MqlParam params[];     // Indicator parameters.
    IndicatorParams() : max_buffers(5) {}
    void SetSize(int _size) {max_buffers = _size;}
  };
  /*
  struct IndicatorValue {
    datetime dt;
    int key;
    MqlParam value; // Contains value based on the data type (real, integer or string type).
  };
  struct IndicatorData {
    datetime dt;
    uint interval;
    void *data[];
  };
  */

  // Struct variables.
  IndicatorParams iparams;  // Indicator parameters.
  // Basic variables.
  //int arr_keys[];          // Keys.
  //datetime _last_bar_time; // Last parsed bar time.

  // Variables.
  MqlParam data[][1];
  datetime dt[][1];
  int index, series, direction;

  //IndicatorData idata[];

  // Enum variables.
  //bool i_data_type[DT_INTEGERS + 1]; // Type of stored data.

  // Logging.
  // Log *logger;
  // Market *market;

public:

  /* Indicator enumerations */

  /*
   * Default enumerations:
   *
   * ENUM_MA_METHOD values:
   *   0: MODE_SMA (Simple averaging)
   *   1: MODE_EMA (Exponential averaging)
   *   2: MODE_SMMA (Smoothed averaging)
   *   3: MODE_LWMA (Linear-weighted averaging)
   *
   * ENUM_APPLIED_PRICE values:
   *   0: PRICE_CLOSE (Close price)
   *   1: PRICE_OPEN (Open price)
   *   2: PRICE_HIGH (The maximum price for the period)
   *   3: PRICE_LOW (The minimum price for the period)
   *   4: PRICE_MEDIAN (Median price) = (high + low)/2
   *   5: PRICE_TYPICAL (Typical price) = (high + low + close)/3
   *   6: PRICE_WEIGHTED (Average price) = (high + low + close + close)/4
   *
   */

  // Define indicator index.
  enum ENUM_INDICATOR_INDEX {
    CURR = 0,
    PREV = 1,
    FAR  = 2,
    FINAL_ENUM_INDICATOR_INDEX // Should be the last one. Used to calculate the number of enum items.
  };

  /* Common indicator line identifiers */

  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

  // Indicator line identifiers used in Envelopes and Fractals indicators.
  enum ENUM_LO_UP_LINE {
    LINE_UPPER  = #ifdef __MQL4__ MODE_UPPER #else UPPER_LINE #endif, // Upper line.
    LINE_LOWER  = #ifdef __MQL4__ MODE_LOWER #else LOWER_LINE #endif, // Bottom line.
    FINAL_LO_UP_LINE_ENTRY,
  };

  // Indicator line identifiers used in Gator and Alligator indicators.
  enum ENUM_GATOR_LINE {
    LINE_JAW   = #ifdef __MQL4__ MODE_GATORJAW   #else GATORJAW_LINE   #endif, // Jaw line.
    LINE_TEETH = #ifdef __MQL4__ MODE_GATORTEETH #else GATORTEETH_LINE #endif, // Teeth line.
    LINE_LIPS  = #ifdef __MQL4__ MODE_GATORLIPS  #else GATORLIPS_LINE  #endif, // Lips line.
    FINAL_GATOR_LINE_ENTRY,
  };

  // Indicator line identifiers used in MACD, RVI and Stochastic indicators.
  enum ENUM_SIGNAL_LINE {
    LINE_MAIN   = #ifdef __MQL4__ MODE_MAIN   #else MAIN_LINE   #endif, // Main line.
    LINE_SIGNAL = #ifdef __MQL4__ MODE_SIGNAL #else SIGNAL_LINE #endif, // Signal line.
    FINAL_SIGNAL_LINE_ENTRY,
  };

  #ifdef __MQL4__
  // The volume type is used in calculations.
  // For MT4, we define it for backward compability.
  // @docs: https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
  enum ENUM_APPLIED_VOLUME {
    VOLUME_TICK = 0,
    VOLUME_REAL = 1
  };
  #endif

  /**
   * Class constructor.
   */
  void Indicator(
    const IndicatorParams &_params,
    ENUM_TIMEFRAMES _tf = NULL,
    string _symbol = NULL
    ) :
      direction(1),
      index(-1),
      series(0),
      Chart(_tf, _symbol)
    {
    iparams = _params;
    iparams.max_buffers = fmin(iparams.max_buffers, 1);
    SetBufferSize(iparams.max_buffers);
    //params.logger = params.logger == NULL ? new Log(V_INFO) : params.logger;
  }
  void Indicator()
    :
    direction(1),
    index(-1),
    series(0)
  {
    iparams.max_buffers = 5;
    SetBufferSize(iparams.max_buffers);
  }

  /* Getters */

  /**
   * Get the recent value given based on the shift.
   */
  MqlParam GetValue(uint _shift = 0) {
    return data[this.GetIndex(_shift)][series];
  }

  /**
   * Get datetime of the last value.
   */
  datetime GetTime(uint _index = 0) {
    return dt[_index][series];
  }

  /**
   * Set size of the buffer.
   */
  uint GetBufferSize() {
    return iparams.max_buffers;
  }

  /* Setters */

  /**
   * Store a new indicator value.
   */
  void AddValue(MqlParam &_entry, datetime _dt = NULL) {
    SetIndex();
    //Print("DATA: Index: ", this.index, "; Series: ", this.series, "; Direction: ", this.direction);
    data[this.index][this.series] = _entry;
    dt[this.index][this.series] = _dt;
  }

  /**
   * Set index for the next value.
   */
  void SetIndex() {
    //Print("Set Index: ", this.index, "; Series: ", this.series, "; Direction: ", this.direction);
    this.index += 1 * this.direction;
    if (this.index < 0 || this.index > this.iparams.max_buffers - 1) {
      //Print("End of index: ", this.index, "; Index: ", this.index, "; Series: ", this.series, "; Direction: ", this.direction);
      //this.index = this.index == 0 ? this.iparams.max_buffers - 1: 0;
      this.direction = -this.direction;
      this.index += 1 * this.direction;
      //this.series = this.series == 0 ? 1 : 0;
    }
  }

  /**
   * Get index for the given shift.
   */
  uint GetIndex(int _shift = 0) {
    if (_shift >= this.iparams.max_buffers) {
      return 0;
    }
    return this.index - _shift * this.direction;
  }

  /**
   * Set size of the buffer.
   */
  void SetBufferSize(uint _size = 5) {
    ArrayResize(data, iparams.max_buffers);
    ArrayResize(dt,   iparams.max_buffers);
    ArraySetAsSeries(data, true);
    ArraySetAsSeries(dt, true);
  }

  /**
   * Replace the value given the key and index.
   */
  /*
  bool ReplaceValueByDatetime(double _val, datetime _dt, int _key = 0) {
    for (int i = 0; i < ArraySize(data); i++) {
      if (data[i].dt == _dt && data[i].key == _key) {
        data[i].value.double_value = _val;
        return true;
      }
    }
    return false;
  }
  */

  /**
   * Get data array index based on the key and index.
   */
  /*
  uint GetIndexByKey(int _key = 0, uint _shift = 0) {
    datetime _bar_time = GetBarTime(_shift);
    for (int i = 0; i < ArraySize(data); i++) {
      if (data[i].dt == _bar_time && data[i].key == _key) {
        return i;
      }
    }
    return -1;
  }
  */

  /**
   * Get name of the indicator.
   */
  string GetName() {
    return iparams.type != NULL ? EnumToString(iparams.type) : "Custom";
  }

  /**
   * Print stored data.
   */
  string ToString(uint _limit = 0) {
    string _out = "";
    /*
    for (uint i = 0; i < fmax(ArraySize(idata.data), _limit); i++) {
      // @todo
      // _out += StringFormat("%s:%s; ", GetKeyByIndex(i), GetValueByIndex(i));
    }
    */
    return _out;
  }

  /**
   * Print stored data.
   */
  void PrintData(uint _limit = 0) {
    Print(ToString(_limit));
  }

  /**
   * Update indicator.
   */
  bool Update() {
    // @todo
    return true;
  }

private:

  /**
   * Returns index for given key.
   *
   * If key does not exist, create one.
   */
  /*
  uint GetKeyIndex(int _key) {
    for (int i = 0; i < ArraySize(arr_keys); i++) {
      if (arr_keys[i] == _key) {
        return i;
      }
    }
    return AddKey(_key);
  }
  */

  /**
   * Add new data key and return its index.
   */
  /*
  uint AddKey(int _key) {
    uint _size = ArraySize(arr_keys);
    ArrayResize(arr_keys, _size + 1, 5);
    arr_keys[_size] = _key;
    return _size;
  }
  */

  /**
   * Checks whether given key exists.
   */
  /*
  bool KeyExists(int _key) {
    for (int i = 0; i < ArraySize(arr_keys); i++) {
      if (arr_keys[i] == _key) {
        return true;
      }
    }
    return false;
  }
  */

};
#endif
