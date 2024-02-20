class Category {
  final String name;
  final String id;
  final String? picture_uri;

  const Category({
    required this.name,
    required this.id,
    this.picture_uri,
  });

  factory Category.fromJson(Map<String, dynamic> data) {
    return Category(
        name: data["name"]! as String,
        id: data["id"]! as String,
        picture_uri: data["picture_uri"]! as String);
  }

  String getName() {
    return name;
  }

  bool hasPicture() {
    return picture_uri != null;
  }

  @override
  bool operator ==(Object other) {
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
