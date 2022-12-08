import 'package:flutter/material.dart';
import 'root_page.dart';

void main() {
  runApp(const MyApp());
}

final routeObserver = RouteObserver();

class MyApp extends StatelessWidget {
 const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RootPage(title: '称号達成度'),
      navigatorObservers: [routeObserver],
    );
  }
}