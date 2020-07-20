import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:yimidelivery/API.dart' as API;

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  // List<Map> pagosDia = List();
  List<Map> pagos = List();
  //= [
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  //   {
  //     "tipo": "Comida",
  //     "monto": 30,
  //     "fecha": "2020-06-23T05:00:00.000Z",
  //     "hora": "12:03:02"
  //   },
  // ];
  num totalSemanal = 0;

  @override
  void initState() {
    super.initState();
    API.getPaymentByWeek().then((list) {
      list.forEach((element) {
        pagos.add(element);
        setState(() {
          totalSemanal += element['monto'];
        });
       });
    });
  }

  String formatDate(String date) {
    List<String> dateList = date.substring(0, 10).split('-');
    return '${dateList[2]} ${formatMonth(dateList[1])} ${dateList[0]}';
  }

  String formatMonth(String month) {
    switch (month) {
      case '01':
        return 'Ene.';
      case '02':
        return 'Feb.';
      case '03':
        return 'Mar.';
      case '04':
        return 'Abr.';
      case '05':
        return 'May.';
      case '06':
        return 'Jun.';
      case '07':
        return 'Jul.';
      case '08':
        return 'Ago.';
      case '09':
        return 'Sep.';
      case '10':
        return 'Oct.';
      case '11':
        return 'Nov.';
      case '12':
        return 'Dic.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de pagos'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                Icons.monetization_on,
                size: 64,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'Ganancias de la semana',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Text(
              'dd MMM. 2020 - dd MM. 2020',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: Text(
              '\$$totalSemanal MXN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height - 280,
                child: ListView(
                  children: List.generate(
                    pagos.length,
                    (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            formatDate(pagos[index]['fecha']),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 15, top: 20, right: 20, left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${pagos[index]['tipo']}',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '\$${pagos[index]['monto']} MXN',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

/*

Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text('dd. MMM. 2020', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 20, right: 20, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Concepto', style: TextStyle(fontSize: 18),),
                            Text('\$200.00 MXN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Concepto', style: TextStyle(fontSize: 18),),
                            Text('\$200.00 MXN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Concepto', style: TextStyle(fontSize: 18),),
                            Text('\$200.00 MXN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ],
                  ),

 */
