// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Renter _$RenterFromJson(Map<String, dynamic> json) => Renter(
      name: json['name'] as String,
      phone: json['phone'] as String,
      rentDate: DateTime.parse(json['rentDate'] as String),
      returnDate: DateTime.parse(json['returnDate'] as String),
      rentedItems: Map<String, int>.from(json['rentedItems'] as Map),
    );

Map<String, dynamic> _$RenterToJson(Renter instance) => <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'rentDate': instance.rentDate.toIso8601String(),
      'returnDate': instance.returnDate.toIso8601String(),
      'rentedItems': instance.rentedItems,
    };
