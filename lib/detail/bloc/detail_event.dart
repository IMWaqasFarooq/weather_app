part of 'detail_bloc.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();
}

class GetDetailEvent extends DetailEvent{
  double lat,lon;
  GetDetailEvent({required this.lat,required this.lon});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
