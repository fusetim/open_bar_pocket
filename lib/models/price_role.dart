enum PriceRole {
  externe,
  ceten,
  menu,
  staff_bar,
  privilegies,
  coutant;

  static const int length = 6;

  factory PriceRole.fromText(String text) {
    switch (text) {
      case "externe":
        return PriceRole.externe;
      case "ceten":
        return PriceRole.ceten;
      case "menu":
        return PriceRole.menu;
      case "staff_bar":
        return PriceRole.staff_bar;
      case "privilegies":
        return PriceRole.privilegies;
      case "coutant":
        return PriceRole.coutant;
      default:
        throw Exception("Unknown price role!");
    }
  }
}
