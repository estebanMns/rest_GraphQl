// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class GraphQLFailure extends Failure {
  final List<String>? errors;
  const GraphQLFailure({required super.message, this.errors});
}

// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({required this.message});
}

class GraphQLException implements Exception {
  final String message;
  final List<String>? errors;
  const GraphQLException({required this.message, this.errors});
}
