import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

/// User data model
class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    required String name,
    String? profileImage,
  }) : super(id: id, email: email, name: name, profileImage: profileImage);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  /// Create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(supabase.User user) {
    final userMetadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: userMetadata['name'] as String? ?? user.email ?? 'User',
      profileImage: userMetadata['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      profileImage: profileImage,
    );
  }
}
