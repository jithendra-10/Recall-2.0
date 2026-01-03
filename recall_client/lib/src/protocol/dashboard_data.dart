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
import 'interaction_summary.dart' as _i3;
import 'package:recall_client/src/protocol/protocol.dart' as _i4;

abstract class DashboardData implements _i1.SerializableModel {
  DashboardData._({
    this.lastSyncTime,
    required this.isSyncing,
    this.nudgeContact,
    this.nudgeDaysSilent,
    this.nudgeLastTopic,
    required this.recentInteractions,
    required this.topContacts,
    required this.totalContacts,
    required this.driftingCount,
    this.networkHealth,
  });

  factory DashboardData({
    DateTime? lastSyncTime,
    required bool isSyncing,
    _i2.Contact? nudgeContact,
    int? nudgeDaysSilent,
    String? nudgeLastTopic,
    required List<_i3.InteractionSummary> recentInteractions,
    required List<_i2.Contact> topContacts,
    required int totalContacts,
    required int driftingCount,
    double? networkHealth,
  }) = _DashboardDataImpl;

  factory DashboardData.fromJson(Map<String, dynamic> jsonSerialization) {
    return DashboardData(
      lastSyncTime: jsonSerialization['lastSyncTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncTime'],
            ),
      isSyncing: jsonSerialization['isSyncing'] as bool,
      nudgeContact: jsonSerialization['nudgeContact'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Contact>(
              jsonSerialization['nudgeContact'],
            ),
      nudgeDaysSilent: jsonSerialization['nudgeDaysSilent'] as int?,
      nudgeLastTopic: jsonSerialization['nudgeLastTopic'] as String?,
      recentInteractions: _i4.Protocol()
          .deserialize<List<_i3.InteractionSummary>>(
            jsonSerialization['recentInteractions'],
          ),
      topContacts: _i4.Protocol().deserialize<List<_i2.Contact>>(
        jsonSerialization['topContacts'],
      ),
      totalContacts: jsonSerialization['totalContacts'] as int,
      driftingCount: jsonSerialization['driftingCount'] as int,
      networkHealth: (jsonSerialization['networkHealth'] as num?)?.toDouble(),
    );
  }

  DateTime? lastSyncTime;

  bool isSyncing;

  _i2.Contact? nudgeContact;

  int? nudgeDaysSilent;

  String? nudgeLastTopic;

  List<_i3.InteractionSummary> recentInteractions;

  List<_i2.Contact> topContacts;

  int totalContacts;

  int driftingCount;

  double? networkHealth;

  /// Returns a shallow copy of this [DashboardData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DashboardData copyWith({
    DateTime? lastSyncTime,
    bool? isSyncing,
    _i2.Contact? nudgeContact,
    int? nudgeDaysSilent,
    String? nudgeLastTopic,
    List<_i3.InteractionSummary>? recentInteractions,
    List<_i2.Contact>? topContacts,
    int? totalContacts,
    int? driftingCount,
    double? networkHealth,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DashboardData',
      if (lastSyncTime != null) 'lastSyncTime': lastSyncTime?.toJson(),
      'isSyncing': isSyncing,
      if (nudgeContact != null) 'nudgeContact': nudgeContact?.toJson(),
      if (nudgeDaysSilent != null) 'nudgeDaysSilent': nudgeDaysSilent,
      if (nudgeLastTopic != null) 'nudgeLastTopic': nudgeLastTopic,
      'recentInteractions': recentInteractions.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'topContacts': topContacts.toJson(valueToJson: (v) => v.toJson()),
      'totalContacts': totalContacts,
      'driftingCount': driftingCount,
      if (networkHealth != null) 'networkHealth': networkHealth,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DashboardDataImpl extends DashboardData {
  _DashboardDataImpl({
    DateTime? lastSyncTime,
    required bool isSyncing,
    _i2.Contact? nudgeContact,
    int? nudgeDaysSilent,
    String? nudgeLastTopic,
    required List<_i3.InteractionSummary> recentInteractions,
    required List<_i2.Contact> topContacts,
    required int totalContacts,
    required int driftingCount,
    double? networkHealth,
  }) : super._(
         lastSyncTime: lastSyncTime,
         isSyncing: isSyncing,
         nudgeContact: nudgeContact,
         nudgeDaysSilent: nudgeDaysSilent,
         nudgeLastTopic: nudgeLastTopic,
         recentInteractions: recentInteractions,
         topContacts: topContacts,
         totalContacts: totalContacts,
         driftingCount: driftingCount,
         networkHealth: networkHealth,
       );

  /// Returns a shallow copy of this [DashboardData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DashboardData copyWith({
    Object? lastSyncTime = _Undefined,
    bool? isSyncing,
    Object? nudgeContact = _Undefined,
    Object? nudgeDaysSilent = _Undefined,
    Object? nudgeLastTopic = _Undefined,
    List<_i3.InteractionSummary>? recentInteractions,
    List<_i2.Contact>? topContacts,
    int? totalContacts,
    int? driftingCount,
    Object? networkHealth = _Undefined,
  }) {
    return DashboardData(
      lastSyncTime: lastSyncTime is DateTime?
          ? lastSyncTime
          : this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      nudgeContact: nudgeContact is _i2.Contact?
          ? nudgeContact
          : this.nudgeContact?.copyWith(),
      nudgeDaysSilent: nudgeDaysSilent is int?
          ? nudgeDaysSilent
          : this.nudgeDaysSilent,
      nudgeLastTopic: nudgeLastTopic is String?
          ? nudgeLastTopic
          : this.nudgeLastTopic,
      recentInteractions:
          recentInteractions ??
          this.recentInteractions.map((e0) => e0.copyWith()).toList(),
      topContacts:
          topContacts ?? this.topContacts.map((e0) => e0.copyWith()).toList(),
      totalContacts: totalContacts ?? this.totalContacts,
      driftingCount: driftingCount ?? this.driftingCount,
      networkHealth: networkHealth is double?
          ? networkHealth
          : this.networkHealth,
    );
  }
}
