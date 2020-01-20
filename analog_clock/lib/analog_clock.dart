// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '${widget.model.low} - ${widget.model.highString}';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color(0xFF008877),
            highlightColor: Color(0xFFA1A1A1),
            accentColor: Color(0xFF717777),
            indicatorColor: Color(0xFFEC4B26),
            dividerColor: Color(0xFFCCCCCC),
            accentTextTheme: TextTheme(
              title: TextStyle(fontSize: 48, color: Color(0xFF333333), fontWeight: FontWeight.bold,),
              headline: TextStyle(fontSize: 18, color: Color(0xFF333333), ),
              body1: TextStyle(fontSize: 16, color: Color(0xFF333333))
            ),
            backgroundColor: Color(0xFFF1F1F1),
          )
        : Theme.of(context).copyWith(
          primaryColor: Color(0xFF33EEFC7),
          highlightColor: Color(0xFFCCCCCC),
          accentColor: Color(0xFF677070),
          indicatorColor: Color(0xFFFF5100),
          dividerColor: Color(0xFF333336),
          accentTextTheme: TextTheme(
          title: TextStyle(fontSize: 48, color: Color(0xFFF9F9F9), fontWeight: FontWeight.bold,),
          headline: TextStyle(fontSize: 18, color: Color(0xFFEEEEEE), ),
          body1: TextStyle(fontSize: 16, color: Color(0xFFC7C7C7))
      ),
            backgroundColor: Color(0xFF111111),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_temperature,style: customTheme.accentTextTheme.title,),
          Text(_location, style: customTheme.accentTextTheme.body1,),
          Padding(padding: EdgeInsets.only(top: 6.0)),
          Text(_condition.toUpperCase(), style: customTheme.accentTextTheme.headline,),
          Text(_temperatureRange, style: customTheme.accentTextTheme.body1,),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Theme(
        data: customTheme,
        child: Container(
          color: customTheme.backgroundColor,
          child: Stack(
            children: [
              ...List.generate(60, (i) => SecIndex(i, _now)),
              ...List.generate(12, (i) => HouIndex(i, _now)),
              ...List.generate(12, (i) => HouIndexInner(i, _now)),
              DayBgline(),
              ...List.generate(30, (i) => DayIndex(i, _now)),
              ...List.generate(12, (i) => MonthIndex(i, _now)),
              CenterPoint(),

              Positioned(
                right: 0,
                bottom: 0,
                child: SizedBox(
                  width: 210.0,
                  height: 150.0,
                  child: Center(
                    child: weatherInfo,
                  ),
                ),
              ),
              Positioned(
                child: ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
