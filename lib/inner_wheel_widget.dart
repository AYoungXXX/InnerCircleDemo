import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'dart:ui' as ui;

///
/// 万花尺组件
///
class InnerWheelWidget extends StatefulWidget {
  const InnerWheelWidget({Key? key, required this.size, this.innerRadius})
      : super(key: key);
  final double size;
  final double? innerRadius;
  @override
  _InnerWheelWidgetState createState() => _InnerWheelWidgetState();
}

class _InnerWheelWidgetState extends State<InnerWheelWidget>
    with TickerProviderStateMixin {
  List<Offset> points = List.empty(growable: true);

  double outAngle = 0.0;

  Offset? lastOffset;
  late Dot dot = dots.first;
  //
  List<Dot> dots = [
    Dot(0, 20, Math.pi / 2),
    Dot(1, 10, Math.pi / 5),
    Dot(2, 30, Math.pi / 6),
    Dot(5, 30, Math.pi),
    Dot(6, 50, Math.pi / 9)
  ];

  //外圆半径
  double get radius => widget.size / 2;
  //内圆半径
  double get innerRadius => widget.innerRadius ?? 35.0;

//
//根据坐标系中的3点确定夹角的方法（注意：夹角是有正负的）
//
  double angle(Offset cen, Offset first, Offset second) {
    double dx1, dx2, dy1, dy2;

    dx1 = first.dx - cen.dx;
    dy1 = first.dy - cen.dy;
    dx2 = second.dx - cen.dx;
    dy2 = second.dy - cen.dy;

    // 计算三边的平方
    double ab2 = (second.dx - first.dx) * (second.dx - first.dx) +
        (second.dy - first.dy) * (second.dy - first.dy);
    double oa2 = dx1 * dx1 + dy1 * dy1;
    double ob2 = dx2 * dx2 + dy2 * dy2;

    // 根据两向量的叉乘来判断顺逆时针
    bool isClockwise = ((first.dx - cen.dx) * (second.dy - cen.dy) -
            (first.dy - cen.dy) * (second.dx - cen.dx)) >
        0;

    // 根据余弦定理计算旋转角的余弦值
    double cosDegree =
        (oa2 + ob2 - ab2) / (2 * Math.sqrt(oa2) * Math.sqrt(ob2));

    // 异常处理，因为算出来会有误差绝对值可能会超过一，所以需要处理一下
    if (cosDegree > 1) {
      cosDegree = 1;
    } else if (cosDegree < -1) {
      cosDegree = -1;
    }

    // 计算弧度
    double radian = Math.acos(cosDegree);

    // 计算旋转过的角度，顺时针为正，逆时针为负
    return isClockwise ? radian : -radian;
    // return (double)(
    //     isClockwise ? Math.toDegrees(radian) : -Math.toDegrees(radian));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          onPressed: () {
            points.clear();
            outAngle = 0.0;
            setState(() {});
          },
          child: const Text("清空路径"),
        ),
        SizedBox(
          height: widget.size,
          width: widget.size,
          child: GestureDetector(
            onTap: () async {
              ///选择新的点
              dynamic result = await showDialog(
                  context: context,
                  builder: (ctx) => SelectDotDialog(
                        size: innerRadius,
                        dots: dots,
                      ));
              if (result != null) {
                dot = result;
                setState(() {});
              }
            },
            onTapDown: (details) {
              lastOffset = details.localPosition;
            },
            onPanUpdate: (details) {
              var result = angle(Offset(widget.size / 2, widget.size / 2),
                  lastOffset!, details.localPosition);
              //单次最大旋转角度
              double maxAngle = 0.1;
              result = Math.min(Math.max(-maxAngle, result), maxAngle);
              lastOffset = details.localPosition;
              outAngle += result;
              double d = dot.width;
              double innerAngle =
                  (radius - innerRadius) / innerRadius * outAngle - dot.angle;
              double x = (radius - innerRadius) * Math.sin(outAngle) -
                  d * Math.sin(innerAngle);
              double y = (radius - innerRadius) * Math.cos(outAngle) +
                  d * Math.cos(innerAngle);
              //将圆心从0,0转换到widget.size/2,widget.size/2
              points.add(Offset(x + widget.size / 2, widget.size / 2 - y));
              setState(() {});
            },
            child: CustomPaint(
              foregroundPainter:
                  _CirclePainter(outAngle, innerRadius, dot, dots),
              child: CustomPaint(
                painter: _CustomPathPainter(points),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///内旋轮路径画板
class _CustomPathPainter extends CustomPainter {
  final Paint _paint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(200, 200),
        [Colors.red, Colors.greenAccent, Colors.blue], [0, .5, 1])
    ..strokeWidth = 1.5;
  final List<Offset> points;

  _CustomPathPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], _paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

///内圆画板
class _CirclePainter extends CustomPainter {
  final double angle;
  final double innerRadius;
  final Dot cur;
  final List<Dot> dots;
  _CirclePainter(this.angle, this.innerRadius, this.cur, this.dots);

  final Paint _paint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _innerCirclePaint = Paint()
    ..color = Colors.grey.withOpacity(.5)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2.0;

  final Paint _dotPaint = Paint()
    ..color = Colors.red.withOpacity(.5)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (Math.min(size.width, size.height)) / 2.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, _paint);

    double x = Math.sin(angle) * (radius - innerRadius);
    double y = Math.cos(angle) * (radius - innerRadius);

    canvas.drawCircle(Offset(size.width / 2 + x, size.height / 2 - y),
        innerRadius, _innerCirclePaint);

    for (int i = 0; i < dots.length; i++) {
      Dot dot = dots[i];
      double d = dot.width;
      double innerAngle =
          (radius - innerRadius) / innerRadius * angle - dot.angle;
      x = (radius - innerRadius) * Math.sin(angle) - d * Math.sin(innerAngle);
      y = (radius - innerRadius) * Math.cos(angle) + d * Math.cos(innerAngle);
      if (dot.id == cur.id) {
        canvas.drawCircle(Offset(size.width / 2 + x, size.height / 2 - y), 2,
            _dotPaint..color = Colors.red.withOpacity(.5));
      } else {
        canvas.drawCircle(Offset(size.width / 2 + x, size.height / 2 - y), 2,
            _dotPaint..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

///圆上的参数点
class Dot {
  final int id;
  final double width;
  final double angle;

  Dot(this.id, this.width, this.angle);
}

///选择点的弹窗
class SelectDotDialog extends StatelessWidget {
  final List<Dot> dots;
  final double size;
  const SelectDotDialog({Key? key, required this.dots, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 2,
        height: size * 2,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(size * 2),
            color: Colors.white),
        child: Flow(
          delegate: _Delegate(dots),
          children: dots
              .map<Widget>(
                (e) => Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context, e);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Delegate extends FlowDelegate {
  final List<Dot> dots;

  _Delegate(this.dots);

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < dots.length; i++) {
      double x = Math.sin(dots[i].angle) * dots[i].width;
      double y = Math.cos(dots[i].angle) * dots[i].width;
      var offset = Matrix4.identity()..translate(x, -y, 0.0);
      context.paintChild(i, transform: offset);
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return true;
  }
}
