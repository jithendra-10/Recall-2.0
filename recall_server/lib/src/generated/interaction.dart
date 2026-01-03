/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'contact.dart' as _i2;
import 'package:recall_server/src/generated/protocol.dart' as _i3;

abstract class Interaction
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = InteractionTable();

  static const db = InteractionRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Interaction',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'contactId': contactId,
      if (contact != null) 'contact': contact?.toJsonForProtocol(),
      'date': date.toJson(),
      'snippet': snippet,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      'embedding': embedding.toJson(),
      'type': type,
      if (sentiment != null) 'sentiment': sentiment,
    };
  }

  static InteractionInclude include({_i2.ContactInclude? contact}) {
    return InteractionInclude._(contact: contact);
  }

  static InteractionIncludeList includeList({
    _i1.WhereExpressionBuilder<InteractionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InteractionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InteractionTable>? orderByList,
    InteractionInclude? include,
  }) {
    return InteractionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Interaction.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Interaction.t),
      include: include,
    );
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

class InteractionUpdateTable extends _i1.UpdateTable<InteractionTable> {
  InteractionUpdateTable(super.table);

  _i1.ColumnValue<int, int> ownerId(int value) => _i1.ColumnValue(
    table.ownerId,
    value,
  );

  _i1.ColumnValue<int, int> contactId(int value) => _i1.ColumnValue(
    table.contactId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> date(DateTime value) => _i1.ColumnValue(
    table.date,
    value,
  );

  _i1.ColumnValue<String, String> snippet(String value) => _i1.ColumnValue(
    table.snippet,
    value,
  );

  _i1.ColumnValue<String, String> subject(String? value) => _i1.ColumnValue(
    table.subject,
    value,
  );

  _i1.ColumnValue<String, String> body(String? value) => _i1.ColumnValue(
    table.body,
    value,
  );

  _i1.ColumnValue<_i1.Vector, _i1.Vector> embedding(_i1.Vector value) =>
      _i1.ColumnValue(
        table.embedding,
        value,
      );

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<String, String> sentiment(String? value) => _i1.ColumnValue(
    table.sentiment,
    value,
  );
}

class InteractionTable extends _i1.Table<int?> {
  InteractionTable({super.tableRelation})
    : super(tableName: 'recall_interaction') {
    updateTable = InteractionUpdateTable(this);
    ownerId = _i1.ColumnInt(
      'ownerId',
      this,
    );
    contactId = _i1.ColumnInt(
      'contactId',
      this,
    );
    date = _i1.ColumnDateTime(
      'date',
      this,
    );
    snippet = _i1.ColumnString(
      'snippet',
      this,
    );
    subject = _i1.ColumnString(
      'subject',
      this,
    );
    body = _i1.ColumnString(
      'body',
      this,
    );
    embedding = _i1.ColumnVector(
      'embedding',
      this,
      dimension: 768,
    );
    type = _i1.ColumnString(
      'type',
      this,
    );
    sentiment = _i1.ColumnString(
      'sentiment',
      this,
    );
  }

  late final InteractionUpdateTable updateTable;

  late final _i1.ColumnInt ownerId;

  late final _i1.ColumnInt contactId;

  _i2.ContactTable? _contact;

  late final _i1.ColumnDateTime date;

  late final _i1.ColumnString snippet;

  late final _i1.ColumnString subject;

  late final _i1.ColumnString body;

  late final _i1.ColumnVector embedding;

  late final _i1.ColumnString type;

  late final _i1.ColumnString sentiment;

  _i2.ContactTable get contact {
    if (_contact != null) return _contact!;
    _contact = _i1.createRelationTable(
      relationFieldName: 'contact',
      field: Interaction.t.contactId,
      foreignField: _i2.Contact.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ContactTable(tableRelation: foreignTableRelation),
    );
    return _contact!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    ownerId,
    contactId,
    date,
    snippet,
    subject,
    body,
    embedding,
    type,
    sentiment,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'contact') {
      return contact;
    }
    return null;
  }
}

class InteractionInclude extends _i1.IncludeObject {
  InteractionInclude._({_i2.ContactInclude? contact}) {
    _contact = contact;
  }

  _i2.ContactInclude? _contact;

  @override
  Map<String, _i1.Include?> get includes => {'contact': _contact};

  @override
  _i1.Table<int?> get table => Interaction.t;
}

class InteractionIncludeList extends _i1.IncludeList {
  InteractionIncludeList._({
    _i1.WhereExpressionBuilder<InteractionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Interaction.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Interaction.t;
}

class InteractionRepository {
  const InteractionRepository._();

  final attachRow = const InteractionAttachRowRepository._();

  /// Returns a list of [Interaction]s matching the given query parameters.
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
  Future<List<Interaction>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InteractionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InteractionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InteractionTable>? orderByList,
    _i1.Transaction? transaction,
    InteractionInclude? include,
  }) async {
    return session.db.find<Interaction>(
      where: where?.call(Interaction.t),
      orderBy: orderBy?.call(Interaction.t),
      orderByList: orderByList?.call(Interaction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Interaction] matching the given query parameters.
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
  Future<Interaction?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InteractionTable>? where,
    int? offset,
    _i1.OrderByBuilder<InteractionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InteractionTable>? orderByList,
    _i1.Transaction? transaction,
    InteractionInclude? include,
  }) async {
    return session.db.findFirstRow<Interaction>(
      where: where?.call(Interaction.t),
      orderBy: orderBy?.call(Interaction.t),
      orderByList: orderByList?.call(Interaction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Interaction] by its [id] or null if no such row exists.
  Future<Interaction?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    InteractionInclude? include,
  }) async {
    return session.db.findById<Interaction>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Interaction]s in the list and returns the inserted rows.
  ///
  /// The returned [Interaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Interaction>> insert(
    _i1.Session session,
    List<Interaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Interaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Interaction] and returns the inserted row.
  ///
  /// The returned [Interaction] will have its `id` field set.
  Future<Interaction> insertRow(
    _i1.Session session,
    Interaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Interaction>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Interaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Interaction>> update(
    _i1.Session session,
    List<Interaction> rows, {
    _i1.ColumnSelections<InteractionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Interaction>(
      rows,
      columns: columns?.call(Interaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Interaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Interaction> updateRow(
    _i1.Session session,
    Interaction row, {
    _i1.ColumnSelections<InteractionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Interaction>(
      row,
      columns: columns?.call(Interaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Interaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Interaction?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<InteractionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Interaction>(
      id,
      columnValues: columnValues(Interaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Interaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Interaction>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<InteractionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<InteractionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InteractionTable>? orderBy,
    _i1.OrderByListBuilder<InteractionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Interaction>(
      columnValues: columnValues(Interaction.t.updateTable),
      where: where(Interaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Interaction.t),
      orderByList: orderByList?.call(Interaction.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Interaction]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Interaction>> delete(
    _i1.Session session,
    List<Interaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Interaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Interaction].
  Future<Interaction> deleteRow(
    _i1.Session session,
    Interaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Interaction>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Interaction>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<InteractionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Interaction>(
      where: where(Interaction.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InteractionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Interaction>(
      where: where?.call(Interaction.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class InteractionAttachRowRepository {
  const InteractionAttachRowRepository._();

  /// Creates a relation between the given [Interaction] and [Contact]
  /// by setting the [Interaction]'s foreign key `contactId` to refer to the [Contact].
  Future<void> contact(
    _i1.Session session,
    Interaction interaction,
    _i2.Contact contact, {
    _i1.Transaction? transaction,
  }) async {
    if (interaction.id == null) {
      throw ArgumentError.notNull('interaction.id');
    }
    if (contact.id == null) {
      throw ArgumentError.notNull('contact.id');
    }

    var $interaction = interaction.copyWith(contactId: contact.id);
    await session.db.updateRow<Interaction>(
      $interaction,
      columns: [Interaction.t.contactId],
      transaction: transaction,
    );
  }
}
