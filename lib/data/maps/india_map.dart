import 'package:flutter/material.dart';
import '../map_model.dart';

List<CityModel> indiaMap = [

  // ================= Maharashtra =================
  CityModel(
    name: 'Mumbai',
    cost: 520,
    rent: 230,
    state: 'Maharashtra',
    color: Colors.orange,
  ),
  CityModel(
    name: 'Pune',
    cost: 380,
    rent: 170,
    state: 'Maharashtra',
    color: Colors.orange,
  ),
  CityModel(
    name: 'Nagpur',
    cost: 300,
    rent: 130,
    state: 'Maharashtra',
    color: Colors.orange,
  ),

  // ================= Karnataka =================
  CityModel(
    name: 'Bangalore',
    cost: 480,
    rent: 210,
    state: 'Karnataka',
    color: Colors.blue,
  ),
  CityModel(
    name: 'Mysore',
    cost: 320,
    rent: 140,
    state: 'Karnataka',
    color: Colors.blue,
  ),
  CityModel(
    name: 'Mangalore',
    cost: 300,
    rent: 130,
    state: 'Karnataka',
    color: Colors.blue,
  ),

  // ================= Tamil Nadu =================
  CityModel(
    name: 'Chennai',
    cost: 450,
    rent: 200,
    state: 'Tamil Nadu',
    color: Colors.red,
  ),
  CityModel(
    name: 'Coimbatore',
    cost: 320,
    rent: 140,
    state: 'Tamil Nadu',
    color: Colors.red,
  ),
  CityModel(
    name: 'Madurai',
    cost: 260,
    rent: 110,
    state: 'Tamil Nadu',
    color: Colors.red,
  ),

  // ================= Kerala =================
  CityModel(
    name: 'Kochi',
    cost: 380,
    rent: 170,
    state: 'Kerala',
    color: Colors.green,
  ),
  CityModel(
    name: 'Thiruvananthapuram',
    cost: 320,
    rent: 140,
    state: 'Kerala',
    color: Colors.green,
  ),
  CityModel(
    name: 'Kozhikode',
    cost: 280,
    rent: 120,
    state: 'Kerala',
    color: Colors.green,
  ),

  // ================= Gujarat =================
  CityModel(
    name: 'Ahmedabad',
    cost: 400,
    rent: 180,
    state: 'Gujarat',
    color: Colors.purple,
  ),
  CityModel(
    name: 'Surat',
    cost: 340,
    rent: 150,
    state: 'Gujarat',
    color: Colors.purple,
  ),
  CityModel(
    name: 'Vadodara',
    cost: 280,
    rent: 120,
    state: 'Gujarat',
    color: Colors.purple,
  ),

  // ================= West Bengal =================
  CityModel(
    name: 'Kolkata',
    cost: 420,
    rent: 190,
    state: 'West Bengal',
    color: Colors.teal,
  ),
  CityModel(
    name: 'Howrah',
    cost: 300,
    rent: 130,
    state: 'West Bengal',
    color: Colors.teal,
  ),
  CityModel(
    name: 'Durgapur',
    cost: 260,
    rent: 110,
    state: 'West Bengal',
    color: Colors.teal,
  ),

  // ================= RAILWAYS =================

CityModel(
  name: 'Northern Rail Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Southern Rail Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Eastern Rail Corridor',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Western Rail Route',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Central Rail Network',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Coastal Rail Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

// ================= AIRPORTS =================

  CityModel(
    name: 'Delhi International Airport',
    cost: 500,
    rent: 150,
    state: 'Airport',
    color: Colors.grey,
    type: PropertyType.airport,
  ),

  CityModel(
    name: 'Mumbai International Airport',
    cost: 500,
    rent: 150,
    state: 'Airport',
    color: Colors.grey,
    type: PropertyType.airport,
  ),

  CityModel(
    name: 'Bangalore International Airport',
    cost: 500,
    rent: 150,
    state: 'Airport',
    color: Colors.grey,
    type: PropertyType.airport,
  ),

  CityModel(
    name: 'Hyderabad International Airport',
    cost: 500,
    rent: 150,
    state: 'Airport',
    color: Colors.grey,
    type: PropertyType.airport,
  ),
];
