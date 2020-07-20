import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yimidelivery/takePictureScreen.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:yimidelivery/services/bussines/service_item.dart';

class AddService extends StatefulWidget {
  AddService({Key key, this.next, this.colonias}) : super(key: key);

  final List<Map> colonias;
  final num next;
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  TextEditingController controller = new TextEditingController();
  String colony,
      colonyCoords,
      phone = '',
      nombre = '',
      idColoia = '',
      imagePath;
  num _cost = 0.0;
  List<Map> colonias;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    colonias = widget.colonias;
  }

  void openCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    var path = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(
                camera: firstCamera,
              )),
    );
    print('Path => $path');
    setState(() {
      imagePath = path;
    });
  }

  bool isValidPhone() {
    return phone.length >= 10 && phone.length <= 14;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        height: MediaQuery.of(context).size.height - 78,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 20, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Pedido ${widget.next}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  RawMaterialButton(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Text(
                'Escribe el nombre de la colonia',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
              child: AutoCompleteTextField(
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  border: OutlineInputBorder(),
                  hintText: 'Colonia',
                  hintStyle: TextStyle(fontSize: 18),
                ),
                clearOnSubmit: false,
                controller: controller,
                style: new TextStyle(color: Colors.black, fontSize: 16.0),
                suggestions: colonias,
                itemBuilder: (context, item) {
                  return ListTile(
                    title: Text(item['nombre']),
                  );
                },
                key: key,
                itemFilter: (item, query) {
                  return item['nombre']
                      .toLowerCase()
                      .contains(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a['nombre']
                      .toLowerCase()
                      .compareTo(b['nombre'].toLowerCase());
                },
                itemSubmitted: (item) {
                  setState(() {
                    colony = item['nombre'];
                    colonyCoords = item["coordenadas"];
                    idColoia = item["id_colonia"];
                    _cost = item['costo'];
                    controller.text = colony;
                  });
                },
                textChanged: (text) {
                  colonias.forEach((item) {
                    if (text.toLowerCase() == item['nombre'].toLowerCase()) {
                      setState(() {
                        colony = item['nombre'];
                        colonyCoords = item["coordenadas"];
                        idColoia = item["id_colonia"];
                        _cost = item['costo'];
                        controller.text = colony;
                      });
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 180, left: 20, right: 20),
              child: Text(
                'Escribe el teléfono',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 210),
              child: Container(
                height: 70,
                child: TextField(
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    border: OutlineInputBorder(),
                    hintText: 'Teléfono',
                    hintStyle: TextStyle(fontSize: 18),
                  ),
                  onChanged: (text) {
                    setState(() {
                      phone = text;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 280, left: 20, right: 20),
              child: Text(
                'Nombre del cliente',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 310),
              child: Container(
                height: 50,
                child: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    border: OutlineInputBorder(),
                    hintText: 'Nombre',
                    hintStyle: TextStyle(fontSize: 18),
                  ),
                  onChanged: (text) {
                    setState(() {
                      nombre = text;
                    });
                  },
                ),
              ),
            ),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 380, left: 20, right: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: SizedBox.expand(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: imagePath == null
                          ? Color(0xFFFF5E20)
                          : Color(0xFF3FC700), //Color(0xFFA9B8D5),//
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.white,
                      textColor: Colors.white,
                      onPressed: openCamera,
                      child: Text(
                        imagePath == null
                            ? "Tomar fotografía"
                            : "Volver a tomar fotografía",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 450, left: 20, right: 20),
              child: Text(
                'Costo: \$ ${_cost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: SizedBox.expand(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: Color(0xFF3FC700), //Color(0xFFA9B8D5),//
                        disabledColor: Color(0xFFA9B8D5),
                        disabledTextColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: colony == null ||
                                !isValidPhone() ||
                                nombre.length == 0 ||
                                imagePath == null
                            ? null
                            : () {
                                Navigator.pop(context, {
                                  "title": 'Pedido ${widget.next}',
                                  "colony": colony,
                                  "coords": colonyCoords,
                                  "id_colonia": idColoia,
                                  "price": _cost,
                                  "customer_phone": phone,
                                  "folio": nombre,
                                  "image_path": imagePath,
                                  "key": ValueKey('value${widget.next}')
                                });
                              },
                        child: Text(
                          "Agregar pedido",
                          style: TextStyle(fontSize: 18),
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
      onWillPop: () async => true,
    );
  }
}
