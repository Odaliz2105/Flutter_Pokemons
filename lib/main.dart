import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'models/pokemon.dart';
import 'services/pokemon_service.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Infinite Scroll',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  static const pageSize = 5;

  final TextEditingController _searchController =
      TextEditingController();

  Pokemon? searchedPokemon;

  late final PagingController<int, Pokemon> _pagingController =
      PagingController(
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) {
        return null;
      }

      return state.pages
              ?.expand((e) => e)
              .length ??
          0;
    },
    fetchPage: (pageKey) async {
      return PokemonService.fetchPokemons(
        pageKey,
        pageSize,
      );
    },
  );

  Future<void> searchPokemon() async {
    final name =
        _searchController.text.trim().toLowerCase();

    if (name.isEmpty) return;

    try {
      final pokemon =
          await PokemonService.fetchPokemonByName(
        name,
      );

      setState(() {
        searchedPokemon = pokemon;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pokémon no encontrado",
          ),
        ),
      );
    }
  }

  void showAllPokemons() {
    setState(() {
      searchedPokemon = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget buildPokemonCard(Pokemon pokemon) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Image.network(
  pokemon.image,
  height: 120,
  errorBuilder: (context, error, stackTrace) {
    return const Icon(
      Icons.image_not_supported,
      size: 80,
    );
  },
),

            Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("ID: ${pokemon.id}"),
            Text("Altura: ${pokemon.height}"),
            Text("Peso: ${pokemon.weight}"),
            Text("Experiencia: ${pokemon.baseExperience}"),
            Text("Orden: ${pokemon.order}"),

            Text(
              "Tipo: ${pokemon.types.map((e) => e['type']['name']).join(', ')}",
            ),

            Text(
              "Habilidades: ${pokemon.abilities.map((e) => e['ability']['name']).join(', ')}",
            ),

            Text(
              "Cantidad Tipos: ${pokemon.types.length}",
            ),

            Text(
              "Cantidad Habilidades: ${pokemon.abilities.length}",
            ),

            Text(
              "Imagen disponible: ${pokemon.image.isNotEmpty}",
            ),

            const Divider(),

            const Text(
              "Hecho por Odaliz Balseca Valencia",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pokémon Infinite Scroll",
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar Pokémon",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: searchPokemon,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => searchPokemon(),
            ),
          ),

          ElevatedButton.icon(
            onPressed: showAllPokemons,
            icon: const Icon(Icons.refresh),
            label: const Text(
              "Mostrar Todos",
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: searchedPokemon != null
                ? ListView(
                    children: [
                      buildPokemonCard(
                        searchedPokemon!,
                      ),
                    ],
                  )
                : PagingListener(
                    controller: _pagingController,
                    builder: (
                      context,
                      state,
                      fetchNextPage,
                    ) {
                      return PagedListView<int, Pokemon>(
                        state: state,
                        fetchNextPage:
                            fetchNextPage,
                        builderDelegate:
                            PagedChildBuilderDelegate<
                                Pokemon>(
                          itemBuilder: (
                            context,
                            pokemon,
                            index,
                          ) {
                            return buildPokemonCard(
                              pokemon,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}