# Bibliotecas

import json
import os
import re
import unicodedata

# Carregar o arquivo GeoJSON
with open("./dados/favelas-e-comunidades.geojson", "r", encoding="utf-8") as file:
    geojson_data = json.load(file)

# Criar diretório de saída se não existir
output_dir = "output_grotas_coordinates"
os.makedirs(output_dir, exist_ok=True)

def sanitize_filename(name):
        # Normaliza os caracteres acentuados para sua versão base (exemplo: "é" → "e")
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    """Remove caracteres inválidos para nomes de arquivos."""
    return re.sub(r'[^a-zA-Z0-9_-]', '_', name)


# Percorrer todas as features do arquivo
for feature in geojson_data["features"]:
    properties = feature.get("properties", {})
    region_name = properties.get("nm_fcu")

    if not region_name:
        continue  # Pula caso não haja nome definido

    region_name = sanitize_filename(region_name)  # Nome sanitizado para arquivo
    file_path = os.path.join(output_dir, f"{region_name}.json")

    # Evita sobrescrita de arquivos
    counter = 1
    while os.path.exists(file_path):
        file_path = os.path.join(output_dir, f"{region_name}_{counter}.json")
        counter += 1

    jsonb_formatted = []
    geometry = feature.get("geometry", {})

    # Verificar se a geometria é um MultiPolygon ou um Polygon
    if geometry.get("type") == "MultiPolygon":
        for polygon in geometry["coordinates"]:
            for coordinates in polygon:
                jsonb_formatted.extend([{ "lat": round(coord[1], 6), "lng": round(coord[0], 6) } for coord in coordinates])
    elif geometry.get("type") == "Polygon":
        for coordinates in geometry["coordinates"]:
            jsonb_formatted.extend([{ "lat": round(coord[1], 6), "lng": round(coord[0], 6) } for coord in coordinates])
    else:
        continue  # Pula geometrias não suportadas

    # Salvar as coordenadas formatadas em arquivos individuais
    with open(file_path, "w", encoding="utf-8") as output_file:
        json.dump(jsonb_formatted, output_file, indent=2, ensure_ascii=False)

print(f"Coordenadas extraídas e salvas em arquivos separados na pasta '{output_dir}', além de um JSON consolidado para Supabase.")
