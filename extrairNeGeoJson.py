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
output_dir = "output_ne_geojson"
os.makedirs(output_dir, exist_ok=True)

def sanitize_filename(name):
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    return re.sub(r'[^a-zA-Z0-9_-]', '_', name)

# Nível de simplificação (opcional)
TOLERANCE = 0.01  # ajuste ou defina como None para não simplificar

# Agrupar features por estado (NM_UF)
features_by_uf = {}

for feature in geojson_data["features"]:
    properties = feature.get("properties", {})
    region_name = properties.get("NM_UF")

    if not region_name:
        continue

    region_key = sanitize_filename(region_name)

    # Simplificar geometria se desejado
    geom = shape(feature["geometry"])
    if TOLERANCE:
        geom = geom.simplify(TOLERANCE, preserve_topology=True)

    # Construir a nova feature com geometria (possivelmente simplificada)
    new_feature = {
        "type": "Feature",
        "geometry": mapping(geom),
        "properties": properties
    }

    features_by_uf.setdefault(region_key, []).append(new_feature)

# Salvar cada grupo em um arquivo GeoJSON separado
for region_key, features in features_by_uf.items():
    feature_collection = {
        "type": "FeatureCollection",
        "features": features
    }

    file_path = os.path.join(output_dir, f"{region_key}.geojson")
    with open(file_path, "w", encoding="utf-8") as output_file:
        json.dump(feature_collection, output_file, ensure_ascii=False, indent=2)

print(f"Arquivos GeoJSON por estado salvos em '{output_dir}'.")
