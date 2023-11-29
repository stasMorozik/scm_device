import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';

class MyApp extends StatelessWidget {
  final Stream<String> stream;

  const MyApp({Key? key, required this.stream}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(stream: stream),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Stream<String> stream;

  const MyHomePage({Key? key, required this.stream}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<String>(
            stream: stream,
            initialData: 'assets/images/default.png',
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Image.file(
                File(snapshot.data as String),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover
              );
            }
          ),
        ]
      ),
    );
  }
}