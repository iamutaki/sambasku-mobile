// Flavor aplikasi (docs/mobile/mobile-base-stack.md Section 8)
enum Flavor { staging, production }

class F {
  F._();

  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static bool get isStaging => appFlavor == Flavor.staging;

  static String get title =>
      isStaging ? 'SambasKu Staging' : 'SambasKu';
}
