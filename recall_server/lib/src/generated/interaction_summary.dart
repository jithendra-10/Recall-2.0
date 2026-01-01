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

abstract class InteractionSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  InteractionSummary._({
    required this.contactName,
    required this.contactEmail,
    required this.summary,
    required this.timestamp,
    required this.type,
  });

  factory InteractionSummary({
    required String contactName,
    required String contactEmail,
    required String summary,
    required DateTime timestamp,
    required String type,
  }) = _InteractionSummaryImpl;

  factory InteractionSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return InteractionSummary(
      contactName: jsonSerialization['contactName'] as String,
      contactEmail: jsonSerialization['contactEmail'] as String,
      summary: jsonSerialization['summary'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      type: jsonSerialization['type'] as String,
    );
  }

  String contactName;

  String contactEmail;

  String summary;

  DateTime timestamp;

  String type;

  /// Returns a shallow copy of this [InteractionSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InteractionSummary copyWith({
    String? contactName,
    String? contactEmail,
    String? summary,
    DateTime? timestamp,
    String? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InteractionSummary',
      'contactName': contactName,
      'contactEmail': contactEmail,
      'summary': summary,
      'timestamp': timestamp.toJson(),
      'type': type,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InteractionSummary',
      'contactName': contactName,
      'contactEmail': contactEmail,
      'summary': summary,
      'timestamp': timestamp.toJson(),
      'type': type,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _InteractionSummaryImpl extends InteractionSummary {
  _InteractionSummaryImpl({
    required String contactName,
    required String contactEmail,
    required String summary,
    required DateTime timestamp,
    required String type,
  }) : super._(
         contactName: contactName,
         contactEmail: contactEmail,
         summary: summary,
         timestamp: timestamp,
         type: type,
       );

  /// Returns a shallow copy of this [InteractionSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InteractionSummary copyWith({
    String? contactName,
    String? contactEmail,
    String? summary,
    DateTime? timestamp,
    String? type,
  }) {
    return InteractionSummary(
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
