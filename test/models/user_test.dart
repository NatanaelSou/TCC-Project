import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson creates correct User instance', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': 'https://example.com/avatar.jpg',
        'created_at': '2023-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.createdAt, isNotNull);
    });

    test('User.toJson returns correct map', () {
      final user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: DateTime(2023),
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['avatar'], 'https://example.com/avatar.jpg');
      expect(json['created_at'], isNotNull);
    });

    test('User.copyWith updates specific fields', () {
      final original = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      );

      final updated = original.copyWith(
        name: 'Jane Doe',
        avatarUrl: 'https://example.com/new-avatar.jpg',
      );

      expect(updated.id, 1);
      expect(updated.name, 'Jane Doe');
      expect(updated.email, 'john@example.com');
      expect(updated.avatarUrl, 'https://example.com/new-avatar.jpg');
    });

    test('User equality works correctly', () {
      final user1 = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      );

      final user2 = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      );

      final user3 = User(
        id: 2,
        name: 'Jane Doe',
        email: 'jane@example.com',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('User.fromJson handles null fields', () {
      final json = {
        'id': null,
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': null,
        'created_at': null,
      };

      final user = User.fromJson(json);

      expect(user.id, isNull);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, isNull);
    });
  });
}
