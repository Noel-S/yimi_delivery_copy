import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/bussines/arrived_service.dart';
import 'package:yimidelivery/API.dart' as API;

class IncomingService extends StatefulWidget {
  IncomingService({
    Key key,
    this.bussinesName,
    this.bussinesAddress,
    this.reference,
    this.serviceType,
    this.tipoServicioID,
    this.bussinesAddressURL,
    this.bussinesId,
    this.expirationTime,
    this.dateTime,
    this.ciudad,
    this.folio,
    this.phone,
    this.parentAction,
  }) : super(key: key);

  final String bussinesName,
      bussinesAddress,
      reference,
      serviceType,
      tipoServicioID,
      bussinesAddressURL,
      bussinesId,
      dateTime,
      ciudad,
      folio,
      phone;
  final int expirationTime;
  final ValueChanged<num> parentAction;

  @override
  _IncomingServiceState createState() => _IncomingServiceState();
}

class _IncomingServiceState extends State<IncomingService> {
  String _name,
      _address,
      _addressURL,
      _reference,
      _serviceType,
      _tipoServicioID,
      _bussinesId,
      _dateTime,
      _ciudad,
      _folio;
  int _expirationTime;
  Timer _timer;
  bool rejectIsOpen = false;
  // int seconds = 30;

  void startTimer() {
    const time = const Duration(seconds: 1);
    _timer = Timer.periodic(time, (timer) {
      setState(() {
        if (_expirationTime < 1) {
          timer.cancel();
          print('Folio: $_folio');
          _rechazarViaje('Tiempo de expiración alcanzado');
          if (rejectIsOpen) {
            Navigator.pop(context);
          }
        } else {
          _expirationTime -= 1;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _name = widget.bussinesName;
    _address = widget.bussinesAddress;
    _reference = widget.reference;
    _serviceType = widget.serviceType;
    _tipoServicioID = widget.tipoServicioID;
    _addressURL = widget.bussinesAddressURL;
    _bussinesId = widget.bussinesId;
    _expirationTime = widget.expirationTime;
    _dateTime = widget.dateTime;
    _ciudad = widget.ciudad;
    _folio = widget.folio;
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  openArrivedService() {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ArrivedService(
            bussinessName: _name,
            bussinesAddress: _address,
            reference: _reference,
            bussinesAddressURL: _addressURL,
            bussinesId: _bussinesId,
            folio: _folio,
            phone: widget.phone,
            parentAction: widget.parentAction,
          );
        });
  }

  void modalRechazo() async {
    String result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Column(
            children: <Widget>[
              Icon(
                Icons.cancel,
                size: 64,
                color: Colors.red,
              ),
              Text(
                "¿Por qué deseas rechazar el viaje?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, 'Dinero insuficiente');
              },
              child: const Text('Dinero insuficiente'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, 'Espacio insuficiente');
              },
              child: const Text('Espacio insuficiente'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, 'Ubicación');
              },
              child: const Text('Ubicación'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancelar'),
              isDefaultAction: true,
            )
          ],
        );
      },
    );
    if (result != null) {
      _rechazarViaje(result);
    }
  }

  void _aceptarViaje() async {
    bool success = await API.acceptService(_folio, _tipoServicioID, _ciudad);
    print('Tipo servicio => $_tipoServicioID');
    if (success) {
      _timer.cancel();
      Navigator.pop(context);
      openArrivedService();
    }
  }

  void _rechazarViaje(String razon) async {
    print('Rechazado por: $razon');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnService', false);
    API.rejectService(_folio, _tipoServicioID, razon);
    _timer.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, left: 20),
                            child: FlatButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: () {
                                modalRechazo();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Rechazar viaje",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80, left: 20),
                            child: Text(
                              _name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 110, left: 20),
                            child: Text(
                              _address,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 150, left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "REFERENCIA",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _reference,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'TIPO DE SERVICIO:  ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          _serviceType,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        // Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(
                        //         top: 175, left: 20, right: 20),
                        //     child: Text(
                        //       _reference,
                        //       style: TextStyle(fontSize: 14),
                        //     ),
                        //   ),
                        // ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.137),
                            child: Material(
                              color: Colors.white,
                              shape: CircleBorder(),
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                          color: Colors.deepOrangeAccent,
                                          width: 2.5)),
                                  child: Text(
                                    '$_expirationTime s',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15, left: 20, right: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: SizedBox.expand(
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    color: Color(0xFF3FC700),
                                    textColor: Colors.white,
                                    onPressed: _aceptarViaje,
                                    child: Text(
                                      "Aceptar viaje",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: (MediaQuery.of(context).size.height * 0.2) - 34,
                      right: 34),
                  child: Container(
                    height: 68,
                    width: 68,
                    child: FittedBox(
                      child: FloatingActionButton(
                        elevation: 10,
                        onPressed: () async {
                          if (await canLaunch(_addressURL)) {
                            final bool nativeAppLaunchSucceeded = await launch(
                              _addressURL,
                            );
                            if (!nativeAppLaunchSucceeded) {
                              print('Launched address url on maps');
                            }
                          }
                        },
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(30),
                                color: Color(0xFF1A73E9)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                Text(
                                  'GO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        onWillPop: () async => false);
  }
}
