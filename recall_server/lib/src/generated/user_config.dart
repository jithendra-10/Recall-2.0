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

abstract class UserConfig
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = UserConfigTable();

  static const db = UserConfigRepository._();

  @override
  int? id;

  int userInfoId;

  String? googleRefreshToken;

  DateTime? lastSyncTime;

  String? gmailHistoryId;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserConfig',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      if (googleRefreshToken != null) 'googleRefreshToken': googleRefreshToken,
      if (lastSyncTime != null) 'lastSyncTime': lastSyncTime?.toJson(),
      if (gmailHistoryId != null) 'gmailHistoryId': gmailHistoryId,
    };
  }

  static UserConfigInclude include() {
    return UserConfigInclude._();
  }

  static UserConfigIncludeList includeList({
    _i1.WhereExpressionBuilder<UserConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserConfigTable>? orderByList,
    UserConfigInclude? include,
  }) {
    return UserConfigIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserConfig.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserConfig.t),
      include: include,
    );
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

class UserConfigUpdateTable extends _i1.UpdateTable<UserConfigTable> {
  UserConfigUpdateTable(super.table);

  _i1.ColumnValue<int, int> userInfoId(int value) => _i1.ColumnValue(
    table.userInfoId,
    value,
  );

  _i1.ColumnValue<String, String> googleRefreshToken(String? value) =>
      _i1.ColumnValue(
        table.googleRefreshToken,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSyncTime(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncTime,
        value,
      );

  _i1.ColumnValue<String, String> gmailHistoryId(String? value) =>
      _i1.ColumnValue(
        table.gmailHistoryId,
        value,
      );
}

class UserConfigTable extends _i1.Table<int?> {
  UserConfigTable({super.tableRelation})
    : super(tableName: 'recall_user_config') {
    updateTable = UserConfigUpdateTable(this);
    userInfoId = _i1.ColumnInt(
      'userInfoId',
      this,
    );
    googleRefreshToken = _i1.ColumnString(
      'googleRefreshToken',
      this,
    );
    lastSyncTime = _i1.ColumnDateTime(
      'lastSyncTime',
      this,
    );
    gmailHistoryId = _i1.ColumnString(
      'gmailHistoryId',
      this,
    );
  }

  late final UserConfigUpdateTable updateTable;

  late final _i1.ColumnInt userInfoId;

  late final _i1.ColumnString googleRefreshToken;

  late final _i1.ColumnDateTime lastSyncTime;

  late final _i1.ColumnString gmailHistoryId;

  @override
  List<_i1.Column> get columns => [
    id,
    userInfoId,
    googleRefreshToken,
    lastSyncTime,
    gmailHistoryId,
  ];
}

class UserConfigInclude extends _i1.IncludeObject {
  UserConfigInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserConfig.t;
}

class UserConfigIncludeList extends _i1.IncludeList {
  UserConfigIncludeList._({
    _i1.WhereExpressionBuilder<UserConfigTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserConfig.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserConfig.t;
}

class UserConfigRepository {
  const UserConfigRepository._();

  /// Returns a list of [UserConfig]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserConfig>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserConfigTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserConfig>(
      where: where?.call(UserConfig.t),
      orderBy: orderBy?.call(UserConfig.t),
      orderByList: orderByList?.call(UserConfig.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserConfig] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserConfig?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserConfigTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserConfigTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserConfig>(
      where: where?.call(UserConfig.t),
      orderBy: orderBy?.call(UserConfig.t),
      orderByList: orderByList?.call(UserConfig.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserConfig] by its [id] or null if no such row exists.
  Future<UserConfig?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserConfig>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserConfig]s in the list and returns the inserted rows.
  ///
  /// The returned [UserConfig]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserConfig>> insert(
    _i1.Session session,
    List<UserConfig> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserConfig>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserConfig] and returns the inserted row.
  ///
  /// The returned [UserConfig] will have its `id` field set.
  Future<UserConfig> insertRow(
    _i1.Session session,
    UserConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserConfig]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserConfig>> update(
    _i1.Session session,
    List<UserConfig> rows, {
    _i1.ColumnSelections<UserConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserConfig>(
      rows,
      columns: columns?.call(UserConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserConfig]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserConfig> updateRow(
    _i1.Session session,
    UserConfig row, {
    _i1.ColumnSelections<UserConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserConfig>(
      row,
      columns: columns?.call(UserConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserConfig] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserConfig?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserConfigUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserConfig>(
      id,
      columnValues: columnValues(UserConfig.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserConfig]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserConfig>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserConfigUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserConfigTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserConfigTable>? orderBy,
    _i1.OrderByListBuilder<UserConfigTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserConfig>(
      columnValues: columnValues(UserConfig.t.updateTable),
      where: where(UserConfig.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserConfig.t),
      orderByList: orderByList?.call(UserConfig.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserConfig]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserConfig>> delete(
    _i1.Session session,
    List<UserConfig> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserConfig>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserConfig].
  Future<UserConfig> deleteRow(
    _i1.Session session,
    UserConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserConfig>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserConfigTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserConfig>(
      where: where(UserConfig.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserConfigTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserConfig>(
      where: where?.call(UserConfig.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
