import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:yimidelivery/API.dart' as API;

class Legal extends StatefulWidget{
  Legal({Key key}) : super(key: key);

  @override
  _LegalState createState() => _LegalState();
}

class _LegalState extends State<Legal>{
  String _terms = '';

  @override
  void initState() {
    super.initState();
    
    API.termsAndConditions().then((string) => setState(() => _terms = string));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Términos y condiciones'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Text(_terms, style: TextStyle(fontSize: 16),)
        ],
      )
    );
  }
}