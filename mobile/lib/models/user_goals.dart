import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors web `DEFAULT_GOALS` / `userGoals` in localStorage.
class UserGoals {
  const UserGoals({
    required this.water,
    required this.steps,
    required this.calories,
    required this.sleep,
  });

  final double water;
  final double steps;
  final double calories;
  final double sleep;

  static const UserGoals defaults = UserGoals(
    water: 2.5,
    steps: 10000,
    calories: 2200,
    sleep: 8,
  );

  UserGoals copyWith({
    double? water,
    double? steps,
    double? calories,
    double? sleep,
  }) {
    return UserGoals(
      water: water ?? this.water,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      sleep: sleep ?? this.sleep,
    );
  }

  Map<String, dynamic> toJson() => {
        'water': water,
        'steps': steps,
        'calories': calories,
        'sleep': sleep,
      };

  factory UserGoals.fromJson(Map<String, dynamic> m) {
    double n(Object? v, double d) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? d;
      return d;
    }

    return UserGoals(
      water: n(m['water'], defaults.water),
      steps: n(m['steps'], defaults.steps),
      calories: n(m['calories'], defaults.calories),
      sleep: n(m['sleep'], defaults.sleep),
    );
  }

  static UserGoals load(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        return UserGoals.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    final legacyWater = prefs.getDouble('goal_water_l');
    if (legacyWater != null) {
      return defaults.copyWith(water: legacyWater);
    }
    return defaults;
  }

  static Future<void> save(SharedPreferences prefs, UserGoals g) async {
    await prefs.setString(_prefsKey, jsonEncode(g.toJson()));
    await prefs.setDouble('goal_water_l', g.water);
  }

  static const _prefsKey = 'user_goals_json';
}
