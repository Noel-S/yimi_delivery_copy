import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class Profile extends StatefulWidget{
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{
  String dropdownValue = 'Tipo de vehículo', nombre, aPaterno, aMaterno, email, phone;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nombre(s)',
                  labelText: 'Nombre(s)',
                  labelStyle: TextStyle(color: Colors.black)
              ),
              onChanged: (text) {
                setState(() {
                  nombre = text;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Apellido paterno',
                  labelText: 'Apellido paterno',
                  labelStyle: TextStyle(color: Colors.black)
              ),
              onChanged: (text) {
                setState(() {
                  aPaterno = text;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 170, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Apellido materno',
                  labelText: 'Apellido materno',
                  labelStyle: TextStyle(color: Colors.black)
              ),
              onChanged: (text) {
                setState(() {
                  aMaterno = text;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 240, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Correo',
                  labelText: 'Correo',
                  labelStyle: TextStyle(color: Colors.black)
              ),
              onChanged: (text) {
                setState(() {
                  email = text;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 310, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Teléfono',
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(color: Colors.black)
              ),
              onChanged: (text) {
                setState(() {
                  phone = text;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 380, left: 30,),
              child: Text('Tipo de vehículo'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 400, left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                child: DropdownButton(
                  isExpanded: true,
                  underline: null,
                  value: dropdownValue,
                  onChanged: (text) {
                    setState(() {
                      dropdownValue = text;
                    });
                  },
                  items: <String>['Tipo de vehículo', 'Uno', 'Dos', 'Tres', 'Cuatro']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
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
}