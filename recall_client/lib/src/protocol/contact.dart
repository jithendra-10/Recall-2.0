/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Contact implements _i1.SerializableModel {
  Contact._({
    this.id,
    required this.ownerId,
    required this.email,
    this.name,
    this.avatarUrl,
    this.bio,
    this.lastContacted,
    required this.healthScore,
    required this.tier,
  });

  factory Contact({
    int? id,
    required int ownerId,
    required String email,
    String? name,
    String? avatarUrl,
    String? bio,
    DateTime? lastContacted,
    required double healthScore,
    required int tier,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      bio: jsonSerialization['bio'] as String?,
      lastContacted: jsonSerialization['lastContacted'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastContacted'],
            ),
      healthScore: (jsonSerialization['healthScore'] as num).toDouble(),
      tier: jsonSerialization['tier'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  String email;

  String? name;

  String? avatarUrl;

  String? bio;

  DateTime? lastContacted;

  double healthScore;

  int tier;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Contact copyWith({
    int? id,
    int? ownerId,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    DateTime? lastContacted,
    double? healthScore,
    int? tier,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'email': email,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (bio != null) 'bio': bio,
      if (lastContacted != null) 'lastContacted': lastContacted?.toJson(),
      'healthScore': healthScore,
      'tier': tier,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactImpl extends Contact {
  _ContactImpl({
    int? id,
    required int ownerId,
    required String email,
    String? name,
    String? avatarUrl,
    String? bio,
    DateTime? lastContacted,
    required double healthScore,
    required int tier,
  }) : super._(
         id: id,
         ownerId: ownerId,
         email: email,
         name: name,
         avatarUrl: avatarUrl,
         bio: bio,
         lastContacted: lastContacted,
         healthScore: healthScore,
         tier: tier,
       );

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Contact copyWith({
    Object? id = _Undefined,
    int? ownerId,
    String? email,
    Object? name = _Undefined,
    Object? avatarUrl = _Undefined,
    Object? bio = _Undefined,
    Object? lastContacted = _Undefined,
    double? healthScore,
    int? tier,
  }) {
    return Contact(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      bio: bio is String? ? bio : this.bio,
      lastContacted: lastContacted is DateTime?
          ? lastContacted
          : this.lastContacted,
      healthScore: healthScore ?? this.healthScore,
      tier: tier ?? this.tier,
    );
  }
}
