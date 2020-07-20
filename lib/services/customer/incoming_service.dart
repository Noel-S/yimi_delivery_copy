import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/customer/arriving_services.dart';

import 'package:yimidelivery/API.dart' as API;

class IncomingService extends StatefulWidget {
  IncomingService({
    Key key,
    this.customerName,
    this.reference,
    this.serviceType,
    this.addressURL,
    this.points,
    this.expirationTime,
    this.dateTime,
    this.montoPagar,
    this.folio,
    this.ciudad,
    this.tipoServicio,
    this.telefono,
    this.apagar,
    this.parentAction,
  }) : super(key: key);

  final String customerName,
      reference,
      serviceType,
      addressURL,
      dateTime,
      folio,
      ciudad,
      tipoServicio,
      telefono;
  final List<Map> points;
  final int expirationTime, apagar;
  final num montoPagar;
  final ValueChanged<num> parentAction;

  @override
  _IncomingServiceState createState() => _IncomingServiceState();
}

class _IncomingServiceState extends State<IncomingService> {
  String _name,
      _addressURL,
      _reference,
      _serviceType,
      _dateTime,
      _folio,
      _ciudad,
      _tipoServicio;
  num _montoGanar = 0;

  List<Map> _points;
  int _expirationTime = 30;
  num _montoPagar;
  Timer _timer;
  bool isOpen = false;

  void startTimer() {
    const time = const Duration(seconds: 1);
    _timer = Timer.periodic(time, (timer) {
      setState(() {
        if (_expirationTime < 1) {
          timer.cancel();
          rechazarPedido('Tiempo de espera excedido');
          if (isOpen) {
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
    _name = widget.customerName;
    _reference = widget.reference;
    _serviceType = widget.serviceType;
    _addressURL = widget.addressURL;
    _points = widget.points;
    _points.forEach((element) {
      print(element);
      _montoGanar += element["mont"];
    });
    _expirationTime = widget.expirationTime;
    _dateTime = widget.dateTime;
    _montoPagar = widget.montoPagar;
    _folio = widget.folio;
    _ciudad = widget.ciudad;
    _tipoServicio = widget.tipoServicio;
    print('Tipo servicio => $_tipoServicio');
    print('Ciudada => $_ciudad');
    print('Folio => $_folio');
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  openArrivingServices() {
    print('Open Arriving Services');
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ArrivingServices(
          services: _points,
          customerName: _name,
          phone: widget.telefono,
          folio: _folio,
          apagar: widget.apagar,
          parentAction: widget.parentAction,
        );
      },
    );
  }

  void modalRechazo() async {
    setState(() {
      isOpen = true;
    });
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
              ]);
        });
    print('Rechazado por: $result');
    if (result != null) {
      rechazarPedido(result);
    }
    setState(() {
      isOpen = false;
    });
  }

  rechazarPedido(String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnService', false);
    API.rejectService(widget.folio, widget.tipoServicio, result);
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
                        // Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Padding(
                        //     padding:
                        //         const EdgeInsets.only(top: 110, left: 20),
                        //     child: Text(
                        //       _address,
                        //       style: TextStyle(fontSize: 14),
                        //     ),
                        //   ),
                        // ),
                        //TODO: button call

                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 110, left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _reference,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'TIPO SERVICIO:  $_serviceType',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'MONTO A PAGAR: \$ ${_montoPagar.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'MONTO A GANAR: \$ ${_montoGanar.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              top: 230,
                              bottom:
                                  (MediaQuery.of(context).size.height * 0.137) +
                                      40),
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(
                              _points.length,
                              (index) => IntrinsicHeight(
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topCenter,
                                          margin: EdgeInsets.only(
                                              left: 20, right: 10, top: 1),
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFFF5E20),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                        Visibility(
                                          visible: index != _points.length - 1,
                                          child: Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: 4,
                                                bottom: 2.7,
                                                left: 9.5,
                                              ),
                                              width: 0.5,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8, top: 3),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    'Punto ${index + 1}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        index == widget.apagar,
                                                    child: Icon(
                                                      Icons.attach_money,
                                                      color: Colors.yellow,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Text(
                                                _points[index]["description"],
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  index == _points.length - 1,
                                              child: Container(
                                                height: 40,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

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
                                  onPressed: () {
                                    _timer.cancel();
                                    API.acceptService(widget.folio,
                                        widget.tipoServicio, widget.ciudad);
                                    Navigator.pop(context);
                                    openArrivingServices();
                                  },
                                  child: Text(
                                    "Aceptar viaje",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
