import 'package:bluetooth_demo/provider/search_devices_provider.dart';
import 'package:bluetooth_demo/screen/search_devices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BloethoothDemoApp());
}

class BloethoothDemoApp extends StatelessWidget {
  const BloethoothDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchDevicesProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SearchDevicesWidget(),
      ),
    );
  }
}
