// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vidu_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ViduEvent {
  String get sessionId => throw _privateConstructorUsedError;
  String get basicAuthToken => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sessionId, String basicAuthToken)
        createConnection,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sessionId, String basicAuthToken)?
        createConnection,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sessionId, String basicAuthToken)? createConnection,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CreateConnection value) createConnection,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CreateConnection value)? createConnection,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CreateConnection value)? createConnection,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViduEventCopyWith<ViduEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViduEventCopyWith<$Res> {
  factory $ViduEventCopyWith(ViduEvent value, $Res Function(ViduEvent) then) =
      _$ViduEventCopyWithImpl<$Res, ViduEvent>;
  @useResult
  $Res call({String sessionId, String basicAuthToken});
}

/// @nodoc
class _$ViduEventCopyWithImpl<$Res, $Val extends ViduEvent>
    implements $ViduEventCopyWith<$Res> {
  _$ViduEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? basicAuthToken = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      basicAuthToken: null == basicAuthToken
          ? _value.basicAuthToken
          : basicAuthToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateConnectionImplCopyWith<$Res>
    implements $ViduEventCopyWith<$Res> {
  factory _$$CreateConnectionImplCopyWith(_$CreateConnectionImpl value,
          $Res Function(_$CreateConnectionImpl) then) =
      __$$CreateConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId, String basicAuthToken});
}

/// @nodoc
class __$$CreateConnectionImplCopyWithImpl<$Res>
    extends _$ViduEventCopyWithImpl<$Res, _$CreateConnectionImpl>
    implements _$$CreateConnectionImplCopyWith<$Res> {
  __$$CreateConnectionImplCopyWithImpl(_$CreateConnectionImpl _value,
      $Res Function(_$CreateConnectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? basicAuthToken = null,
  }) {
    return _then(_$CreateConnectionImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      basicAuthToken: null == basicAuthToken
          ? _value.basicAuthToken
          : basicAuthToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CreateConnectionImpl implements _CreateConnection {
  const _$CreateConnectionImpl(
      {required this.sessionId, required this.basicAuthToken});

  @override
  final String sessionId;
  @override
  final String basicAuthToken;

  @override
  String toString() {
    return 'ViduEvent.createConnection(sessionId: $sessionId, basicAuthToken: $basicAuthToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateConnectionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.basicAuthToken, basicAuthToken) ||
                other.basicAuthToken == basicAuthToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, basicAuthToken);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateConnectionImplCopyWith<_$CreateConnectionImpl> get copyWith =>
      __$$CreateConnectionImplCopyWithImpl<_$CreateConnectionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sessionId, String basicAuthToken)
        createConnection,
  }) {
    return createConnection(sessionId, basicAuthToken);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sessionId, String basicAuthToken)?
        createConnection,
  }) {
    return createConnection?.call(sessionId, basicAuthToken);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sessionId, String basicAuthToken)? createConnection,
    required TResult orElse(),
  }) {
    if (createConnection != null) {
      return createConnection(sessionId, basicAuthToken);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CreateConnection value) createConnection,
  }) {
    return createConnection(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CreateConnection value)? createConnection,
  }) {
    return createConnection?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CreateConnection value)? createConnection,
    required TResult orElse(),
  }) {
    if (createConnection != null) {
      return createConnection(this);
    }
    return orElse();
  }
}

abstract class _CreateConnection implements ViduEvent {
  const factory _CreateConnection(
      {required final String sessionId,
      required final String basicAuthToken}) = _$CreateConnectionImpl;

  @override
  String get sessionId;
  @override
  String get basicAuthToken;
  @override
  @JsonKey(ignore: true)
  _$$CreateConnectionImplCopyWith<_$CreateConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViduState {
  CreateConnectionStateState get createConnectionStateState =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViduStateCopyWith<ViduState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViduStateCopyWith<$Res> {
  factory $ViduStateCopyWith(ViduState value, $Res Function(ViduState) then) =
      _$ViduStateCopyWithImpl<$Res, ViduState>;
  @useResult
  $Res call({CreateConnectionStateState createConnectionStateState});
}

/// @nodoc
class _$ViduStateCopyWithImpl<$Res, $Val extends ViduState>
    implements $ViduStateCopyWith<$Res> {
  _$ViduStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createConnectionStateState = null,
  }) {
    return _then(_value.copyWith(
      createConnectionStateState: null == createConnectionStateState
          ? _value.createConnectionStateState
          : createConnectionStateState // ignore: cast_nullable_to_non_nullable
              as CreateConnectionStateState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViduStateImplCopyWith<$Res>
    implements $ViduStateCopyWith<$Res> {
  factory _$$ViduStateImplCopyWith(
          _$ViduStateImpl value, $Res Function(_$ViduStateImpl) then) =
      __$$ViduStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CreateConnectionStateState createConnectionStateState});
}

/// @nodoc
class __$$ViduStateImplCopyWithImpl<$Res>
    extends _$ViduStateCopyWithImpl<$Res, _$ViduStateImpl>
    implements _$$ViduStateImplCopyWith<$Res> {
  __$$ViduStateImplCopyWithImpl(
      _$ViduStateImpl _value, $Res Function(_$ViduStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createConnectionStateState = null,
  }) {
    return _then(_$ViduStateImpl(
      createConnectionStateState: null == createConnectionStateState
          ? _value.createConnectionStateState
          : createConnectionStateState // ignore: cast_nullable_to_non_nullable
              as CreateConnectionStateState,
    ));
  }
}

/// @nodoc

class _$ViduStateImpl implements _ViduState {
  const _$ViduStateImpl({required this.createConnectionStateState});

  @override
  final CreateConnectionStateState createConnectionStateState;

  @override
  String toString() {
    return 'ViduState(createConnectionStateState: $createConnectionStateState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViduStateImpl &&
            (identical(other.createConnectionStateState,
                    createConnectionStateState) ||
                other.createConnectionStateState ==
                    createConnectionStateState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, createConnectionStateState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViduStateImplCopyWith<_$ViduStateImpl> get copyWith =>
      __$$ViduStateImplCopyWithImpl<_$ViduStateImpl>(this, _$identity);
}

abstract class _ViduState implements ViduState {
  const factory _ViduState(
      {required final CreateConnectionStateState
          createConnectionStateState}) = _$ViduStateImpl;

  @override
  CreateConnectionStateState get createConnectionStateState;
  @override
  @JsonKey(ignore: true)
  _$$ViduStateImplCopyWith<_$ViduStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
