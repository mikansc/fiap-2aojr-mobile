import 'package:custo_de_vida/screens/favorite.dart';
import 'package:custo_de_vida/screens/home.dart';
import 'package:custo_de_vida/screens/search.dart';
import 'package:custo_de_vida/screens/details.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consulta de custo de vida',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: "/search",
      routes: {
        "/": (context) => const Home(),
        "/search": (context) => Search(),
        "/favorites": (context) => Favorite(),
        // "/books" :(context) => const ListBookWidget(),
        // "/cars" :(context) => const ListCarWidget(),
      },
    );
  }
}
