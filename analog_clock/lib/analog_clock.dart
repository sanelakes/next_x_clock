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
            cardColor: Color(0xBC555555),
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
          cardColor: Color(0xBACCCCCC),
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
              Positioned(
                right: 0.0,
                top: 0.0,
                width: 210.0,
                height: 300.0,
                child: Container(
                  child: Weather(condition: _condition, time: _now, customTheme: customTheme,),
                ),
              ),

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
                width: 210.0,
                height: 150.0,
                child: Center(
                  child: weatherInfo,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class Weather extends StatelessWidget {
  const Weather({
    this.condition,
    this.time,
    this.customTheme,
  });
  final String condition;
  final DateTime time;
  final ThemeData customTheme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(210.0, 300.0),
      painter: _WeatherPainter(condition: condition, time: time, customTheme: customTheme),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  _WeatherPainter({
    this.condition,
    this.time,
    this.customTheme,
  });
  final String condition;
  final DateTime time;
  final ThemeData customTheme;


  @override
  void paint(Canvas canvas, Size size) {

    if (condition == 'sunny' || condition == 'cloudy') {
      if ( (time.hour >= 6 && time.hour < 18)) {
        var gradient = RadialGradient(
          center: Alignment.center,
          radius: 0.3,
          colors: [
            Color(0xFFD9D78C),
            Color(0xFFF1B926),
          ],
          stops: [0.1, 1.0,],
        );
        Path path = Path()
          ..addOval(Rect.fromCircle(center: Offset(100.0, 72.0), radius: 36.0));
        canvas.drawShadow(path, Color(0x80FFFF66), 10.0, true);

        Paint paint = Paint()
          ..shader = gradient.createShader(Rect.fromCircle(center: Offset(102.0, 72.0), radius: 30.0));
        canvas.drawCircle(Offset(105.0, 80.0), 30.0, paint);
      } else {
        var gradient = RadialGradient(
          center: Alignment.center,
          radius: 0.3,
          colors: [
            Color(0xFFD9D78C),
            Color(0xFFF1B926),
          ],
          stops: [0.1, 1.0,],
        );
        Path path = Path();
        makePath(path, 'M121.234855,35.8598663 C132.961215,41.7948775 141,53.9586593 141,68 C141,87.882251 124.882251,104 105,104 C85.117749,104 69,87.882251 69,68 C69,65.8591576 69.1868713,63.7619614 69.5451921,61.7238332 C72.2177244,75.5549684 84.3890783,86 99,86 C115.568542,86 129,72.5685425 129,56 C129,48.3784705 126.157904,41.4207481 121.475724,36.128846 L121.234855,35.8598663 Z');
        canvas.drawShadow(path, Color(0x88FFEE00), 12.0, true);

        Paint paint = Paint()
          ..shader = gradient.createShader(Rect.fromCircle(center: Offset(96.0, 90.0), radius: 30.0));
        canvas.drawPath(path, paint);
      }
    }
    if (condition == 'cloudy') {
      Path path = Path()
        ..moveTo(82,74,)
        ..cubicTo(89.7756931,74,96.5149867,78.4373533,99.8237561,84.9179349,)
        ..cubicTo(101.436616,84.323967,103.180475,84,105,84,)
        ..cubicTo(113.284271,84,120,90.7157288,120,99,)
        ..cubicTo(120,107.284271,113.284271,114,105,114,)
        ..lineTo(82,114,)
        ..cubicTo(70.954305,114,62,105.045695,62,94,)
        ..cubicTo(62,82.954305,70.954305,74,82,74,)
        ..close()
        ..moveTo(127.068966,62,)
        ..cubicTo(131.761194,62,135.828009,64.662412,137.82468,68.550761,)
        ..cubicTo(138.797958,68.1943802,139.850286,68,140.948276,68,)
        ..cubicTo(145.947405,68,150,72.0294373,150,77,)
        ..cubicTo(150,81.9705627,145.947405,86,140.948276,86,)
        ..lineTo(127.068966,86,)
        ..cubicTo(120.40346,86,115,80.627417,115,74,)
        ..cubicTo(115,67.372583,120.40346,62,127.068966,62,)
        ..close();
      canvas.drawShadow(path, Color(0x80808080), 4.0, true);
      Paint paint = Paint()
        ..color = Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
    if (condition == 'rainy' || condition == 'thunderstorm' || condition == 'snowy') {
      Path path = Path()
        ..moveTo(91,57,)..cubicTo(98.7756931,57,105.514987,61.4373533,108.823756,67.9179349,)..cubicTo(110.436616,67.323967,112.180475,67,114,67,)..cubicTo(122.284271,67,129,73.7157288,129,82,)..cubicTo(129,90.2842712,122.284271,97,114,97,)..lineTo(91,97,)..cubicTo(79.954305,97,71,88.045695,71,77,)..cubicTo(71,65.954305,79.954305,57,91,57,)..close();
      Paint paint = Paint()
        ..color = customTheme.highlightColor
        ..style = PaintingStyle.fill;
      canvas.drawShadow(path, Color(0x80888888), 4.0, true);
      canvas.drawPath(path, paint);
      path = Path()
        ..moveTo(130.068966,65,)..cubicTo(134.761194,65,138.828009,67.662412,140.82468,71.550761,)..cubicTo(141.797958,71.1943802,142.850286,71,143.948276,71,)..cubicTo(148.947405,71,153,75.0294373,153,80,)..cubicTo(153,84.9705627,148.947405,89,143.948276,89,)..lineTo(130.068966,89,)..cubicTo(123.40346,89,118,83.627417,118,77,)..cubicTo(118,70.372583,123.40346,65,130.068966,65,)..close();
      canvas.drawShadow(path, Color(0x80888888), 4.0, true);
      canvas.drawPath(path, paint);
      path = Path()
        ..moveTo(75.0689655,76,)..cubicTo(79.7611941,76,83.8280092,78.662412,85.8246804,82.550761,)..cubicTo(86.7979579,82.1943802,87.8502865,82,88.9482759,82,)..cubicTo(93.9474051,82,98,86.0294373,98,91,)..cubicTo(98,95.9705627,93.9474051,100,88.9482759,100,)..lineTo(75.0689655,100,)..cubicTo(68.4034599,100,63,94.627417,63,88,)..cubicTo(63,81.372583,68.4034599,76,75.0689655,76,)..close();
      paint
        ..color = customTheme.cardColor;
      canvas.drawShadow(path, Color(0x80888888), 4.0, true);
      canvas.drawPath(path, paint);
      path = Path()
        ..moveTo(105,62,)..cubicTo(112.775693,62,119.514987,66.4373533,122.823756,72.9179349,)..cubicTo(124.436616,72.323967,126.180475,72,128,72,)..cubicTo(136.284271,72,143,78.7157288,143,87,)..cubicTo(143,95.2842712,136.284271,102,128,102,)..lineTo(105,102,)..cubicTo(93.954305,102,85,93.045695,85,82,)..cubicTo(85,70.954305,93.954305,62,105,62,)..close();
      canvas.drawShadow(path, Color(0x80888888), 4.0, true);
      canvas.drawPath(path, paint);
      path = Path()
        ..moveTo(118.706759,157.027975,)..lineTo(119.563926,157.543013,)..lineTo(110.293241,172.972025,)..lineTo(109.436074,172.456987,)..lineTo(118.706759,157.027975,)..close()..moveTo(87.706759,152.027975,)..lineTo(88.5639263,152.543013,)..lineTo(79.293241,167.972025,)..lineTo(78.4360737,167.456987,)..lineTo(87.706759,152.027975,)..close()..moveTo(75.3646298,148.65577,)..lineTo(77.9361317,150.200884,)..lineTo(67.6353702,167.34423,)..lineTo(65.0638683,165.799116,)..lineTo(75.3646298,148.65577,)..close()..moveTo(105.36463,123.65577,)..lineTo(107.936132,125.200884,)..lineTo(97.6353702,142.34423,)..lineTo(95.0638683,140.799116,)..lineTo(105.36463,123.65577,)..close()..moveTo(128.36463,117.65577,)..lineTo(130.936132,119.200884,)..lineTo(120.63537,136.34423,)..lineTo(118.063868,134.799116,)..lineTo(128.36463,117.65577,)..close()..moveTo(145.706759,115.027975,)..lineTo(146.563926,115.543013,)..lineTo(137.293241,130.972025,)..lineTo(136.436074,130.456987,)..lineTo(145.706759,115.027975,)..close()
        ..moveTo(73.3646298,107.65577,)..lineTo(75.9361317,109.200884,)..lineTo(65.6353702,126.34423,)..lineTo(63.0638683,124.799116,)..lineTo(73.3646298,107.65577,)..close()..moveTo(91.706759,108.027975,)..lineTo(92.5639263,108.543013,)..lineTo(83.293241,123.972025,)..lineTo(82.4360737,123.456987,)..lineTo(91.706759,108.027975,)..close()..moveTo(100.36463,102.65577,)..lineTo(102.936132,104.200884,)..lineTo(92.6353702,121.34423,)..lineTo(90.0638683,119.799116,)..lineTo(100.36463,102.65577,)..close()..moveTo(122.706759,99.0279753,)..lineTo(123.563926,99.5430133,)..lineTo(114.293241,114.972025,)..lineTo(113.436074,114.456987,)..lineTo(122.706759,99.0279753,)..close();
      paint
        ..color = Color(0xC09F9FAF);
      canvas.drawPath(path, paint);
      if (condition == 'thunderstorm') {
        path = Path()
          ..moveTo(114.439453,102.912109,)..lineTo(125.98877,103.028809,)..lineTo(98.4526367,126.831055,)..lineTo(114.330078,168.375,)..lineTo(76.7933605,184.092773,)..lineTo(87.6656239,225.073242,)..lineTo(71.1757813,181.97168,)..lineTo(107.464844,164.507812,)..lineTo(90.1655659,128.819681,)..lineTo(114.439453,102.912109,)..close()
          ..moveTo(114.265137,115.642578,)..lineTo(154.175781,135.932962,)..lineTo(147.739708,159.291016,)..lineTo(184.445313,177.932962,)..lineTo(144.175781,164.960937,)..lineTo(144.175781,137.960937,)..lineTo(106.175781,122.616707,)..lineTo(114.265137,115.642578,)..close()
          ..moveTo(71.7460938,101.072266,)..lineTo(95.9052734,107.339844,)..lineTo(98.71875,103.180664,)..lineTo(111.643555,103.018555,)..lineTo(99.4345703,114.974609,)..lineTo(77.6796875,107.962891,)..lineTo(76.4375,135.646484,)..lineTo(52.2773438,130.507813,)..lineTo(43,159.279297,)..lineTo(50.359375,122.992188,)..lineTo(57.0207269,124.217395,)..lineTo(71.6933594,126.476563,)..lineTo(71.9433394,106.401452,)..lineTo(71.7460938,101.072266,)..close();
        paint
          ..color = customTheme.cardColor;
        canvas.drawShadow(path, Color(0x80808080), 3.0, true);
        canvas.drawPath(path, paint);
      }
      if (condition == 'snowy') {
        path = Path();
        final points = [105,90,107.078461,92.25,106.558846,95.25,105.519615,95.5,106.03923,97.5,105.795007,98.67475,106.730275,97.8840356,108.790192,97.3169873,108.495577,96.3259619,110.93577,94.3929492,114,95,113.01423,97.8570508,110.054423,98.9240381,109.309808,98.1830127,107.769615,99.6160254,106.590278,100,107.769505,100.383914,109.309808,101.816987,110.054423,101.075962,113.01423,102.142949,114,105,110.93577,105.607051,108.495577,103.674038,108.790192,102.683013,106.730385,102.116025,105.795007,101.325,106.03923,102.499878,105.519615,104.5,106.558846,104.75,107.078461,107.75,105,110,102.921539,107.75,103.441154,104.75,104.480385,104.5,103.96077,102.5,104.204984,101.325,103.269725,102.115964,101.209808,102.683013,101.504423,103.674038,99.0642305,105.607051,96,105,96.9857695,102.142949,99.9455771,101.075962,100.690192,101.816987,102.230385,100.383975,103.409713,100,102.230495,99.6160864,100.690192,98.1830127,99.9455771,98.9240381,96.9857695,97.8570508,96,95,99.0642305,94.3929492,101.504423,96.3259619,101.209808,97.3169873,103.269615,97.8839746,104.204984,98.67475,103.96077,97.5001221,104.480385,95.5,103.441154,95.25,102.921539,92.25];
        for (var i = 0; i < points.length; i ++ ) {
          if (i.isOdd)
            continue;
          if (i == 0)
            path.moveTo(points[i].toDouble(), points[i + 1].toDouble());
          if (i == points.length - 1)
            path.close();
          else
            path.lineTo(points[i].toDouble(), points[i + 1].toDouble());
        }
        final Color shadowC = Color(0xA7111111);
        canvas.save();
        canvas.translate(-15.0, 8.0);
        paint
          ..color = customTheme.highlightColor
          ..style = PaintingStyle.fill;
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(72.0, 50.0);
        canvas.rotate(0.15);
        canvas.scale(0.55);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(50.0, 66.0);
        canvas.rotate(0.25);
        canvas.scale(0.75);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(20.0, 46.0);
        canvas.scale(0.60);
        canvas.rotate(0.24);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(40.0, 16.0);
        canvas.rotate(0.14);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(15.0, 14.0);
        canvas.rotate(0.16);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
        canvas.save();
        canvas.translate(-14.0, 36.0);
        canvas.rotate(0.1);
        canvas.drawShadow(path, shadowC, 2.0, true);
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
    if (condition == 'foggy') {
      Path path = Path()
        ..addOval(Rect.fromCircle(center: Offset(102, 69),radius: 30))
        ..addOval(Rect.fromCircle(center: Offset(83.5, 91.5),radius: 37.5))
        ..addOval(Rect.fromCircle(center: Offset(114.5, 103.5),radius: 37.5))
        ..addOval(Rect.fromCircle(center: Offset(137, 82),radius: 25));
      canvas.drawShadow(path, Color(0x80707070), 8.0, true);
      Paint paint = Paint()
        ..color = Color(0x60808080)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      paint
        ..color = Color(0xC7C7C7C7);
      canvas
        ..drawCircle(Offset(82, 91), 25, paint)
        ..drawCircle(Offset(102, 69), 20, paint)
        ..drawCircle(Offset(115, 103), 25, paint)
        ..drawCircle(Offset(135.5, 81.5), 16.5, paint);
    }
    if (condition == "windy") {
      Path path = Path()
        ..moveTo(156.857163,102,)..cubicTo(158.592904,102,160,103.407096,160,105.142837,)..cubicTo(160,106.818725,158.688272,108.188243,157.035505,108.2807,)..lineTo(156.857163,108.285675,)..lineTo(107.47666,108.285675,)..cubicTo(97.0724093,108.285675,100.466812,118.885845,107.548447,118.885845,)..cubicTo(113.073185,118.885845,116.428241,113.93773,120.106415,115.868844,)..cubicTo(123.784588,117.799959,123.419946,121.132483,120.715313,125.486111,)..cubicTo(118.010681,129.839739,109.795313,132.163873,103.976349,130.414442,)..cubicTo(98.2866945,128.703887,93.4739551,124.965074,91.0668658,119.385082,)..lineTo(90.8886255,118.954257,)..cubicTo(90.6385551,118.263129,88.3892622,111.321856,92.1849979,106.736104,)..cubicTo(96.1051838,102,98.2754998,102,107.342382,102,)..lineTo(156.857163,102,)..close()
        ..moveTo(166,89,)..cubicTo(168.761424,89,171,91.2385763,171,94,)..cubicTo(171,96.7614237,168.761424,99,166,99,)..lineTo(52,99,)..cubicTo(49.2385763,99,47,96.7614237,47,94,)..cubicTo(47,91.2385763,49.2385763,89,52,89,)..lineTo(166,89,)..close()
        ..moveTo(72.2470703,60.5664063,)..cubicTo(74.2841797,65.4375,73.3059107,70.2017688,69.5709801,72.1326721,)..cubicTo(65.8360496,74.0635754,62.2199776,65.5315938,56.6099885,65.5315938,)..cubicTo(49.4190785,65.5315938,46.6298828,79.2851563,59.7463384,79.7150124,)..lineTo(143.857506,79.7150124,)..cubicTo(145.593058,79.7150124,147,81.1219548,147,82.8575062,)..cubicTo(147,84.5930576,145.593058,86,143.857506,86,)..lineTo(54.5190936,85.9975333,)..cubicTo(47.0370588,85.9693429,44.8791072,85.6189758,41.2187141,81.2644136,)..cubicTo(37.2380366,76.5288272,39.8047776,69.2810015,39.9204796,69.0000815,)..cubicTo(42.3058844,63.2084114,48.9174816,55.2264568,56.7463384,53.1469198,)..cubicTo(64.5751953,51.0673828,70.2099609,55.6953125,72.2470703,60.5664063,)..close();
      canvas.drawShadow(path, Color(0xA0606060), 4.0, true);
      Paint paint = Paint()
        ..color = customTheme.cardColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter oldDelegate) {
    return oldDelegate.condition != condition || (oldDelegate.time.hour < 6 && time.hour >=6) || (oldDelegate.time.hour < 18 && time.hour >=18);
  }
}
