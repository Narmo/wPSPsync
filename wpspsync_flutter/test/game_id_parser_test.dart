import 'package:flutter_test/flutter_test.dart';
import 'package:wpspsync_flutter/models/models.dart';

void main() {
  group('GameIDParser', () {
    test('parses Game ID from save folder', () {
      expect(GameIDParser.parse('ULUS10566DATA00'), equals('ULUS10566'));
      expect(GameIDParser.parse('savedata_ules00151_profile'), equals('ULES00151'));
    });

    test('returns null when no Game ID exists', () {
      expect(GameIDParser.parse('PROFILE_BACKUP'), isNull);
    });
  });
}
