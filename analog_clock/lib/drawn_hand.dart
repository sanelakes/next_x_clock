// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hand.dart';

final String secIndexData01 = "M12,12 L20,22.5 L20,55.5 L12,66 L4,55.5 L4,22.5 L12,12 Z M12,0 L24,13 L24,16.375 L12,8.5 L0,16.375 L0,13 L12,0 Z";
final String secIndexData02 = "M7,0 L13.9282032,9.5 L13.9282032,28.5 L7,38 L0.0717967697,28.5 L0.0717967697,9.5 Z";
final String secIndexData03 = "M12,12 L20,22.5 L20,55.5 L12,66 L4,55.5 L4,22.5 L12,12 Z M12,16.95 L7,23.512 L7,54.487 L12,61.049 L17,54.486 L17,23.513 L12,16.95 Z M12,0 L24,13 L24,16.375 L12,8.5 L0,16.375 L0,13 L12,0 Z";
final String houIndexData01 = "M29.6573179,0 C39.7981853,0 49.7130547,0.967612324 59.3146359,2.81554675 L43.718624,61.022475 C39.1290602,60.3488544 34.4339287,60 29.6573179,60 C24.8810551,60 20.1862596,60.3488036 15.5970147,61.022475 L0,2.81554675 C9.6015812,0.967612324 19.5164506,0 29.6573179,0 Z";
final String houStrokeData1 = "M0.616769154,4.63534701 L19.0181882,73.304738 C24.9220713,72.1080947 30.9664386,71.5 37.0891888,71.5 C43.2120387,71.5 49.2567325,72.1081142 55.1611795,73.3047464 L73.5616152,4.63534856 C61.6950392,1.89611067 49.483389,0.5 37.0891888,0.5 C24.6949909,0.5 12.4833429,1.89611014 0.616769155,4.63534701 Z";
final String houIndexData02 = "M3,1 C4.1045695,1 5,1.8954305 5,3 C5,4.1045695 4.1045695,5 3,5 C1.8954305,5 1,4.1045695 1,3 C1,1.8954305 1.8954305,1 3,1 Z";
final String houStrokeData2 = "M16,1 L19,6 L16,11 L10,11 L7,6 L10,1 L16,1 Z M7,6 L1,6 M19,6 L25,6";
final String dayBGroundLine = "M64.9519053,0.577350269 L0.5,37.7886751 L0.5,112.211325 L64.9519053,149.42265 L129.403811,112.211325 L129.403811,37.7886751 L64.9519053,0.577350269 Z";
final String theCenterPoint = "M10.3923048,0 L20.7846097,6 L20.7846097,18 L10.3923048,24 L0,18 L0,6 Z";

final EdgeInsets clockPadding = EdgeInsets.only(left: 18.0);
void makePath(Path path, String pathData) {
  final Iterable<Match> itr = RegExp(r"[A-Z][\d\.\,\s]*").allMatches(pathData);
  for (Match m in itr) {
    String match = m.group(0).trim();
    List<String> step;
    if (match.startsWith("M")) {
      step = match.substring(1).split(",");
      path.moveTo(double.parse(step[0]), double.parse(step[1]));
    }
    if (match.startsWith("L")) {
      step = match.substring(1).split(",");
      path.lineTo(double.parse(step[0]), double.parse(step[1]));
    }
    if (match.startsWith("C")) {
      step = match.substring(1).split(" ").join(",").split(",");
      path.cubicTo(double.parse(step[0]), double.parse(step[1]), double.parse(step[2]), double.parse(step[3]), double.parse(step[4]), double.parse(step[5]),);
    }
    if (match.startsWith("Z")) {
      path.close();
    }
  }
}

class IndexPaint extends Hand {
  const IndexPaint({
    @required Color color,
    @required double angleRadians,
    @required this.data,
    @required this.offset,
    double size = 1.0,
    this.drawStroke = false,
    this.strokeColor = const Color(0xFF979797),
    this.strokeData = "",
    this.rotation = 0.0,
  })  : assert(color != null),
        assert(angleRadians != null),
        super(
        color: color,
        size: size,
        angleRadians: angleRadians,
      );

  final String data;
  final double offset;
  final bool drawStroke;
  final Color strokeColor;
  final String strokeData;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: clockPadding,
      child: Transform.rotate(
        angle: angleRadians / 180 * math.pi,
        child: FittedBox(
          fit: BoxFit.contain,
          child: CustomPaint(
            size: Size(480.0, 480.0),
            painter: _IndexPainter(data: data, color: color, scale: size, offset: offset, drawStroke: drawStroke, strokeColor: strokeColor, strokeData: strokeData, rotation: rotation, center: false),
          ),
        ),
      ),
    );
  }
}

class BgElement extends StatelessWidget {
  const BgElement({
    this.color = Colors.transparent,
    this.data = "",
    this.drawStroke = false,
    this.strokeColor = const Color(0xFF979797),
    this.strokeData = "",
    this.center = false,
  }) ;

  final String data;
  final bool drawStroke;
  final Color color;
  final Color strokeColor;
  final String strokeData;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: clockPadding,
      child: FittedBox(
        fit: BoxFit.contain,
        child: CustomPaint(
          size: Size(480.0, 480.0),
          painter: _IndexPainter(data: data, color: color, scale: 1.0, offset: 0.0, rotation: 0.0,drawStroke: drawStroke, strokeColor: strokeColor, strokeData: strokeData, center: center),
        ),
      ),
    );
  }
}

class _IndexPainter extends CustomPainter {
  _IndexPainter({
    @required this.data,
    @required this.color,
    @required this.scale,
    @required this.offset,
    this.drawStroke,
    this.strokeColor,
    this.strokeData,
    this.rotation,
    this.center,
  })  :
        assert(color != null),
        assert(scale >= 0.0);

  final String data;
  final Color color;
  final double scale;
  final double offset;
  final bool drawStroke;
  final Color strokeColor;
  final String strokeData;
  final double rotation;
  final bool center;

  @override
  void paint(Canvas canvas, Size size) {

    Paint paint = Paint();
    Path path = Path();
    Rect pathBounds = Offset.zero & Size.zero;

    if (data.isNotEmpty) {
      makePath(path, data);
      pathBounds = path.getBounds();
    }

    canvas.translate(size.width / 2 - pathBounds.width * scale / 2.0 , offset - pathBounds.height * scale / 2.0);
    canvas.scale(scale, scale);

    if (rotation != 0.0) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(rotation / 180 * math.pi);
      canvas.translate( -size.width / 2, -pathBounds.height + size.height / 2);
    }
    if (center)  canvas.translate(0, size.height / 2.0 );


    if (data.isNotEmpty) {
      paint
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawPath(path, paint);
    }


    if (strokeData.isNotEmpty) {
      Path sPath = Path();
      makePath(sPath, strokeData);
      canvas.translate(- (sPath.getBounds().width - pathBounds.width) * scale / 2.0 , - (sPath.getBounds().height - pathBounds.height) * scale / 2.0);

      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = strokeColor;
      canvas.drawPath(sPath, paint);
    }

    if (drawStroke && strokeData.isEmpty) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = strokeColor;
      canvas.scale(0.95, 0.96);
      canvas.translate(1.0, 1.0);
      canvas.drawPath(path, paint);
    }

  }

  @override
  bool shouldRepaint(_IndexPainter oldDelegate) {
    return oldDelegate.color != color ||
      oldDelegate.rotation != rotation;
  }
}

class SecIndex extends StatelessWidget {
  const SecIndex(this.index, this.time);
  final int index;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    Color color;
    final int sec = time.second;
    final int min = time.minute;
    bool drawStroke = false;
    String data;
    double offset;

    if (index == sec) {
      color = Theme.of(context).indicatorColor;
    } else if (index <= min) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Theme.of(context).dividerColor;
      drawStroke = true;
    }

    if (index % 5 == 0) {
      data = index == 0 && index != sec ? secIndexData03 : secIndexData01;
      offset = 36.0;
    } else {
      data = secIndexData02;
      offset = 42;
    }
    return IndexPaint(data: data, color: color, angleRadians: index  * 6.0, offset: offset, drawStroke: drawStroke,);
  }
}

class HouIndex extends StatelessWidget {
  const HouIndex(this.index, this.time);
  final int index;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    Color color;
    final int hour = time.hour;

    if (index < hour % 12) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Theme.of(context).accentColor;
    }

    return IndexPaint(data: houIndexData01, color: color, angleRadians: index  * 30.0 + 15.0 , offset: 111.0, drawStroke: true, strokeColor: Theme.of(context).dividerColor, strokeData: houStrokeData1,);
  }
}

class HouIndexInner extends StatelessWidget {
  const HouIndexInner(this.index, this.time);
  final int index;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color sColor;
    double rotation;
    final int hour = time.hour;

    if (index < hour % 12) {
      color = Color(0xBBFFFFFF);
      sColor = Color(0x99FFFFFF);
      rotation = 90.0;
    } else {
      color = Color(0x80FFFFFF);
      sColor = Color(0x50FFFFFF);
      rotation = 0.0;
    }

    return IndexPaint(data: houIndexData02, color: color, angleRadians: index  * 30.0 + 15.0, offset: 108.0, drawStroke: true, strokeColor: sColor, strokeData: houStrokeData2, rotation: rotation,);
  }
}

class DayBgline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BgElement(strokeData: dayBGroundLine, strokeColor: Theme.of(context).dividerColor, drawStroke: true, center: true,);
  }
}

class DayIndex extends StatelessWidget {
  const DayIndex(this.index, this.time);
  final int index;
  final DateTime time;
  @override
  Widget build(BuildContext context) {
    final dayA = index % 30;

    final dayO = index % 5;
    final double angle = dayA < 5 ? 30.0 : dayA < 10 ? 90.0 : dayA < 15 ? 150 : dayA < 20 ? 210 : dayA < 25 ? 270 : 330;
    final double offset = dayO == 0 ? -26.0 : dayO == 1 ? -13.0 : dayO == 2 ? 0.0 : dayO == 3 ? 13 : 26;
    Color color;
    if (time.day > 30 && index == 0) {
      color = Theme.of(context).indicatorColor;
    } else if (index < time.day) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Theme.of(context).accentColor;
    }
    return Container(
      padding: clockPadding,
      child: Transform.rotate(
        angle: angle / 180.0 * math.pi,
        child: FittedBox(
          fit: BoxFit.contain,
          child: CustomPaint(
            size: Size(480.0, 480.0),
            painter: _DayPainter(color: color, offset: offset,),
          ),
        ),
      ),
    );
  }
}

class _DayPainter extends CustomPainter {
  _DayPainter({
    @required this.color,
    @required this.offset,
  });
  final Color color;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + offset - 5, 170);

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(5.0, 5.0), 5.0, paint);
  }

  @override
  bool shouldRepaint(_DayPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class MonthIndex extends StatelessWidget {
  const MonthIndex(this.index, this.time);
  final int index;
  final DateTime time;
  @override
  Widget build(BuildContext context) {
    Color color;
    bool on;
    double angle = index < 2 ? 30.0 : index < 4 ? 90.0 : index < 6 ? 150 : index < 8 ? 210 : index < 10 ? 270 : 330;
    if (index < time.month) {
      color = Theme.of(context).indicatorColor;
      on = true;
    } else {
      color = Theme.of(context).highlightColor;
      on = false;
    }
    return Container(
      padding: clockPadding,
      child: Transform.rotate(
        angle: angle / 180.0 * math.pi,
        child: FittedBox(
          fit: BoxFit.contain,
          child: CustomPaint(
            size: Size(480.0, 480.0),
            painter: _MonthPainter(color: color, on: on, odd: (index + 1).isOdd),
          ),
        ),
      ),
    );
  }
}

class _MonthPainter extends CustomPainter {
  _MonthPainter({
    @required this.color,
    @required this.on,
    @required this.odd,
  });
  final Color color;
  final bool on;
  final bool odd;

  @override
  void paint(Canvas canvas, Size size) {
    Offset offset;
    Path path = Path();
    if (odd) {
      if (on) {
        path.addPolygon([Offset(26, 0), Offset(26, 31), Offset(18, 31), Offset(0, 0)], true);
      } else {
        path.addPolygon([Offset(23, 0), Offset(23, 26), Offset(15, 26), Offset(0, 0)], true);
      }
      offset = Offset(-path.getBounds().width - 2,  - path.getBounds().height - 22);
    } else {
      if (on) {
        path.addPolygon([Offset(0, 0), Offset(0, 31), Offset(8, 31), Offset(26, 0)], true);
      } else {
        path.addPolygon([Offset(0, 0), Offset(0, 26), Offset(8, 26), Offset(23, 0)], true);
      }
      offset = Offset(2, -path.getBounds().height - 22);
    }
    canvas.translate(size.width / 2.0 + offset.dx, size.height / 2.0 + offset.dy,);
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MonthPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class CenterPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BgElement(data: theCenterPoint, color: Theme.of(context).indicatorColor, center: true,);
  }
}