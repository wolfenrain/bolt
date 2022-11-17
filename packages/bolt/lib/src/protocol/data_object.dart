import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template data_object}
/// Represents the data of a packet being sent over the network.
/// {@endtemplate}
@immutable
abstract class DataObject extends Equatable {
  /// {@macro data_object}
  const DataObject();
}
