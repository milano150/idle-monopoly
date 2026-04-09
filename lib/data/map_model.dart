import 'package:flutter/material.dart';

enum PropertyType { city, railway, airport }

class CityModel {
  final String name;
  final int cost;
  final int rent;
  final String state;
  final Color color;
  final PropertyType type;

  CityModel({
    required this.name,
    required this.cost,
    required this.rent,
    required this.state,
    required this.color,
    this.type = PropertyType.city,
  });
}
