library;

import '../domain/menu.dart';

abstract class MenuItemDecorator implements MenuComponent {
  final MenuComponent _inner;
  MenuItemDecorator(this._inner);

  @override
  String get id => _inner.id;

  @override
  String get name => _inner.name;

  @override
  double price() => _inner.price();

  @override
  String describe() => _inner.describe();
}

class ExtraTopping extends MenuItemDecorator {
  final String toppingName;
  final double extraCharge;

  ExtraTopping(super.inner, {required this.toppingName, required this.extraCharge}) {
    if (extraCharge < 0) {
      throw ArgumentError.value(extraCharge, 'extraCharge', 'must not be negative');
    }
  }

  @override
  double price() => super.price() + extraCharge;

  @override
  String describe() => '${super.describe()} + $toppingName';
}

class SideSubstitution extends MenuItemDecorator {
  final String from;
  final String to;
  final double surcharge;

  SideSubstitution(super.inner, {required this.from, required this.to, this.surcharge = 0});

  @override
  double price() => super.price() + surcharge;

  @override
  String describe() => '${super.describe()} (sub $from→$to)';
}

class AllergenNote extends MenuItemDecorator {
  final String note;
  AllergenNote(super.inner, {required this.note});

  @override
  String describe() => '${super.describe()} ⚠ $note';
}
