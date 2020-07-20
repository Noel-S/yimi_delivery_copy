import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:yimidelivery/image_preview.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  int flashOption = 0;

  @override
  void initState() {
    super.initState();
    // Para visualizar la salida actual de la cámara, es necesario
    // crear un CameraController.
    _controller = CameraController(
      // Obtén una cámara específica de la lista de cámaras disponibles
      widget.camera,
      // Define la resolución a utilizar
      ResolutionPreset.medium,
      // No pide permisos de audio
      enableAudio: false,
    );

    // A continuación, debes inicializar el controlador. Esto devuelve un Future!
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Asegúrate de deshacerte del controlador cuando se deshaga del Widget.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Take a picture')),
      // Debes esperar hasta que el controlador se inicialice antes de mostrar la vista previa
      // de la cámara. Utiliza un FutureBuilder para mostrar un spinner de carga
      // hasta que el controlador haya terminado de inicializar.
      body: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Si el Future está completo, muestra la vista previa
                return CameraPreview(_controller);
              } else {
                // De lo contrario, muestra un indicador de carga
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Align(
          //   alignment: Alignment.bottomLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: RawMaterialButton(
          //       shape: CircleBorder(),
          //       onPressed: flash,
          //       child: Padding(
          //         padding: const EdgeInsets.all(15),
          //         child: Icon(
          //           flashOption == 0
          //               ? Icons.flash_off
          //               : flashOption == 1 ? Icons.flash_auto : Icons.flash_on,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          // Agrega un callback onPressed
          onPressed: () async {
            // if (flashOption == 1) {
            //   Lamp.flash(Duration(milliseconds: 1000));
            // }
            // Toma la foto en un bloque de try / catch. Si algo sale mal,
            // atrapa el error.
            try {
              // Ensure the camera is initialized
              await _initializeControllerFuture;

              // Construye la ruta donde la imagen debe ser guardada usando
              // el paquete path.
              final path = join(
                //
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );

              // Attempt to take a picture and log where it's been saved
              await _controller.takePicture(path);
              // En este ejemplo, guarda la imagen en el directorio temporal. Encuentra
              // el directorio temporal usando el plugin `path_provider`.
              //

              var data = await showModalBottomSheet(
                context: context,
                enableDrag: false,
                isDismissible: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return ImagePreview(path: path);
                },
              );

              if (data) {
                Navigator.pop(context, path);
              }
            } catch (e) {
              // Si se produce un error, regístralo en la consola.
              print(e);
            }
          },
        ),
      ),
    );
  }
}
