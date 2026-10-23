import 'package:flutter/material.dart';

import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  List<dynamic> pokemons = [];

  Map<String, dynamic>? pokemonSelecionado;

  bool carregando = false;

  // PARTE 1 e 3 — resultado da pesquisa / sorteio
  Map<String, dynamic>? resultadoBusca;

  bool buscando = false;

  String? erroBusca;

  // PARTE 3 (Opção D) — favoritos (id -> resumo do Pokémon)
  final Map<int, Map<String, dynamic>> favoritos = {};

  Future<void> carregarPokemons() async {
    carregando = true;

    notifyListeners();

    try {
      pokemons = await PokemonService.buscarPokemons();
    } catch (e) {
      pokemons = [];
    }

    carregando = false;

    notifyListeners();
  }

  Future<void> carregarDetalhes(
    int id,
  ) async {
    carregando = true;

    pokemonSelecionado = null;

    notifyListeners();

    try {
      pokemonSelecionado = await PokemonService.buscarDetalhes(
        id,
      );
    } catch (e) {
      pokemonSelecionado = null;
    }

    carregando = false;

    notifyListeners();
  }

  // PARTE 1 — PESQUISAR POR NOME
  Future<void> pesquisarPorNome(String nome) async {
    if (nome.trim().isEmpty) {
      resultadoBusca = null;
      erroBusca = 'Digite o nome de um Pokémon';
      notifyListeners();
      return;
    }

    await _executarBusca(
      () => PokemonService.buscarPorNome(nome),
    );
  }

  // PARTE 3 (A) — POKÉMON ALEATÓRIO
  Future<void> sortearPokemon() async {
    await _executarBusca(
      () => PokemonService.buscarAleatorio(),
    );
  }

  Future<void> _executarBusca(
    Future<Map<String, dynamic>> Function() busca,
  ) async {
    buscando = true;
    resultadoBusca = null;
    erroBusca = null;

    notifyListeners();

    try {
      resultadoBusca = await busca();
    } catch (e) {
      erroBusca = e.toString().replaceFirst('Exception: ', '');
    }

    buscando = false;

    notifyListeners();
  }

  void limparBusca() {
    resultadoBusca = null;
    erroBusca = null;
    notifyListeners();
  }

  // PARTE 3 (D) — FAVORITOS
  bool ehFavorito(int id) => favoritos.containsKey(id);

  void alternarFavorito(Map<String, dynamic> pokemon) {
    final int id = pokemon['id'];

    if (favoritos.containsKey(id)) {
      favoritos.remove(id);
    } else {
      favoritos[id] = {
        'id': pokemon['id'],
        'nome': pokemon['nome'],
        'imagem': pokemon['imagem'],
        'tipo': pokemon['tipo'] ??
            ((pokemon['tipos'] as List).isNotEmpty
                ? pokemon['tipos'][0]
                : ''),
      };
    }

    notifyListeners();
  }
}
