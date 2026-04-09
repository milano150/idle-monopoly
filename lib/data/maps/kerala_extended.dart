import 'package:flutter/material.dart';
import '../map_model.dart';

List<CityModel> keralaExtendedMap = [

  // ================= Thiruvananthapuram =================
  CityModel(name: 'Thiruvananthapuram', cost: 420, rent: 200, state: 'Thiruvananthapuram', color: Colors.green),
  CityModel(name: 'Neyyattinkara', cost: 280, rent: 130, state: 'Thiruvananthapuram', color: Colors.green),
  CityModel(name: 'Attingal', cost: 250, rent: 115, state: 'Thiruvananthapuram', color: Colors.green),

  // ================= Kollam =================
  CityModel(name: 'Kollam', cost: 380, rent: 180, state: 'Kollam', color: Colors.teal),
  CityModel(name: 'Karunagappally', cost: 260, rent: 120, state: 'Kollam', color: Colors.teal),
  CityModel(name: 'Punalur', cost: 230, rent: 105, state: 'Kollam', color: Colors.teal),

  // ================= Pathanamthitta =================
  CityModel(name: 'Pathanamthitta', cost: 320, rent: 150, state: 'Pathanamthitta', color: Colors.lightGreen),
  CityModel(name: 'Adoor', cost: 240, rent: 110, state: 'Pathanamthitta', color: Colors.lightGreen),
  CityModel(name: 'Thiruvalla', cost: 290, rent: 135, state: 'Pathanamthitta', color: Colors.lightGreen),

  // ================= Alappuzha =================
  CityModel(name: 'Alappuzha', cost: 350, rent: 165, state: 'Alappuzha', color: Colors.cyan),
  CityModel(name: 'Cherthala', cost: 260, rent: 120, state: 'Alappuzha', color: Colors.cyan),
  CityModel(name: 'Kayamkulam', cost: 240, rent: 110, state: 'Alappuzha', color: Colors.cyan),

  // ================= Kottayam =================
  CityModel(name: 'Kottayam', cost: 370, rent: 175, state: 'Kottayam', color: Colors.blue),
  CityModel(name: 'Changanassery', cost: 260, rent: 120, state: 'Kottayam', color: Colors.blue),
  CityModel(name: 'Pala', cost: 240, rent: 110, state: 'Kottayam', color: Colors.blue),

  // ================= Idukki =================
  CityModel(name: 'Thodupuzha', cost: 300, rent: 140, state: 'Idukki', color: Colors.brown),
  CityModel(name: 'Munnar', cost: 330, rent: 155, state: 'Idukki', color: Colors.brown),
  CityModel(name: 'Kattappana', cost: 220, rent: 100, state: 'Idukki', color: Colors.brown),

  // ================= Ernakulam =================
  CityModel(name: 'Kochi', cost: 480, rent: 230, state: 'Ernakulam', color: Colors.deepPurple),
  CityModel(name: 'Aluva', cost: 290, rent: 135, state: 'Ernakulam', color: Colors.deepPurple),
  CityModel(name: 'Perumbavoor', cost: 260, rent: 120, state: 'Ernakulam', color: Colors.deepPurple),

  // ================= Thrissur =================
  CityModel(name: 'Thrissur', cost: 420, rent: 200, state: 'Thrissur', color: Colors.orange),
  CityModel(name: 'Guruvayur', cost: 290, rent: 135, state: 'Thrissur', color: Colors.orange),
  CityModel(name: 'Chalakudy', cost: 260, rent: 120, state: 'Thrissur', color: Colors.orange),

  // ================= Palakkad =================
  CityModel(name: 'Palakkad', cost: 350, rent: 165, state: 'Palakkad', color: Colors.amber),
  CityModel(name: 'Ottapalam', cost: 240, rent: 110, state: 'Palakkad', color: Colors.amber),
  CityModel(name: 'Mannarkkad', cost: 220, rent: 100, state: 'Palakkad', color: Colors.amber),

  // ================= Malappuram =================
  CityModel(name: 'Malappuram', cost: 370, rent: 175, state: 'Malappuram', color: Colors.red),
  CityModel(name: 'Manjeri', cost: 270, rent: 125, state: 'Malappuram', color: Colors.red),
  CityModel(name: 'Tirur', cost: 260, rent: 120, state: 'Malappuram', color: Colors.red),

  // ================= Kozhikode =================
  CityModel(name: 'Kozhikode', cost: 420, rent: 200, state: 'Kozhikode', color: Colors.indigo),
  CityModel(name: 'Vadakara', cost: 260, rent: 120, state: 'Kozhikode', color: Colors.indigo),
  CityModel(name: 'Koyilandy', cost: 240, rent: 110, state: 'Kozhikode', color: Colors.indigo),

  // ================= Wayanad =================
  CityModel(name: 'Kalpetta', cost: 300, rent: 140, state: 'Wayanad', color: Colors.greenAccent),
  CityModel(name: 'Sulthan Bathery', cost: 270, rent: 125, state: 'Wayanad', color: Colors.greenAccent),
  CityModel(name: 'Mananthavady', cost: 240, rent: 110, state: 'Wayanad', color: Colors.greenAccent),

  // ================= Kannur =================
  CityModel(name: 'Kannur', cost: 380, rent: 180, state: 'Kannur', color: Colors.blueGrey),
  CityModel(name: 'Thalassery', cost: 270, rent: 125, state: 'Kannur', color: Colors.blueGrey),
  CityModel(name: 'Payyannur', cost: 240, rent: 110, state: 'Kannur', color: Colors.blueGrey),

  // ================= Kasaragod =================
  CityModel(name: 'Kasaragod', cost: 320, rent: 150, state: 'Kasaragod', color: Colors.purple),
  CityModel(name: 'Kanhangad', cost: 260, rent: 120, state: 'Kasaragod', color: Colors.purple),
  CityModel(name: 'Uppala', cost: 220, rent: 100, state: 'Kasaragod', color: Colors.purple),

  // ================= RAILWAYS =================

CityModel(
  name: 'Southern Railway Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Konkan Coastal Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Malabar Express Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Travancore Rail Route',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Western Ghats Line',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

CityModel(
  name: 'Backwater Rail Corridor',
  cost: 300,
  rent: 50,
  state: 'Railway',
  color: Colors.black,
  type: PropertyType.railway,
),

// ================= AIRPORTS =================

CityModel(
  name: 'Trivandrum International Airport',
  cost: 500,
  rent: 100,
  state: 'Airport',
  color: Colors.grey,
  type: PropertyType.airport,
),

CityModel(
  name: 'Cochin International Airport',
  cost: 500,
  rent: 100,
  state: 'Airport',
  color: Colors.grey,
  type: PropertyType.airport,
),

CityModel(
  name: 'Calicut International Airport',
  cost: 500,
  rent: 100,
  state: 'Airport',
  color: Colors.grey,
  type: PropertyType.airport,
),

CityModel(
  name: 'Kannur International Airport',
  cost: 500,
  rent: 100,
  state: 'Airport',
  color: Colors.grey,
  type: PropertyType.airport,
),

];
