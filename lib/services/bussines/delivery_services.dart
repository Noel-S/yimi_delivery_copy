// import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/bussines/service_item.dart';
import 'package:yimidelivery/API.dart' as API;

class DeliveryPedido extends StatefulWidget {
  DeliveryPedido({
    Key key,
    this.pedidos,
    this.folio,
    this.listaPedidos,
    this.colonies,
    this.wereDelivered,
    this.currentStep,
    this.completed,
    this.restored,
    this.parentAction,
  }) : super(key: key);
  final List<ServiceItem> pedidos;
  final String folio;
  final List<Map> listaPedidos;
  final List<String> colonies, wereDelivered;
  final int currentStep, completed;
  final bool restored;
  final ValueChanged<num> parentAction;

  _DeliveryPedidoState createState() => _DeliveryPedidoState();
}

class _DeliveryPedidoState extends State<DeliveryPedido> {
  List<Map> _pedidos;
  bool restored;
  num currentStep = 0;
  num completed = 0;

  next() {
    if (currentStep != _pedidos.length - 1) {
      API.entregaServicioNegocio(widget.folio, completed);
      goToStep(currentStep + 1);
      setState(() {
        completed++;
      });
      setData();
    } else {
      leave();
      API.finalizarPedidoNegocio(widget.folio, completed);
      print('Viaje finalizado');
      Navigator.pop(context);
    }
  }

  goToStep(num step) {
    setState(() {
      currentStep = step;
    });
  }

  @override
  void initState() {
    super.initState();
    restored = widget.restored == true;
    _pedidos = List<Map>();
    if (!restored) {
      widget.pedidos.forEach((element) {
        _pedidos.add({
          "title": element.title,
          "colony": element.colony,
          "isDelivered": false,
          "key": element.key
        });
      });
    }
    setData();
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', 'delivering_bussines');

    List<String> colonies = [];
    List<String> wereDelivered = [];

    setState(() {
      if (restored) {
        colonies = widget.colonies;
        wereDelivered = widget.wereDelivered;
        currentStep = widget.currentStep;
        completed = widget.completed;
        print('Colonies => $colonies');
        print('WereDelivered => $wereDelivered');
        print('currentStep => $currentStep');
        print('completed => $completed');

        for (var i = 0; i < colonies.length; i++) {
          _pedidos.add({
            "title": "Pedido ${(i + 1)}",
            "colony": colonies[i],
            "isDelivered": wereDelivered[i] == 'true',
            "key": ValueKey('value$i')
          });
        }
        restored = false;
      } else {
        _pedidos.forEach((element) {
          colonies.add(element['colony']);
          wereDelivered.add('${element['isDelivered']}');
        });
      }
      prefs.setString('folio', widget.folio);
      prefs.setStringList('colonies', colonies);
      prefs.setStringList('weredelivered', wereDelivered);
      prefs.setInt('currentStep', currentStep);
      prefs.setInt('completed', completed);
    });
  }

  void leave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', null);
    prefs.setStringList('colonies', null);
    prefs.setStringList('weredelivered', null);
    prefs.setInt('currentStep', null);
    prefs.setInt('completed', null);
    prefs.setBool('isOnService', false);

    // widget.parentAction(1);
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
                        'Pedidos: ${_pedidos.length}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: FloatingActionButton(
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
                          child: Icon(Icons.headset_mic),
                          mini: true,
                        ),
                      ),
                    ],
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
                      onPressed: _pedidos[currentStep]["isDelivered"] ||
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
                            left: 50, right: 50, top: 11, bottom: 11),
                        child: Text(
                          currentStep == _pedidos.length - 1
                              ? 'Finalizar viaje'
                              : 'Entregado',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      color: Color(0xFF3FC700),
                    ),
                  );
                },
                currentStep: currentStep,
                steps: List.generate(
                  _pedidos.length,
                  (index) => Step(
                      title: Text(
                        _pedidos[index]["title"],
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: index == completed
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      content: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            _pedidos[index]["colony"],
                            style: TextStyle(fontSize: 16),
                          )),
                      state: StepState.complete,
                      isActive: index <= completed),
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
