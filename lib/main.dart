import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_uygulama_mimarisi/views/book_view.dart';
import 'package:provider/provider.dart';
// import 'views/books_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kütüphane Uygulaması',
        theme: ThemeData(),
        home: FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Beklenilmeyen Bir Hata Oluştur'));
              } else if (snapshot.hasData) {
                return BooksView();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })

        //MyHomePage(title: 'Flutter Demo Home Page'),
        );
  }
}
