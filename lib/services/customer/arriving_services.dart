import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/customer/delivering_services.dart';
import 'package:yimidelivery/API.dart' as API;

class ArrivingServices extends StatefulWidget {
  ArrivingServices({
    Key key,
    this.services,
    this.customerName,
    this.phone,
    this.folio,
    this.restored,
    this.apagar,
    this.parentAction,
  }) : super(key: key);
  final List<Map> services;
  final String customerName, phone, folio;
  final bool restored;
  final int apagar;
  final ValueChanged<num> parentAction;

  _ArrivingServicesState createState() => _ArrivingServicesState();
}

class _ArrivingServicesState extends State<ArrivingServices> {
  bool restored;

  openDeliveryServices() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DeliveringServices(
          services: widget.services,
          customerName: widget.customerName,
          phone: widget.phone,
          folio: widget.folio,
          apagar: widget.apagar,
          parentAction: widget.parentAction,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    restored = widget.restored == true;
    // setData();
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', 'arrived_customer');
    prefs.setString('customername', widget.customerName); //bussinessName
    prefs.setString('folio', widget.folio);
    prefs.setString('phone', widget.phone);
    prefs.setInt('apagar', widget.apagar);

    List<String> descriptions = [];
    List<String> coords = [];
    List<String> monts = [];

    if (restored) {
      widget.services.forEach((element) {
        coords.add(element['coords']);
        descriptions.add(element['description']);
        monts.add('${element['mont']}');
      });
    }

    prefs.setStringList('descriptions', descriptions);
    prefs.setStringList('coords', coords);
    prefs.setStringList('monts', monts);
    // prefs.setString('customerAddress', _address); //bussinesAddress
    // prefs.setString('reference', _reference); //reference
    // prefs.setString('addressURL', _addressURL); //bussinesAddressURL

    // openAlert();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        color: Colors.white,
        height: (MediaQuery.of(context).size.height * 0.8) + 28,
        child: Stack(
          children: <Widget>[
            Material(
              color: Colors.white,
              elevation: 8,
              child: Container(
                height: 70,
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${widget.customerName == null ? 'Nombre cliente'.toUpperCase() : widget.customerName.toUpperCase()}',
                        style: TextStyle(fontSize: 18),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 20),
                      //   child: FlatButton(
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               color: Color(0xFF3FC700),
                      //               textColor: Colors.white,
                      //               onPressed: () async {
                      //                   if (await canLaunch(
                      //                       'tel:${widget.phone}')) {
                      //                     final bool nativeAppLaunchSucceeded =
                      //                         await launch(
                      //                       'tel:${widget.phone}',
                      //                     );
                      //                     if (!nativeAppLaunchSucceeded) {
                      //                       print('Launched phone on dialer');
                      //                     }
                      //                   }
                      //                 },
                      //               child: Row(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 children: <Widget>[
                      //                   Padding(
                      //                        padding: const EdgeInsets.only(right: 8.0),
                      //                        child: Icon(Icons.phone),
                      //                      ),
                      //                   Text(
                      //                     "Llamar",
                      //                     style: TextStyle(fontSize: 18),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 100,
                  bottom: (MediaQuery.of(context).size.height * 0.137) + 40),
              child: ListView(
                shrinkWrap: true,
                children: List.generate(
                  widget.services.length,
                  (index) => IntrinsicHeight(
                    child: Row(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
                              margin:
                                  EdgeInsets.only(left: 20, right: 10, top: 1),
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                  color: Color(0xFFFF5E20),
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            Visibility(
                              visible: index != widget.services.length - 1,
                              child: Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 4, bottom: 2.7, left: 9.5),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 3),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Punto ${index + 1}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Visibility(
                                        visible: index == widget.apagar,
                                        child: Icon(
                                          Icons.attach_money,
                                          color: Colors.yellow,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    widget.services[index]["description"],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Visibility(
                                  visible: index == widget.services.length - 1,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
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
                        API.iniciarServicioMandadoCliente(
                            widget.folio, widget.services.length);
                        Navigator.pop(context);
                        openDeliveryServices();
                      },
                      child: Text(
                        "Iniciar viaje",
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
      onWillPop: () async => false,
    );
  }
}

/*
ListView(
              padding: EdgeInsets.only(bottom: 40),
              children: List.generate(_pedidos.length, (index) => Padding(
                  padding: const EdgeInsets.only(top: 15, left: 60, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_pedidos[index]["title"], style: TextStyle(fontSize: 24),),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_pedidos[index]["colony"], style: TextStyle(fontSize: 18),),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.6,
                            height: 45,
                            child: SizedBox.expand(
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                color: Color(0xFF3FC700),
                                disabledColor: Color(0xFFA9B8D5),
                                disabledTextColor: Colors.white,
                                textColor: Colors.white,
                                onPressed:index==0&&!_pedidos[0]["isArrived"]?(){
                                  print('Entregado ${_pedidos[0]["title"]}');
                                  setState(() {
                                    _pedidos[0]["isArrived"] = true;
                                  });
                                }:index>0&&_pedidos[index-1]["isArrived"]&&!_pedidos[index]["isArrived"]?() {
                                  print('Entregado ${_pedidos[index]["title"]}');
                                  setState(() {
                                    _pedidos[index]["isArrived"] = true;
                                  });
                                  if(index == _pedidos.length-1) {
                                    Navigator.pop(context);
                                  }
                                }:null,
                                child: Text(
                                  index==_pedidos.length-1?"Finalizar viaje":"Entregado",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
              ),),
            ),
*/
