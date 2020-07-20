// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  Notifications({Key key, this.notifications, this.delete}) : super(key: key);
  final List<Map> notifications;
  final Function delete;

  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map> notifications;

  @override
  void initState() {
    super.initState();
    notifications = List<Map>();
    widget.notifications.forEach((element) {
      notifications.add(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height - 80, //25,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Material(
              color: Colors.white,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      focusColor: Colors.red,
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 15),
                      child: Text(
                        'Notificaciones',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Chip(label: Text('${notifications.length}', style: TextStyle(color: Colors.white),), backgroundColor: Color(0xFFFF5E20),)
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 59),
            child: ListView(
              children: List.generate(
                notifications.length,
                (index) => Card(
                  elevation: 1,
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: ListTile(
                      key: ValueKey('value${notifications[index]["id"]}'),
                      title: Text(notifications[index]["title"]),
                      subtitle: Text(notifications[index]["body"]),
                      trailing: IconButton(
                        onPressed: () {
                          widget.delete(notifications[index]["id"]);
                          setState(() {
                            notifications.removeAt(index);
                          });
                        },
                        highlightColor: Color(0x80FF5E20),
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
