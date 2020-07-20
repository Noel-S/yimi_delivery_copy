import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:yimidelivery/API.dart' as API;

class DeliveringServices extends StatefulWidget {
  DeliveringServices({
    Key key,
    this.services,
    this.customerName,
    this.phone,
    this.folio,
    this.listaPedidos,
    this.currentStep,
    this.completed,
    this.restored,
    this.apagar,
    this.parentAction,
  }) : super(key: key);
  final List<Map> services, listaPedidos;
  final String customerName, phone, folio;
  final bool restored;
  final int currentStep, completed, apagar;
  final ValueChanged<num> parentAction;

  _DeliveringServicesState createState() => _DeliveringServicesState();
}

class _DeliveringServicesState extends State<DeliveringServices> {
  List<Map> _services;
  num currentStep = 0;
  num completed = 0;

  next() async {
    if (currentStep != _services.length - 1) {
      API.entregaServicioCliente(widget.folio, completed); // +1
      goToStep(currentStep + 1);
      setState(() {
        completed++;
      });
    } else {
      // setState(() => complete = true);
      API.finalizarPedidoCliente(widget.folio, completed); // +1
      leave();
      print('Viaje finalizado');
      Navigator.pop(context);
    }
  }

  goToStep(num step) {
    setState(() {
      currentStep = step;
    });
  }

  void leave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', null);
    prefs.setBool('isOnService', false);
    // num montoPagar = 0;
    // _services.forEach((element) => montoPagar += num.parse(element['mont']));
    widget.parentAction(2);
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', 'delivering_customer');
    prefs.setString('customername', widget.customerName); //bussinessName
    prefs.setString('folio', widget.folio);
    prefs.setString('phone', widget.phone);
    prefs.setInt('apagar', widget.apagar);

    List<String> descriptions = [];
    List<String> coords = [];
    List<String> monts = [];

    _services.forEach((element) {
      coords.add(element['coords']);
      descriptions.add(element['description']);
      monts.add('${element['mont']}');
    });

    prefs.setStringList('descriptions', descriptions);
    prefs.setStringList('coords', coords);
    prefs.setStringList('monts', monts);
    // prefs.setString('customerAddress', _address); //bussinesAddress
    // prefs.setString('reference', _reference); //reference
    // prefs.setString('addressURL', _addressURL); //bussinesAddressURL

    // openAlert();
  }

  @override
  void initState() {
    super.initState();
    //  _services = widget.services;
    _services = List<Map>();

    if (widget.services == null) {
      widget.listaPedidos.forEach((element) {
        _services.add(element);
      });
    } else {
      int index = 0;
      widget.services.forEach((element) {
        _services.add({
          "title": 'Punto ${index + 1}',
          "mont": element["mont"],
          "coords": element["cordenadas"],
          "description": element["description"],
          "isArrived": false,
          "key": ValueKey('value${index + 1}')
        });
        index++;
      });
    }
    // setData();
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
                  child: Text(
                    '${widget.customerName}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 70),
              child: Stepper(
                onStepTapped: (step) => goToStep(step),
                onStepContinue: next,
                controlsBuilder: (context, {onStepCancel, onStepContinue}) {
                  return Container(
                    alignment: Alignment.bottomRight,
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: FlatButton(
                      onPressed: _services[currentStep]["isArrived"] ||
                              currentStep != completed
                          ? null
                          : onStepContinue,
                      disabledColor: Color(0xFFA9B8D5),
                      disabledTextColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 45, right: 50, top: 11, bottom: 11),
                        child: Text(
                          currentStep == _services.length - 1
                              ? 'Finalizar viaje'
                              : 'Entregar al punto ${currentStep + 1}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      color: Color(0xFF3FC700),
                    ),
                  );
                },
                currentStep: currentStep,
                steps: List.generate(
                  _services.length,
                  (index) => Step(
                      title: Row(
                        children: <Widget>[
                          Text(
                            _services[index]["title"],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: index == completed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
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
                      content: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _services[index]["description"],
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )),
                      state: StepState.complete,
                      isActive: index <= completed),
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
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
