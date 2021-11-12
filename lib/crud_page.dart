import 'package:flutter/material.dart';

class CrudPage extends StatefulWidget {
  CrudPage({Key? key}) : super(key: key);

  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Crud İşlemleri'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Veriler',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
