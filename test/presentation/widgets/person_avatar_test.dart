import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/widgets/person_avatar.dart';

void main() {
  group('PersonAvatar.initialOf', () {
    test('a plain name takes its first letter', () {
      expect(PersonAvatar.initialOf('سارة'), 'س');
      expect(PersonAvatar.initialOf('Khaloud'), 'K');
    });

    test('a title before the name is skipped', () {
      expect(PersonAvatar.initialOf('د. أمل'), 'أ');
      expect(PersonAvatar.initialOf('Dr. Sara'), 'S');
    });

    test('blank and null have no letter', () {
      expect(PersonAvatar.initialOf(null), '');
      expect(PersonAvatar.initialOf('   '), '');
    });
  });

  testWidgets('a real name is shown as its letter', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: PersonAvatar(name: 'سارة')));
    expect(find.text('س'), findsOneWidget);
  });

  testWidgets('no name falls back to a neutral icon, never a made-up letter',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PersonAvatar()));
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('the last-resort initial is used only when there is no name',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PersonAvatar(fallbackInitial: 'خ')));
    expect(find.text('خ'), findsOneWidget);
  });
}
