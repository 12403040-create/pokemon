import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import 'tela_detalhes_pokemon.dart';

class TelaFavoritos extends StatelessWidget {
  const TelaFavoritos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    final favoritos = provider.favoritos.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        centerTitle: true,
      ),
      body: favoritos.isEmpty
          ? const Center(
              child: Text('Nenhum Pokémon favorito ainda'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final pokemon = favoritos[index];

                return Card(
                  child: ListTile(
                    leading: pokemon['imagem'] == null
                        ? const Icon(Icons.catching_pokemon, size: 40)
                        : Image.network(pokemon['imagem'], width: 60),
                    title: Text(
                      pokemon['nome'].toString().toUpperCase(),
                    ),
                    subtitle: Text('Tipo: ${pokemon['tipo']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        context
                            .read<PokemonProvider>()
                            .alternarFavorito(pokemon);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TelaDetalhesPokemon(
                              idPokemon: pokemon['id'],
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
