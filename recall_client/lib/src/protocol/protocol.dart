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
import 'chat_message.dart' as _i2;
import 'contact.dart' as _i3;
import 'dashboard_data.dart' as _i4;
import 'greetings/greeting.dart' as _i5;
import 'interaction.dart' as _i6;
import 'interaction_summary.dart' as _i7;
import 'setup_status.dart' as _i8;
import 'user_config.dart' as _i9;
import 'package:recall_client/src/protocol/contact.dart' as _i10;
import 'package:recall_client/src/protocol/interaction_summary.dart' as _i11;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i12;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i13;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i14;
export 'chat_message.dart';
export 'contact.dart';
export 'dashboard_data.dart';
export 'greetings/greeting.dart';
export 'interaction.dart';
export 'interaction_summary.dart';
export 'setup_status.dart';
export 'user_config.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ChatMessage) {
      return _i2.ChatMessage.fromJson(data) as T;
    }
    if (t == _i3.Contact) {
      return _i3.Contact.fromJson(data) as T;
    }
    if (t == _i4.DashboardData) {
      return _i4.DashboardData.fromJson(data) as T;
    }
    if (t == _i5.Greeting) {
      return _i5.Greeting.fromJson(data) as T;
    }
    if (t == _i6.Interaction) {
      return _i6.Interaction.fromJson(data) as T;
    }
    if (t == _i7.InteractionSummary) {
      return _i7.InteractionSummary.fromJson(data) as T;
    }
    if (t == _i8.SetupStatus) {
      return _i8.SetupStatus.fromJson(data) as T;
    }
    if (t == _i9.UserConfig) {
      return _i9.UserConfig.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ChatMessage?>()) {
      return (data != null ? _i2.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Contact?>()) {
      return (data != null ? _i3.Contact.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DashboardData?>()) {
      return (data != null ? _i4.DashboardData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Greeting?>()) {
      return (data != null ? _i5.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Interaction?>()) {
      return (data != null ? _i6.Interaction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.InteractionSummary?>()) {
      return (data != null ? _i7.InteractionSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.SetupStatus?>()) {
      return (data != null ? _i8.SetupStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.UserConfig?>()) {
      return (data != null ? _i9.UserConfig.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i7.InteractionSummary>) {
      return (data as List)
              .map((e) => deserialize<_i7.InteractionSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i3.Contact>) {
      return (data as List).map((e) => deserialize<_i3.Contact>(e)).toList()
          as T;
    }
    if (t == List<_i10.Contact>) {
      return (data as List).map((e) => deserialize<_i10.Contact>(e)).toList()
          as T;
    }
    if (t == List<_i11.InteractionSummary>) {
      return (data as List)
              .map((e) => deserialize<_i11.InteractionSummary>(e))
              .toList()
          as T;
    }
    try {
      return _i12.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i13.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i14.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ChatMessage => 'ChatMessage',
      _i3.Contact => 'Contact',
      _i4.DashboardData => 'DashboardData',
      _i5.Greeting => 'Greeting',
      _i6.Interaction => 'Interaction',
      _i7.InteractionSummary => 'InteractionSummary',
      _i8.SetupStatus => 'SetupStatus',
      _i9.UserConfig => 'UserConfig',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('recall.', '');
    }

    switch (data) {
      case _i2.ChatMessage():
        return 'ChatMessage';
      case _i3.Contact():
        return 'Contact';
      case _i4.DashboardData():
        return 'DashboardData';
      case _i5.Greeting():
        return 'Greeting';
      case _i6.Interaction():
        return 'Interaction';
      case _i7.InteractionSummary():
        return 'InteractionSummary';
      case _i8.SetupStatus():
        return 'SetupStatus';
      case _i9.UserConfig():
        return 'UserConfig';
    }
    className = _i12.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i13.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i14.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i2.ChatMessage>(data['data']);
    }
    if (dataClassName == 'Contact') {
      return deserialize<_i3.Contact>(data['data']);
    }
    if (dataClassName == 'DashboardData') {
      return deserialize<_i4.DashboardData>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i5.Greeting>(data['data']);
    }
    if (dataClassName == 'Interaction') {
      return deserialize<_i6.Interaction>(data['data']);
    }
    if (dataClassName == 'InteractionSummary') {
      return deserialize<_i7.InteractionSummary>(data['data']);
    }
    if (dataClassName == 'SetupStatus') {
      return deserialize<_i8.SetupStatus>(data['data']);
    }
    if (dataClassName == 'UserConfig') {
      return deserialize<_i9.UserConfig>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i12.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i13.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i14.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
