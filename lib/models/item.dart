import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final String name;
  int totalQuantity;
  int availableQuantity;

  Item({
    required this.name,
    required this.totalQuantity,
    required this.availableQuantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
