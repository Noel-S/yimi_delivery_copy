import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:camera/camera.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:yimidelivery/custom_switch_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yimidelivery/image_preview.dart';
import 'package:yimidelivery/legal/legal.dart';
import 'package:yimidelivery/login/login.dart';
import 'package:yimidelivery/notifications.dart';
import 'package:yimidelivery/payment/payment.dart';
import 'package:yimidelivery/profile/profile.dart';
import 'package:yimidelivery/services/bussines/add_service.dart';
import 'package:yimidelivery/services/bussines/arrived_service.dart';
import 'package:yimidelivery/services/bussines/delivery_services.dart';
// import 'package:yimidelivery/services/bussines/arrived_service.dart';
import 'package:yimidelivery/services/bussines/incoming_service.dart'
    as Bussines;
import 'package:yimidelivery/services/bussines/services_list.dart';
import 'package:yimidelivery/services/customer/arriving_services.dart';
import 'package:yimidelivery/services/customer/delivering_services.dart';
import 'package:yimidelivery/services/customer/incoming_service.dart'
    as Customer;
// import 'package:http/http.dart' as http;
import 'package:yimidelivery/API.dart' as API;
import 'package:yimidelivery/takePictureScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getSesion().then((value) => runApp(MyApp(
        sesion: value,
      )));
}

Future<String> getSesion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.get("nombre");
}

class MyApp extends StatelessWidget {
  MyApp({this.sesion});
  final String sesion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yimi Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'LucidaSans',
      ),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => sesion == null ? Login() : MyHomePage(),
        '/profile': (context) => Profile(),
        '/payment': (context) => Payment(),
        '/legal': (context) => Legal(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String nombre,
      aPaterno,
      correo,
      telefono,
      foto = 'https://socialveo.co/frontend/assets/images/default-user.png';
  bool _location = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Database database;
  num notificationCount = 0, totalSemanal = 0, totalDia = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static AudioCache player = new AudioCache();
  static const sound = "audio/notification_sound.mp3";
  List<String> paths = List();

  _updateInfo(num result) {
    API.getPaymentByWeek().then((list) => list.forEach((element) {
          print(element['monto']);
          totalSemanal += element['monto'];
        }));

    API.getPaymentByDay(DateTime.now().toString().substring(0, 10)).then(
          (list) => list.forEach((element) {
            setState(() {
              totalDia += element['monto'];
            });
          }),
        );
  }

  void getData() async {
    String name, lName, email, phone, lastAction, photo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString("nombre");
    lName = prefs.getString("apellido");
    email = prefs.getString("correo");
    phone = prefs.getString("telefono");
    photo = prefs.getString("imagen_perfil");
    print('Photo => $photo');
    name != null
        ? setState(() {
            nombre = name;
            aPaterno = lName;
            correo = email;
            telefono = phone;
            foto = photo;
          })
        : setState(() {
            nombre = 'Usuario';
            aPaterno = 'Apellido';
            correo = 'usuario.apellido@correo.com';
            telefono = '5351146978';
            foto =
                'https://socialveo.co/frontend/assets/images/default-user.png';
          });

    lastAction = prefs.getString('lastAction');
    setState(() {
      _location = prefs.getBool('wasActive') == null
          ? false
          : prefs.getBool('wasActive');
    });

    if (lastAction == 'arrived_bussines') {
      String bussinesName = prefs.getString('bussinesName');
      String bussinesAddress = prefs.getString('bussinesAddress');
      String reference = prefs.getString('reference');
      String bussinesAddressURL = prefs.getString('bussinesAddressURL');
      String bussinesId = prefs.getString('bussinesId');
      String folio = prefs.getString('folio');
      String phone = prefs.getString('phone');

      showModalBottomSheet(
          context: context,
          enableDrag: false,
          isDismissible: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return ArrivedService(
              bussinessName: bussinesName,
              bussinesAddress: bussinesAddress,
              reference: reference,
              bussinesAddressURL: bussinesAddressURL,
              bussinesId: bussinesId,
              folio: folio,
              phone: phone,
              restored: true,
              parentAction: _updateInfo,
            );
          });
    } else if (lastAction == 'list') {
      //TODO: guardar la lista de pedidos y mandarla como parametro opcional.
      String folio = prefs.getString('folio');
      // List<Map> colonias = await database.rawQuery('SELECT * FROM Colony');
      List<String> colonies = prefs.getStringList('colonies');
      List<String> coords = prefs.getStringList('coords');
      List<String> ids = prefs.getStringList('phones');
      List<String> phones = prefs.getStringList('phones');
      List<String> prices = prefs.getStringList('prices');
      List<String> folios = prefs.getStringList('folios');
      List<String> images = prefs.getStringList('images');
      bool accept = prefs.getBool('aceptIsActive');
      String idNegocio = prefs.getString('id_negocio');
      print('Colonias => $colonies');
      print('Coordenadas => $coords');
      print('Telefonos => $ids');
      print('Folios => $folios');

      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ServiceList(
          idNegocio: idNegocio,
          folio: folio,
          colonies: colonies,
          coords: coords,
          ids: ids,
          phones: phones,
          prices: prices,
          folios: folios,
          images: images,
          aceptIsActive: accept,
          restored: true,
          parentAction: _updateInfo,
        ),
      );
    } else if (lastAction == 'adding') {
      print('Muy pronto.');
    } else if (lastAction == 'delivering_bussines') {
      String folio = prefs.getString('folio');

      List<String> colonies = prefs.getStringList('colonies');
      List<String> delivered = prefs.getStringList('weredelivered');

      int currentStep = prefs.getInt('currentStep');
      int completed = prefs.getInt('completed');

      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return DeliveryPedido(
            folio: folio,
            wereDelivered: delivered,
            colonies: colonies,
            currentStep: currentStep,
            completed: completed,
            restored: true,
            parentAction: _updateInfo,
          );
        },
      );
    } else if (lastAction == 'arrived_customer') {
      String customerName = prefs.getString('customername');
      String phone = prefs.getString('phone');
      String folio = prefs.getString('folio');
      List<Map> points = [];
      List<String> descriptions = prefs.getStringList('descriptions');
      List<String> coords = prefs.getStringList('coords');
      List<String> monts = prefs.getStringList('monts');
      int apagar = prefs.getInt('apagar');

      print('Descriptions => $descriptions');
      print('Coords => $coords');
      print('Monts => $monts');

      for (var i = 0; i < descriptions.length; i++) {
        points.add({
          "description": descriptions[i],
          "coords": coords[i],
          "mont": monts[i]
        });
      }

      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ArrivingServices(
            services: points,
            customerName: customerName,
            phone: phone,
            folio: folio,
            restored: true,
            parentAction: _updateInfo,
            apagar: apagar,
          );
        },
      );
    } else if (lastAction == 'delivering_customer') {
      String customerName = prefs.getString('customername');
      String phone = prefs.getString('phone');
      String folio = prefs.getString('folio');

      int currentStep = prefs.getInt('currentStep');
      int completed = prefs.getInt('completed');

      List<Map> points = [];
      List<String> descriptions = prefs.getStringList('descriptions');
      List<String> coords = prefs.getStringList('coords');
      List<String> monts = prefs.getStringList('monts');
      List<String> arrived = prefs.getStringList('arrived');
      int apagar = prefs.getInt('apagar');

      for (var i = 0; i < descriptions.length; i++) {
        points.add({
          "description": descriptions[i],
          "cords": coords[i],
          "mont": monts[i],
          "isArrived": arrived[i] == 'true',
          "key": ValueKey('value$i'),
        });
      }

      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return DeliveringServices(
            listaPedidos: points,
            customerName: customerName,
            phone: phone,
            folio: folio,
            currentStep: currentStep,
            completed: completed,
            restored: true,
            parentAction: _updateInfo,
            apagar: apagar,
          );
        },
      );
    }
  }

  void openIncommingServiceBussines(
    String bussinesName,
    String bussinesAddress,
    String reference,
    String serviceType,
    String tipoServicioID,
    String bussinesAddressURL,
    String bussinesId,
    int expirationTime,
    String dateTime,
    String ciudad,
    String folio,
    String phone,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnService', true);

    // print('Folio => $folio');
    // print(bussinesAddress);
    // print(reference);
    // print(bussinesAddressURL);
    // print(qrData);
    // print(expirationTime);
    // print(dateTime);
    // List<Map> colonias = await database.rawQuery('SELECT * FROM Colony');

    // getNotficationCount();
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Bussines.IncomingService(
          bussinesName: bussinesName,
          bussinesAddress: bussinesAddress,
          reference: reference,
          serviceType: serviceType,
          tipoServicioID: tipoServicioID,
          bussinesAddressURL: bussinesAddressURL,
          bussinesId: bussinesId,
          expirationTime: expirationTime,
          dateTime: dateTime,
          ciudad: ciudad,
          folio: folio,
          // colonias: colonias,
          phone: phone,
        );
      },
    );
  }

  void openIncommingServiceCustomer(
      String customerName,
      String reference,
      String serviceType,
      String addressURL,
      List<Map> points,
      int expirationTime,
      String dateTime,
      num monto,
      String telefono,
      String folio,
      String ciudad,
      String tipoServicio,
      int apagar) async {
    // print(cuatomerName);
    // print(customerAddress);
    // print(reference);
    // print(customerAddressURL);
    // print(points);
    // print(expirationTime);
    // print(dateTime);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnService', true);

    // getNotficationCount();
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Customer.IncomingService(
          customerName: customerName,
          reference: reference,
          serviceType: serviceType,
          addressURL: addressURL,
          points: points,
          expirationTime: expirationTime,
          dateTime: dateTime,
          montoPagar: monto,
          folio: folio,
          ciudad: ciudad,
          tipoServicio: tipoServicio,
          telefono: telefono,
          apagar: apagar,
          parentAction: _updateInfo,
        );
      },
    );
  }

  void showPrueba() async {
    // List<Map> colonias =
    //     await API.getPrecioColoniaApp('74ea35a2-c7ab-11ea-beb3-7845c4bca6ea');

    // colonias.forEach((element) => print(element));

    // if (paths.length < 2) {
    // final cameras = await availableCameras();
    // final firstCamera = cameras.first;
    // var path = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TakePictureScreen(
    //       camera: firstCamera,
    //     ),
    //   ),
    // );
    //   if (path != null) {
    //     setState(() {
    //       paths.add(path);
    //     });
    //   }
    // } else {
    //   API.cobrarNegocio(
    //     '555',
    //     '[15, 15]',
    //     '["19.7777, -113.95555", "19.7777, -113.95555"]',
    //     '[3214567890, 3214567890]',
    //     '[123456, 123456]',
    //     '["Salagua", "Salagua"]',
    //     '[735d870a-badd-11ea-aa17-a4badb101a12, 735d870a-badd-11ea-aa17-a4badb101a12]',
    //     paths,
    //   );
    // }

    // print('Path => $path');

    // if (path != null) {
    //   API.cobrarNegocio(
    //       '555',
    //       '[15]',
    //       '["19.7777, -113.95555"]',
    //       '[3214567890]',
    //       '[123456]',
    //       '["Salagua"]',
    //       '[735d870a-badd-11ea-aa17-a4badb101a12]',
    //       [path]);
    // }

    // List<Map> puntos = [];
    // for (var i = 0; i < 3; i++) {
    //   puntos.add({
    //     "description": 'Descripción ${i + 1}',
    //     "coords": "19.125478, -113.225468",
    //     "mont": 15.4
    //   });
    // }
    // openIncommingServiceCustomer(
    //   "bussines_name",
    //   "reference",
    //   "service_type",
    //   "bussines_address_url",
    //   puntos, // List<Map>(),//
    //   500,
    //   "2020-07-16",
    //   180,
    //   "1234567890",
    //   "folio",
    //   "ciudad",
    //   "tipoServicio",
    //   1,
    // );

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('lastAction', null);
    // prefs.setString('folio', null);
    // prefs.setStringList('colonies', null);
    // prefs.setStringList('coords', null);
    // prefs.setStringList('phones', null);
    // prefs.setStringList('phones', null);
    // prefs.setStringList('prices', null);
    // prefs.setStringList('folios', null);
    // prefs.setBool('aceptIsActive', null);

    // RegExp re = RegExp(r'(-{0,1}\d+[.]\d+),\s(-{0,1}\d+[.]\d+)');
    // String p = '19.244356, -103.742708,19.244356, -103.741111';
    // re.allMatches(p).forEach((element) { print(element.group(0)); });
    // List<Map> colonias = await database.rawQuery('SELECT * FROM Colony');
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceList(
        idNegocio: '74ea35a2-c7ab-11ea-beb3-7845c4bca6ea',
        folio: '454654654',
      ),
    );

    // List<Map> notifications = await database.rawQuery('SELECT * FROM Colony');
    // var data = await showModalBottomSheet(
    //   context: context,
    //   enableDrag: false,
    //   isDismissible: true,
    //   isScrollControlled: true,
    //   builder: (BuildContext context) {
    //     return AddService(
    //       next: 1,
    //       colonias: notifications,
    //     );
    //   },
    // );

    // print(data);

    // showModalBottomSheet(
    //   context: context,
    //   enableDrag: false,
    //   isDismissible: true,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (BuildContext context) {
    //     return ArrivedService(
    //       bussinessName: 'bussinesName',
    //       bussinesAddress: 'bussinesAddress',
    //       reference: 'reference',
    //       bussinesAddressURL: 'bussinesAddressURL',
    //       bussinesId: 'bussinesId',
    //       colonias: [],
    //       folio: 'folio',
    //       phone: '14253453',
    //       restored: true,
    //     );
    //   },
    // );

    // Timer(Duration(seconds: 10), () => Navigator.popUntil(context, ModalRoute.withName("/")));
    // timer.cancel();

    // showModalBottomSheet(
    //   context: context,
    //   enableDrag: false,
    //   isDismissible: false,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (BuildContext context) {
    //     return DeliveryPedido(
    //       pedidos: [],
    //       folio: '12345',
    //       colonies: [],
    //       wereDelivered: [],
    //       currentStep: 0,
    //       completed: 0,
    //       restored: false,
    //     );
    //   },
    // );

    // await showDialog<String>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return CupertinoAlertDialog(
    //       title: Text('El servicio fué cancelado'),
    //       content: Column(
    //         children: <Widget>[
    //           Padding(
    //             padding: const EdgeInsets.only(top: 15, bottom: 0),
    //             child: Text(
    //               "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    //             ),
    //           ),
    //           // Padding(
    //           //   padding: const EdgeInsets.only(top: 15),
    //           //   child: Icon(
    //           //     Icons.favorite,
    //           //     size: 48 ,
    //           //     color: Colors.red,
    //           //   ),
    //           // ),
    //           Container(
    //               width: 150,
    //               height: 100,
    //               child: FlareActor(
    //                 'assets/animations/broken.flr',
    //                 animation: 'break',
    //                 fit: BoxFit.contain,
    //               ))
    //         ],
    //       ),
    //       actions: <Widget>[
    //         CupertinoDialogAction(child: Text('Aceptar'), isDefaultAction: true, onPressed: () => Navigator.pop(context),)
    //       ],
    //     );
    //   },
    // );

    // List<Map> colonias = await database.rawQuery('SELECT * FROM Colony');
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  @override
  void dispose() {
    if (!_location) {
      _stopService().then((value) => super.dispose());
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('isOnService', false));
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('lastAction', null));
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('wasActive', false));
    initializeNotifications();
    startNotificationsDB();
    API.getPaymentByWeek().then((list) => list.forEach((element) {
          print(element['monto']);
          totalSemanal += element['monto'];
        }));

    API.getPaymentByDay(DateTime.now().toString().substring(0, 10)).then(
          (list) => list.forEach((element) {
            setState(() {
              totalDia += element['monto'];
            });
          }),
        );
  }

  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_stat_name');
    var initializeIOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings);
  }

  Future showSingleNotification(int id, String message, String subtext,
      {String sound}) async {
    var androidChannel = AndroidNotificationDetails(
      'yimi_delivery',
      'yimi_delivery',
      'yimi_delivery_description',
      importance: Importance.High,
      priority: Priority.Max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    localNotificationsPlugin.show(id, message, subtext, platformChannel,
        payload: 'Default_sound');
  }

  void _startService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('wasActive', true);

    setState(() {
      _location = true;
    });

    if (!await API.registerUser()) {
      setState(() {
        _location = false;
      });
      print('Error al registrar usuario para recivir servicios.');
    }
  }

  Future<void> _stopService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int statusRepartidor = 0;
    bool isOnService = prefs.getBool('isOnService') == null
        ? false
        : prefs.getBool('isOnService');
    if (!isOnService) {
      setState(() {
        _location = false;
      });
      prefs.setBool('wasActive', false);
      prefs.setInt("status_repartidor", statusRepartidor);

      API.logout();

      if (Platform.isAndroid) {
        var methodChanel = MethodChannel("com.kio.yimidelivery/location");
        String data = await methodChanel.invokeMethod("stopServiceLocation");
        debugPrint(data);
      }
    }
  }

  void startNotificationsDB() async {
    // database = await openDatabase(
    //   'yimidelivery_notifications',
    //   version: 1,
    //   onCreate: (Database db, int version) async {
    //     // When creating the db, create the table
    //     await db.execute(
    //         'CREATE TABLE Notification (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, body TEXT)');
    //   },
    //   onOpen: (db) async {
    //     await db.execute('DROP TABLE IF EXISTS Colony');
    //     await db.execute(
    //         'CREATE TABLE Colony (id_colonia TEXT, nombre TEXT, costo REAL, coordenadas TEXT, tiempo_holgura REAL)');
    //     List<Map> colonies = await API.getColonies();
    //     colonies.forEach((element) async {
    //       // print(element);
    //       await db.transaction((txn) async {
    //         int affected = await txn.rawInsert(
    //             'INSERT INTO Colony(id_colonia, nombre, costo, coordenadas, tiempo_holgura) VALUES("${element['id_colonia']}", "${element['nombre']}", ${element['costo']}, "${element['coordenadas']}", "${element['tiempo_holgura']}")');
    //         print('Colonies inserted: $affected');
    //       });
    //     });
    //   },
    // );

    // getNotficationCount();

    getData();

    startFirebase();
  }

  void startFirebase() {
    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          player.play(sound);
          // print('onMessage: $message');
          printWrapped('onMessage: $message');

          await showSingleNotification(
            1,
            message["data"]["title"],
            message["data"]["body"],
          );
          String action = message["data"]["action"];
          if (action == "service_canceled") {
            Navigator.popUntil(context, ModalRoute.withName("/"));
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('lastAction', null);
            prefs.setBool('isOnService', false);
            await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text('El servicio fué cancelado'),
                  content: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 0),
                        child: Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        ),
                      ),
                      Container(
                          width: 150,
                          height: 100,
                          child: FlareActor(
                            'assets/animations/broken.flr',
                            animation: 'break',
                            fit: BoxFit.contain,
                          ))
                    ],
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('Aceptar'),
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              },
            );
          }
          if (action == "new_delivery_bussines") {
            // insertNotification(
            //   message["notification"]["title"],
            //   message["notification"]["body"],
            // );
            openIncommingServiceBussines(
              message["data"]["bussines_name"],
              message["data"]["bussines_address"],
              message["data"]["reference"],
              message["data"]["service_type"],
              message["data"]["tipoServicio"],
              message["data"]["bussines_address_url"],
              message["data"]["id_bussines"],
              int.parse(message["data"]["expiration_time"]),
              message["data"]["date_time"],
              message["data"]["ciudad"],
              message["data"]["folio"],
              message["data"]["phone_bussines"],
              //Monto
            );
          } else if (action == "new_delivery_customer") {
            // insertNotification(
            //   message["data"]["title"],
            //   message["data"]["body"],
            // );
            RegExp re = RegExp(r'(-{0,1}\d+[.]\d+),\s(-{0,1}\d+[.]\d+)');
            List<RegExpMatch> coordenadas = re
                .allMatches(
                    message["data"]["coordenadasArray"].replaceAll('"', ''))
                .toList();
            List<dynamic> descripciones = message["data"]["descripcionArray"]
                .replaceAll('"', '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(',');
            List<dynamic> montosServicio = message["data"]["montoServicio"]
                .replaceAll(' ', '')
                .replaceAll('"', '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(',');
            // TODO: Si es servicio son completos si no es uno menos
            // TODO: A pagar (apagar)
            // TODO: bandera para saber si trae un servicio
            // List<dynamic> puntosArray = jsonDecode(message["data"]["puntosArray"]);
            print(montosServicio);
            print(descripciones);

            List<Map> pointsMap = List();
            for (var i = 0; i < coordenadas.length; i++) {
              print('Coordenada ${i + 1} ${coordenadas[i].group(0)}');
              pointsMap.add({
                "description": descripciones[i],
                "coords": coordenadas[i].group(0),
                "mont": message["data"]["banderaServicio"] == 'true' &&
                        i == coordenadas.length - 1
                    ? 0
                    : num.parse(montosServicio[i])
              });
            }

            // print('Nombre => ${message["data"]["bussines_name"]}');
            // print('Referencia => ${message["data"]["reference"]}');
            // print('Tipo servicio => ${message["data"]["service_type"]}');
            // print('Maps URL => ${message["data"]["bussines_address_url"]}');
            // print('Telefono cliente => ${message["data"]["phone_customer"]}');
            // print('Monto a pagar => ${message["data"]["montoPagar"]}');
            // print('Folio => ${message["data"]["folio"]}');
            // print('Ciudad => ${message["data"]["ciudad"]}');
            // print('Tipo servicio (str) => ${message["data"]["tipoServicio"]}');
            // print('A pagar => ${message["data"]["apagar"]}');

            openIncommingServiceCustomer(
              message["data"]["bussines_name"],
              message["data"]["reference"],
              message["data"]["service_type"],
              message["data"]["bussines_address_url"],
              pointsMap, // List<Map>(),//
              int.parse(message["data"]["expiration_time"]),
              message["data"]["date_time"],
              num.parse(message["data"]["montoPagar"]),
              message["data"]["phone_customer"],
              message["data"]["folio"],
              message["data"]["ciudad"],
              message["data"]["tipoServicio"],
              int.parse(message["data"]["apagar"]),
            );
          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: "); //$message
          String action = message["data"]["action"];
          if (action != null) {
            if (action == "new_delivery_bussines") {
              // insertNotification(
              //   message["data"]["title"],
              //   message["data"]["body"],
              // ); //Fecha y hora y tipo de notificación(Servicio a cliente o negocio o cualquier otro).
              openIncommingServiceBussines(
                message["data"]["bussines_name"],
                message["data"]["bussines_address"],
                message["data"]["reference"],
                message["data"]["service_type"],
                message["data"]["tipoServicio"],
                message["data"]["bussines_address_url"],
                message["data"]["id_bussines"],
                int.parse(message["data"]["expiration_time"]),
                message["data"]["date_time"],
                message["data"]["ciudad"],
                message["data"]["folio"],
                message["data"]["phone_bussines"],
              );
            } else if (action == "new_delivery_customer") {
              // insertNotification(
              //   message["data"]["title"],
              //   message["data"]["body"],
              // );
              List<dynamic> points = jsonDecode(message["data"]["points"]);
              List<Map> pointsMap = List();
              points.forEach((element) {
                pointsMap.add(element);
              });
              openIncommingServiceCustomer(
                message["data"]["bussines_name"],
                message["data"]["reference"],
                message["data"]["service_type"],
                message["data"]["bussines_address_url"],
                pointsMap,
                int.parse(message["data"]["expiration_time"]),
                message["data"]["date_time"],
                num.parse(message["data"]["montoPagar"]),
                message["data"]["phone_customer"],
                message["data"]["folio"],
                message["data"]["ciudad"],
                message["data"]["tipoServicio"],
                message["data"]["apagar"],
              );
            }
          }
        },
      );
    } catch (e) {
      print(e);
    }

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print(token);
    });
  }

  void getNotficationCount() async {
    num count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM Notification'));
    print(count);
    setState(() {
      notificationCount = count;
    });
  }

  void insertNotification(String title, String body) async {
    await database.transaction((txn) async {
      int affected = await txn.rawInsert(
          'INSERT INTO Notification(title, body) VALUES("$title", "$body")');
      print('Inserted: $affected');
      setState(() {
        notificationCount += affected;
      });
    });
  }

  void deleteNotification(num id) async {
    print('Deleted ID => $id');
    Batch batch = database.batch();
    batch.delete('Notification', where: 'id = ?', whereArgs: [id]);
    await batch.commit(noResult: true);
    setState(() {
      notificationCount -= 1;
    });
  }

  void openNotifications() async {
    List<Map> notifications =
        await database.rawQuery('SELECT * FROM Notification');
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Notifications(
          notifications: notifications,
          delete: deleteNotification,
        );
      },
    );
  }

  void logOut() async {
    API.logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("nombre", null);
    await prefs.setString("apellido", null);
    await prefs.setString("correo", null);
    await prefs.setString("telefono", null);
    await prefs.setString("token", null);
    await prefs.setString("id_usuario", null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
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
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF5E20),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        actions: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.only(right: 10),
          //   child: IconButton(
          //     onPressed: openNotifications,
          //     icon: notificationCount == 0
          //         ? Icon(
          //             Icons.notifications,
          //             size: 24,
          //           )
          //         : Image.asset(
          //             'assets/images/notifications_white.png',
          //             width: 24,
          //             height: 24,
          //           ),
          //   ),
          // ),
          Center(
            child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Material(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.transparent,
                  child: Container(
                    height: 24,
                    width: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: GestureDetector(
                        onTap: () async {
                          if (await Geolocator().isLocationServiceEnabled()) {
                            Geolocator().checkGeolocationPermissionStatus(
                                locationPermission:
                                    GeolocationPermission.locationAlways);
                            print(_location);
                            _location ? _stopService() : _startService();
                          } else {
                            Toast.show(
                                "Para comenzar, activa la ubicación", context,
                                duration: 4);
                          }
                        },
                        child: CustomSwitchButton(
                          backgroundColor:
                              _location ? Colors.lightGreen : Color(0xFFD92222),
                          unCheckedColor: Colors.white,
                          checkedColor: Colors.white,
                          animationDuration: Duration(milliseconds: 250),
                          checked: _location,
                          buttonWidth: 50,
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
            child: Stack(
          children: <Widget>[
            Align(
              alignment:
                  _location ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 40),
                child: Image.asset(
                  _location
                      ? "assets/images/personaje_buscando.png"
                      : "assets/images/personaje_servicios.png",
                  height: MediaQuery.of(context).size.height * 0.65,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Text(
                  _location
                      ? "Buscando servicios..."
                      : 'Bienvenido! Conéctate...',
                  style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFFFF5E20),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: FlatButton(
            //     onPressed: () {
            //       // player.play(sound);
            //       showPrueba();
            //       // Toast.show('Puedes agregar hasta 10 pedidos.', context, duration: 4);

            //       // openIncommingServiceBussines(
            //       //   "KUKARA EXPRESS", //bussines_name
            //       //   "AV. 5 DE MAYO NO 1100-A CENTRO TUXTEPEC 68300", //bussines_address
            //       //   "Cliente pide un repartidor y le asigna las tareas de reparto que entren en los requerimientos de tamaño de caja y el peso.",//reference
            //       //   "Variado",//service_type
            //       //   "1",//tipoServicio
            //       //   "https://www.google.com.mx/maps/place/Kukara+Express/@19.2693944,-103.7501276,17z/data=!3m1!4b1!4m5!3m4!1s0x842545683c348ef5:0x25448d2e7e1540a5!8m2!3d19.2693944!4d-103.7479389",
            //       //   "https://www.google.com/",//id_bussines
            //       //   10000,//expiration_time
            //       //   "2020-06-30 15:28:15 UTC", //date_time
            //       //   "p09809ohi98Y89g",// Ciudad
            //       //   "123", // Folio
            //       //   "5211234567890", //phone_bussines
            //       // );

            //       // openIncommingServiceCustomer(
            //       //   "ALEJANDRA",
            //       //   "Referencia",
            //       //   "Variado",
            //       //   "https://www.google.com.mx/maps/",
            //       //   [
            //       //     {
            //       //       "address": "AV. 5 de Mayo no. 1100-A Centro Tuxtepec 68300",
            //       //       "reference": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
            //       //       "description": "Fusce lacinia nunc sed ligula faucibus cursus.",
            //       //     },
            //       //     {
            //       //       "address": "AV. 5 de Mayo no. 1100-A Centro Tuxtepec 68300",
            //       //       "reference": "Vestibulum velit odio, auctor in ligula et, viverra facilisis sapien.",
            //       //       "address_url": "https://www.google.com.mx/maps/",
            //       //       "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            //       //     },
            //       //     {
            //       //       "address": "AV. 5 de Mayo no. 1100-A Centro Tuxtepec 68300",
            //       //       "reference": "Vestibulum velit odio, auctor in ligula et, viverra facilisis sapien.",
            //       //       "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            //       //     }
            //       //   ],
            //       //   500,
            //       //   "2020-06-30 15:28:15 UTC",
            //       // );

            //       // openIncommingServiceCustomer(
            //       //   "NOMBRE DEL CLIENTE",
            //       //   "Referencia",
            //       //   "Variado",
            //       //   "bussines_address_url",
            //       //   [
            //       //     {
            //       //       "description": 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            //       //       "coords": '123.123123, 134.423841',
            //       //       "mont": 30.0
            //       //     },
            //       //     {
            //       //       "description": 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            //       //       "coords": '123.123123, 134.423841',
            //       //       "mont": 30.0
            //       //     },
            //       //     {
            //       //       "description": 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            //       //       "coords": '123.123123, 134.423841',
            //       //       "mont": 30.0
            //       //     }
            //       //   ], // List<Map>(),//
            //       //   10,
            //       //   "date_time",
            //       //   500,
            //       //   "1234567890",
            //       //   "123",
            //       //   "klhsfasoiha",
            //       //   "dasdasdasdasdasdasdasd"
            //       // );
            //     },
            //     child: Text('Prueba'),
            //   ),
            // )
          ],
        )),
      ),
      drawer: Drawer(
          child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Image.asset(
                        //   "assets/images/user.png",
                        //   width: 64,
                        //   height: 64,
                        // ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                            foto,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/user.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
                              );
                            },
                            // loadingBuilder: (context, child, loadingProgress) {
                            //   return CircularProgressIndicator();
                            // },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Hola',
                                style: TextStyle(
                                  color: Color(0xFFFF5E20),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$nombre $aPaterno',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Text('Tel: $phone', style: TextStyle(fontSize: 12),),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '$correo',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 185, left: 5, right: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Color(0xFFFF5E20),
                ),
                height: 6,
              ),
            ),
            ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.only(top: 200),
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Historial de pagos',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/payment');
                  },
                ),
                ListTile(
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    logOut();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 220.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 95,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.fromBorderSide(
                          BorderSide(color: Color(0xFFFF5E20), width: 3)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 10),
                        child: Text(
                          '\$$totalSemanal',
                          style: TextStyle(
                              color: Color(0xFFFF5E20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Ganancia semanal',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 95,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.fromBorderSide(
                          BorderSide(color: Color(0xFFFF5E20), width: 3)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 10),
                        child: Text(
                          '\$$totalDia',
                          style: TextStyle(
                              color: Color(0xFFFF5E20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Ganancia del día',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Yimi Delivery v1.0.0',
                      textAlign: TextAlign.center,
                    ),
                    FlatButton(
                      child: Text(
                        'Términos y condiciones',
                        style: TextStyle(color: Color(0xFFFF5E20)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/legal');
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
  //[ ] TODO: Actualizar ganancia al finalizar viajes.
  //[x] TODO: Número telefono 10 digitos maximo
  //[x] TODO: Botón burbuja más grande
  //[x] TODO: Centrar precios de pedidos
  //[x] TODO: Precios a dos decimales
  //[x] TODO: Cambiar numero siempre consecutivo al arrastrar pedidos
  //[x] TODO: Tomar fotografía en agregar pedido
  //[~] TODO: Agregar array de imagenes para mandar al cobrar servicio
  //[~] TODO: Entregar pedido y finalizar agregar el número de pedido en API (numeroPedido)
  //[x] TODO: Cancelar servicio notificación
  //[x] TODO: Cambiar startsWith a contains para buscar colonias
  //[x] TODO: Preview fotografía tomada
  //[x] TODO: Cambiar switch inmediatamente
  //[x] TODO: Cerrar recordatiorio al presionar cualquier lugar en ArrivedService

}
