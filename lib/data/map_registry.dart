import 'maps/kerala_map.dart';
import 'maps/india_map.dart';
import 'map_model.dart';
import 'maps/kerala_extended.dart';


class GameMapRegistry {

  static List<CityModel> getMap(String mapName) {
    switch (mapName) {
      case 'kerala':
        return keralaMap;

      case 'india':
        return indiaMap;

      case 'kerala_extended':
        return keralaExtendedMap;


      default:
        return keralaMap;
    }
  }
}
