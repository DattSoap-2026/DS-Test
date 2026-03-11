import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/bhatti/bhatti_cooking_screen.dart';

void main() {
  test('normalizes material token across spacing and separators', () {
    expect(
      normalizeBhattiMaterialToken('  Acid_Slurry  '),
      equals('acid slurry'),
    );
    expect(
      normalizeBhattiMaterialToken('ACID-SLURRY'),
      equals('acid slurry'),
    );
  });

  test('matches tank and formula material by name when ids differ', () {
    final matched = bhattiMaterialsOverlap(
      firstId: 'tank-mat-1',
      firstName: 'Silicate',
      secondId: 'formula-mat-9',
      secondName: 'SILICATE',
    );

    expect(matched, isTrue);
  });

  test('matches by id even when names differ', () {
    final matched = bhattiMaterialsOverlap(
      firstId: 'mat-1',
      firstName: 'Acid Slurry',
      secondId: 'mat-1',
      secondName: 'AS',
    );

    expect(matched, isTrue);
  });

  test('does not match unrelated materials', () {
    final matched = bhattiMaterialsOverlap(
      firstId: 'mat-1',
      firstName: 'Caustic Soda',
      secondId: 'mat-2',
      secondName: 'Fatty Acid',
    );

    expect(matched, isFalse);
  });
}
