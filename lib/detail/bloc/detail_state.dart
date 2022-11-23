part of 'detail_bloc.dart';

abstract class DetailState extends Equatable {
  const DetailState();
}

class DetailInitial extends DetailState {
  @override
  List<Object> get props => [];
}


class DetailLoadingState extends DetailState{

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DetailEmptyState extends DetailState{

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DetailSuccessState extends DetailState{
  final DetailModel detailModel;

  DetailSuccessState(this.detailModel);

  @override
  // TODO: implement props
  List<Object> get props => [detailModel];
}

class DetailErrorState extends DetailState{
  final String error;

  DetailErrorState(this.error);

  @override
  // TODO: implement props
  List<Object> get props => [error];
}
