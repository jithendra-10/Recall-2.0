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
import 'package:recall_server/src/generated/protocol.dart' as _i2;

abstract class ChatMessage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChatMessage._({
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
  });

  factory ChatMessage({
    required String role,
    required String content,
    required DateTime timestamp,
    List<String>? sources,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      role: jsonSerialization['role'] as String,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      sources: jsonSerialization['sources'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['sources'],
            ),
    );
  }

  String role;

  String content;

  DateTime timestamp;

  List<String>? sources;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
    List<String>? sources,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      'role': role,
      'content': content,
      'timestamp': timestamp.toJson(),
      if (sources != null) 'sources': sources?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMessage',
      'role': role,
      'content': content,
      'timestamp': timestamp.toJson(),
      if (sources != null) 'sources': sources?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    required String role,
    required String content,
    required DateTime timestamp,
    List<String>? sources,
  }) : super._(
         role: role,
         content: content,
         timestamp: timestamp,
         sources: sources,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
    Object? sources = _Undefined,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sources: sources is List<String>?
          ? sources
          : this.sources?.map((e0) => e0).toList(),
    );
  }
}
