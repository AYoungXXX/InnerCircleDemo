import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dynamic_clock2/dynamic_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamController<DateTime> streamController =
      StreamController<DateTime>.broadcast();
  late Stream<String> hour$;
  late Stream<String> min$;
  late Stream<String> sec$;
  late Stream<String> date$;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    final Map<int, String> weekMapper = {
      1: "一",
      2: "二",
      3: "三",
      4: "四",
      5: "五",
      6: "六",
      7: "日",
    };
    hour$ = streamController.stream
        .map((event) => '${event.hour}')
        .map((event) => covertStr(event))
        .distinct();
    min$ = streamController.stream
        .map((event) => '${event.minute}')
        .map((event) => covertStr(event))
        .distinct();
    sec$ = streamController.stream
        .map((event) => '${event.second}')
        .map((event) => covertStr(event))
        .distinct();
    date$ = streamController.stream.map((event) {
      return '${event.year}年${event.month}月${event.day}日 星期${weekMapper[event.weekday]}';
    }).distinct();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      streamController.sink.add(DateTime.now());
    });
  }

  String covertStr(String str) {
    return str.length > 1 ? str : "0$str";
  }

  @override
  void dispose() {
    timer.cancel();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StreamBuilder<String>(
                    stream: date$,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "",
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    }),
              ),
              _buildClock(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClock() {
    const TextStyle textStyle =
        TextStyle(fontSize: 90, color: Colors.white, height: 1);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<String>(
              stream: hour$,
              builder: (context, snapshot) {
                String data = snapshot.data ?? '';
                return DynamicWidget(
                  n: data,
                  fontSize: 90,
                );
              }),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              ":",
              style: textStyle,
            ),
          ),
          StreamBuilder<String>(
              stream: min$,
              builder: (context, snapshot) {
                String data = snapshot.data ?? '';
                return DynamicWidget(
                  n: data,
                  fontSize: 90,
                );
              }),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              ":",
              style: textStyle,
            ),
          ),
          StreamBuilder<String>(
              stream: sec$,
              builder: (context, snapshot) {
                String data = snapshot.data ?? '';
                return DynamicWidget(
                  n: data,
                  fontSize: 90,
                );
              }),
        ],
      ),
    );
  }
}
