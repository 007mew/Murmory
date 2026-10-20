// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MemoriesTable extends Memories with TableInfo<$MemoriesTable, Memory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _audioFilePathMeta =
      const VerificationMeta('audioFilePath');
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
      'audio_file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioFileHashMeta =
      const VerificationMeta('audioFileHash');
  @override
  late final GeneratedColumn<String> audioFileHash = GeneratedColumn<String>(
      'audio_file_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _transcriptStatusMeta =
      const VerificationMeta('transcriptStatus');
  @override
  late final GeneratedColumn<String> transcriptStatus = GeneratedColumn<String>(
      'transcript_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _summaryStatusMeta =
      const VerificationMeta('summaryStatus');
  @override
  late final GeneratedColumn<String> summaryStatus = GeneratedColumn<String>(
      'summary_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _processingModeMeta =
      const VerificationMeta('processingMode');
  @override
  late final GeneratedColumn<String> processingMode = GeneratedColumn<String>(
      'processing_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _languageCodeMeta =
      const VerificationMeta('languageCode');
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
      'language_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _rawMetadataJsonMeta =
      const VerificationMeta('rawMetadataJson');
  @override
  late final GeneratedColumn<String> rawMetadataJson = GeneratedColumn<String>(
      'raw_metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        createdAt,
        updatedAt,
        durationMs,
        audioFilePath,
        audioFileHash,
        fileSizeBytes,
        transcriptStatus,
        summaryStatus,
        isFavorite,
        isArchived,
        processingMode,
        languageCode,
        rawMetadataJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(Insertable<Memory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
          _audioFilePathMeta,
          audioFilePath.isAcceptableOrUnknown(
              data['audio_file_path']!, _audioFilePathMeta));
    } else if (isInserting) {
      context.missing(_audioFilePathMeta);
    }
    if (data.containsKey('audio_file_hash')) {
      context.handle(
          _audioFileHashMeta,
          audioFileHash.isAcceptableOrUnknown(
              data['audio_file_hash']!, _audioFileHashMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('transcript_status')) {
      context.handle(
          _transcriptStatusMeta,
          transcriptStatus.isAcceptableOrUnknown(
              data['transcript_status']!, _transcriptStatusMeta));
    }
    if (data.containsKey('summary_status')) {
      context.handle(
          _summaryStatusMeta,
          summaryStatus.isAcceptableOrUnknown(
              data['summary_status']!, _summaryStatusMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('processing_mode')) {
      context.handle(
          _processingModeMeta,
          processingMode.isAcceptableOrUnknown(
              data['processing_mode']!, _processingModeMeta));
    }
    if (data.containsKey('language_code')) {
      context.handle(
          _languageCodeMeta,
          languageCode.isAcceptableOrUnknown(
              data['language_code']!, _languageCodeMeta));
    }
    if (data.containsKey('raw_metadata_json')) {
      context.handle(
          _rawMetadataJsonMeta,
          rawMetadataJson.isAcceptableOrUnknown(
              data['raw_metadata_json']!, _rawMetadataJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Memory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      audioFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_file_path'])!,
      audioFileHash: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_file_hash'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      transcriptStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transcript_status'])!,
      summaryStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary_status'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      processingMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}processing_mode'])!,
      languageCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_code'])!,
      rawMetadataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}raw_metadata_json'])!,
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class Memory extends DataClass implements Insertable<Memory> {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int durationMs;
  final String audioFilePath;
  final String audioFileHash;
  final int fileSizeBytes;
  final String transcriptStatus;
  final String summaryStatus;
  final bool isFavorite;
  final bool isArchived;
  final String processingMode;
  final String languageCode;
  final String rawMetadataJson;
  const Memory(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      required this.durationMs,
      required this.audioFilePath,
      required this.audioFileHash,
      required this.fileSizeBytes,
      required this.transcriptStatus,
      required this.summaryStatus,
      required this.isFavorite,
      required this.isArchived,
      required this.processingMode,
      required this.languageCode,
      required this.rawMetadataJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['audio_file_path'] = Variable<String>(audioFilePath);
    map['audio_file_hash'] = Variable<String>(audioFileHash);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['transcript_status'] = Variable<String>(transcriptStatus);
    map['summary_status'] = Variable<String>(summaryStatus);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['processing_mode'] = Variable<String>(processingMode);
    map['language_code'] = Variable<String>(languageCode);
    map['raw_metadata_json'] = Variable<String>(rawMetadataJson);
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      durationMs: Value(durationMs),
      audioFilePath: Value(audioFilePath),
      audioFileHash: Value(audioFileHash),
      fileSizeBytes: Value(fileSizeBytes),
      transcriptStatus: Value(transcriptStatus),
      summaryStatus: Value(summaryStatus),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      processingMode: Value(processingMode),
      languageCode: Value(languageCode),
      rawMetadataJson: Value(rawMetadataJson),
    );
  }

  factory Memory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memory(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      audioFilePath: serializer.fromJson<String>(json['audioFilePath']),
      audioFileHash: serializer.fromJson<String>(json['audioFileHash']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      transcriptStatus: serializer.fromJson<String>(json['transcriptStatus']),
      summaryStatus: serializer.fromJson<String>(json['summaryStatus']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      processingMode: serializer.fromJson<String>(json['processingMode']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      rawMetadataJson: serializer.fromJson<String>(json['rawMetadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'audioFilePath': serializer.toJson<String>(audioFilePath),
      'audioFileHash': serializer.toJson<String>(audioFileHash),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'transcriptStatus': serializer.toJson<String>(transcriptStatus),
      'summaryStatus': serializer.toJson<String>(summaryStatus),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'processingMode': serializer.toJson<String>(processingMode),
      'languageCode': serializer.toJson<String>(languageCode),
      'rawMetadataJson': serializer.toJson<String>(rawMetadataJson),
    };
  }

  Memory copyWith(
          {String? id,
          String? title,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? durationMs,
          String? audioFilePath,
          String? audioFileHash,
          int? fileSizeBytes,
          String? transcriptStatus,
          String? summaryStatus,
          bool? isFavorite,
          bool? isArchived,
          String? processingMode,
          String? languageCode,
          String? rawMetadataJson}) =>
      Memory(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        durationMs: durationMs ?? this.durationMs,
        audioFilePath: audioFilePath ?? this.audioFilePath,
        audioFileHash: audioFileHash ?? this.audioFileHash,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        transcriptStatus: transcriptStatus ?? this.transcriptStatus,
        summaryStatus: summaryStatus ?? this.summaryStatus,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        processingMode: processingMode ?? this.processingMode,
        languageCode: languageCode ?? this.languageCode,
        rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
      );
  Memory copyWithCompanion(MemoriesCompanion data) {
    return Memory(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      audioFileHash: data.audioFileHash.present
          ? data.audioFileHash.value
          : this.audioFileHash,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      transcriptStatus: data.transcriptStatus.present
          ? data.transcriptStatus.value
          : this.transcriptStatus,
      summaryStatus: data.summaryStatus.present
          ? data.summaryStatus.value
          : this.summaryStatus,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      processingMode: data.processingMode.present
          ? data.processingMode.value
          : this.processingMode,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      rawMetadataJson: data.rawMetadataJson.present
          ? data.rawMetadataJson.value
          : this.rawMetadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memory(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('audioFileHash: $audioFileHash, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('transcriptStatus: $transcriptStatus, ')
          ..write('summaryStatus: $summaryStatus, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('processingMode: $processingMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('rawMetadataJson: $rawMetadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      createdAt,
      updatedAt,
      durationMs,
      audioFilePath,
      audioFileHash,
      fileSizeBytes,
      transcriptStatus,
      summaryStatus,
      isFavorite,
      isArchived,
      processingMode,
      languageCode,
      rawMetadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memory &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.durationMs == this.durationMs &&
          other.audioFilePath == this.audioFilePath &&
          other.audioFileHash == this.audioFileHash &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.transcriptStatus == this.transcriptStatus &&
          other.summaryStatus == this.summaryStatus &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.processingMode == this.processingMode &&
          other.languageCode == this.languageCode &&
          other.rawMetadataJson == this.rawMetadataJson);
}

class MemoriesCompanion extends UpdateCompanion<Memory> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> durationMs;
  final Value<String> audioFilePath;
  final Value<String> audioFileHash;
  final Value<int> fileSizeBytes;
  final Value<String> transcriptStatus;
  final Value<String> summaryStatus;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<String> processingMode;
  final Value<String> languageCode;
  final Value<String> rawMetadataJson;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.audioFileHash = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.transcriptStatus = const Value.absent(),
    this.summaryStatus = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.durationMs = const Value.absent(),
    required String audioFilePath,
    this.audioFileHash = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.transcriptStatus = const Value.absent(),
    this.summaryStatus = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        audioFilePath = Value(audioFilePath);
  static Insertable<Memory> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? durationMs,
    Expression<String>? audioFilePath,
    Expression<String>? audioFileHash,
    Expression<int>? fileSizeBytes,
    Expression<String>? transcriptStatus,
    Expression<String>? summaryStatus,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<String>? processingMode,
    Expression<String>? languageCode,
    Expression<String>? rawMetadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (audioFileHash != null) 'audio_file_hash': audioFileHash,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (transcriptStatus != null) 'transcript_status': transcriptStatus,
      if (summaryStatus != null) 'summary_status': summaryStatus,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (processingMode != null) 'processing_mode': processingMode,
      if (languageCode != null) 'language_code': languageCode,
      if (rawMetadataJson != null) 'raw_metadata_json': rawMetadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? durationMs,
      Value<String>? audioFilePath,
      Value<String>? audioFileHash,
      Value<int>? fileSizeBytes,
      Value<String>? transcriptStatus,
      Value<String>? summaryStatus,
      Value<bool>? isFavorite,
      Value<bool>? isArchived,
      Value<String>? processingMode,
      Value<String>? languageCode,
      Value<String>? rawMetadataJson,
      Value<int>? rowid}) {
    return MemoriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationMs: durationMs ?? this.durationMs,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      audioFileHash: audioFileHash ?? this.audioFileHash,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      transcriptStatus: transcriptStatus ?? this.transcriptStatus,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      processingMode: processingMode ?? this.processingMode,
      languageCode: languageCode ?? this.languageCode,
      rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (audioFileHash.present) {
      map['audio_file_hash'] = Variable<String>(audioFileHash.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (transcriptStatus.present) {
      map['transcript_status'] = Variable<String>(transcriptStatus.value);
    }
    if (summaryStatus.present) {
      map['summary_status'] = Variable<String>(summaryStatus.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (processingMode.present) {
      map['processing_mode'] = Variable<String>(processingMode.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (rawMetadataJson.present) {
      map['raw_metadata_json'] = Variable<String>(rawMetadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('audioFileHash: $audioFileHash, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('transcriptStatus: $transcriptStatus, ')
          ..write('summaryStatus: $summaryStatus, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('processingMode: $processingMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('rawMetadataJson: $rawMetadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptSegmentsTable extends TranscriptSegments
    with TableInfo<$TranscriptSegmentsTable, TranscriptSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoryIdMeta =
      const VerificationMeta('memoryId');
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
      'memory_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES memories (id) ON DELETE CASCADE'));
  static const VerificationMeta _startMsMeta =
      const VerificationMeta('startMs');
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
      'start_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
      'end_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _speakerLabelMeta =
      const VerificationMeta('speakerLabel');
  @override
  late final GeneratedColumn<int> speakerLabel = GeneratedColumn<int>(
      'speaker_label', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sequenceIndexMeta =
      const VerificationMeta('sequenceIndex');
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
      'sequence_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memoryId,
        startMs,
        endMs,
        content,
        confidence,
        speakerLabel,
        sequenceIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_segments';
  @override
  VerificationContext validateIntegrity(Insertable<TranscriptSegment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(_memoryIdMeta,
          memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta));
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(_startMsMeta,
          startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta));
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
          _endMsMeta, endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta));
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('speaker_label')) {
      context.handle(
          _speakerLabelMeta,
          speakerLabel.isAcceptableOrUnknown(
              data['speaker_label']!, _speakerLabelMeta));
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
          _sequenceIndexMeta,
          sequenceIndex.isAcceptableOrUnknown(
              data['sequence_index']!, _sequenceIndexMeta));
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {memoryId, sequenceIndex},
      ];
  @override
  TranscriptSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptSegment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memory_id'])!,
      startMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_ms'])!,
      endMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_ms'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      speakerLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speaker_label']),
      sequenceIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_index'])!,
    );
  }

  @override
  $TranscriptSegmentsTable createAlias(String alias) {
    return $TranscriptSegmentsTable(attachedDatabase, alias);
  }
}

class TranscriptSegment extends DataClass
    implements Insertable<TranscriptSegment> {
  final String id;
  final String memoryId;
  final int startMs;
  final int endMs;
  final String content;
  final double confidence;
  final int? speakerLabel;
  final int sequenceIndex;
  const TranscriptSegment(
      {required this.id,
      required this.memoryId,
      required this.startMs,
      required this.endMs,
      required this.content,
      required this.confidence,
      this.speakerLabel,
      required this.sequenceIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['content'] = Variable<String>(content);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || speakerLabel != null) {
      map['speaker_label'] = Variable<int>(speakerLabel);
    }
    map['sequence_index'] = Variable<int>(sequenceIndex);
    return map;
  }

  TranscriptSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptSegmentsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      content: Value(content),
      confidence: Value(confidence),
      speakerLabel: speakerLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerLabel),
      sequenceIndex: Value(sequenceIndex),
    );
  }

  factory TranscriptSegment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptSegment(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      content: serializer.fromJson<String>(json['content']),
      confidence: serializer.fromJson<double>(json['confidence']),
      speakerLabel: serializer.fromJson<int?>(json['speakerLabel']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'content': serializer.toJson<String>(content),
      'confidence': serializer.toJson<double>(confidence),
      'speakerLabel': serializer.toJson<int?>(speakerLabel),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
    };
  }

  TranscriptSegment copyWith(
          {String? id,
          String? memoryId,
          int? startMs,
          int? endMs,
          String? content,
          double? confidence,
          Value<int?> speakerLabel = const Value.absent(),
          int? sequenceIndex}) =>
      TranscriptSegment(
        id: id ?? this.id,
        memoryId: memoryId ?? this.memoryId,
        startMs: startMs ?? this.startMs,
        endMs: endMs ?? this.endMs,
        content: content ?? this.content,
        confidence: confidence ?? this.confidence,
        speakerLabel:
            speakerLabel.present ? speakerLabel.value : this.speakerLabel,
        sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      );
  TranscriptSegment copyWithCompanion(TranscriptSegmentsCompanion data) {
    return TranscriptSegment(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      content: data.content.present ? data.content.value : this.content,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      speakerLabel: data.speakerLabel.present
          ? data.speakerLabel.value
          : this.speakerLabel,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegment(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('confidence: $confidence, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('sequenceIndex: $sequenceIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId, startMs, endMs, content,
      confidence, speakerLabel, sequenceIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptSegment &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.content == this.content &&
          other.confidence == this.confidence &&
          other.speakerLabel == this.speakerLabel &&
          other.sequenceIndex == this.sequenceIndex);
}

class TranscriptSegmentsCompanion extends UpdateCompanion<TranscriptSegment> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> content;
  final Value<double> confidence;
  final Value<int?> speakerLabel;
  final Value<int> sequenceIndex;
  final Value<int> rowid;
  const TranscriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.content = const Value.absent(),
    this.confidence = const Value.absent(),
    this.speakerLabel = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptSegmentsCompanion.insert({
    required String id,
    required String memoryId,
    required int startMs,
    required int endMs,
    required String content,
    this.confidence = const Value.absent(),
    this.speakerLabel = const Value.absent(),
    required int sequenceIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memoryId = Value(memoryId),
        startMs = Value(startMs),
        endMs = Value(endMs),
        content = Value(content),
        sequenceIndex = Value(sequenceIndex);
  static Insertable<TranscriptSegment> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? content,
    Expression<double>? confidence,
    Expression<int>? speakerLabel,
    Expression<int>? sequenceIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (content != null) 'content': content,
      if (confidence != null) 'confidence': confidence,
      if (speakerLabel != null) 'speaker_label': speakerLabel,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptSegmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memoryId,
      Value<int>? startMs,
      Value<int>? endMs,
      Value<String>? content,
      Value<double>? confidence,
      Value<int?>? speakerLabel,
      Value<int>? sequenceIndex,
      Value<int>? rowid}) {
    return TranscriptSegmentsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      content: content ?? this.content,
      confidence: confidence ?? this.confidence,
      speakerLabel: speakerLabel ?? this.speakerLabel,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (speakerLabel.present) {
      map['speaker_label'] = Variable<int>(speakerLabel.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('confidence: $confidence, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6C63FF'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, colorHex, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String colorHex;
  final DateTime createdAt;
  const Tag(
      {required this.id,
      required this.name,
      required this.colorHex,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tag copyWith(
          {String? id, String? name, String? colorHex, DateTime? createdAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? colorHex,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryTagsTable extends MemoryTags
    with TableInfo<$MemoryTagsTable, MemoryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memoryIdMeta =
      const VerificationMeta('memoryId');
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
      'memory_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES memories (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [memoryId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_tags';
  @override
  VerificationContext validateIntegrity(Insertable<MemoryTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('memory_id')) {
      context.handle(_memoryIdMeta,
          memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta));
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memoryId, tagId};
  @override
  MemoryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryTag(
      memoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memory_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $MemoryTagsTable createAlias(String alias) {
    return $MemoryTagsTable(attachedDatabase, alias);
  }
}

class MemoryTag extends DataClass implements Insertable<MemoryTag> {
  final String memoryId;
  final String tagId;
  const MemoryTag({required this.memoryId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['memory_id'] = Variable<String>(memoryId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  MemoryTagsCompanion toCompanion(bool nullToAbsent) {
    return MemoryTagsCompanion(
      memoryId: Value(memoryId),
      tagId: Value(tagId),
    );
  }

  factory MemoryTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryTag(
      memoryId: serializer.fromJson<String>(json['memoryId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memoryId': serializer.toJson<String>(memoryId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  MemoryTag copyWith({String? memoryId, String? tagId}) => MemoryTag(
        memoryId: memoryId ?? this.memoryId,
        tagId: tagId ?? this.tagId,
      );
  MemoryTag copyWithCompanion(MemoryTagsCompanion data) {
    return MemoryTag(
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryTag(')
          ..write('memoryId: $memoryId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(memoryId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryTag &&
          other.memoryId == this.memoryId &&
          other.tagId == this.tagId);
}

class MemoryTagsCompanion extends UpdateCompanion<MemoryTag> {
  final Value<String> memoryId;
  final Value<String> tagId;
  final Value<int> rowid;
  const MemoryTagsCompanion({
    this.memoryId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryTagsCompanion.insert({
    required String memoryId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : memoryId = Value(memoryId),
        tagId = Value(tagId);
  static Insertable<MemoryTag> custom({
    Expression<String>? memoryId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memoryId != null) 'memory_id': memoryId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryTagsCompanion copyWith(
      {Value<String>? memoryId, Value<String>? tagId, Value<int>? rowid}) {
    return MemoryTagsCompanion(
      memoryId: memoryId ?? this.memoryId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryTagsCompanion(')
          ..write('memoryId: $memoryId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessingJobsTable extends ProcessingJobs
    with TableInfo<$ProcessingJobsTable, ProcessingJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoryIdMeta =
      const VerificationMeta('memoryId');
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
      'memory_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES memories (id) ON DELETE CASCADE'));
  static const VerificationMeta _jobTypeMeta =
      const VerificationMeta('jobType');
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
      'job_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _attemptMeta =
      const VerificationMeta('attempt');
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
      'attempt', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxAttemptsMeta =
      const VerificationMeta('maxAttempts');
  @override
  late final GeneratedColumn<int> maxAttempts = GeneratedColumn<int>(
      'max_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultJsonMeta =
      const VerificationMeta('resultJson');
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
      'result_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memoryId,
        jobType,
        status,
        attempt,
        maxAttempts,
        createdAt,
        updatedAt,
        scheduledAt,
        errorMessage,
        resultJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<ProcessingJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(_memoryIdMeta,
          memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta));
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(_jobTypeMeta,
          jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta));
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempt')) {
      context.handle(_attemptMeta,
          attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta));
    }
    if (data.containsKey('max_attempts')) {
      context.handle(
          _maxAttemptsMeta,
          maxAttempts.isAcceptableOrUnknown(
              data['max_attempts']!, _maxAttemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('result_json')) {
      context.handle(
          _resultJsonMeta,
          resultJson.isAcceptableOrUnknown(
              data['result_json']!, _resultJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessingJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memory_id'])!,
      jobType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      maxAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      resultJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_json']),
    );
  }

  @override
  $ProcessingJobsTable createAlias(String alias) {
    return $ProcessingJobsTable(attachedDatabase, alias);
  }
}

class ProcessingJob extends DataClass implements Insertable<ProcessingJob> {
  final String id;
  final String memoryId;
  final String jobType;
  final String status;
  final int attempt;
  final int maxAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime scheduledAt;
  final String? errorMessage;
  final String? resultJson;
  const ProcessingJob(
      {required this.id,
      required this.memoryId,
      required this.jobType,
      required this.status,
      required this.attempt,
      required this.maxAttempts,
      required this.createdAt,
      required this.updatedAt,
      required this.scheduledAt,
      this.errorMessage,
      this.resultJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['job_type'] = Variable<String>(jobType);
    map['status'] = Variable<String>(status);
    map['attempt'] = Variable<int>(attempt);
    map['max_attempts'] = Variable<int>(maxAttempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    return map;
  }

  ProcessingJobsCompanion toCompanion(bool nullToAbsent) {
    return ProcessingJobsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      jobType: Value(jobType),
      status: Value(status),
      attempt: Value(attempt),
      maxAttempts: Value(maxAttempts),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      scheduledAt: Value(scheduledAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
    );
  }

  factory ProcessingJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingJob(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      jobType: serializer.fromJson<String>(json['jobType']),
      status: serializer.fromJson<String>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
      maxAttempts: serializer.fromJson<int>(json['maxAttempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'jobType': serializer.toJson<String>(jobType),
      'status': serializer.toJson<String>(status),
      'attempt': serializer.toJson<int>(attempt),
      'maxAttempts': serializer.toJson<int>(maxAttempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'resultJson': serializer.toJson<String?>(resultJson),
    };
  }

  ProcessingJob copyWith(
          {String? id,
          String? memoryId,
          String? jobType,
          String? status,
          int? attempt,
          int? maxAttempts,
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? scheduledAt,
          Value<String?> errorMessage = const Value.absent(),
          Value<String?> resultJson = const Value.absent()}) =>
      ProcessingJob(
        id: id ?? this.id,
        memoryId: memoryId ?? this.memoryId,
        jobType: jobType ?? this.jobType,
        status: status ?? this.status,
        attempt: attempt ?? this.attempt,
        maxAttempts: maxAttempts ?? this.maxAttempts,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        resultJson: resultJson.present ? resultJson.value : this.resultJson,
      );
  ProcessingJob copyWithCompanion(ProcessingJobsCompanion data) {
    return ProcessingJob(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      maxAttempts:
          data.maxAttempts.present ? data.maxAttempts.value : this.maxAttempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      resultJson:
          data.resultJson.present ? data.resultJson.value : this.resultJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingJob(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('resultJson: $resultJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId, jobType, status, attempt,
      maxAttempts, createdAt, updatedAt, scheduledAt, errorMessage, resultJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingJob &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.jobType == this.jobType &&
          other.status == this.status &&
          other.attempt == this.attempt &&
          other.maxAttempts == this.maxAttempts &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.scheduledAt == this.scheduledAt &&
          other.errorMessage == this.errorMessage &&
          other.resultJson == this.resultJson);
}

class ProcessingJobsCompanion extends UpdateCompanion<ProcessingJob> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<String> jobType;
  final Value<String> status;
  final Value<int> attempt;
  final Value<int> maxAttempts;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> scheduledAt;
  final Value<String?> errorMessage;
  final Value<String?> resultJson;
  final Value<int> rowid;
  const ProcessingJobsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessingJobsCompanion.insert({
    required String id,
    required String memoryId,
    required String jobType,
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime scheduledAt,
    this.errorMessage = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memoryId = Value(memoryId),
        jobType = Value(jobType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        scheduledAt = Value(scheduledAt);
  static Insertable<ProcessingJob> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<String>? jobType,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<int>? maxAttempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? scheduledAt,
    Expression<String>? errorMessage,
    Expression<String>? resultJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (jobType != null) 'job_type': jobType,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (maxAttempts != null) 'max_attempts': maxAttempts,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (resultJson != null) 'result_json': resultJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessingJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memoryId,
      Value<String>? jobType,
      Value<String>? status,
      Value<int>? attempt,
      Value<int>? maxAttempts,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? scheduledAt,
      Value<String?>? errorMessage,
      Value<String?>? resultJson,
      Value<int>? rowid}) {
    return ProcessingJobsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      errorMessage: errorMessage ?? this.errorMessage,
      resultJson: resultJson ?? this.resultJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (maxAttempts.present) {
      map['max_attempts'] = Variable<int>(maxAttempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingJobsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('resultJson: $resultJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $TranscriptSegmentsTable transcriptSegments =
      $TranscriptSegmentsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $MemoryTagsTable memoryTags = $MemoryTagsTable(this);
  late final $ProcessingJobsTable processingJobs = $ProcessingJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [memories, transcriptSegments, tags, memoryTags, processingJobs];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('memories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transcript_segments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('memories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('memory_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('memory_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('memories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('processing_jobs', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$MemoriesTableCreateCompanionBuilder = MemoriesCompanion Function({
  required String id,
  Value<String> title,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> durationMs,
  required String audioFilePath,
  Value<String> audioFileHash,
  Value<int> fileSizeBytes,
  Value<String> transcriptStatus,
  Value<String> summaryStatus,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String> processingMode,
  Value<String> languageCode,
  Value<String> rawMetadataJson,
  Value<int> rowid,
});
typedef $$MemoriesTableUpdateCompanionBuilder = MemoriesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> durationMs,
  Value<String> audioFilePath,
  Value<String> audioFileHash,
  Value<int> fileSizeBytes,
  Value<String> transcriptStatus,
  Value<String> summaryStatus,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String> processingMode,
  Value<String> languageCode,
  Value<String> rawMetadataJson,
  Value<int> rowid,
});

final class $$MemoriesTableReferences
    extends BaseReferences<_$AppDatabase, $MemoriesTable, Memory> {
  $$MemoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TranscriptSegmentsTable, List<TranscriptSegment>>
      _transcriptSegmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transcriptSegments,
              aliasName: $_aliasNameGenerator(
                  db.memories.id, db.transcriptSegments.memoryId));

  $$TranscriptSegmentsTableProcessedTableManager get transcriptSegmentsRefs {
    final manager = $$TranscriptSegmentsTableTableManager(
            $_db, $_db.transcriptSegments)
        .filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transcriptSegmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MemoryTagsTable, List<MemoryTag>>
      _memoryTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.memoryTags,
              aliasName:
                  $_aliasNameGenerator(db.memories.id, db.memoryTags.memoryId));

  $$MemoryTagsTableProcessedTableManager get memoryTagsRefs {
    final manager = $$MemoryTagsTableTableManager($_db, $_db.memoryTags)
        .filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProcessingJobsTable, List<ProcessingJob>>
      _processingJobsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.processingJobs,
              aliasName: $_aliasNameGenerator(
                  db.memories.id, db.processingJobs.memoryId));

  $$ProcessingJobsTableProcessedTableManager get processingJobsRefs {
    final manager = $$ProcessingJobsTableTableManager($_db, $_db.processingJobs)
        .filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_processingJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioFilePath => $composableBuilder(
      column: $table.audioFilePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioFileHash => $composableBuilder(
      column: $table.audioFileHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcriptStatus => $composableBuilder(
      column: $table.transcriptStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summaryStatus => $composableBuilder(
      column: $table.summaryStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processingMode => $composableBuilder(
      column: $table.processingMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawMetadataJson => $composableBuilder(
      column: $table.rawMetadataJson,
      builder: (column) => ColumnFilters(column));

  Expression<bool> transcriptSegmentsRefs(
      Expression<bool> Function($$TranscriptSegmentsTableFilterComposer f) f) {
    final $$TranscriptSegmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transcriptSegments,
        getReferencedColumn: (t) => t.memoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranscriptSegmentsTableFilterComposer(
              $db: $db,
              $table: $db.transcriptSegments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> memoryTagsRefs(
      Expression<bool> Function($$MemoryTagsTableFilterComposer f) f) {
    final $$MemoryTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.memoryTags,
        getReferencedColumn: (t) => t.memoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoryTagsTableFilterComposer(
              $db: $db,
              $table: $db.memoryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> processingJobsRefs(
      Expression<bool> Function($$ProcessingJobsTableFilterComposer f) f) {
    final $$ProcessingJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processingJobs,
        getReferencedColumn: (t) => t.memoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessingJobsTableFilterComposer(
              $db: $db,
              $table: $db.processingJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
      column: $table.audioFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioFileHash => $composableBuilder(
      column: $table.audioFileHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcriptStatus => $composableBuilder(
      column: $table.transcriptStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summaryStatus => $composableBuilder(
      column: $table.summaryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processingMode => $composableBuilder(
      column: $table.processingMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageCode => $composableBuilder(
      column: $table.languageCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawMetadataJson => $composableBuilder(
      column: $table.rawMetadataJson,
      builder: (column) => ColumnOrderings(column));
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
      column: $table.audioFilePath, builder: (column) => column);

  GeneratedColumn<String> get audioFileHash => $composableBuilder(
      column: $table.audioFileHash, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get transcriptStatus => $composableBuilder(
      column: $table.transcriptStatus, builder: (column) => column);

  GeneratedColumn<String> get summaryStatus => $composableBuilder(
      column: $table.summaryStatus, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<String> get processingMode => $composableBuilder(
      column: $table.processingMode, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => column);

  GeneratedColumn<String> get rawMetadataJson => $composableBuilder(
      column: $table.rawMetadataJson, builder: (column) => column);

  Expression<T> transcriptSegmentsRefs<T extends Object>(
      Expression<T> Function($$TranscriptSegmentsTableAnnotationComposer a) f) {
    final $$TranscriptSegmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transcriptSegments,
            getReferencedColumn: (t) => t.memoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TranscriptSegmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transcriptSegments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> memoryTagsRefs<T extends Object>(
      Expression<T> Function($$MemoryTagsTableAnnotationComposer a) f) {
    final $$MemoryTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.memoryTags,
        getReferencedColumn: (t) => t.memoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoryTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.memoryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> processingJobsRefs<T extends Object>(
      Expression<T> Function($$ProcessingJobsTableAnnotationComposer a) f) {
    final $$ProcessingJobsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processingJobs,
        getReferencedColumn: (t) => t.memoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessingJobsTableAnnotationComposer(
              $db: $db,
              $table: $db.processingJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MemoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MemoriesTable,
    Memory,
    $$MemoriesTableFilterComposer,
    $$MemoriesTableOrderingComposer,
    $$MemoriesTableAnnotationComposer,
    $$MemoriesTableCreateCompanionBuilder,
    $$MemoriesTableUpdateCompanionBuilder,
    (Memory, $$MemoriesTableReferences),
    Memory,
    PrefetchHooks Function(
        {bool transcriptSegmentsRefs,
        bool memoryTagsRefs,
        bool processingJobsRefs})> {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> audioFilePath = const Value.absent(),
            Value<String> audioFileHash = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String> transcriptStatus = const Value.absent(),
            Value<String> summaryStatus = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String> processingMode = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<String> rawMetadataJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoriesCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            durationMs: durationMs,
            audioFilePath: audioFilePath,
            audioFileHash: audioFileHash,
            fileSizeBytes: fileSizeBytes,
            transcriptStatus: transcriptStatus,
            summaryStatus: summaryStatus,
            isFavorite: isFavorite,
            isArchived: isArchived,
            processingMode: processingMode,
            languageCode: languageCode,
            rawMetadataJson: rawMetadataJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> title = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> durationMs = const Value.absent(),
            required String audioFilePath,
            Value<String> audioFileHash = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String> transcriptStatus = const Value.absent(),
            Value<String> summaryStatus = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String> processingMode = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<String> rawMetadataJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoriesCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            durationMs: durationMs,
            audioFilePath: audioFilePath,
            audioFileHash: audioFileHash,
            fileSizeBytes: fileSizeBytes,
            transcriptStatus: transcriptStatus,
            summaryStatus: summaryStatus,
            isFavorite: isFavorite,
            isArchived: isArchived,
            processingMode: processingMode,
            languageCode: languageCode,
            rawMetadataJson: rawMetadataJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MemoriesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transcriptSegmentsRefs = false,
              memoryTagsRefs = false,
              processingJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transcriptSegmentsRefs) db.transcriptSegments,
                if (memoryTagsRefs) db.memoryTags,
                if (processingJobsRefs) db.processingJobs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transcriptSegmentsRefs)
                    await $_getPrefetchedData<Memory, $MemoriesTable,
                            TranscriptSegment>(
                        currentTable: table,
                        referencedTable: $$MemoriesTableReferences
                            ._transcriptSegmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MemoriesTableReferences(db, table, p0)
                                .transcriptSegmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.memoryId == item.id),
                        typedResults: items),
                  if (memoryTagsRefs)
                    await $_getPrefetchedData<Memory, $MemoriesTable,
                            MemoryTag>(
                        currentTable: table,
                        referencedTable:
                            $$MemoriesTableReferences._memoryTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MemoriesTableReferences(db, table, p0)
                                .memoryTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.memoryId == item.id),
                        typedResults: items),
                  if (processingJobsRefs)
                    await $_getPrefetchedData<Memory, $MemoriesTable,
                            ProcessingJob>(
                        currentTable: table,
                        referencedTable: $$MemoriesTableReferences
                            ._processingJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MemoriesTableReferences(db, table, p0)
                                .processingJobsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.memoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MemoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MemoriesTable,
    Memory,
    $$MemoriesTableFilterComposer,
    $$MemoriesTableOrderingComposer,
    $$MemoriesTableAnnotationComposer,
    $$MemoriesTableCreateCompanionBuilder,
    $$MemoriesTableUpdateCompanionBuilder,
    (Memory, $$MemoriesTableReferences),
    Memory,
    PrefetchHooks Function(
        {bool transcriptSegmentsRefs,
        bool memoryTagsRefs,
        bool processingJobsRefs})>;
typedef $$TranscriptSegmentsTableCreateCompanionBuilder
    = TranscriptSegmentsCompanion Function({
  required String id,
  required String memoryId,
  required int startMs,
  required int endMs,
  required String content,
  Value<double> confidence,
  Value<int?> speakerLabel,
  required int sequenceIndex,
  Value<int> rowid,
});
typedef $$TranscriptSegmentsTableUpdateCompanionBuilder
    = TranscriptSegmentsCompanion Function({
  Value<String> id,
  Value<String> memoryId,
  Value<int> startMs,
  Value<int> endMs,
  Value<String> content,
  Value<double> confidence,
  Value<int?> speakerLabel,
  Value<int> sequenceIndex,
  Value<int> rowid,
});

final class $$TranscriptSegmentsTableReferences extends BaseReferences<
    _$AppDatabase, $TranscriptSegmentsTable, TranscriptSegment> {
  $$TranscriptSegmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MemoriesTable _memoryIdTable(_$AppDatabase db) =>
      db.memories.createAlias(
          $_aliasNameGenerator(db.transcriptSegments.memoryId, db.memories.id));

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager($_db, $_db.memories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TranscriptSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMs => $composableBuilder(
      column: $table.startMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMs => $composableBuilder(
      column: $table.endMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speakerLabel => $composableBuilder(
      column: $table.speakerLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => ColumnFilters(column));

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableFilterComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranscriptSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMs => $composableBuilder(
      column: $table.startMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMs => $composableBuilder(
      column: $table.endMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speakerLabel => $composableBuilder(
      column: $table.speakerLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex,
      builder: (column) => ColumnOrderings(column));

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableOrderingComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranscriptSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<int> get speakerLabel => $composableBuilder(
      column: $table.speakerLabel, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => column);

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranscriptSegmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TranscriptSegmentsTable,
    TranscriptSegment,
    $$TranscriptSegmentsTableFilterComposer,
    $$TranscriptSegmentsTableOrderingComposer,
    $$TranscriptSegmentsTableAnnotationComposer,
    $$TranscriptSegmentsTableCreateCompanionBuilder,
    $$TranscriptSegmentsTableUpdateCompanionBuilder,
    (TranscriptSegment, $$TranscriptSegmentsTableReferences),
    TranscriptSegment,
    PrefetchHooks Function({bool memoryId})> {
  $$TranscriptSegmentsTableTableManager(
      _$AppDatabase db, $TranscriptSegmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptSegmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memoryId = const Value.absent(),
            Value<int> startMs = const Value.absent(),
            Value<int> endMs = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<int?> speakerLabel = const Value.absent(),
            Value<int> sequenceIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TranscriptSegmentsCompanion(
            id: id,
            memoryId: memoryId,
            startMs: startMs,
            endMs: endMs,
            content: content,
            confidence: confidence,
            speakerLabel: speakerLabel,
            sequenceIndex: sequenceIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memoryId,
            required int startMs,
            required int endMs,
            required String content,
            Value<double> confidence = const Value.absent(),
            Value<int?> speakerLabel = const Value.absent(),
            required int sequenceIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              TranscriptSegmentsCompanion.insert(
            id: id,
            memoryId: memoryId,
            startMs: startMs,
            endMs: endMs,
            content: content,
            confidence: confidence,
            speakerLabel: speakerLabel,
            sequenceIndex: sequenceIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TranscriptSegmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({memoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (memoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memoryId,
                    referencedTable:
                        $$TranscriptSegmentsTableReferences._memoryIdTable(db),
                    referencedColumn: $$TranscriptSegmentsTableReferences
                        ._memoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TranscriptSegmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TranscriptSegmentsTable,
    TranscriptSegment,
    $$TranscriptSegmentsTableFilterComposer,
    $$TranscriptSegmentsTableOrderingComposer,
    $$TranscriptSegmentsTableAnnotationComposer,
    $$TranscriptSegmentsTableCreateCompanionBuilder,
    $$TranscriptSegmentsTableUpdateCompanionBuilder,
    (TranscriptSegment, $$TranscriptSegmentsTableReferences),
    TranscriptSegment,
    PrefetchHooks Function({bool memoryId})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<String> colorHex,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> colorHex,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MemoryTagsTable, List<MemoryTag>>
      _memoryTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.memoryTags,
              aliasName: $_aliasNameGenerator(db.tags.id, db.memoryTags.tagId));

  $$MemoryTagsTableProcessedTableManager get memoryTagsRefs {
    final manager = $$MemoryTagsTableTableManager($_db, $_db.memoryTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> memoryTagsRefs(
      Expression<bool> Function($$MemoryTagsTableFilterComposer f) f) {
    final $$MemoryTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.memoryTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoryTagsTableFilterComposer(
              $db: $db,
              $table: $db.memoryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> memoryTagsRefs<T extends Object>(
      Expression<T> Function($$MemoryTagsTableAnnotationComposer a) f) {
    final $$MemoryTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.memoryTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoryTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.memoryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool memoryTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            colorHex: colorHex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> colorHex = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            colorHex: colorHex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({memoryTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (memoryTagsRefs) db.memoryTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (memoryTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, MemoryTag>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._memoryTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).memoryTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool memoryTagsRefs})>;
typedef $$MemoryTagsTableCreateCompanionBuilder = MemoryTagsCompanion Function({
  required String memoryId,
  required String tagId,
  Value<int> rowid,
});
typedef $$MemoryTagsTableUpdateCompanionBuilder = MemoryTagsCompanion Function({
  Value<String> memoryId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$MemoryTagsTableReferences
    extends BaseReferences<_$AppDatabase, $MemoryTagsTable, MemoryTag> {
  $$MemoryTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoriesTable _memoryIdTable(_$AppDatabase db) =>
      db.memories.createAlias(
          $_aliasNameGenerator(db.memoryTags.memoryId, db.memories.id));

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager($_db, $_db.memories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.memoryTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MemoryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableFilterComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MemoryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableOrderingComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MemoryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MemoryTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MemoryTagsTable,
    MemoryTag,
    $$MemoryTagsTableFilterComposer,
    $$MemoryTagsTableOrderingComposer,
    $$MemoryTagsTableAnnotationComposer,
    $$MemoryTagsTableCreateCompanionBuilder,
    $$MemoryTagsTableUpdateCompanionBuilder,
    (MemoryTag, $$MemoryTagsTableReferences),
    MemoryTag,
    PrefetchHooks Function({bool memoryId, bool tagId})> {
  $$MemoryTagsTableTableManager(_$AppDatabase db, $MemoryTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> memoryId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoryTagsCompanion(
            memoryId: memoryId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String memoryId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoryTagsCompanion.insert(
            memoryId: memoryId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MemoryTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({memoryId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (memoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memoryId,
                    referencedTable:
                        $$MemoryTagsTableReferences._memoryIdTable(db),
                    referencedColumn:
                        $$MemoryTagsTableReferences._memoryIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$MemoryTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$MemoryTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MemoryTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MemoryTagsTable,
    MemoryTag,
    $$MemoryTagsTableFilterComposer,
    $$MemoryTagsTableOrderingComposer,
    $$MemoryTagsTableAnnotationComposer,
    $$MemoryTagsTableCreateCompanionBuilder,
    $$MemoryTagsTableUpdateCompanionBuilder,
    (MemoryTag, $$MemoryTagsTableReferences),
    MemoryTag,
    PrefetchHooks Function({bool memoryId, bool tagId})>;
typedef $$ProcessingJobsTableCreateCompanionBuilder = ProcessingJobsCompanion
    Function({
  required String id,
  required String memoryId,
  required String jobType,
  Value<String> status,
  Value<int> attempt,
  Value<int> maxAttempts,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime scheduledAt,
  Value<String?> errorMessage,
  Value<String?> resultJson,
  Value<int> rowid,
});
typedef $$ProcessingJobsTableUpdateCompanionBuilder = ProcessingJobsCompanion
    Function({
  Value<String> id,
  Value<String> memoryId,
  Value<String> jobType,
  Value<String> status,
  Value<int> attempt,
  Value<int> maxAttempts,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> scheduledAt,
  Value<String?> errorMessage,
  Value<String?> resultJson,
  Value<int> rowid,
});

final class $$ProcessingJobsTableReferences
    extends BaseReferences<_$AppDatabase, $ProcessingJobsTable, ProcessingJob> {
  $$ProcessingJobsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MemoriesTable _memoryIdTable(_$AppDatabase db) =>
      db.memories.createAlias(
          $_aliasNameGenerator(db.processingJobs.memoryId, db.memories.id));

  $$MemoriesTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoriesTableTableManager($_db, $_db.memories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProcessingJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnFilters(column));

  $$MemoriesTableFilterComposer get memoryId {
    final $$MemoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableFilterComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProcessingJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnOrderings(column));

  $$MemoriesTableOrderingComposer get memoryId {
    final $$MemoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableOrderingComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProcessingJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => column);

  $$MemoriesTableAnnotationComposer get memoryId {
    final $$MemoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoryId,
        referencedTable: $db.memories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MemoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.memories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProcessingJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessingJobsTable,
    ProcessingJob,
    $$ProcessingJobsTableFilterComposer,
    $$ProcessingJobsTableOrderingComposer,
    $$ProcessingJobsTableAnnotationComposer,
    $$ProcessingJobsTableCreateCompanionBuilder,
    $$ProcessingJobsTableUpdateCompanionBuilder,
    (ProcessingJob, $$ProcessingJobsTableReferences),
    ProcessingJob,
    PrefetchHooks Function({bool memoryId})> {
  $$ProcessingJobsTableTableManager(
      _$AppDatabase db, $ProcessingJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memoryId = const Value.absent(),
            Value<String> jobType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<int> maxAttempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingJobsCompanion(
            id: id,
            memoryId: memoryId,
            jobType: jobType,
            status: status,
            attempt: attempt,
            maxAttempts: maxAttempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
            errorMessage: errorMessage,
            resultJson: resultJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memoryId,
            required String jobType,
            Value<String> status = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<int> maxAttempts = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            required DateTime scheduledAt,
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingJobsCompanion.insert(
            id: id,
            memoryId: memoryId,
            jobType: jobType,
            status: status,
            attempt: attempt,
            maxAttempts: maxAttempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
            errorMessage: errorMessage,
            resultJson: resultJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessingJobsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({memoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (memoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memoryId,
                    referencedTable:
                        $$ProcessingJobsTableReferences._memoryIdTable(db),
                    referencedColumn:
                        $$ProcessingJobsTableReferences._memoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProcessingJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessingJobsTable,
    ProcessingJob,
    $$ProcessingJobsTableFilterComposer,
    $$ProcessingJobsTableOrderingComposer,
    $$ProcessingJobsTableAnnotationComposer,
    $$ProcessingJobsTableCreateCompanionBuilder,
    $$ProcessingJobsTableUpdateCompanionBuilder,
    (ProcessingJob, $$ProcessingJobsTableReferences),
    ProcessingJob,
    PrefetchHooks Function({bool memoryId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$TranscriptSegmentsTableTableManager get transcriptSegments =>
      $$TranscriptSegmentsTableTableManager(_db, _db.transcriptSegments);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$MemoryTagsTableTableManager get memoryTags =>
      $$MemoryTagsTableTableManager(_db, _db.memoryTags);
  $$ProcessingJobsTableTableManager get processingJobs =>
      $$ProcessingJobsTableTableManager(_db, _db.processingJobs);
}
