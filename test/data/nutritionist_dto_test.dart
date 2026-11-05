import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/nutritionist_dto.dart';
import 'package:healthylife_ai/domain/entities/nutritionist_entities.dart';

void main() {
  test('maps every field of the object in guide 9.1', () {
    final profile = NutritionistDto.fromJson({
      'name': 'د. أمل',
      'gender': 'female',
      'clinic_name': 'عيادة الشفاء',
      'specialty': 'أخصائية تغذية علاجية',
      'whatsapp_number': '+970599123456',
      'bio': 'نص تعريفي',
      'reply_hours': 'الأحد–الخميس 9–5',
    });

    expect(profile?.name, 'د. أمل');
    expect(profile?.clinicName, 'عيادة الشفاء');
    expect(profile?.specialty, 'أخصائية تغذية علاجية');
    expect(profile?.whatsappNumber, '+970599123456');
    expect(profile?.bio, 'نص تعريفي');
    expect(profile?.replyHours, 'الأحد–الخميس 9–5');
  });

  test('null, blank and missing optional fields come out as null', () {
    final profile = NutritionistDto.fromJson({
      'name': 'د. أمل',
      'clinic_name': null,
      'specialty': '   ',
      'whatsapp_number': '',
    });

    expect(profile?.clinicName, isNull);
    expect(profile?.specialty, isNull);
    expect(profile?.whatsappNumber, isNull);
    expect(profile?.bio, isNull);
    expect(profile?.replyHours, isNull);
  });

  test('an answer without a usable name is refused', () {
    expect(NutritionistDto.fromJson({'name': null}), isNull);
    expect(NutritionistDto.fromJson({'name': '  '}), isNull);
    expect(NutritionistDto.fromJson('not an object'), isNull);
  });

  test('the WhatsApp link keeps only the digits (guide 9.1)', () {
    const withPlus = NutritionistProfile(
      name: 'د. أمل',
      whatsappNumber: '+970 599-123-456',
    );
    expect(withPlus.whatsappUri, Uri.parse('https://wa.me/970599123456'));

    const none = NutritionistProfile(name: 'د. أمل');
    expect(none.whatsappUri, isNull);
  });

  test('saving and reading back keeps the same profile', () {
    const profile = NutritionistProfile(
      name: 'د. أمل',
      clinicName: 'عيادة',
      whatsappNumber: '+970599123456',
    );

    final again = NutritionistDto.fromJson(NutritionistDto.toJson(profile));

    expect(again?.name, profile.name);
    expect(again?.clinicName, profile.clinicName);
    expect(again?.whatsappNumber, profile.whatsappNumber);
    expect(again?.specialty, isNull);
  });
}
