import 'package:flutter/material.dart';
import 'package:weather_app/detail/bloc/detail_bloc.dart';
import 'package:weather_app/detail/model/country.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/detail/model/detail_model.dart';

class WeatherDetails extends StatefulWidget {
  const WeatherDetails({Key? key, required this.country}) : super(key: key);
  final Country country;

  @override
  State<WeatherDetails> createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends State<WeatherDetails> {

  late Country country;
  late DetailBloc _bloc;
  late DetailModel detailModel;

  @override
  void initState() {
    // TODO: implement initState
    country = widget.country;
    _bloc = DetailBloc();
    // detailModel =DetailModel();
    _bloc.add(GetDetailEvent(lat: country.lat, lon: country.lon));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocListener<DetailBloc, DetailState>(
        listener: (context, state) {
          // TODO: implement listener
          if(state is DetailSuccessState){
            detailModel =state.detailModel;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                country.name
            ),
          ),

          body: BlocBuilder<DetailBloc, DetailState>(
            builder: (context, state) {

              if(state is DetailLoadingState){
                return Center(child: CircularProgressIndicator(),);
              }else if(state is DetailSuccessState){
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                          "Temperature ${detailModel.main!.temp.toString()} Celsius"
                      ),
                      SizedBox(height: 20,),
                      Text(
                          "weather  ${detailModel.weather![0].main.toString()}"
                      ),
                      SizedBox(height: 20,),

                      Text(
                          "description ${detailModel.weather![0].description.toString()}"
                      ),
                    ],
                  ),
                );

              }else{
                return SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
