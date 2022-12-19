import 'package:custo_de_vida/API/categories_http_request.dart';
import 'package:custo_de_vida/API/drinks_http_request.dart';
import 'package:custo_de_vida/components/autocomplete_input.dart';
import 'package:custo_de_vida/components/hamburger_menu.dart';
import 'package:custo_de_vida/components/loading.dart';
import 'package:custo_de_vida/database/database.dart';
import 'package:custo_de_vida/models/category.dart';
import 'package:custo_de_vida/models/drink_card.dart';
import 'package:custo_de_vida/screens/details.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  List<Category> categories = [];
  List<DrinkCard> drinkCards = [];
  bool loading = false;
  bool loadingDrinks = false;

  Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  initState() {
    super.initState();
    loadCategories();
  }

  loadCategories() async {
    setState(() {
      widget.loading = true;
    });

    var db = await _getDatabaseInstance('categories.db');

    List<Category> loadedCategories = [];

    var categsFromDb = await db.categoryDao.findAll();

    if (categsFromDb.isNotEmpty) {
      print('::: CARREGOU DO DB :::');
      loadedCategories = categsFromDb;
    } else {
      var categsFromHttp = await CategoriesHttpRequest.getCategories();
      print('::: CARREGOU DO HTTP :::');
      for (var cat in categsFromHttp) {
        print('PERSISTING:: ${cat.title}');
        db.categoryDao.insertCategory(cat);
      }
      loadedCategories = categsFromHttp;
    }

    setState(() {
      widget.categories = loadedCategories;
      widget.loading = false;
    });
  }

  _loadDrinks(String categName) async {
    setState(() {
      widget.drinkCards = [];
      widget.loadingDrinks = true;
    });
    var db = await _getDatabaseInstance('drinks.db');

    List<DrinkCard> loadedDrinks = [];

    if (widget.drinkCards.isEmpty) {
      var drinksFromDb = await db.drinkDao.findAllByCategory(categName);

      if (drinksFromDb.isEmpty) {
        print('Loaded drinks from HTTP Request');
        var drinksFromHttp = await DrinksHttpRequest.getDrinks(categName);

        for (var drink in drinksFromHttp) {
          db.drinkDao.insertDrink(drink);
        }

        loadedDrinks = drinksFromHttp;
      } else {
        print('Loaded drinks from FloorDB');
        loadedDrinks = drinksFromDb;
      }

      var drinksResponse = await DrinksHttpRequest.getDrinks(categName);
      setState(() {
        widget.drinkCards = drinksResponse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const HamburgerMenu(),
        appBar: AppBar(
          title: const Text("Cocktails"),
        ),
        body: widget.loading
            ? const Loading()
            : Center(
                child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const Text(
                      'Buscar',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    AutocompleteInput(
                        labelText: 'Categoria',
                        hintText: 'Selecione uma categoria de drink',
                        options: widget.categories,
                        onOptionSelected: (categSelected) =>
                            _loadDrinks(categSelected)),
                    const Text(
                      'Resultados:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildList(),
                  ],
                ),
              )));
  }

  ListView _buildList() {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.black, height: 2),
      itemBuilder: (_, index) => _buildItem(index),
      itemCount: widget.drinkCards.length,
    );
  }

  Widget _buildItem(int index) {
    DrinkCard drink = widget.drinkCards[index];
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5)),
      child: ListTile(
        title: Text(drink.name),
        trailing: Icon(Icons.search),
        subtitle: Text(drink.category),
        onTap: () {
          // TODO: Pass drink name
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Details(drinkId: drink.drinkId)));
        },
      ),
    );
  }

  Future<AppDatabase> _getDatabaseInstance(String dbName) async =>
      await $FloorAppDatabase.databaseBuilder(dbName).build();
}
