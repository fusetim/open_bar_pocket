class Category {
  final String name;
  final String? image_url;
  final String? ident;

  const Category({required this.name, this.image_url, this.ident});

  String getName() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    return other is Category &&
        other.ident == ident &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(ident, name);
}
