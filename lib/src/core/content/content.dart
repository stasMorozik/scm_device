class Content {
  final String id;
  final int displayDuration;
  final String url;
  final String name;
  final String dir;
  final String path;
  final List<int> binary;

  Content(
    this.id, 
    this.displayDuration, 
    this.url, 
    this.name,
    this.dir, 
    this.path,
    this.binary
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayDuration': displayDuration,
      'url': url,
      'name': name,
      'dir': dir,
      'path': path
    };
  }

  @override
  String toString() {
    return '''
      Content {
        id: $id, 
        displayDuration: $displayDuration, 
        url: $url, 
        name: $name,
        dir: $dir,  
        path: $path
      }
    ''';
  }
}