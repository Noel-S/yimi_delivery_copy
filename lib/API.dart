import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_id/device_id.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String Address = "yimi2.ddns.net";
String monitoreoServerAddress = "http://$Address:3000/monitoreo";
String usuariosServerAddress = "http://$Address:3001/users";

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

/// Login del usuario
Future<bool> login(String email, String password) async {
  print(email);
  print(password);
  var response = await http.post(
    '$usuariosServerAddress/loginRepartidor',
    headers: {"Accept": "application/json"},
    body: {
      "usuario": email.replaceAll(' ', ''),
      "contrasena": password,
    },
  );

  var data = json.decode(response.body);
  print(data);

  if (data['response'] != null) {
    var userInfo = data['response'][0];
    print(userInfo);
    String deviceID = await DeviceId.getID;
    print('DeviceID: $deviceID');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("nombre", userInfo["nombre"]);
    await prefs.setString("apellido", userInfo["apellido_pat"]);
    await prefs.setString("correo", userInfo["correo"]);
    await prefs.setString("telefono", userInfo["telefono"]);
    await prefs.setString("token", userInfo["token"]);
    await prefs.setString("device_id", deviceID);
    await prefs.setString("id_usuario", userInfo["id_usuario"]);
    await prefs.setString("id_ciudad", userInfo["id_ciudad"]);
    await prefs.setString('imagen_perfil', userInfo["imagen_perfil"]);
    await prefs.setString(
        "tipo_vehiculo", "1"); //TODO: Taer tipo de vehículo en login
    await prefs.setInt("status_repartidor", 0);
    await prefs.setString("telefono_atencion", '3129438295');
    return true;
  }
  print('Error');
  return false;
}

/// Aceptar el servicio que llegó
Future<bool> acceptService(
    String folio, String tipoServicio, String ciudadId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");

  print('Tipo servicio => $tipoServicio');

  var response = await http.post(
    '$monitoreoServerAddress/AceptaServicioBase',
    headers: {"Accept": "application/json"},
    body: {
      "idRepartidor": idUsuario,
      "folio": folio,
      "tipoServicio": tipoServicio,
      "ciudadId": ciudadId,
    },
  );

  var json = await jsonDecode(response.body);
  print(json);

  if (json['codigo'] == '001') {
    return true;
  }
  return false;
}

/// Rechazar el servicio que llegó
void rejectService(String folio, String tipoServicio, String razon) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");

  var response = await http.post(
    '$monitoreoServerAddress/RechazaServicioBase',
    headers: {"Accept": "application/json"},
    body: {
      "idRepartidor": idUsuario,
      "folio": folio,
      "tipoServicio": tipoServicio,
      "razonRechazo": razon
    },
  );

  print(response.body);
}

/// Registrar repartidor como activo
Future<bool> registerUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String nombre = prefs.getString("nombre");
  String telefono = prefs.getString("telefono");
  String idUsuario = prefs.getString("id_usuario");
  String tipoVehiculo = prefs.getString("tipo_vehiculo");
  int statusRepartidor = 1;
  prefs.setInt("status_repartidor", statusRepartidor);
  String fireBaseToken = await _firebaseMessaging.getToken();
  print(fireBaseToken);
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  String ciudad = prefs.getString("id_ciudad");
  print(ciudad);

  var response = await http.post(
    '$monitoreoServerAddress/registerRepartidorOnline',
    headers: {"Accept": "application/json"},
    body: {
      "idRepartidor": '$idUsuario',
      "disponible": '$statusRepartidor',
      "nombre": nombre,
      "tel": telefono,
      "tiempoUltimoServicio":
          '0', //TODO: Qué se mandará en tiempoUltimoServicio
      "tiempoEstimadoUltimoServicio":
          '0', //TODO: Qué se mandará en tiempoEstimadoUltimoServicio
      "coordenadas": "${position.latitude}, ${position.longitude}",
      "ultimaEnvioCoordenadas":
          '1', //TODO: Qué se mandará en ultimaEnvioCoordenadas
      "idFirebase": fireBaseToken,
      "tipoVehiculo": tipoVehiculo == null ? '1' : tipoVehiculo,
      "idCiudad": ciudad
    },
  );

  var data = jsonDecode(response.body);
  print(data);

  if (data["codigo"] == 1 || data["codigo"] == 0) {
    if (Platform.isAndroid) {
      var methodChanel = MethodChannel("com.kio.yimidelivery/location");
      String data = await methodChanel.invokeMethod("startServiceLocation");
      print('invokeMethod $data');
    }
    return true;
  }
  return false;
}

/// Pago semanal del repartidor (List)
Future<List<Map>> getPaymentByWeek() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");
  print('Pago semanal => Id usuario: $idUsuario');
  var response = await http.post(
    '$monitoreoServerAddress/PagoSemanalRepartidor',
    headers: {"Accept": "application/json"},
    body: {"idRepartidor": idUsuario},
  );

  var json = await jsonDecode(response.body);

  if (json != 'Error al procesar los datos') {
    if (json['codigo'] == '001') {
      List<dynamic> list = json['data'];
      List<Map> returnList = List();
      list.forEach((element) => returnList.add(element));
      return returnList;
    }
  }

  print(json);

  return List();
}

/// Pago según día del repartidor (List)
Future<List<Map>> getPaymentByDay(String date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");
  print('Pago del día => Id usuario: $idUsuario');
  var response = await http.post(
    '$monitoreoServerAddress/PagoSemanalRepartidor',
    headers: {"Accept": "application/json"},
    body: {"idRepartidor": idUsuario, "fecha": date},
  );

  var json = await jsonDecode(response.body);
  if (json != 'Error al procesar los datos') {
    if (json['codigo'] == '001') {
      List<dynamic> list = json['data'];
      List<Map> returnList = List();
      list.forEach((element) => returnList.add(element));
      return returnList;
    }
  }
  print(json);

  return List();
}

/// Problema con el qr del establecimiento
Future<bool> qrError(String idBussines) async {
  var response = await http.post(
    '$monitoreoServerAddress/QrDetalleError',
    headers: {"Accept": "application/json"},
    body: {"idNegocio": idBussines},
  );

  var json = await jsonDecode(response.body);
  print(json);

  if (json['codigo'] == '000') {
    return true;
  }
  return false;
}

/// Obtener el listdo de colonias (List)
Future<List<Map>> getColonies() async {
  print("Colonias => GetListadoColonias");
  var response = await http.get(
    '$monitoreoServerAddress/GetListadoColonias',
    headers: {"Accept": "application/json"},
  );

  var json = await jsonDecode(response.body);
  print("Colonias => Response");
  print(json);

  if (json != 'Error al procesar los datos') {
    if (json['codigo'] == '001') {
      List<dynamic> list = json['data'];
      List<Map> returnList = List();
      list.forEach((element) => returnList.add(element));
      return returnList;
    }
  }
  return List();
}

Future<List<Map>> getPrecioColoniaApp(String idNegocio) async {
  print("Colonias => GetListadoColonias");
  var response = await http.post(
    '$monitoreoServerAddress/GetPrecioColoniaApp',
    headers: {
      "Accept": "application/json",
    },
    body: {
      "idNegocio": idNegocio,
    },
  );

  var json = await jsonDecode(response.body);
  // printWrapped(json.toString());

  if (json != 'Error al procesar los datos') {
    if (json['codigo'] == '001') {
      String jsonD = json['data'][0]['json_costos']
          .toString()
          .replaceAll('    ', '')
          .replaceAll('\n', '');
      List<String> infoStr = jsonD.split('},{');
      RegExp reId = RegExp(r'(?<=idColonia:\s).*(?=,colonia:)');
      RegExp reNombre = RegExp(r'(?<=colonia:\s).*(?=,km:)');
      RegExp reCoordenadas = RegExp(r'(?<=coordenadas:\s).*(?=,origen:)');
      RegExp reOrigen = RegExp(r'(?<=origen:\s).*(?=,costo:)');
      RegExp reCosto = RegExp(r'(?<=costo:\s)\d*(?=.*)');
      List<Map> returnList = List();
      for (var colonia in infoStr) {
        // print(colonia);
        String id = reId.firstMatch(colonia).group(0);
        String nombre = reNombre.firstMatch(colonia).group(0);
        String coordenadas = reCoordenadas.firstMatch(colonia).group(0);
        String origen = reOrigen.firstMatch(colonia).group(0);
        String costo = reCosto.firstMatch(colonia).group(0);
        returnList.add({
          "id_colonia": id,
          "nombre": nombre,
          "coordenadas": coordenadas,
          "origen": origen,
          "costo": num.parse(costo)
        });
      }

      print("Colonias => Colonias obtenidas");

      return returnList;
    }
  }
  return List();
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Future<String> termsAndConditions() async {
  print("Terminos y condiciones => termsAndConditions");
  var response = await http.get(
    '$monitoreoServerAddress/LegalRepartidorMandados',
    headers: {"Accept": "application/json"},
  );

  var json = await jsonDecode(response.body);

  if (json['codigo'] == '001') {
    String string = json['data'][0]['tc_usuario_chofer_manadados'];
    return string;
  }
  return 'No hay términos y condiciones';
}

void logout() async {
  print("Logout => Logout repartidor");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");
  var response = await http.post('$monitoreoServerAddress/LogoutRepartidor',
      headers: {"Accept": "application/json"},
      body: {"idRepartidor": idUsuario});

  var json = await jsonDecode(response.body);
  print(json);
}

void iniciarServicioMandadoNegocio(
    String folio, int pedidos, String nombresArray) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String nombre = prefs.getString("nombre") + " " + prefs.getString("apellido");
  String telefono = prefs.getString("telefono");
  print("iniciarServicioMandado");
  var response = await http.post(
    '$monitoreoServerAddress/IniciarServicioMandadoNegocio',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "nombre": nombre,
      "telefonoRepartidor": telefono,
      "numeroPedidos": '$pedidos',
      "nombresArray": nombresArray,
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}

void iniciarServicioMandadoCliente(String folio, int pedidos) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String nombre = prefs.getString("nombre") + " " + prefs.getString("apellido");
  String telefono = prefs.getString("telefono");
  print("iniciarServicioMandado");
  var response = await http.post(
    '$monitoreoServerAddress/IniciarServicioMandadoCliente',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "nombre": nombre,
      "telefonoRepartidor": telefono,
      "numeroPedidos": '$pedidos'
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}

void cobrarNegocio(
    String folio,
    String costosArray,
    String coloniasArray,
    String nombresColoniasArray,
    String idsColoniasArray,
    String telefonosArray,
    String nombresArray,
    List<String> imagesArray) async {
  print("Cobrar negocio");

  var request = new http.MultipartRequest(
      "POST", Uri.parse('$monitoreoServerAddress/CobrarNegocio'));
  // var request = new http.MultipartRequest(
  //     "POST",
  //     Uri.parse(
  //         'http://10.0.2.2:5000/datos'));
  print(nombresArray);
  request.fields['folio'] = folio;
  request.fields['costosArray'] = costosArray;
  request.fields['coloniasArray'] = coloniasArray;
  request.fields['telefonoArrayCustomer'] = telefonosArray;
  request.fields['nombresArray'] = nombresArray;
  request.fields['coloniasNombres'] = nombresColoniasArray;
  request.fields['coloniasIds'] = idsColoniasArray;

  request.headers['Content-Encoding'] = "application/gzip";

  for (var i = 0; i < imagesArray.length; i++) {
    request.files.add(await http.MultipartFile.fromPath(
        'ticket${i + 1}', imagesArray[i],
        contentType: MediaType('image', 'png')));
  }

  var response = await request.send();
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) => print(value));

  // var response = await http.post(
  //   '$monitoreoServerAddress/CobrarNegocio',
  //   headers: {"Accept": "application/json"},
  //   body: {
  //     "folio": folio,
  //     "costosArray": costosArray,
  //     "coloniasArray": coloniasArray,
  //     "telefonoArrayCustomer": telefonosArray,
  //     "foliosArray": foliosArray,
  //     "coloniasNombres": nombresColoniasArray,
  //     "coloniasIds": idsColoniasArray
  //   },
  // );

  // print(jsonDecode(response.body));
}

void entregaServicioNegocio(String folio, int numeroPedido) async {
  print("Entregar srvicio negocio");
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  var response = await http.post(
    '$monitoreoServerAddress/EntregaServicio',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "coordenadasEntrega": "${position.latitude}, ${position.longitude}",
      "numeroPedido": '$numeroPedido'
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}

void entregaServicioCliente(String folio, int numeroPedido) async {
  print("Entregar servicio cliente");
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  var response = await http.post(
    '$monitoreoServerAddress/EntregaServicioCliente',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "coordenadasEntrega": "${position.latitude}, ${position.longitude}",
      "numeroPedido": '$numeroPedido'
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}

void finalizarPedidoNegocio(String folio, int numeroPedido) async {
  print("Finalizar pedido negocio");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  var response = await http.post(
    '$monitoreoServerAddress/FinalizarPedidoNegocio',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "coordenadasEntrega": "${position.latitude}, ${position.longitude}",
      "idRepartidor": idUsuario,
      "numeroPedido": '$numeroPedido'
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}

void finalizarPedidoCliente(String folio, int numeroPedido) async {
  print("Finalizar pedido ciente");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String idUsuario = prefs.getString("id_usuario");
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  var response = await http.post(
    '$monitoreoServerAddress/FinalizarPedidoCliente',
    headers: {"Accept": "application/json"},
    body: {
      "folio": folio,
      "coordenadasEntrega": "${position.latitude}, ${position.longitude}",
      "idRepartidor": idUsuario,
      "numeroPedido": '$numeroPedido'
    },
  );

  var json = await jsonDecode(response.body);
  print(json);
}
