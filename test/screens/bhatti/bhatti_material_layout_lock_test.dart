import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/bhatti/bhatti_cooking_screen.dart';

void main() {
  test('formula material rows stay inline on mobile widths', () {
    expect(useInlineFormulaMaterialRowLayoutForWidth(320), isTrue);
    expect(useInlineFormulaMaterialRowLayoutForWidth(560), isTrue);
    expect(useInlineFormulaMaterialRowLayoutForWidth(649), isTrue);
  });

  test('formula material rows use classic field layout on tablet/desktop', () {
    expect(useInlineFormulaMaterialRowLayoutForWidth(650), isFalse);
    expect(useInlineFormulaMaterialRowLayoutForWidth(900), isFalse);
    expect(useInlineFormulaMaterialRowLayoutForWidth(1280), isFalse);
  });
}
