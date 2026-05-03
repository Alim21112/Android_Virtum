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
    String s(dynamic v) => v == null ? '' : v.toString();

    return FirebaseConfigResponse(
      enabled: json['enabled'] == true,
      apiKey: s(json['apiKey']),
      authDomain: s(json['authDomain']),
      appId: s(json['appId']),
      projectId: s(json['projectId']),
      messagingSenderId: s(json['messagingSenderId']),
      storageBucket: s(json['storageBucket']),
    );
  }
}
