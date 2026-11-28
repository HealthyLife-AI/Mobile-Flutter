import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/presentation/screens/update_required_screen.dart';

import '../../helpers/localized_app.dart';

/// Audit MO-06: the blocking screen shown on 426 app_update_required.
void main() {
  testWidgets('with a store link: title, body and an update button (Arabic)',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      home: const UpdateRequiredScreen(
          update: UpdateRequired(storeUrl: 'https://play.example.test/app')),
      locale: const Locale('ar'),
    ));

    expect(find.text('حدّث التطبيق'), findsOneWidget);
    expect(find.textContaining('محفوظ'), findsOneWidget);
    expect(find.text('تحديث'), findsOneWidget);
  });

  testWidgets('without a store link there is no button, only the text',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      home: const UpdateRequiredScreen(update: UpdateRequired()),
      locale: const Locale('en'),
    ));

    expect(find.text('Update the app'), findsOneWidget);
    expect(find.text('Update'), findsNothing);
  });

  testWidgets('there is no way back from it', (tester) async {
    await tester.pumpWidget(localizedApp(
      home: const UpdateRequiredScreen(update: UpdateRequired()),
      locale: const Locale('en'),
    ));

    expect(find.byType(BackButton), findsNothing);
    final pop = tester.widget<PopScope>(find.byType(PopScope).first);
    expect(pop.canPop, isFalse);
  });
}
