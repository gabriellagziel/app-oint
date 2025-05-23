// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

/// Debug helper that tracks updates to a property.
///
/// Use this in debugging to record stack traces for when a property is updated.
/// For instance to track the field `bar` change
///
///     class Foo {
///       Bar bar;
///       Foo(this.bar);
///     }
///
/// to
///
///     class Foo {
///       StackTraceValue<Bar> _bar;
///       Foo(Bar bar) : _bar = StackTraceValue(bar);
///       Bar get bar => _bar.value;
///       void set bar(Bar value) {
///         _bar.value = value;
///       }
///     }
///
class StackTraceValue<T> {
  T _value;
  List<(T, StackTrace)> _stackTraces = [];

  StackTraceValue(this._value) {
    _stackTraces.add((_value, StackTrace.current));
  }

  T get value => _value;

  void set value(T v) {
    _stackTraces.add((v, StackTrace.current));
    _value = v;
  }
}

/// Debug helper that tracks updates to a list.
///
/// Use this in debugging to record stack traces for when a list is updated.
/// For instance to track the list `bars` change
///
///     class Foo {
///       List<Bar> bars;
///       Foo(this.bars);
///     }
///
/// to
///
///     class Foo {
///       StackTraceList<Bar> _bars;
///       Foo(List<Bar> bars) : _bars = StackTraceList(bars);
///       List<Bar> get bars => _bars;
///       void set bars(List<Bar> value) {
///         _bars.value = value;
///       }
///     }
///
class StackTraceList<T> with ListMixin<T> implements List<T> {
  List<T> _list;
  List<(String, Object?, StackTrace)> _stackTraces = [];

  StackTraceList(this._list) {
    _stackTraces.add(('init', _list, StackTrace.current));
  }

  List<T> get value => _list;

  void set value(List<T> v) {
    _stackTraces.add(('value', v, StackTrace.current));
    _list = v;
  }

  @override
  void add(T element) {
    _stackTraces.add(('add', element, StackTrace.current));
    _list.add(element);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _stackTraces.add(('addAll', iterable.toList(), StackTrace.current));
    _list.addAll(iterable);
  }

  @override
  void clear() {
    _stackTraces.add(('clear', null, StackTrace.current));
    _list.clear();
  }

  @override
  int get length => _list.length;

  @override
  void set length(int newLength) {
    _stackTraces.add(('length=', newLength, StackTrace.current));
    _list.length = newLength;
  }

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    _stackTraces.add(('[$index]=', value, StackTrace.current));
    _list[index] = value;
  }

  @override
  bool remove(Object? element) {
    _stackTraces.add(('remove', element, StackTrace.current));
    return _list.remove(element);
  }
}
