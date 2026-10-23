import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import 'tela_detalhes_pokemon.dart';
import 'tela_favoritos.dart';

class TelaPokemon extends StatefulWidget {
  const TelaPokemon({
    super.key,
  });

  @override
  State<TelaPokemon> createState() => _TelaPokemonState();
}

class _TelaPokemonState extends State<TelaPokemon> {
  final TextEditingController _controladorBusca = TextEditingController();

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  void _abrirDetalhes(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TelaDetalhesPokemon(
            idPokemon: id,
          );
        },
      ),
    );
  }

  void _pesquisar() {
    FocusScope.of(context).unfocus();

    context.read<PokemonProvider>().pesquisarPorNome(
          _controladorBusca.text,
        );
  }

  // Card com o resultado da pesquisa / sorteio
  Widget _cardResultado(BuildContext context, PokemonProvider provider) {
    if (provider.buscando) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.erroBusca != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          provider.erroBusca!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final pokemon = provider.resultadoBusca;

    if (pokemon == null) {
      return const SizedBox.shrink();
    }

    final bool favorito = provider.ehFavorito(pokemon['id']);

    return Card(
      color: const Color.fromARGB(255, 255, 241, 241),
      child: ListTile(
        leading: pokemon['imagem'] == null
            ? const Icon(Icons.catching_pokemon, size: 40)
            : Image.network(pokemon['imagem'], width: 70),
        title: Text(
          '#${pokemon['id']}  ${pokemon['nome'].toString().toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tipo: ${(pokemon['tipos'] as List).join(', ')}\n'
          'Altura: ${pokemon['altura']}  |  Peso: ${pokemon['peso']}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            favorito ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () {
            context.read<PokemonProvider>().alternarFavorito(pokemon);
          },
        ),
        onTap: () => _abrirDetalhes(context, pokemon['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
        ),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            icon: Badge(
              isLabelVisible: provider.favoritos.isNotEmpty,
              label: Text('${provider.favoritos.length}'),
              child: const Icon(Icons.favorite),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaFavoritos(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PARTE 1 — PESQUISA POR NOME
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controladorBusca,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _pesquisar(),
                    decoration: const InputDecoration(
                      labelText: 'Nome do Pokémon',
                      hintText: 'Ex: pikachu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pesquisar,
                  child: const Text('Pesquisar'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // PARTE 3 (A) — POKÉMON ALEATÓRIO + LISTA
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<PokemonProvider>().sortearPokemon();
                    },
                    icon: const Icon(Icons.casino),
                    label: const Text('Pokémon Aleatório'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PokemonProvider>().carregarPokemons();
                    },
                    child: const Text(
                      'Buscar Pokémon',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // RESULTADO DA PESQUISA / SORTEIO
            _cardResultado(context, provider),

            const SizedBox(height: 10),

            if (provider.carregando) const CircularProgressIndicator(),
            if (!provider.carregando)
              Expanded(
                child: ListView.builder(
                  itemCount: provider.pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = provider.pokemons[index];

                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          pokemon['imagem'],
                          width: 60,
                        ),
                        title: Text(
                          pokemon['nome'].toString().toUpperCase(),
                        ),
                        subtitle: Text(
                          'Tipo: ${pokemon['tipo']}',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () => _abrirDetalhes(context, pokemon['id']),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
