import 'package:json_annotation/json_annotation.dart';

part 'renter.g.dart';

@JsonSerializable()
class Renter {
  String name;
  String phone;
  DateTime rentDate;
  DateTime returnDate;
  Map<String, int> rentedItems; // Item name and quantity

  Renter({
    required this.name,
    required this.phone,
    required this.rentDate,
    required this.returnDate,
    required this.rentedItems,
  });

  factory Renter.fromJson(Map<String, dynamic> json) => _$RenterFromJson(json);
  Map<String, dynamic> toJson() => _$RenterToJson(this);
}
