// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables, unused_field, avoid_print
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';



class SymbolFlutter extends StatefulWidget {
  SymbolFlutter({Key? key}) : super(key: key);

  @override
  State<SymbolFlutter> createState() => _SymbolFlutterState();
}

class _SymbolFlutterState extends State<SymbolFlutter> {
  static final CameraPosition _pos = CameraPosition(
      target: LatLng(13.356133786884268, 45.35889580793817), zoom: 7);

  Completer<MapmyIndiaMapController> _cont = Completer();

  late MapmyIndiaMapController controller;

  Future<void> addImage(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  void addMarker() async {
    await addImage("icon", "assets/marker.png");
    controller.addSymbol(SymbolOptions(
        geometry: LatLng(13.356133786884268, 45.35889580793817),
        // textField: "Hi Sourabh",
        textColor: "red",
        textSize: 12,
        // draggable: true,
        iconAnchor: "qwwe",
        iconHaloBlur: 2.2,
        // iconOpacity: 0.6,
        iconSize: 0.3,
        // iconColor: "red",
        iconImage: "icon"));
  }

  @override
  void initState() {
    MapmyIndiaAccountManager.setMapSDKKey(
        "d3fc8af5-0f19-4b4d-9c1e-fe0152a311e5");
    MapmyIndiaAccountManager.setRestAPIKey("47e0624fbd6e55e8dd13e4453f089aa7");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.map_rounded),
                Spacer(),
                Text("2. Mapmyindia Symbol making"),
                Spacer(),
                Icon(Icons.search)
              ],
            ),
            centerTitle: false,
          ),
          body: MapmyIndiaMap(
            initialCameraPosition: _pos,
            onMapCreated: (map) => {controller = map},
            onStyleLoadedCallback: () => {addMarker()},
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              MapmyIndiaMapController controller = await _cont.future;
              controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(13.356133786884268, 45.35889580793817),
                      zoom: 10)));
              print("object");
            },
            child: Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }
}
