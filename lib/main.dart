import 'package:flutter/material.dart';
import 'ChatPage/landing.dart'; // backgroundCanvas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome!'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/canvas');
                  },
                  child: const Text('Canvas >'),
                ),
              ],
            ),
          ),
        ),
        '/canvas': (context) => Scaffold(
          body: backgroundCanvas(),
        ),
      },
    );
  }
}
