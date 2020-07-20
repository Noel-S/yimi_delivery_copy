// import 'package:device_id/device_id.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget{
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{
  String _email, _password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 70, bottom: 50),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 2.5,
                color: Colors.orange,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Text(
                'Cambiar contraseña',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 260, left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Correo'
                ),
                onChanged: (text) {
                  setState(() {
                    _email = text;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 340, left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Contraseña'
                ),
                obscureText: true,
                onChanged: (text) {
                  setState(() {
                    _password = text;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 400),
                child: FlatButton(
                  color: Colors.orange,
                  textColor: Colors.white,
                  onPressed: () {},
                  child: Text(
                    "Guardar",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        )

    );
  }

  update() async {
    var response = await http.post(
        'http://35.215.23.202:3001/users/loginRepartidor',
        headers: {
          "Accept": "application/json"
        },
        body: {
          "usuario": _email,
          "contrasena": _password
        }
    );

    var data = json.decode(response.body);
    print(data);
  }
}