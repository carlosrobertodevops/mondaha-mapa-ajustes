// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:typed_data';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_map/flutter_map.dart';

class SupabaseGoogleMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String memberTable;
  final String polygonTable;
  final double initialLat;
  final double initialLng;
  final double zoom;

  const SupabaseGoogleMap({
    Key? key,
    this.width,
    this.height,
    required this.memberTable,
    required this.polygonTable,
    required this.initialLat,
    required this.initialLng,
    required this.zoom,
  }) : super(key: key);

  @override
  _SupabaseGoogleMapState createState() => _SupabaseGoogleMapState();
}

class _SupabaseGoogleMapState extends State<SupabaseGoogleMap> {
  final supabase = Supabase.instance.client;
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _fetchMarkers(context);
    _fetchPolygons(context);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: gmaps.GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: gmaps.CameraPosition(
            target: gmaps.LatLng(widget.initialLat, widget.initialLng),
            zoom: widget.zoom,
          ),
          markers: _markers,
          polygons: _polygons,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          // onMapCreated: (gmaps.GoogleMapController controller) {
          //   _controller = controller},
          // controller.setMapStyle(MapStyle().aubergine);
          //},
        ),
      ),
    );
  }

  //Método _fetchMarkers
  Future<void> _fetchMarkers(BuildContext context) async {
    // dados da tabela de membros dentro do supabase
    final response = await supabase.from(widget.memberTable).select();
    gmaps.Marker _addMarkers;

    response.forEach((item) async {
      // if (item['latitude'] != null && item['longitude'] != null) {
      double lat = item['latitude'];
      double lng = item['longitude'];

      _addMarkers = gmaps.Marker(
        markerId: gmaps.MarkerId(item['id'].toString()),
        position: gmaps.LatLng(lat, lng),
        icon: await _getAssetMapBitmap(context, item['icon']),
        // icon: await _getAssetIcon(context, item['icon']).then((value) => value),
        infoWindow: InfoWindow(title: item['name'], snippet: 'Teste do Marker'),
      );
      // }

      setState(() {
        // if (_addMarkers != null) {
        _markers.add(_addMarkers);
        // }
      });
    });
  }

  Future<AssetMapBitmap> _getAssetMapBitmap(
    BuildContext context,
    String icon,
  ) async {
    final ImageConfiguration _imageConfiguration =
        createLocalImageConfiguration(context);
    AssetMapBitmap assetMapBitmap = await AssetMapBitmap.create(
      _imageConfiguration,
      icon,
      // 'assets/images/map_icon.png',
      imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
      width: 32, // Desired width in logical pixels.
      height: 32, // Desired height in logical pixels.
    );
    return assetMapBitmap;
  }

  //Método _getAssetIcon
  Future<gmaps.BitmapDescriptor> _getAssetIcon(
    BuildContext context,
    String icon,
  ) async {
    final Completer<gmaps.BitmapDescriptor> bitmapIcon =
        Completer<gmaps.BitmapDescriptor>();
    final ImageConfiguration config = createLocalImageConfiguration(
      context,
      size: Size(32, 32),
    );

    AssetImage(icon)
        .resolve(config)
        .addListener(
          ImageStreamListener((ImageInfo image, bool sync) async {
            final ByteData? bytes = await image.image.toByteData(
              format: ImageByteFormat.png,
            );
            final gmaps.BitmapDescriptor bitmap = gmaps
                .BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
            bitmapIcon.complete(bitmap);
          }),
        );

    return await bitmapIcon.future;
  }

  Color _hexToColor(String hex) {
    switch (hex.toUpperCase()) {
      case '#FF0000':
        return Colors.red;
      case '#00FF00':
        return Colors.green;
      case '#0000FF':
        return Colors.blue;
      case '#FFFF00':
        return Colors.yellow;
      case '#800080':
        return Colors.purple;
      case '#000000':
        return Colors.black;
      case '#FFFFFF':
        return Colors.white;
      default:
        return Colors.black; // Cor padrão
    }
  }

  // Selecionando os dados dos poligonos
  Future<void> _fetchPolygons(BuildContext context) async {
    // Dados da tabela de poligonos dentro do supabase
    final response = await supabase.from(widget.polygonTable).select();
    if (response.isEmpty) {
      debugPrint("Nenhum polígono encontrado.");
      return;
    }

    Set<gmaps.Polygon> _addPolygons = {};

    for (var item in response) {
      if (item['coordenadas'] == null || item['coordenadas'] is! List) continue;
      List<gmaps.LatLng> pontos =
          (item['coordenadas'] as List)
              .map((coord) => gmaps.LatLng(coord['lat'], coord['lng']))
              .toList();

      Color strokeColor = _hexToColor(
        item['cor_hex'] ?? _hexToColor("#0000FF"),
      );
      double opacity = (item['opacidade'] as num?)?.toDouble() ?? 0.2;
      opacity = opacity.clamp(0.0, 1.0);

      _addPolygons.add(
        gmaps.Polygon(
          polygonId: gmaps.PolygonId(item['id'].toString()),
          points: pontos,
          strokeWidth: item['largura_linha'] ?? 3,
          strokeColor: strokeColor,
          fillColor: strokeColor.withOpacity(opacity),
        ),
      );
    }

    setState(() {
      _polygons = _addPolygons;
    });
  }

  void _showMemberDetails(Map<String, dynamic> memberData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                memberData['nome'] ?? 'Sem Nome',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("📍 Latitude: ${memberData['latitude']}"),
              Text("📍 Longitude: ${memberData['longitude']}"),
              if (memberData['email'] != null)
                Text("📧 Email: ${memberData['email']}"),
              if (memberData['telefone'] != null)
                Text("📞 Telefone: ${memberData['telefone']}"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fechar"),
              ),
            ],
          ),
        );
      },
    );
  }
}
