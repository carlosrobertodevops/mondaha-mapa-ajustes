// Automatic FlutterFlow imports
import '/backend/backend.dart';
import "package:community_testing_ryusdv/backend/schema/structs/index.dart"
    as community_testing_ryusdv_data_schema;
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import "package:community_testing_ryusdv/backend/schema/structs/index.dart"
    as community_testing_ryusdv_data_schema;
import "package:community_testing_ryusdv/backend/schema/enums/enums.dart"
    as community_testing_ryusdv_enums;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHttpFlutterMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String memberTable;
  final String polygonTable;
  final double initialLat;
  final double initialLng;
  final double zoom;

  const SupabaseHttpFlutterMap({
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
  _SupabaseHttpFlutterMapState createState() => _SupabaseHttpFlutterMapState();
}

class _SupabaseHttpFlutterMapState extends State<SupabaseHttpFlutterMap> {
  final supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  List<Marker> _markers = [];
  List<Polygon> _polygons = [];

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
    _fetchPolygons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: latLng.LatLng(widget.initialLat, widget.initialLng),
          initialZoom: widget.zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolygonLayer(polygons: _polygons),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }

  // Adicionando as Markers
  Future<void> _fetchMarkers() async {
    final response = await supabase.from(widget.memberTable).select();
    List<Marker> markers =
        response.map<Marker>((item) {
          return Marker(
            width: 40,
            height: 40,
            point: latLng.LatLng(item['latitude'], item['longitude']),
            child: GestureDetector(
              onTap: () => _showMemberDetails(item),
              child: Image.network(
                _getMarkerIcon(item['tipo']) ?? FFAppState().markerDefault,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/marker_blue.png',
                    width: 40,
                    height: 40,
                  );
                },
              ),
            ),
          );
        }).toList();

    setState(() {
      _markers = markers;
    });
  }

  String _getMarkerIcon(String tipo) {
    switch (tipo) {
      case 'CV':
        return FFAppState().markerRed;
      case 'PCC':
        return FFAppState().markerBlue;
      case 'BPL/PCC':
        return FFAppState().markerBlue1;
      default:
        return FFAppState().markerDefault;
    }
  }

  // Adicionando os Poligonos
  Future<void> _fetchPolygons() async {
    final response = await supabase.from(widget.polygonTable).select();
    List<Polygon> polygons =
        response.map<Polygon>((item) {
          List<latLng.LatLng> points =
              (item['coordenadas'] as List)
                  .map((coord) => latLng.LatLng(coord['lat'], coord['lng']))
                  .toList();

          return Polygon(
            points: points,
            color: _hexToColor(item['cor_hex'] ?? "#0000FF").withOpacity(0.2),
            borderColor: _hexToColor(item['cor_hex'] ?? "#0000FF"),
            borderStrokeWidth: item['largura_linha'] ?? 3.0,
          );
        }).toList();

    setState(() {
      _polygons = polygons;
    });
  }

  // Ajustando as cores dos polígonos
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  // Show
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
