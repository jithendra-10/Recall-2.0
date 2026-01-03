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

abstract class InteractionSummary implements _i1.SerializableModel {
  InteractionSummary._({
    required this.contactName,
    required this.contactEmail,
    this.contactAvatarUrl,
    required this.summary,
    this.subject,
    this.body,
    required this.timestamp,
    required this.type,
  });

  factory InteractionSummary({
    required String contactName,
    required String contactEmail,
    String? contactAvatarUrl,
    required String summary,
    String? subject,
    String? body,
    required DateTime timestamp,
    required String type,
  }) = _InteractionSummaryImpl;

  factory InteractionSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return InteractionSummary(
      contactName: jsonSerialization['contactName'] as String,
      contactEmail: jsonSerialization['contactEmail'] as String,
      contactAvatarUrl: jsonSerialization['contactAvatarUrl'] as String?,
      summary: jsonSerialization['summary'] as String,
      subject: jsonSerialization['subject'] as String?,
      body: jsonSerialization['body'] as String?,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      type: jsonSerialization['type'] as String,
    );
  }

  String contactName;

  String contactEmail;

  String? contactAvatarUrl;

  String summary;

  String? subject;

  String? body;

  DateTime timestamp;

  String type;

  /// Returns a shallow copy of this [InteractionSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InteractionSummary copyWith({
    String? contactName,
    String? contactEmail,
    String? contactAvatarUrl,
    String? summary,
    String? subject,
    String? body,
    DateTime? timestamp,
    String? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InteractionSummary',
      'contactName': contactName,
      'contactEmail': contactEmail,
      if (contactAvatarUrl != null) 'contactAvatarUrl': contactAvatarUrl,
      'summary': summary,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      'timestamp': timestamp.toJson(),
      'type': type,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InteractionSummaryImpl extends InteractionSummary {
  _InteractionSummaryImpl({
    required String contactName,
    required String contactEmail,
    String? contactAvatarUrl,
    required String summary,
    String? subject,
    String? body,
    required DateTime timestamp,
    required String type,
  }) : super._(
         contactName: contactName,
         contactEmail: contactEmail,
         contactAvatarUrl: contactAvatarUrl,
         summary: summary,
         subject: subject,
         body: body,
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
    Object? contactAvatarUrl = _Undefined,
    String? summary,
    Object? subject = _Undefined,
    Object? body = _Undefined,
    DateTime? timestamp,
    String? type,
  }) {
    return InteractionSummary(
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactAvatarUrl: contactAvatarUrl is String?
          ? contactAvatarUrl
          : this.contactAvatarUrl,
      summary: summary ?? this.summary,
      subject: subject is String? ? subject : this.subject,
      body: body is String? ? body : this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
