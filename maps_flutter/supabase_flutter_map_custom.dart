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
import 'dart:math'; // Import necessário para gerar números aleatórios
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupabaseFlutterMapCustom extends StatefulWidget {
  final double? width;
  final double? height;
  final String memberTable;
  final String polygonTable;
  final String searchTerm;
  final double initialLat;
  final double initialLng;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final bool interactiveZoom;
  final String mapType;
  final bool showMarkers;
  final bool showPolygons;
  final Future Function(int membroId)? onMarkerMemberId;

  const SupabaseFlutterMapCustom({
    Key? key,
    this.width,
    this.height,
    required this.memberTable,
    required this.polygonTable,
    required this.searchTerm,
    required this.initialLat,
    required this.initialLng,
    required this.zoom,
    this.minZoom = 5.0,
    this.maxZoom = 18.0,
    this.interactiveZoom = true,
    this.mapType = "osm",
    this.showMarkers = true,
    this.showPolygons = true,
    this.onMarkerMemberId,
  }) : super(key: key);

  @override
  _SupabaseFlutterMapCustomState createState() =>
      _SupabaseFlutterMapCustomState();
}

class _SupabaseFlutterMapCustomState extends State<SupabaseFlutterMapCustom> {
  // Variáveis iniciais
  final supabase = Supabase.instance.client;
  final MapController _mapController = MapController();
  bool _isLoading = false;

  List<Marker> _markers = [];
  List<Polygon> _polygons = [];

  String _selectedMapType = "osm";
  String _mapType = "osm";

  Map<String, int> _factionCount = {};
  int _totalMembers = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  // Iniciação
  @override
  void initState() {
    super.initState();
    bool _isLoading = false;
    _fetchMarkers(widget.searchTerm);
    _fetchPolygons();
    _searchController.addListener(() {
      setState(() {}); // Atualiza o botão "X" dinamicamente
    });
  }

  // Limpar à memóraa
  @override
  void dispose() {
    // supabase.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Atualizar os marcadores e poligonos
  @override
  void didUpdateWidget(covariant SupabaseFlutterMapCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchTerm != widget.searchTerm) {
      setState(() {
        _markers.clear();
        _polygons.clear();
      });

      _fetchMarkers(widget.searchTerm);
      _fetchPolygons();
    }
  }

  // Build do widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  latLng.LatLng(widget.initialLat, widget.initialLng),
              initialZoom: widget.zoom,
              minZoom: widget.minZoom,
              maxZoom: widget.maxZoom,
            ),
            children: [
              TileLayer(urlTemplate: _getTileLayerUrl(_selectedMapType)),
              if (widget.showPolygons) PolygonLayer(polygons: _polygons),
              if (widget.showMarkers) MarkerLayer(markers: _markers),
            ],
          ),
          _buildFloatingSearch(),
          _buildFactionCounters(),
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  // opção de busca dentro do próprio mapa
  Widget _buildFloatingSearch() {
    return Positioned(
      top: 16,
      right: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: FlutterFlowTheme.of(context).primary),
          decoration: InputDecoration(
            hintText: "Buscar informações no mapa...",
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
            hoverColor: FlutterFlowTheme.of(context).primary,
            border: OutlineInputBorder(
              // Define a borda
              borderRadius: BorderRadius.circular(12), // Define o raio da borda
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context)
                    .primary, // Define a cor da borda
                width: 2, // Define a largura da borda
              ),
            ),
            enabledBorder: OutlineInputBorder(
              // Borda quando o campo NÃO está focado
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              // Borda quando o campo está focado
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 2.5,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        color: FlutterFlowTheme.of(context).primary),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchTerm = "";
                        _fetchMarkers(_searchTerm);
                        _fetchPolygons();
                      });
                    },
                  )
                : Icon(Icons.search,
                    color: FlutterFlowTheme.of(context).primary),
          ),
          cursorColor: FlutterFlowTheme.of(context).primary,
          onSubmitted: (value) {
            setState(() {
              _searchTerm = value;
            });
            _fetchMarkers(_searchTerm);
            _fetchPolygons();
          },
        ),
      ),
    );
  }

  // Totalizador das facções
  Widget _buildFactionCounters() {
    return Positioned(
      top: 70,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // Cor de fundo do container
          borderRadius: BorderRadius.circular(12), // Borda arredondada
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Sombra suave
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe o total geral de membros com cor primária
            Text(
              'Total de Membro(s): $_totalMembers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
            SizedBox(height: 10),
            // Lista de facções e suas contagens
            ..._factionCount.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getTooltipColor(
                            '${entry.key}'), //FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                    Text(
                      '( ${entry.value} )',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTooltipColor(
                            '${entry.key}'), // FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Botões flutuantes na lateral direta do mapa
  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Atualizar",
            tooltip: 'Atualizar os dados do Mapa',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () async {
              setState(() {
                _isLoading = true; // Começa o loading
                _searchController.clear();
                _searchTerm = "";
              });

              // Aguarde as funções assíncronas terminarem
              await _fetchMarkers(_searchTerm);
              await _fetchPolygons();

              setState(() {
                _isLoading = false; // Termina o loading
              });
            },
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).info,
                      ),
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(Icons.refresh_outlined),
          ),
          SizedBox(height: 10),

          // Centralizar mapa
          FloatingActionButton(
            heroTag: "center",
            tooltip: 'Centro do Mapa',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _mapController.move(
                latLng.LatLng(widget.initialLat, widget.initialLng),
                widget.zoom),
            child: Icon(Icons.center_focus_strong),
          ),
          SizedBox(height: 10),

          // Zoom (+)
          FloatingActionButton(
            heroTag: "zoom_in",
            tooltip: 'Aumentar o Zoom',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _mapController.move(
                _mapController.camera.center, _mapController.camera.zoom + 1),
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 10),

          // Zoom (-)
          FloatingActionButton(
            heroTag: "zoom_out",
            tooltip: 'Diminuir o Zoom',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _mapController.move(
                _mapController.camera.center, _mapController.camera.zoom - 1),
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 10),

          // Mover para cima
          FloatingActionButton(
            heroTag: "move_up",
            tooltip: 'Mover para cima',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _moveMap(0, -0.01),
            child: Icon(Icons.arrow_upward),
          ),
          SizedBox(height: 10),

          // Mover para baixo
          FloatingActionButton(
            heroTag: "move_down",
            tooltip: 'Mover para baixo',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _moveMap(0, 0.01),
            child: Icon(Icons.arrow_downward),
          ),
          SizedBox(height: 10),

          // Mover para à esquerda
          FloatingActionButton(
            heroTag: "move_left",
            tooltip: 'Mover para esquerda',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _moveMap(-0.01, 0),
            child: Icon(Icons.arrow_back),
          ),
          SizedBox(height: 10),

          // Mover para à direita
          FloatingActionButton(
            heroTag: "move_right",
            tooltip: 'Mover para direita',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () => _moveMap(0.01, 0),
            child: Icon(Icons.arrow_forward),
          ),
          SizedBox(height: 10),

          // Mudar o mapa
          FloatingActionButton(
            heroTag: "change_map",
            tooltip: 'Mudar mapa (Google, OSM, Satelite, escuro, cinza e etc)',
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () async {
              setState(() {
                _isLoading = true; // Começa o loading
                // Alternar entre os tipos de mapa
                if (_selectedMapType == "osm") {
                  _selectedMapType = "google";
                } else if (_selectedMapType == "google") {
                  _selectedMapType = "satellite";
                } else if (_selectedMapType == "satellite") {
                  _selectedMapType = "dark";
                } else if (_selectedMapType == "dark") {
                  _selectedMapType = "light";
                } else if (_selectedMapType == "light") {
                  _selectedMapType = "lightgray";
                } else if (_selectedMapType == "lightgray") {
                  _selectedMapType = "osm";
                } else {
                  _selectedMapType = "osm";
                }
              });
              // Atualiza os polígonos quando o tipo de mapa muda
              // Aguarde as funções assíncronas terminarem
              await _fetchMarkers(_searchTerm);
              await _fetchPolygons();
              setState(() {
                _isLoading = false; // Termina o loading
              });
            },
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).info,
                      ),
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(Icons.map),
          ),
        ],
      ),
    );
  }

  // URL real para os diferentes tipos de tiles
  String _getTileLayerUrl(String mapType) {
    switch (mapType) {
      case "osm":
        return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"; // Open Streat Maps
      case "google":
        return "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}"; // Google Maps
      case "satellite":
        return "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"; // Satélite do Google Maps
      case "dark":
        return "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png"; // CartoDB Dark Matter
      case "light":
        return "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"; // CartoDB Light
      case "gray":
        return "https://{s}.basemaps.cartocdn.com/gray_all/{z}/{x}/{y}.png"; // CartoDB Gray (cinza claro)
      case "lightgray":
        return "https://{s}.basemaps.cartocdn.com/lightgray_all/{z}/{x}/{y}.png"; // CartoDB Light Gray (uma opção alternativa de cinza)
      default:
        return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
    }
  }

  // Mover-se no mapa
  void _moveMap(double deltaLng, double deltaLat) {
    final currentCenter = _mapController.camera.center;
    final newCenter = latLng.LatLng(
      currentCenter.latitude + deltaLat,
      currentCenter.longitude + deltaLng,
    );
    _mapController.move(newCenter, _mapController.camera.zoom);
  }

  // Adicionar markers no Mapa e ajustar os deslocalmentoa
  Future<void> _fetchMarkers(String searchTerm) async {
    final response = await supabase
        .from(widget.memberTable)
        .select()
        .ilike('pesquisa', '%$searchTerm%');

    Map<String, List<Map<String, dynamic>>> positionMap = {};
    Map<String, latLng.LatLng> adjustedPositions = {};
    Map<String, int> tempFactionCount = {}; // Contador temporário
    int total = 0; // Contador total

    List<Marker> markers = response.map<Marker>((item) {
      double lat = item['latitude'];
      double lng = item['longitude'];

      String positionKey = "$lat,$lng";

      if (positionMap.containsKey(positionKey)) {
        positionMap[positionKey]!.add(item);
        double offset = _getSmallOffset(positionMap[positionKey]!.length);
        lat += offset;
        lng += offset;
      } else {
        positionMap[positionKey] = [item];
      }

      latLng.LatLng adjustedPosition = latLng.LatLng(lat, lng);
      adjustedPositions[item['id'].toString()] =
          adjustedPosition; // Salva a posição ajustada

      // Atualiza a contagem de facção
      String faction = item['faccao_nome'] ?? 'Desconhecido';
      tempFactionCount[faction] = (tempFactionCount[faction] ?? 0) + 1;
      total++; // Incrementa o total

      return Marker(
        width: 40,
        height: 40,
        point: adjustedPosition,
        child: GestureDetector(
          //onTap: () => _showMemberDetails([item]),
          onTap: () {
            widget.onMarkerMemberId!(item['membro_id']);
          },
          child: Tooltip(
            message:
                ' (' + item['faccao_nome'] + ') ' + item['nome_completo'] ??
                    'Sem nome',
            padding: EdgeInsets.all(8), // Adicionando espaço interno
            decoration: BoxDecoration(
              color: _getTooltipColor(item['faccao_nome']), // Cor de fundo
              borderRadius: BorderRadius.circular(4), // Bordas arredondadas
            ),
            textStyle: TextStyle(
              color: FlutterFlowTheme.of(context).primaryText, // Cor do texto
              fontWeight: FontWeight.bold,
            ),
            preferBelow: false, // Tooltip aparece acima do ícone
            waitDuration: Duration(seconds: 1), // Tempo para o balão aparecer
            child: Image.network(
              _getMarkerIcon(item['faccao_nome']) ?? FFAppState().markerDefault,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  FFAppState().markerDefault,
                  width: 40,
                  height: 40,
                );
              },
            ),
          ),
        ),
      );
    }).toList();

    setState(() {
      _markers = markers;
      _factionCount = tempFactionCount;
      _totalMembers = total;
    });
  }

  // Função para gerar um pequeno deslocamento
  double _getSmallOffset(int count) {
    final random = Random();
    double baseOffset = 0.0001; // Deslocamento padrão
    double randomOffset = random.nextDouble() * 0.00015; // Pequena variação
    return (random.nextBool()
        ? baseOffset + randomOffset
        : -baseOffset - randomOffset);
  }

  // Icone dos Markers
  String _getMarkerIcon(String tipo) {
    switch (tipo) {
      case 'CV':
        return FFAppState().markerRedCustom;
      case 'PCC':
        return FFAppState().markerBlueCustom;
      case 'BPL/PCC':
        return FFAppState().markerBlue1Custom;
      default:
        return FFAppState().markerDefaultCustom;
    }
  }

  // Cor do Tooltip
  Color _getTooltipColor(String tipo) {
    switch (tipo) {
      case 'CV':
        return FlutterFlowTheme.of(context).secondary.withOpacity(0.6);
      case 'PCC':
        return FlutterFlowTheme.of(context).primary.withOpacity(0.6);
      case 'BPL/PCC':
        return FlutterFlowTheme.of(context).primary.withOpacity(0.6);
      default:
        return FlutterFlowTheme.of(context).primaryBackground.withOpacity(0.6);
    }
  }

  // Adicionando os Poligonos
  Future<void> _fetchPolygons() async {
    final response = await supabase.from(widget.polygonTable).select();

    // Filtrar apenas os itens que possuem uma cor definida
    List validItems =
        response.where((item) => item['cor_hex'] != null).toList();

    List<Polygon> polygons = validItems.map<Polygon>((item) {
      List<latLng.LatLng> points = (item['coordenadas'] as List)
          .map((coord) => latLng.LatLng(coord['lat'], coord['lng']))
          .toList();

      String hexColor = item['cor_hex'];
      double borderStrokeWidth = item['largura_linha'] ?? 3.0;

      // Se a cor for preta e o mapa for "dark" ou "satellite", mudar para branca
      if (hexColor.toUpperCase() == "#000000" &&
          (_selectedMapType == "dark" || _selectedMapType == "satellite")) {
        hexColor = "#FFFFFF";
      }

      return Polygon(
        points: points,
        color: _hexToColor(hexColor).withOpacity(0.1),
        borderColor: _hexToColor(hexColor),
        borderStrokeWidth: borderStrokeWidth,
      );
    }).toList(); // Agora, não há risco de valores nulos

    setState(() {
      _polygons = polygons;
    });
  }

  // // Adicionando os Poligonos
  // Future<void> _fetchPolygons() async {
  //   final response = await supabase.from(widget.polygonTable).select();

  //   List<Polygon> polygons = response.map<Polygon>((item) {

  //     List<latLng.LatLng> points = (item['coordenadas'] as List)
  //         .map((coord) => latLng.LatLng(coord['lat'], coord['lng']))
  //         .toList();

  //     String hexColor = item['cor_hex'] ?? "#000000";
  //     double borderStrokeWidth = item['largura_linha'] ?? 3.0;

  //     // Se a cor for preta e o mapa for "dark" ou "satellite", mudar para branca
  //     if (hexColor.toUpperCase() == "#000000" &&
  //         (_selectedMapType == "dark" || _selectedMapType == "satellite")) {
  //       hexColor = "#FFFFFF";
  //     }

  //     return Polygon(
  //       points: points,
  //       color: _hexToColor(hexColor).withOpacity(0.1),
  //       borderColor: _hexToColor(hexColor),
  //       borderStrokeWidth: borderStrokeWidth,
  //     );
  //   }).toList();

  //   setState(() {
  //     _polygons = polygons;
  //   });
  // }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  void _showMemberDetails(List<Map<String, dynamic>> members) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: members
                .map((memberData) => Column(
                      children: [
                        Text(
                          memberData['nome_completo'] ?? 'Sem informação',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text("📍 Latitude: ${memberData['latitude']}"),
                        Text("📍 Longitude: ${memberData['longitude']}"),
                        Text("📧 Facção: ${memberData['faccao_nome']}"),
                        Image.network(
                          (memberData['fotos_path'] is List &&
                                  memberData['fotos_path'].isNotEmpty)
                              ? memberData['fotos_path']
                                  [0] // Pega a primeira imagem
                              : _getMarkerIcon(memberData['faccao_nome']),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(FFAppState().markerDefault,
                                width: 150, height: 150);
                          },
                        ),
                        Divider(),
                      ],
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}git