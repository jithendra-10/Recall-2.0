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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class SetupStatus
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SetupStatus._({
    required this.hasToken,
    required this.emailCount,
    required this.interactionCount,
    required this.isSyncing,
  });

  factory SetupStatus({
    required bool hasToken,
    required int emailCount,
    required int interactionCount,
    required bool isSyncing,
  }) = _SetupStatusImpl;

  factory SetupStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return SetupStatus(
      hasToken: jsonSerialization['hasToken'] as bool,
      emailCount: jsonSerialization['emailCount'] as int,
      interactionCount: jsonSerialization['interactionCount'] as int,
      isSyncing: jsonSerialization['isSyncing'] as bool,
    );
  }

  bool hasToken;

  int emailCount;

  int interactionCount;

  bool isSyncing;

  /// Returns a shallow copy of this [SetupStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SetupStatus copyWith({
    bool? hasToken,
    int? emailCount,
    int? interactionCount,
    bool? isSyncing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SetupStatus',
      'hasToken': hasToken,
      'emailCount': emailCount,
      'interactionCount': interactionCount,
      'isSyncing': isSyncing,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SetupStatus',
      'hasToken': hasToken,
      'emailCount': emailCount,
      'interactionCount': interactionCount,
      'isSyncing': isSyncing,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SetupStatusImpl extends SetupStatus {
  _SetupStatusImpl({
    required bool hasToken,
    required int emailCount,
    required int interactionCount,
    required bool isSyncing,
  }) : super._(
         hasToken: hasToken,
         emailCount: emailCount,
         interactionCount: interactionCount,
         isSyncing: isSyncing,
       );

  /// Returns a shallow copy of this [SetupStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SetupStatus copyWith({
    bool? hasToken,
    int? emailCount,
    int? interactionCount,
    bool? isSyncing,
  }) {
    return SetupStatus(
      hasToken: hasToken ?? this.hasToken,
      emailCount: emailCount ?? this.emailCount,
      interactionCount: interactionCount ?? this.interactionCount,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}
