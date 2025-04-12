// import 'dart:io';

// void main() async {
//   final geojsonString = await File('./dados/nordestebr.geojson').readAsString();
//   final nomeUF = 'Pernambuco';

//   final coords = extrairCoordenadas(geojsonString, nomeUF);

//   print('Total de coordenadas extraídas para $nomeUF: ${coords.length}');
//   print(coords.take(5)); // mostra as primeiras 5 coordenadas
// }

import 'dart:convert';

List<Map<String, double>> extrairCoordenadas(
  String geojsonString,
  String nomeUF,
) {
  final geojsonData = jsonDecode(geojsonString);
  List<Map<String, double>> coordenadas = [];

  for (var feature in geojsonData['features']) {
    final properties = feature['properties'];
    final nome = properties['NM_UF'];

    if (nome != nomeUF) continue;

    final geometry = feature['geometry'];
    final geomType = geometry['type'];
    final coords = geometry['coordinates'];

    if (geomType == 'MultiPolygon') {
      for (var polygon in coords) {
        for (var ring in polygon) {
          coordenadas.addAll(
            ring.map<Map<String, double>>(
              (coord) => {
                "lat": (coord[1] as num).toDouble(),
                "lng": (coord[0] as num).toDouble(),
              },
            ),
          );
        }
      }
    } else if (geomType == 'Polygon') {
      for (var ring in coords) {
        coordenadas.addAll(
          ring.map<Map<String, double>>(
            (coord) => {
              "lat": (coord[1] as num).toDouble(),
              "lng": (coord[0] as num).toDouble(),
            },
          ),
        );
      }
    } else {
      throw Exception("Formato de geometria não suportado: $geomType");
    }
  }

  return coordenadas;
}
