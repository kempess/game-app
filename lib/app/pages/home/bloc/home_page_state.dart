part of 'home_page_bloc.dart';

@immutable
abstract class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

class IntializingError extends HomePageState {
  final String message;
  const IntializingError(this.message);

  @override
  List<Object> get props => [message];
}

class IntializingLoading extends HomePageState {}

class IntializingSuccess extends HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageLoading extends HomePageState {}

class HomePageSuccess extends HomePageState {
  final List<GameModel> games;
  const HomePageSuccess({required this.games});

  @override
  List<Object> get props => [games];
}

class HomePageError extends HomePageState {
  final String message;
  const HomePageError(this.message);

  @override
  List<Object> get props => [message];
}
