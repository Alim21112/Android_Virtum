class FirebaseConfigResponse {
  const FirebaseConfigResponse({
    required this.enabled,
    required this.apiKey,
    required this.authDomain,
    required this.appId,
    required this.projectId,
    required this.messagingSenderId,
    required this.storageBucket,
  });

  final bool enabled;
  final String apiKey;
  final String authDomain;
  final String appId;
  final String projectId;
  final String messagingSenderId;
  final String storageBucket;

  bool get canInitializeFirebase =>
      enabled &&
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      projectId.isNotEmpty &&
      messagingSenderId.isNotEmpty;

  factory FirebaseConfigResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseConfigResponse(
      enabled: json['enabled'] == true,
      apiKey: json['apiKey'] as String? ?? '',
      authDomain: json['authDomain'] as String? ?? '',
      appId: json['appId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      messagingSenderId: json['messagingSenderId'] as String? ?? '',
      storageBucket: json['storageBucket'] as String? ?? '',
    );
  }
}
