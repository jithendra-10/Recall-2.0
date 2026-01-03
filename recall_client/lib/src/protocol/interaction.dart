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
import 'contact.dart' as _i2;
import 'package:recall_client/src/protocol/protocol.dart' as _i3;

abstract class Interaction implements _i1.SerializableModel {
  Interaction._({
    this.id,
    required this.ownerId,
    required this.contactId,
    this.contact,
    required this.date,
    required this.snippet,
    this.subject,
    this.body,
    required this.embedding,
    required this.type,
    this.sentiment,
  });

  factory Interaction({
    int? id,
    required int ownerId,
    required int contactId,
    _i2.Contact? contact,
    required DateTime date,
    required String snippet,
    String? subject,
    String? body,
    required _i1.Vector embedding,
    required String type,
    String? sentiment,
  }) = _InteractionImpl;

  factory Interaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Interaction(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      contactId: jsonSerialization['contactId'] as int,
      contact: jsonSerialization['contact'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Contact>(
              jsonSerialization['contact'],
            ),
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      snippet: jsonSerialization['snippet'] as String,
      subject: jsonSerialization['subject'] as String?,
      body: jsonSerialization['body'] as String?,
      embedding: _i1.VectorJsonExtension.fromJson(
        jsonSerialization['embedding'],
      ),
      type: jsonSerialization['type'] as String,
      sentiment: jsonSerialization['sentiment'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  int contactId;

  _i2.Contact? contact;

  DateTime date;

  String snippet;

  String? subject;

  String? body;

  _i1.Vector embedding;

  String type;

  String? sentiment;

  /// Returns a shallow copy of this [Interaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Interaction copyWith({
    int? id,
    int? ownerId,
    int? contactId,
    _i2.Contact? contact,
    DateTime? date,
    String? snippet,
    String? subject,
    String? body,
    _i1.Vector? embedding,
    String? type,
    String? sentiment,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Interaction',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'contactId': contactId,
      if (contact != null) 'contact': contact?.toJson(),
      'date': date.toJson(),
      'snippet': snippet,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      'embedding': embedding.toJson(),
      'type': type,
      if (sentiment != null) 'sentiment': sentiment,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InteractionImpl extends Interaction {
  _InteractionImpl({
    int? id,
    required int ownerId,
    required int contactId,
    _i2.Contact? contact,
    required DateTime date,
    required String snippet,
    String? subject,
    String? body,
    required _i1.Vector embedding,
    required String type,
    String? sentiment,
  }) : super._(
         id: id,
         ownerId: ownerId,
         contactId: contactId,
         contact: contact,
         date: date,
         snippet: snippet,
         subject: subject,
         body: body,
         embedding: embedding,
         type: type,
         sentiment: sentiment,
       );

  /// Returns a shallow copy of this [Interaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Interaction copyWith({
    Object? id = _Undefined,
    int? ownerId,
    int? contactId,
    Object? contact = _Undefined,
    DateTime? date,
    String? snippet,
    Object? subject = _Undefined,
    Object? body = _Undefined,
    _i1.Vector? embedding,
    String? type,
    Object? sentiment = _Undefined,
  }) {
    return Interaction(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      contactId: contactId ?? this.contactId,
      contact: contact is _i2.Contact? ? contact : this.contact?.copyWith(),
      date: date ?? this.date,
      snippet: snippet ?? this.snippet,
      subject: subject is String? ? subject : this.subject,
      body: body is String? ? body : this.body,
      embedding: embedding ?? this.embedding.clone(),
      type: type ?? this.type,
      sentiment: sentiment is String? ? sentiment : this.sentiment,
    );
  }
}
