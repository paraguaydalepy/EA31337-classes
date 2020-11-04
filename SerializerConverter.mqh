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
#ifndef SERIALIZER_CONVERTER_MQH
#define SERIALIZER_CONVERTER_MQH

// Includes.
#include "SerializerNode.mqh"

class SerializerConverter {
 public:
  SerializerNode* root_node;

  SerializerConverter(SerializerNode* _root = NULL) : root_node(_root) {}

  SerializerConverter(SerializerConverter& right) { root_node = right.root_node; }

  template <typename X>
  static SerializerConverter FromObject(X& _value) {
    Serializer _serializer(NULL, Serialize);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassObject(_value, "", _value);
    SerializerConverter _converter(_serializer.GetRoot());
    return _converter;
  }

  template <typename X>
  static SerializerConverter FromStruct(X _value) {
    Serializer _serializer(NULL, Serialize);
    _serializer.FreeRootNodeOwnership();
    _serializer.PassStruct(_value, "", _value);
    SerializerConverter _converter(_serializer.GetRoot());
    return _converter;
  }

  template <typename C>
  static SerializerConverter FromString(string arg) {
    root = C::Parse(arg);
    return this;
  }

  template <typename R>
  string ToString() {
    return R::Stringify(root_node);
  }

  template <typename R, typename A1>
  string ToString(A1 arg1) {
    return R::Stringify(root_node, arg1);
  }

  template <typename R, typename A1, typename A2>
  string ToString(A1 arg1, A2 arg2) {
    return R::Stringify(root_node, arg1, arg2);
  }

  template <typename R, typename A1, typename A2, typename A3>
  string ToString(A1 arg1, A2 arg2, A3 arg3) {
    return R::Stringify(root_node, arg1, arg2, arg3);
  }
};

#endif
