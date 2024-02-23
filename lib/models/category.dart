import 'dart:typed_data';

class Category {
  final String name;
  final String id;
  final Uint8List? picture_data;

  const Category({
    required this.name,
    required this.id,
    required this.picture_data,
  });

  String getName() {
    return name;
  }

  bool hasPicture() {
    return picture_data != null;
  }

  @override
  bool operator ==(Object other) {
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
