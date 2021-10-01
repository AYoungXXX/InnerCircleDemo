import 'package:flutter/material.dart';
import 'dart:math' as math;

///
///动态翻转widget
///
class DynamicWidget extends StatefulWidget {
  final String n;
  final double? size;
  final double? fontSize;
  const DynamicWidget(
      {Key? key, required this.n, this.size = 120, this.fontSize = 100})
      : super(key: key);

  @override
  _DynamicWidgetState createState() => _DynamicWidgetState();
}

class _DynamicWidgetState extends State<DynamicWidget>
    with TickerProviderStateMixin {
  late String previous, next;
  late AnimationController anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    previous = widget.n;
    next = widget.n;
  }

  @override
  void didUpdateWidget(covariant DynamicWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    next = widget.n;
    previous = oldWidget.n;
    anim.forward(from: 0);
  }

  Widget _buildItem(String text) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF212121), Color(0xFF0D0D0D)],
            stops: [0, .6]),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: widget.fontSize, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: .5,
                  child: _buildItem(next)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: .5,
                child: _buildItem(previous),
              ),
            ),
          ),
          AnimatedBuilder(
              animation: anim,
              builder: (ctx, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.005)
                    ..rotateX(Tween(begin: 0.0, end: math.pi / 2).evaluate(
                        CurvedAnimation(
                            parent: anim, curve: const Interval(0, .5)))),
                  origin: Offset(widget.size! / 2, widget.size! / 2),
                  // alignment: Alignment.bottomCenter,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipRect(
                      child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: .5,
                          child: _buildItem(previous)),
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: anim,
              builder: (ctx, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .005)
                    ..rotateX(Tween(begin: -math.pi / 2, end: 0.0).evaluate(
                        CurvedAnimation(
                            parent: anim, curve: const Interval(.5, 1.0)))),
                  origin: Offset(widget.size! / 2, widget.size! / 2),
                  // alignment: Alignment.bottomCenter,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: .5,
                          child: _buildItem(next)),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
