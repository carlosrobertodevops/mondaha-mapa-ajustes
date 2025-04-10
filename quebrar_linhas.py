from geopy.distance import geodesic

def quebrar_linhas_distantes(pontos, limite_km=50):
    """
    Quebra a linha entre pontos distantes demais.
    
    Args:
        pontos (list): lista de dicionários {"lat": float, "lng": float}
        limite_km (float): distância máxima permitida entre dois pontos consecutivos
    
    Returns:
        list: nova lista com None como quebra entre segmentos
    """
    resultado = []

    for i in range(len(pontos) - 1):
        resultado.append(pontos[i])
        dist = geodesic(
            (pontos[i]["lat"], pontos[i]["lng"]),
            (pontos[i + 1]["lat"], pontos[i + 1]["lng"])
        ).km
        if dist >= limite_km:
            resultado.append(None)

    resultado.append(pontos[-1])
    return resultado
