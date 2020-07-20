import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  final String path;

  ImagePreview({
    Key key,
    @required this.path,
  }) : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.file(
              File.fromUri(Uri.parse(widget.path)),
              fit: BoxFit.fill,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20),
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context, false),
                heroTag: 'again',
                child: Icon(
                  Icons.refresh,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context, true),
                heroTag: 'save',
                child: Icon(
                  Icons.check,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
