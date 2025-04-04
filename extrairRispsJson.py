import json
import os

# Carregar o arquivo GeoJSON
with open("./dados/risps.geojson", "r", encoding="utf-8") as file:
    geojson_data = json.load(file)

# Criar diretório de saída se não existir
output_dir = "output_risps_coordinates"
os.makedirs(output_dir, exist_ok=True)

def sanitize_filename(name):
        # Normaliza os caracteres acentuados para sua versão base (exemplo: "é" → "e")
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    """Remove caracteres inválidos para nomes de arquivos."""

# Percorrer todas as features do arquivo
for feature in geojson_data["features"]:
    properties = feature["properties"]
    region_name = properties.get("RISP")  # Nome do município como chave

    if not region_name:
        continue  # Pula caso não haja nome definido

    region_name = sanitize_filename(region_name)  # Nome sanitizado para arquivo
    file_path = os.path.join(output_dir, f"{region_name}.json")

    jsonb_formatted = []
    geometry = feature["geometry"]

    # Verificar se a geometria é um MultiPolygon ou um Polygon
    if geometry["type"] == "MultiPolygon":
        for polygon in geometry["coordinates"]:
            for coordinates in polygon:
                jsonb_formatted.extend([{"lat": coord[1], "lng": coord[0]} for coord in coordinates])
    elif geometry["type"] == "Polygon":
        for coordinates in geometry["coordinates"]:
            jsonb_formatted.extend([{"lat": coord[1], "lng": coord[0]} for coord in coordinates])
    else:
        raise ValueError("Formato de geometria não suportado")

    # Salvar as coordenadas formatadas em arquivos individuais
    with open(file_path, "w", encoding="utf-8") as output_file:
        json.dump(jsonb_formatted, output_file, indent=2, ensure_ascii=False)


print(f"Coordenadas extraídas e salvas em arquivos separados na pasta '{output_dir}', além de um JSON consolidado para Supabase.")
