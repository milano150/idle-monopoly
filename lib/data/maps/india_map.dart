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

  // ================= Uttar Pradesh =================
  CityModel(
    name: 'Lucknow',
    cost: 360,
    rent: 160,
    state: 'Uttar Pradesh',
    color: Colors.indigo,
  ),
  CityModel(
    name: 'Kanpur',
    cost: 300,
    rent: 130,
    state: 'Uttar Pradesh',
    color: Colors.indigo,
  ),
  CityModel(
    name: 'Varanasi',
    cost: 280,
    rent: 120,
    state: 'Uttar Pradesh',
    color: Colors.indigo,
  ),

  // ================= Rajasthan =================
  CityModel(
    name: 'Jaipur',
    cost: 380,
    rent: 170,
    state: 'Rajasthan',
    color: Colors.deepOrange,
  ),
  CityModel(
    name: 'Udaipur',
    cost: 320,
    rent: 140,
    state: 'Rajasthan',
    color: Colors.deepOrange,
  ),
  CityModel(
    name: 'Jodhpur',
    cost: 300,
    rent: 130,
    state: 'Rajasthan',
    color: Colors.deepOrange,
  ),

  // ================= Telangana =================
  CityModel(
    name: 'Hyderabad',
    cost: 460,
    rent: 200,
    state: 'Telangana',
    color: Colors.cyan,
  ),
  CityModel(
    name: 'Warangal',
    cost: 300,
    rent: 130,
    state: 'Telangana',
    color: Colors.cyan,
  ),
  CityModel(
    name: 'Nizamabad',
    cost: 260,
    rent: 110,
    state: 'Telangana',
    color: Colors.cyan,
  ),

  // ================= Andhra Pradesh =================
  CityModel(
    name: 'Visakhapatnam',
    cost: 420,
    rent: 180,
    state: 'Andhra Pradesh',
    color: Colors.lightBlue,
  ),
  CityModel(
    name: 'Vijayawada',
    cost: 340,
    rent: 150,
    state: 'Andhra Pradesh',
    color: Colors.lightBlue,
  ),
  CityModel(
    name: 'Guntur',
    cost: 280,
    rent: 120,
    state: 'Andhra Pradesh',
    color: Colors.lightBlue,
  ),

  // ================= Punjab =================
  CityModel(
    name: 'Amritsar',
    cost: 360,
    rent: 160,
    state: 'Punjab',
    color: Colors.yellow,
  ),
  CityModel(
    name: 'Ludhiana',
    cost: 320,
    rent: 140,
    state: 'Punjab',
    color: Colors.yellow,
  ),
  CityModel(
    name: 'Jalandhar',
    cost: 300,
    rent: 130,
    state: 'Punjab',
    color: Colors.yellow,
  ),

  // ================= Madhya Pradesh =================
  CityModel(
    name: 'Indore',
    cost: 380,
    rent: 170,
    state: 'Madhya Pradesh',
    color: Colors.greenAccent,
  ),
  CityModel(
    name: 'Bhopal',
    cost: 340,
    rent: 150,
    state: 'Madhya Pradesh',
    color: Colors.greenAccent,
  ),
  CityModel(
    name: 'Gwalior',
    cost: 280,
    rent: 120,
    state: 'Madhya Pradesh',
    color: Colors.greenAccent,
  ),

  // ================= Bihar =================
  CityModel(name: 'Patna', cost: 340, rent: 150, state: 'Bihar', color: Colors.deepPurple),
  CityModel(name: 'Gaya', cost: 280, rent: 120, state: 'Bihar', color: Colors.deepPurple),
  CityModel(name: 'Bhagalpur', cost: 260, rent: 110, state: 'Bihar', color: Colors.deepPurple),

  // ================= Haryana =================
  CityModel(name: 'Gurgaon', cost: 420, rent: 180, state: 'Haryana', color: Colors.lime),
  CityModel(name: 'Faridabad', cost: 320, rent: 140, state: 'Haryana', color: Colors.lime),
  CityModel(name: 'Panipat', cost: 280, rent: 120, state: 'Haryana', color: Colors.lime),

  // ================= Himachal Pradesh =================
  CityModel(name: 'Shimla', cost: 320, rent: 140, state: 'Himachal Pradesh', color: Colors.lightBlue),
  CityModel(name: 'Manali', cost: 300, rent: 130, state: 'Himachal Pradesh', color: Colors.lightBlue),
  CityModel(name: 'Dharamshala', cost: 280, rent: 120, state: 'Himachal Pradesh', color: Colors.lightBlue),

  // ================= Jharkhand =================
  CityModel(name: 'Ranchi', cost: 320, rent: 140, state: 'Jharkhand', color: Colors.greenAccent),
  CityModel(name: 'Jamshedpur', cost: 300, rent: 130, state: 'Jharkhand', color: Colors.greenAccent),
  CityModel(name: 'Dhanbad', cost: 280, rent: 120, state: 'Jharkhand', color: Colors.greenAccent),

  // ================= Chhattisgarh =================
  CityModel(name: 'Raipur', cost: 320, rent: 140, state: 'Chhattisgarh', color: Colors.blueGrey),
  CityModel(name: 'Bhilai', cost: 300, rent: 130, state: 'Chhattisgarh', color: Colors.blueGrey),
  CityModel(name: 'Bilaspur', cost: 280, rent: 120, state: 'Chhattisgarh', color: Colors.blueGrey),

  // ================= Odisha =================
  CityModel(name: 'Bhubaneswar', cost: 360, rent: 160, state: 'Odisha', color: Colors.orangeAccent),
  CityModel(name: 'Cuttack', cost: 300, rent: 130, state: 'Odisha', color: Colors.orangeAccent),
  CityModel(name: 'Rourkela', cost: 280, rent: 120, state: 'Odisha', color: Colors.orangeAccent),

  // ================= Assam =================
  CityModel(name: 'Guwahati', cost: 360, rent: 160, state: 'Assam', color: Colors.lightGreen),
  CityModel(name: 'Silchar', cost: 280, rent: 120, state: 'Assam', color: Colors.lightGreen),
  CityModel(name: 'Dibrugarh', cost: 260, rent: 110, state: 'Assam', color: Colors.lightGreen),

  // ================= Arunachal Pradesh =================
  CityModel(name: 'Itanagar', cost: 280, rent: 120, state: 'Arunachal Pradesh', color: Colors.cyanAccent),
  CityModel(name: 'Tawang', cost: 260, rent: 110, state: 'Arunachal Pradesh', color: Colors.cyanAccent),
  CityModel(name: 'Ziro', cost: 250, rent: 100, state: 'Arunachal Pradesh', color: Colors.cyanAccent),

  // ================= Meghalaya =================
  CityModel(name: 'Shillong', cost: 300, rent: 130, state: 'Meghalaya', color: Colors.tealAccent),
  CityModel(name: 'Tura', cost: 260, rent: 110, state: 'Meghalaya', color: Colors.tealAccent),
  CityModel(name: 'Nongpoh', cost: 240, rent: 100, state: 'Meghalaya', color: Colors.tealAccent),

  // ================= Manipur =================
  CityModel(name: 'Imphal', cost: 300, rent: 130, state: 'Manipur', color: Colors.indigoAccent),
  CityModel(name: 'Thoubal', cost: 260, rent: 110, state: 'Manipur', color: Colors.indigoAccent),
  CityModel(name: 'Churachandpur', cost: 240, rent: 100, state: 'Manipur', color: Colors.indigoAccent),

  // ================= Mizoram =================
  CityModel(name: 'Aizawl', cost: 300, rent: 130, state: 'Mizoram', color: Colors.blueAccent),
  CityModel(name: 'Lunglei', cost: 260, rent: 110, state: 'Mizoram', color: Colors.blueAccent),
  CityModel(name: 'Champhai', cost: 240, rent: 100, state: 'Mizoram', color: Colors.blueAccent),

  // ================= Nagaland =================
  CityModel(name: 'Kohima', cost: 300, rent: 130, state: 'Nagaland', color: Colors.deepOrangeAccent),
  CityModel(name: 'Dimapur', cost: 280, rent: 120, state: 'Nagaland', color: Colors.deepOrangeAccent),
  CityModel(name: 'Mokokchung', cost: 250, rent: 100, state: 'Nagaland', color: Colors.deepOrangeAccent),

  // ================= Tripura =================
  CityModel(name: 'Agartala', cost: 300, rent: 130, state: 'Tripura', color: Colors.purpleAccent),
  CityModel(name: 'Udaipur', cost: 260, rent: 110, state: 'Tripura', color: Colors.purpleAccent),
  CityModel(name: 'Dharmanagar', cost: 240, rent: 100, state: 'Tripura', color: Colors.purpleAccent),

  // ================= Sikkim =================
  CityModel(name: 'Gangtok', cost: 300, rent: 130, state: 'Sikkim', color: Colors.green),
  CityModel(name: 'Namchi', cost: 260, rent: 110, state: 'Sikkim', color: Colors.green),
  CityModel(name: 'Gyalshing', cost: 240, rent: 100, state: 'Sikkim', color: Colors.green),

  // ================= Uttarakhand =================
  CityModel(name: 'Dehradun', cost: 340, rent: 150, state: 'Uttarakhand', color: Colors.blue),
  CityModel(name: 'Haridwar', cost: 300, rent: 130, state: 'Uttarakhand', color: Colors.blue),
  CityModel(name: 'Nainital', cost: 280, rent: 120, state: 'Uttarakhand', color: Colors.blue),

  // ================= Goa =================
  CityModel(name: 'Panaji', cost: 380, rent: 170, state: 'Goa', color: Colors.teal),
  CityModel(name: 'Margao', cost: 300, rent: 130, state: 'Goa', color: Colors.teal),
  CityModel(name: 'Vasco da Gama', cost: 280, rent: 120, state: 'Goa', color: Colors.teal),

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
