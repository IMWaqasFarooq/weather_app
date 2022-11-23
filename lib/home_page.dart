import 'package:flutter/material.dart';
import 'package:weather_app/detail/model/country.dart';
import 'package:weather_app/detail/weather_details.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Country selectedValue = Country(name: "Dubai", lat: 25.17, lon: 55.30);
  List<Country> cityList =[
    Country(name: "Dubai", lat: 25.17, lon: 55.30),
    Country(name: "London", lat: 51.51, lon: -0.12),
    Country(name: "Abuja", lat: 9.07, lon: 7.49),
    Country(name: "Brasilia", lat: -23.5, lon: -46.62),
    Country(name: "Paris", lat: 48.86, lon: 2.35),
    Country(name: "Sydney", lat: -33.87, lon: 151.21),
    Country(name: "Ottawa", lat:  45.33, lon: -75.72)
   ];

  bool selected = false;




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Home"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          DropdownButton<Country>(
          value: selected? selectedValue:cityList[0],
            icon: const Icon(Icons.arrow_downward),
            isExpanded: true,
            elevation: 16,
            style: const TextStyle(color: Colors.blue),
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            onChanged: (Country? country) {
              // This is called when the user selects an item.
              setState(() {
                selectedValue = country!;
                selected = true;
              });
            },
            items: cityList.map<DropdownMenuItem<Country>>((Country country) {
              return DropdownMenuItem<Country>(
                value: country,

                child: Text(country.name),
              );
            }).toList(),
          ),
              SizedBox(height: 50,),
              ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>WeatherDetails(country: selectedValue)));
                  },
                  child: Text(
                    "Select"
                  ))
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
