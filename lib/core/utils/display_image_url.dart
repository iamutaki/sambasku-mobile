/// URL tampilan gambar: bungkus jsDelivr dengan wsrv.nl untuk resize.
/// URL ImageKit / lain dikembalikan apa adanya.
String? displayImageUrl(
  String? url, {
  int? width,
  int? height,
}) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  final host = uri.host.toLowerCase();
  final isJsDelivr = host == 'cdn.jsdelivr.net' || host.endsWith('.jsdelivr.net');
  if (!isJsDelivr) return url;

  final originPath = '${uri.host}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
  return Uri.https('wsrv.nl', '/', {
    'url': originPath,
    if (width != null) 'w': '$width',
    if (height != null) 'h': '$height',
    'fit': 'cover',
    'output': 'webp',
  }).toString();
}
