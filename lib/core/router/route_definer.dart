/// Definisi route per fitur (pola jnn_mobile): path + name dalam satu
/// konstanta, dipakai GoRoute dan navigasi (context.goNamed / pushNamed).
class RouteDefiner {
  final String path;
  final String name;

  const RouteDefiner({required this.path, required this.name});
}
