// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      name: json['name'] as String,
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      availableQuantity: (json['availableQuantity'] as num).toInt(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'totalQuantity': instance.totalQuantity,
      'availableQuantity': instance.availableQuantity,
    };
