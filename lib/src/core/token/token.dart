class Token {
  final String access;
  final String refresh;

  Token(this.access, this.refresh);

  Map<String, dynamic> toMap() {
    return {
      'access': access,
      'refresh': refresh
    };
  }

  @override
  String toString() {
    return '''
      Token {
        access: $access, 
        refresh: $refresh
      }
    ''';
  }
}