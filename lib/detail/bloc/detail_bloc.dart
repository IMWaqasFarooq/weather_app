import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app/detail/model/detail_model.dart';
import 'package:dio/dio.dart';


part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitial()) {
    on<DetailEvent>((event, emit) async {
      // TODO: implement event handler

      if(event is GetDetailEvent){
        emit(DetailLoadingState());

          try{
            final DetailModel detailModel = await getDetail(event.lat,event.lon);

            emit(DetailSuccessState(detailModel));
          }catch (e){

            print("error..."+e.toString());
            emit(DetailErrorState("Something went wrong"));
          }

      }

    });
  }

  Future<DetailModel> getDetail(double lat, double lon) async {
    final Dio _dio = Dio();

    final queryParameters = {
      'lat': lat,
      'lon':lon,
      'units':"metric",
      'appid':"c730ce6516c73a461b8012a02c629209",

    };

    print("params...."+ queryParameters.toString());

    final response = await _dio.get("https://api.openweathermap.org/data/2.5/weather",queryParameters: queryParameters);

    final jsonResponse =response.data;
    print(jsonResponse.toString());
    return DetailModel.fromJson(jsonResponse);
    // return jsonResponse.toString();

  }
}
