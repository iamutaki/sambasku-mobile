/// Hasil snap satu sumbu ke [target].
///
/// [delta] adalah perpindahan yang dipakai frame ini (bukan delta jari mentah
/// kalau sedang menempel). [accum] menumpuk gerakan jari sejak menempel, supaya
/// lepas dari tengah butuh geseran yang cukup, bukan satu frame yang kebetulan
/// besar.
class AxisSnapResult {
  const AxisSnapResult({
    required this.delta,
    required this.stuck,
    required this.accum,
  });

  final double delta;
  final bool stuck;
  final double accum;
}

AxisSnapResult snapAxis({
  required double center,
  required double target,
  required double delta,
  required double threshold,
  required bool stuck,
  required double accum,
}) {
  if (stuck) {
    final nextAccum = accum + delta;
    if (nextAccum.abs() > threshold) {
      return AxisSnapResult(delta: nextAccum, stuck: false, accum: 0);
    }
    return AxisSnapResult(
      delta: target - center,
      stuck: true,
      accum: nextAccum,
    );
  }

  final next = center + delta;
  final overshoot = next - target;
  if (overshoot.abs() <= threshold) {
    return AxisSnapResult(
      delta: target - center,
      stuck: true,
      accum: overshoot,
    );
  }
  return AxisSnapResult(delta: delta, stuck: false, accum: 0);
}
