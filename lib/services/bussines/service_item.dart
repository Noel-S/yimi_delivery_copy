import 'package:flutter/material.dart';

class ServiceItem extends StatefulWidget {
  ServiceItem({Key key, this.title, this.colony, this.colonyCoords, this.price, this.customerPhone, this.action, this.folio, this.idColonia, this.imagePath}): super(key: key);
    String title;
    // set changeTitle(String newTitle) {
    //   title = newTitle;
    // }
    final String imagePath;
    final String colony;
    final String colonyCoords;
    final String price;
    final String customerPhone;
    final String folio;
    final String idColonia;
    final Function action;
    
  @override
  _ServiceItemState createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
          child: Container(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Container(
                 width: 160,
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.title, style: TextStyle(fontSize: 21,),),
                      Text(widget.colony, style: TextStyle(fontSize: 16, color: Color(0xFFA9B8D5)),)
                    ],
                 ),
               ),
               Text('\$ ${widget.price}', style: TextStyle(fontSize: 20)),
               Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(Icons.drag_handle, size: 32,),
                    ),
                    IconButton(
                      highlightColor: Color(0x80FF5E20),
                      onPressed: widget.action,
                      icon: Icon(Icons.close, size: 32,),
                    )
                  ],
               ),
             ],
          ),
        ),
      ),
    );
  }

}