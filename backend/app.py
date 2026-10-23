import random

from flask import Flask, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)

CORS(app)

POKEAPI = "https://pokeapi.co/api/v2"
TOTAL_POKEMONS = 1025 

def consultar_pokeapi(identificador):
    """
    Consulta /pokemon/<id ou nome> na PokéAPI.

    Retorna (dados, None) em caso de sucesso
    ou (None, (resposta_json, status)) em caso de erro.
    """
    try:
        resposta = requests.get(
            f"{POKEAPI}/pokemon/{identificador}",
            timeout=10
        )
    except requests.RequestException:
        return None, (
            jsonify({"erro": "PokéAPI indisponível"}),
            502
        )

    if resposta.status_code == 404:
        return None, (
            jsonify({"erro": "Pokémon não encontrado"}),
            404
        )

    if resposta.status_code != 200:
        return None, (
            jsonify({"erro": "Erro ao consultar a PokéAPI"}),
            502
        )

    return resposta.json(), None


def formatar_resumo(dados):
    """JSON resumido usado na pesquisa por nome e no aleatório."""

    tipos = [t["type"]["name"] for t in dados["types"]]

    return {
        "id": dados["id"],
        "nome": dados["name"],
        "imagem": dados["sprites"]["front_default"],
        "tipo": tipos[0],
        "tipos": tipos,
        "altura": dados["height"],
        "peso": dados["weight"]
    }



@app.route("/pokemons", methods=["GET"])
def listar_pokemons():

    resposta = requests.get(
        "https://pokeapi.co/api/v2/pokemon?limit=30"
    )

    dados = resposta.json()

    pokemons = []

    for pokemon in dados["results"]:

        detalhes = requests.get(
            pokemon["url"]
        ).json()

        pokemon_formatado = {
            "id": detalhes["id"],
            "nome": detalhes["name"],
            "imagem": detalhes["sprites"]["front_default"],
            "tipo": detalhes["types"][0]["type"]["name"]
        }

        pokemons.append(
            pokemon_formatado
        )

    return jsonify(pokemons)


@app.route("/pokemons/nome/<nome>", methods=["GET"])
def buscar_por_nome(nome):

    nome = nome.strip().lower()

    if nome == "":
        return jsonify({"erro": "Informe um nome"}), 400

    dados, erro = consultar_pokeapi(nome)

    if erro:
        return erro

    return jsonify(formatar_resumo(dados))


@app.route("/pokemons/aleatorio", methods=["GET"])
def pokemon_aleatorio():

    id_sorteado = random.randint(1, TOTAL_POKEMONS)

    dados, erro = consultar_pokeapi(id_sorteado)

    if erro:
        return erro

    return jsonify(formatar_resumo(dados))



@app.route("/pokemons/<int:id>", methods=["GET"])
def detalhes_pokemon(id):

    dados, erro = consultar_pokeapi(id)

    if erro:
        return erro

    tipos = []

    for tipo in dados["types"]:
        tipos.append(
            tipo["type"]["name"]
        )

    habilidades = []

    for habilidade in dados["abilities"]:
        habilidades.append(
            habilidade["ability"]["name"]
        )


    stats = {}

    for stat in dados["stats"]:
        stats[stat["stat"]["name"]] = stat["base_stat"]

    pokemon = {
        "id": dados["id"],
        "nome": dados["name"],
        "imagem": dados["sprites"]["front_default"],
        "altura": dados["height"],
        "peso": dados["weight"],
        "experiencia": dados["base_experience"],
        "tipos": tipos,
        "habilidades": habilidades,
        "hp": stats.get("hp"),
        "ataque": stats.get("attack"),
        "defesa": stats.get("defense"),
    
        "velocidade": stats.get("speed"),
        "ataque_especial": stats.get("special-attack")
    }

    return jsonify(pokemon)


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=True
    )
