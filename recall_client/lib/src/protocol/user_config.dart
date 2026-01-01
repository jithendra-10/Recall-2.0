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

abstract class UserConfig implements _i1.SerializableModel {
  UserConfig._({
    this.id,
    required this.userInfoId,
    this.googleRefreshToken,
    this.lastSyncTime,
    this.gmailHistoryId,
  });

  factory UserConfig({
    int? id,
    required int userInfoId,
    String? googleRefreshToken,
    DateTime? lastSyncTime,
    String? gmailHistoryId,
  }) = _UserConfigImpl;

  factory UserConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserConfig(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      googleRefreshToken: jsonSerialization['googleRefreshToken'] as String?,
      lastSyncTime: jsonSerialization['lastSyncTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncTime'],
            ),
      gmailHistoryId: jsonSerialization['gmailHistoryId'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  String? googleRefreshToken;

  DateTime? lastSyncTime;

  String? gmailHistoryId;

  /// Returns a shallow copy of this [UserConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserConfig copyWith({
    int? id,
    int? userInfoId,
    String? googleRefreshToken,
    DateTime? lastSyncTime,
    String? gmailHistoryId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserConfig',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      if (googleRefreshToken != null) 'googleRefreshToken': googleRefreshToken,
      if (lastSyncTime != null) 'lastSyncTime': lastSyncTime?.toJson(),
      if (gmailHistoryId != null) 'gmailHistoryId': gmailHistoryId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserConfigImpl extends UserConfig {
  _UserConfigImpl({
    int? id,
    required int userInfoId,
    String? googleRefreshToken,
    DateTime? lastSyncTime,
    String? gmailHistoryId,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         googleRefreshToken: googleRefreshToken,
         lastSyncTime: lastSyncTime,
         gmailHistoryId: gmailHistoryId,
       );

  /// Returns a shallow copy of this [UserConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserConfig copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    Object? googleRefreshToken = _Undefined,
    Object? lastSyncTime = _Undefined,
    Object? gmailHistoryId = _Undefined,
  }) {
    return UserConfig(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      googleRefreshToken: googleRefreshToken is String?
          ? googleRefreshToken
          : this.googleRefreshToken,
      lastSyncTime: lastSyncTime is DateTime?
          ? lastSyncTime
          : this.lastSyncTime,
      gmailHistoryId: gmailHistoryId is String?
          ? gmailHistoryId
          : this.gmailHistoryId,
    );
  }
}
