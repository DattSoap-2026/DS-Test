// Maharashtra Administrative Divisions
// 6 Zones (Divisions) → 36 Districts

class MaharashtraZones {
  static const Map<String, List<String>> zoneDistrictMap = {
    'Konkan Division': [
      'Mumbai City',
      'Mumbai Suburban',
      'Thane',
      'Palghar',
      'Raigad',
      'Ratnagiri',
      'Sindhudurg',
    ],
    'Pune Division': ['Pune', 'Satara', 'Sangli', 'Kolhapur', 'Solapur'],
    'Nashik Division': [
      'Nashik',
      'Ahmednagar',
      'Jalgaon',
      'Dhule',
      'Nandurbar',
    ],
    'Chhatrapati Sambhajinagar Division': [
      'Chhatrapati Sambhajinagar',
      'Jalna',
      'Beed',
      'Dharashiv',
      'Latur',
      'Nanded',
      'Parbhani',
      'Hingoli',
    ],
    'Amravati Division': [
      'Amravati',
      'Akola',
      'Washim',
      'Buldhana',
      'Yavatmal',
    ],
    'Nagpur Division': [
      'Nagpur',
      'Wardha',
      'Chandrapur',
      'Gadchiroli',
      'Bhandara',
      'Gondia',
    ],
  };

  static List<String> get zones => zoneDistrictMap.keys.toList();

  static List<String> getDistricts(String zone) {
    return zoneDistrictMap[zone] ?? [];
  }

  static String? getZoneForDistrict(String district) {
    for (var entry in zoneDistrictMap.entries) {
      if (entry.value.contains(district)) {
        return entry.key;
      }
    }
    return null;
  }
}
