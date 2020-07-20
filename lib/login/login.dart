// import 'package:device_id/device_id.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:yimidelivery/main.dart';
import 'package:yimidelivery/API.dart' as API;
// TODO: Renombrar y mover MyHomePage a un unevo archivo

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _email = '', _password = '', _error = '';
  bool loginTry = false;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void _login() async {
    setState(() {
      loginTry = true;
    });
    if (validate()) {
      if(await API.login(_email, _password)){
        setState(() => loginTry = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        setState(() {
          _error = 'Correo o contraseña incorrectos';
          loginTry = false;
        });
      }
    }
  }

  bool validate() {
    bool res = _email.replaceAll(' ', '').trim().length == 0 || _password.replaceAll(' ', '').trim().length == 0;
    if (res) {
      print('Los campos no pueden estar vacíos');
      setState(() {
        _error = 'Los campos no pueden estar vacíos';
        loginTry = false;
      });
    }
    return !res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.125),
              child: Image.asset(
                'assets/images/logotipo_colores.png',
                width: MediaQuery.of(context).size.width / 2.25,
              ),
            ),

            Image.asset(
              'assets/images/personaje_login.png',
              height: MediaQuery.of(context).size.height < 800
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.385,
            ),
            // Container(
            //   alignment: Alignment.center,
            //   height: MediaQuery.of(context).size.height < 800
            //       ? MediaQuery.of(context).size.height * 0.25
            //       : MediaQuery.of(context).size.height * 0.385,
            //       color: Colors.blue,
            //       child: CircularProgressIndicator(),
            // ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Container(
                height: 50,
                child: TextField(
                  enabled: !loginTry,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    border: OutlineInputBorder(),
                    hintText: 'Correo',
                    hintStyle: TextStyle(fontSize: 18),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _email = text;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 5),
              child: Container(
                child: Column(
                  children: <Widget>[
                    TextField(
                      enabled: !loginTry,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        border: OutlineInputBorder(),
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                      obscureText: true,
                      onChanged: (text) {
                        setState(() {
                          _password = text;
                        });
                      },
                    ),
                    Visibility(
                      visible: _error != null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            FlatButton(
              textColor: Colors.blue,
              onPressed: () {},
              child: Text(
                "¿Olvidaste tu contraseña?",
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20, left: 20, right: 20, top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: SizedBox.expand(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: Color(0xFFEC6A2C),
                        disabledColor: Color(0xD0EC6A2C),
                        textColor: Colors.white,
                        onPressed: loginTry ? null : _login,
                        child: loginTry
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                "Continuar",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w400),
                              ),
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

    // //"martin@gmail.com" "12345"
    // var response = await http.post('http://35.208.143.82:3001/users/loginRepartidor',
    //   headers: {
    //     "Accept": "application/json"
    //   },
    //   body: {
    //     "usuario": _email,
    //     "contrasena": _password,
    //   },
    // );

    // var data = json.decode(response.body);
    // print(data);

    // if (data['response'] != null) {
    //   var userInfo = data['response'][0];
    //   String deviceID = await DeviceId.getID;
    //   print(deviceID);
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setString("nombre", userInfo["nombre"]);
    //   await prefs.setString("apellido", userInfo["apellido_pat"]);
    //   await prefs.setString("correo", userInfo["correo"]);
    //   await prefs.setString("telefono", userInfo["telefono"]);
    //   await prefs.setString("token", userInfo["token"]);
    //   await prefs.setString("device_id", deviceID);
    //   await prefs.setString("id_usuario", userInfo["id_usuario"]);
    //   await prefs.setInt("status_repartidor", 0);
    //   setState(() => loginTry = false);
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    // } else {
    //   print('Error');
    //   setState(() {
    //     _error = 'Correo o contraseña incorrectos';
    //     loginTry = false;
    //   });
    // }
