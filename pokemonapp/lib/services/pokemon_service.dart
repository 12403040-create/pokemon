import 'dart:convert';

import 'package:http/http.dart' as http;

class PokemonService {
  static const String url = 'http://127.0.0.1:5001/pokemons';

  // BUSCAR TODOS
  static Future<List<dynamic>> buscarPokemons() async {
    final resposta = await http.get(
      Uri.parse(url),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao buscar Pokémon',
    );
  }

  // BUSCAR UM POKÉMON
  static Future<Map<String, dynamic>> buscarDetalhes(int id) async {
    final resposta = await http.get(
      Uri.parse(
        '$url/$id',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao buscar detalhes',
    );
  }

  // PARTE 1 — BUSCAR POR NOME
  // GET /pokemons/nome/<nome>
  static Future<Map<String, dynamic>> buscarPorNome(String nome) async {
    final resposta = await http.get(
      Uri.parse(
        '$url/nome/${Uri.encodeComponent(nome.trim().toLowerCase())}',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    if (resposta.statusCode == 404) {
      throw Exception(
        'Pokémon "$nome" não encontrado',
      );
    }

    throw Exception(
      'Erro ao pesquisar Pokémon',
    );
  }

  // PARTE 3 (Opção A) — POKÉMON ALEATÓRIO
  // GET /pokemons/aleatorio
  static Future<Map<String, dynamic>> buscarAleatorio() async {
    final resposta = await http.get(
      Uri.parse(
        '$url/aleatorio',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao sortear Pokémon',
    );
  }
}
