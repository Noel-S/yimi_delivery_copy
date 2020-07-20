// import 'dart:developer';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:sqflite/sqflite.dart';
// import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/bussines/services_list.dart';
import 'package:yimidelivery/API.dart' as API;

class ArrivedService extends StatefulWidget {
  ArrivedService({
    Key key,
    this.bussinessName,
    this.bussinesAddress,
    this.reference,
    this.bussinesAddressURL,
    this.bussinesId,
    this.folio,
    this.phone,
    this.restored,
    this.parentAction,
  }) : super(key: key);
  final String bussinessName,
      bussinesAddress,
      reference,
      bussinesAddressURL,
      bussinesId,
      folio,
      phone;
  final bool restored;
  final ValueChanged parentAction;

  @override
  _ArrivedServiceState createState() => _ArrivedServiceState();
}

class _ArrivedServiceState extends State<ArrivedService> {
  String _name, _address, _addressURL, _reference, _qrData;
  bool qrReady = false;

  abrirListaPedidos() {
    leave();
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceList(
        folio: widget.folio,
        parentAction: widget.parentAction,
        idNegocio: widget.bussinesId,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _name = widget.bussinessName;
    _address = widget.bussinesAddress;
    _reference = widget.reference;
    _addressURL = widget.bussinesAddressURL;
    _qrData = widget.bussinesId;

    setData();
  }

  void openAlert() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Yimi te recuerda'),
          content: FlatButton(
            highlightColor: Color(0x0),
            splashColor: Color(0x0),
            onPressed: () => Navigator.pop(context),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 0),
                  child: Text(
                    "Usa cubrebocas en todos tus viajes",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Icon(
                    Icons.thumb_up,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', 'arrived_bussines');
    prefs.setString('bussinesName', _name); //bussinessName
    prefs.setString('bussinesAddress', _address); //bussinesAddress
    prefs.setString('reference', _reference); //reference
    prefs.setString('bussinesAddressURL', _addressURL); //bussinesAddressURL
    prefs.setString('bussinesId', _qrData); //bussinesId
    prefs.setString('folio', widget.folio);
    prefs.setString('phone', widget.phone);
    openAlert();
  }

  void leave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('lastAction', 'arrived_bussines');
    prefs.setString('bussinesName', null); //bussinessName
    prefs.setString('bussinesAddress', null); //bussinesAddress
    prefs.setString('reference', null); //reference
    prefs.setString('bussinesAddressURL', null); //bussinesAddressURL
    prefs.setString('bussinesId', null); //bussinesId
    prefs.setString('folio', null);
    prefs.setString('phone', null);
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
                  height: MediaQuery.of(context).size.height * 0.8,
                  color: Colors.white,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 43, left: 20),
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
                          padding: const EdgeInsets.only(top: 72, left: 20),
                          child: Text(
                            _address,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 120, left: 20),
                          child: Text(
                            "REFERENCIA",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 145, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _reference,
                                style: TextStyle(fontSize: 14),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: FlatButton(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 28),
                                      color: Color(0xFF3FC700),
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        if (await canLaunch(
                                            'tel:${widget.phone}')) {
                                          final bool nativeAppLaunchSucceeded =
                                              await launch(
                                            'tel:${widget.phone}',
                                          );
                                          if (!nativeAppLaunchSucceeded) {
                                            print('Launched phone on dialer');
                                          }
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Icon(Icons.phone),
                                          ),
                                          Text(
                                            "Llamar",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Visibility(
                          visible: !qrReady,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 145, left: 250),
                            child: RawMaterialButton(
                              elevation: 10,
                              constraints:
                                  BoxConstraints(minHeight: 45, minWidth: 45),
                              shape: CircleBorder(),
                              child: Icon(
                                Icons.close,
                                size: 32,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                API.qrError(_qrData);
                                // setState(() {
                                //   qrReady = true;
                                // });
                                abrirListaPedidos();
                              },
                              fillColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              RawMaterialButton(
                                onPressed: qrReady
                                    ? null
                                    : () async {
                                        String result = await scanner.scan();
                                        if (result == _qrData) {
                                          setState(() {
                                            qrReady = true;
                                          });
                                        }
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: qrReady
                                      ? Icon(
                                          CupertinoIcons
                                              .check_mark_circled_solid,
                                          color: Colors.green,
                                          size: 92,
                                        )
                                      : Image.asset(
                                          'assets/images/QR_lector.png',
                                          height: 92,
                                          width: 92,
                                        ),
                                ),
                              ),
                              Text(
                                qrReady ? "CÓDIGO ESCANEADO" : "ESCANEAR QR",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                                  disabledColor: Color(0xFFA9B8D5),
                                  disabledTextColor: Colors.white,
                                  textColor: Colors.white,
                                  onPressed: qrReady ? abrirListaPedidos : null,
                                  child: Text(
                                    "En punto de encuentro",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
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
                            final bool nativeAppLaunchSucceeded =
                                await launch(_addressURL);
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
                  )),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: DraggableFab(
                child: RawMaterialButton(
                  elevation: 10,
                  constraints: BoxConstraints(minHeight: 45, minWidth: 45),
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.headset_mic,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (await canLaunch(
                        'tel:${prefs.getString('telefono_atencion')}')) {
                      final bool nativeAppLaunchSucceeded = await launch(
                          'tel:${prefs.getString('telefono_atencion')}');
                      if (!nativeAppLaunchSucceeded) {
                        print('Launched address url on maps');
                      }
                    }
                  },
                  fillColor: Color(0xFFFF5E20),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}

/*
  FloatingActionButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (await canLaunch('tel:${prefs.getString('telefono_atencion')}')) {
                      final bool nativeAppLaunchSucceeded =
                          await launch('tel:${prefs.getString('telefono_atencion')}');
                      if (!nativeAppLaunchSucceeded) {
                        print('Launched address url on maps');
                      }
                    }
                  },
                  child: Icon(Icons.headset_mic),
                  mini: true,
                ),
 */
