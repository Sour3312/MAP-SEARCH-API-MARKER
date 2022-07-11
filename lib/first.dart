// +=+=+=+=+=+=+=+=+=+=+ INTEGRATED MAP WITH FLOATING SEARCH BAR AND CALLING DATA FROM APIs +=+=+=+=+=+=+=+=+=+=+=+=

// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, unused_field, prefer_const_constructors, no_leading_underscores_for_local_identifiers, unused_element
//Here the method CallGeocode(5) not working  so the latlng cant be generated(API issue)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // =+=+=+=+=+=+=+=+=+= Global VAriables =+=+=+=+=+=+=+=+=+=
  final Completer<MapmyIndiaMapController> _controller = Completer();

  bool isMapLoded = false;

  late MapmyIndiaMapController controller;

  var userInput,
      AT,
      request,
      myToken,
      sorted,
      acc_tok,
      SortedData,
      ApiData,
      setOnTextfield,
      DataLength;

  // Starting cameraposition of map
  final CameraPosition _MmiPlex = CameraPosition(
      target: LatLng(28.550844565376654, 77.26890518202649), zoom: 4);

  Future<void> addImage(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  // =+=+=+=+=+=+=+=+=+=FUNCTIONS =+=+=+=+=+=+=+=+=+=
// ============= 1st Function for token generation =============================
  getToken() async {
    print("getToken called");
    request = https.Request(
        'POST',
        Uri.parse(
            'https://outpost.mapmyindia.com/api/security/oauth/token?grant_type=client_credentials&client_id=33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==&client_secret=lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww'));
    https.StreamedResponse response = await request.send();

    //CHECKING STATUS OF RETRIVED DATA
    if (response.statusCode == 200) {
      var statusOfRespnse = response.reasonPhrase;
      print("Your current status is : $statusOfRespnse");

      AT = await response.stream.bytesToString();
      myToken = json.decode(AT);
      print(myToken);

      //sorted acess token from mytoken
      acc_tok = myToken["access_token"];
      print("Your access token is: ${acc_tok}");
    } else {
      print(response.reasonPhrase);
    }
    setState(() {
      getApi(userInput); //calling 2nd function
    });
  }

//==============2nd  Function for calling API===================================
  getApi(value) async {
    final respon = await https.get(
        Uri.parse(
            // 'https://atlas.mappls.com/api/places/search/json?query=ranchi }'), //static
            'https://atlas.mappls.com/api/places/search/json?query=${{
          userInput
        }}}'), //dynamic
        headers: {
          'Access-Control-Allow-Origin': "*",
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
          'cors': '*',
          HttpHeaders.authorizationHeader: "bearer ${acc_tok}",
        });
    try {
      ApiData = await json.decode(respon.body); //actual data coming from API
      print(ApiData);
      DataLength = ApiData["suggestedLocations"].length; //length of coming data
      print("This is Apidata length: ${DataLength}");
      return ApiData;
    } catch (e) {
      print(e);
    }
  }

//==============3rd Function form Listtile(OnTap)===============================

  colorCng(selectedOp) {
    setState(() {
      setOnTextfield = selectedOp;
    });
    print(setOnTextfield);
  }

//==============4th Function for ommapcreadted from body =======================

  void _onMapCreated(MapmyIndiaMapController _controller) {
    controller = _controller;
    setState(() {
      isMapLoded = true;
    });
  }

// ========== =============5th function for latlng generation ==================
  callGeocode(value) async {
    try {
      print("entered");
      GeocodeResponse? responsee =
          await MapmyIndiaGeoCoding(address: "Ranchi").callGeocoding();
      print("qwertyuiop ");

      if (responsee != null &&
          responsee.results != null &&
          responsee.results!.isNotEmpty) {
        print("AGAIN  ENTERED");
        Fluttertoast.showToast(msg: responsee.results![0].formattedAddress!);

        // addMarker(LatLng(
        //     responsee.results![0].latitude!, responsee.results![0].longitude!));
      }
    } catch (e) {
      print("not entered");
      if (e is PlatformException) {
        print('${e.code} --- ${e.message}');
        Fluttertoast.showToast(
            msg: '${e.code} --- ${e.message}', timeInSecForIosWeb: 50000);
      }
    }
  }

// ===================== 6th function for latlng to address generation =========
  reverseGeocode(LatLng latlng) async {
    try {
      ReverseGeocodeResponse? result =
          await MapmyIndiaReverseGeocode(location: latlng).callReverseGeocode();
      if (result != null &&
          result.results != null &&
          result.results!.isNotEmpty) {
        Fluttertoast.showToast(msg: result.results![0].formattedAddress!);
      }
      print(result);
    } catch (e) {
      if (e is PlatformException) {
        Fluttertoast.showToast(msg: '${e.code} --- ${e.message}');
      }
    }
  }

// ========== ============= 7th function for adding marker =====================

  void addMarker() async {
    await addImage("icon", "assets/marker.png");
    controller.addSymbol(SymbolOptions(
        geometry: LatLng(28.941572539478678, 67.89277389972276),
        iconSize: 0.2,
        iconHaloBlur: 2.2,
        iconImage: "icon"));
  }

// =+=+=+=+=+=+=+=+=+= Required keys 4 loading map =+=+=+=+=+=+=+=+=+=+=+=+=+=
  @override
  void initState() {
    super.initState();
    MapmyIndiaAccountManager.setMapSDKKey("${acc_tok}"); //dynamic way
    // MapmyIndiaAccountManager.setMapSDKKey(
    //     "cd00d163-db3b-4d58-8396-a2cb019c65b3"); //static way
    MapmyIndiaAccountManager.setRestAPIKey("47e0624fbd6e55e8dd13e4453f089aa7");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww");
  }

// =+=+=+=+=+=+=+=+= MAP INTEGRATION & MAIN  BODY  =+=+=+=+=+=+=+=+
  @override
  Widget build(BuildContext context) {
    FloatingSearchBarController _controller = FloatingSearchBarController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Integration with Sourabh"),
      ),
      body: Stack(children: [
        //1.-------------------MAp render--------------------
        MapmyIndiaMap(
          initialCameraPosition: _MmiPlex,
          myLocationRenderMode: MyLocationRenderMode.COMPASS,
          compassEnabled: true,
          myLocationEnabled: true,
          onMapLongClick: (point, latlng) => {reverseGeocode(latlng)},
          myLocationTrackingMode: MyLocationTrackingMode.NoneCompass,
          onMapCreated: _onMapCreated,
        ),
        //2.-------------------Searchbar render--------------------
        FloatingSearchBar(
          controller: _controller,
          hint: 'Search here ex: Ranchi/Delhi...',

          //+=+=+=+= taking user input +=+=+=+=
          onQueryChanged: (value) {
            userInput = value;
            setState(() {
              getToken();
            });
            print(userInput);
          },
          openAxisAlignment: 0.0,
          axisAlignment: 0.0,
          scrollPadding: EdgeInsets.only(top: 5, bottom: 0),
          elevation: 40.0,
          physics: BouncingScrollPhysics(),
          transitionCurve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 500),
          transition: CircularFloatingSearchBarTransition(),
          debounceDelay: Duration(milliseconds: 400),
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                icon: Icon(Icons.place),
                onPressed: () {
                  print('Places Pressed');
                  // Navigator.pop(context);
                },
              ),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          builder: (context, transition) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Material(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: SingleChildScrollView(
                    child: Container(
                      height: 600.0,
                      color: Colors.white,
                      child: Expanded(
                        child: Column(
                          children: [
                            //------- creating suggestions via listtile -------
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      tileColor: Colors.grey[200],
                                      trailing:
                                          Icon(Icons.location_on_outlined),
                                      title: Text(
                                        ApiData["suggestedLocations"][index]
                                            ["placeAddress"],
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        ApiData["suggestedLocations"][index]
                                            ["placeName"],
                                        style:
                                            TextStyle(color: Colors.blue[300]),
                                      ),
                                      onTap: () {
                                        colorCng(ApiData["suggestedLocations"]
                                            [index]["placeAddress"]);
                                        addMarker();
                                        controller.moveCamera(
                                            CameraUpdate.newLatLngZoom(
                                                LatLng(28.941572539478678,
                                                    67.89277389972276),
                                                4));
                                        print(
                                            "Marker added on: ${ApiData["suggestedLocations"][index]["placeAddress"]}");
                                        callGeocode(userInput);
                                      },
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          addMarker();
          controller.moveCamera(CameraUpdate.newLatLngZoom(
              LatLng(28.941572539478678, 67.89277389972276), 4));
        },
        child: Icon(Icons.my_location),
      ),
      drawer: Drawer(),
    );
  }
}
