/// The admin portal accepts Google Drive share links for images. Those
/// open a Drive page, not the image, so rewrite them to Google's image CDN
/// (same approach as the admin's preview). Other URLs pass through.
String directImageUrl(String url) {
  String? id;
  if (url.contains('drive.google.com')) {
    final fileMatch = RegExp(r'/file/d/([^/?#]+)').firstMatch(url);
    final idMatch = RegExp(r'[?&]id=([^&#]+)').firstMatch(url);
    id = fileMatch?.group(1) ?? idMatch?.group(1);
  }
  return id == null ? url : 'https://lh3.googleusercontent.com/d/$id';
}
