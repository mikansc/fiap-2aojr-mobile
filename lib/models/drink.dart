class Drink {
 late String name;
 late String thumb;
 late String? id;
 late String category;
 late String alcoholic;
 late String instructions;


 Drink(
      {required this.name,
      required this.thumb,
      this.id,
      required this.category,
      required this.alcoholic,
      required this.instructions});

  Drink.fromJson(Map<String, dynamic> json) {
    name = json['strDrink'];
    thumb = json['strDrinkThumb'];
    id = json['idDrink'];
    category = json['strCategory'];
    alcoholic = json['strAlcoholic'];
    instructions = json['strInstructions'];
  }
}