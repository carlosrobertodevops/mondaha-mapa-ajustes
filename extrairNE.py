# Bibliotecas
import json
import os
import re
import unicodedata
from shapely.geometry import shape, mapping

# Carregar o arquivo GeoJSON
with open("./dados/nordestebr.geojson", "r", encoding="utf-8") as file:
    geojson_data = json.load(file)

# Criar diretório de saída se não existir
output_dir = "output_ne_coordinates"
os.makedirs(output_dir, exist_ok=True)

def sanitize_filename(name):
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    return re.sub(r'[^a-zA-Z0-9_-]', '_', name)

# Nível de simplificação (quanto maior, mais simplifica)
TOLERANCE = 0.01  # ajuste conforme necessário

# Percorrer todas as features do arquivo
for feature in geojson_data["features"]:
    properties = feature["properties"]
    region_name = properties.get("NM_UF")

    if not region_name:
        continue

    region_name = sanitize_filename(region_name)
    file_path = os.path.join(output_dir, f"{region_name}.json")

    # Simplificação com Shapely
    geom = shape(feature["geometry"])
    simplified_geom = geom.simplify(TOLERANCE, preserve_topology=True)

    jsonb_formatted = []

    # A estrutura simplificada pode ainda ser Polygon ou MultiPolygon
    coords = mapping(simplified_geom)["coordinates"]
    geom_type = mapping(simplified_geom)["type"]

    if geom_type == "MultiPolygon":
        for polygon in coords:
            for ring in polygon:
                jsonb_formatted.extend([{"lat": round(coord[1], 6), "lng": round(coord[0], 6)} for coord in ring])
    elif geom_type == "Polygon":
        for ring in coords:
            jsonb_formatted.extend([{"lat": round(coord[1], 6), "lng": round(coord[0], 6)} for coord in ring])
    else:
        raise ValueError("Formato de geometria não suportado")

    # Salvar JSON compacto (uma linha só)
    with open(file_path, "w", encoding="utf-8") as output_file:
        json.dump(jsonb_formatted, output_file, separators=(',', ':'), ensure_ascii=False)

print(f"Coordenadas extraídas, simplificadas e salvas em '{output_dir}'.")
