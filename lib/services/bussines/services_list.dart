import 'dart:convert';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/services/bussines/service_item.dart';
import 'package:yimidelivery/services/bussines/add_service.dart';
import 'package:yimidelivery/services/bussines/delivery_services.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/API.dart' as API;

class ServiceList extends StatefulWidget {
  ServiceList({
    Key key,
    this.folio,
    this.idNegocio,
    this.colonies,
    this.coords,
    this.ids,
    this.phones,
    this.prices,
    this.folios,
    this.images,
    this.aceptIsActive,
    this.restored,
    this.add,
    this.parentAction,
  }) : super(key: key);

  final String folio, idNegocio;
  final List<String> colonies, coords, ids, phones, prices, folios, images;
  final bool aceptIsActive, restored, add;
  final ValueChanged<num> parentAction;

  @override
  _ServiceListState createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  bool aceptIsActive = false, restored, add;
  num _total = 0.0;
  List<ServiceItem> services = [];
  List<Map> colonias;

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', 'list');

    prefs.setString('folio', widget.folio);
    prefs.setString('id_negocio', widget.idNegocio);

    List<String> colonies = [];
    List<String> coords = [];
    List<String> ids = [];
    List<String> phones = [];
    List<String> prices = [];
    List<String> folios = [];
    List<String> images = [];
    setState(() {
      if (restored) {
        colonies = widget.colonies;
        coords = widget.coords;
        ids = widget.ids;
        phones = widget.phones;
        prices = widget.prices;
        folios = widget.folios;
        images = widget.images;
        for (var i = 0; i < colonies.length; i++) {
          var key = ValueKey('value${(i + 1)}');
          _total += num.parse(widget.prices[i] == null ? 0 : widget.prices[i]);

          services.add(ServiceItem(
            key: key,
            title: 'Pedido ${(i + 1)}',
            colony: colonies[i],
            colonyCoords: coords[i],
            idColonia: ids[i],
            customerPhone: phones[i],
            price: prices[i],
            folio: folios[i],
            imagePath: images[i],
            action: () {
              setState(() {
                services.removeWhere((element) => element.key == key);
                _total -= num.parse(widget.prices[i]);
                if (services.length == 0) {
                  aceptIsActive = false;
                }
              });
            },
          ));
        }
        aceptIsActive = widget.aceptIsActive;
        restored = false;
        if (add) {
          print('Abrir modal agregar pedido linea 91');
          add = false;
        }
      } else {
        for (var i = 0; i < services.length; i++) {
          print(services[i].key);
          colonies.add(services[i].colony);
          coords.add(services[i].colonyCoords);
          ids.add(services[i].idColonia);
          phones.add(services[i].customerPhone);
          prices.add(services[i].price);
          folios.add(services[i].folio);
          images.add(services[i].imagePath);
        }
      }
      prefs.setStringList('colonies', colonies);
      prefs.setStringList('coords', coords);
      prefs.setStringList('phones', ids);
      prefs.setStringList('phones', phones);
      prefs.setStringList('prices', prices);
      prefs.setStringList('folios', folios);
      prefs.setStringList('images', images);
      prefs.setBool('aceptIsActive', aceptIsActive);
    });
  }

  void leave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastAction', null);
    prefs.setString('folio', null);
    prefs.setStringList('colonies', null);
    prefs.setStringList('coords', null);
    prefs.setStringList('phones', null);
    prefs.setStringList('phones', null);
    prefs.setStringList('prices', null);
    prefs.setStringList('folios', null);
    prefs.setString('id_negocio', null);
    prefs.setBool('aceptIsActive', null);
  }

  @override
  void initState() {
    super.initState();
    restored = widget.restored == true;
    add = widget.add == true;
    API
        .getPrecioColoniaApp(widget.idNegocio)
        .then((value) => setState(() => colonias = value));
    setData();
  }

  void _updateServices(int oldIndex, int newIndex) {
    if (newIndex >= services.length) {
      newIndex -= 1;
    }
    final ServiceItem item = services.removeAt(oldIndex);
    // item.changeTitle = 'Pedido ${newIndex+1}';
    services.insert(newIndex, item);
    for (var i = 0; i < services.length; i++) {
      services[i].title = 'Pedido ${i + 1}';
    }
  }

  abrirListaPedidosColonia() async {
    var data = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddService(
          next: services.length + 1,
          colonias: colonias,
        );
      },
    );
    print(data);
    if (data != null) {
      setState(
        () {
          services.add(ServiceItem(
            key: data["key"],
            title: data["title"],
            colony: data["colony"],
            colonyCoords: data["coords"],
            idColonia: data['id_colonia'],
            customerPhone: data["customer_phone"],
            price:
                '${data["price"] == null ? 0.toStringAsFixed(2) : data["price"].toStringAsFixed(2)}',
            folio: data['folio'],
            imagePath: data['image_path'],
            action: () {
              setState(() {
                services.removeWhere((element) => element.key == data["key"]);
                _total -= data["price"] == null ? 0 : data["price"];
                if (services.length == 0) {
                  aceptIsActive = false;
                } else {
                  for (var i = 0; i < services.length; i++) {
                    services[i].title = 'Pedido ${i + 1}';
                  }
                }
              });
            },
          ));
          _total += data["price"] == null ? 0 : data["price"];
          setData();
        },
      );
    }
  }

  abrirListaPedidosDelivery() {
    leave();
    String nombres = '';
    services.forEach((element) {
      nombres += '${element.folio},';
    });
    // String nombresArray = jsonEncode(folios);
    nombres = nombres.substring(0, nombres.length - 1);
    API.iniciarServicioMandadoNegocio(widget.folio, services.length, nombres);

    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DeliveryPedido(
          pedidos: services,
          folio: widget.folio,
          parentAction: widget.parentAction,
        );
      },
    );
  }

  cobrar() {
    print('Cobrar');
    List<String> precios = [],
        colonias = [],
        telefonos = [],
        folios = [],
        idsColonias = [],
        nombresColonias = [],
        images = [];

    services.forEach((element) {
      precios.add(element.price);
      colonias.add(element.colonyCoords);
      telefonos.add(element.customerPhone);
      folios.add(element.folio);
      idsColonias.add(element.idColonia);
      nombresColonias.add(element.colony);
      images.add(element.imagePath);
    });

    String costosArray = jsonEncode(precios);
    String coloniasArray = jsonEncode(colonias);
    String nombresColoniasArray = jsonEncode(nombresColonias);
    String idsColoniasArray = jsonEncode(idsColonias);
    String telefonosArray = jsonEncode(telefonos);
    String nombresArray = jsonEncode(folios);
    // print(costosArray.replaceAll('"', '').replaceAll('\$ ', ''));
    // print(coloniasArray);
    // print(telefonosArray.replaceAll('"', ''));

    API.cobrarNegocio(
        widget.folio, //Folio
        costosArray.replaceAll('"', '').replaceAll('\$ ', ''), //costosArray
        coloniasArray, //coloniasArray
        nombresColoniasArray, //.replaceAll('"', ''), //nombresColoniasArray
        idsColoniasArray.replaceAll('"', ''), //idsColoniasArray
        telefonosArray.replaceAll('"', ''), //telefonosArray
        nombresArray, //.replaceAll('"', ''), //foliosArray
        images);

    setState(() {
      aceptIsActive = true;
    });
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
                padding: EdgeInsets.only(top: 28),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  color: Colors.white,
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      Material(
                        elevation: 4,
                        color: Colors.white,
                        child: Container(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18, left: 20),
                            child: Text(
                              'Pedidos: ${services.length}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 58, bottom: 155),
                          child: ReorderableListView(
                              padding: EdgeInsets.zero,
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  _updateServices(oldIndex, newIndex);
                                });
                              },
                              children: services),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 125, left: 20),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Por cobrar:',
                                style: TextStyle(fontSize: 20),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  '\$ ${_total.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 73, left: 20, right: 20),
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
                                onPressed: services.length == 0 || aceptIsActive
                                    ? null
                                    : cobrar,
                                // onPressed: cobrar,
                                child: Text(
                                  "Cobrado",
                                  style: TextStyle(fontSize: 18),
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
                                disabledColor: Color(0xFFA9B8D5),
                                disabledTextColor: Colors.white,
                                textColor: Colors.white,
                                onPressed: aceptIsActive
                                    ? abrirListaPedidosDelivery
                                    : null,
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
                      onPressed: aceptIsActive
                          ? null
                          : () {
                              if (services.length <= 10) {
                                abrirListaPedidosColonia();
                              } else {
                                Toast.show(
                                    'Puedes agregar hasta 10 pedidos.', context,
                                    duration: 4);
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
                              color: Color(0xFFEC6A2C)),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
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
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
