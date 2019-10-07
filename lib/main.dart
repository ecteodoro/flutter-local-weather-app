import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(new LocalWeatherApp());

class LocalWeatherApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new CupertinoApp(
      title: 'Local Weather',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Scaffold homePage = Scaffold(
      body: FutureBuilder<WeatherCondition>(
        future: fetchWeatherCondition('Itapema', 'BR'),
        builder: (context, response) {
          if (response.hasError) {
            return Text("${response.error}");
          }
          return response.hasData
            ? ListView(
                children: [
                  locationSection(response.data.city, response.data.country),
                  dateSection(response.data.date),
                  iconSection(response.data.icon),
                  weatherConditionSection(response.data.condition, response.data.description),
                  temperatureSection(response.data.temperature)
                ]
              )
            : Center(
                child: CircularProgressIndicator()
              );
        }
      )
    );
    return homePage;
  } 
}

Widget locationSection(String city, String country) {
  Widget locationSection = Container(
    margin: const EdgeInsets.only(top: 40.0, left: 20.0, bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(city,
            style: TextStyle(
                fontFamily: 'Avenir Next',
                fontWeight: FontWeight.w700,
                fontSize: 17.0)
              ),
        Text(' | $country',
            style: TextStyle(
                fontFamily: 'Avenir Next',
                fontWeight: FontWeight.w400,
                fontSize: 17.0)),
      ],
    )
  );
  return locationSection;
}

Widget dateSection(DateTime date) {
  final formatter = new DateFormat('EEEE, MMMM d, y');
  final formattedDate = formatter.format(date);
  Widget locationSection = Container(
      margin: EdgeInsets.only(top: 40.0, left: 20.0, bottom: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Text(formattedDate,
            style: TextStyle(
                fontFamily: 'Avenir Next',
                fontWeight: FontWeight.w400,
                fontSize: 17.0))
      ]));
  return locationSection;
}

Widget iconSection(String icon) {
  Widget iconSection = Container(
    margin: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start, 
      children: <Widget>[
        SvgPicture.asset('icons/$icon.svg',
          color: Colors.tealAccent, 
          height: 200.0)
      ]
    )
  );

  return iconSection;
}

Widget weatherConditionSection(String condition, String description) {
  Widget weatherConditionSection = Container(
    margin: EdgeInsets.only(top: 8.0, left: 20.0, bottom: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: <Widget>[
        Text(
          condition,
          style: TextStyle(
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w400,
            fontSize: 24.0)),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w200,
            fontSize: 17.0))
      ]
    )
  );
  return weatherConditionSection;
}

Widget temperatureSection(double temperature) {
  int roundedTemperature = temperature.round();
  Widget temperatureSection = Container(
    margin: EdgeInsets.only(top: 0.0, left: 20.0, bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start, 
      children: <Widget>[
        Text(
          '$roundedTemperature˚',
          style: TextStyle(
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w700,
            fontSize: 120.0
          )
        ),
        Text(
          'F',
          style: TextStyle(
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w400,
            fontSize: 80.0
          )
        )
      ]
    )
  );
  return temperatureSection;
}

Future<WeatherCondition> fetchWeatherCondition(String city, String country) async {
  final response = await http.get('http://api.openweathermap.org/data/2.5/weather?q=$city,$country&appid=36d3fd81d4a312ea481325978c5fe7ec');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    WeatherCondition wc = WeatherCondition.fromJSON(json.decode(response.body));
    return wc;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load weather condition');
  }
}

class WeatherCondition {
  final DateTime date;
  final String condition;
  final String description;
  final String icon;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double temperature;
  final int pressure;
  final int humidity;
  final double minTemperature;
  final double maxTemperature;
  final double windSpeed;
  final double windDegrees;

  WeatherCondition(
      {this.date,
      this.condition,
      this.description,
      this.icon,
      this.city,
      this.country,
      this.latitude,
      this.longitude,
      this.temperature,
      this.pressure,
      this.humidity,
      this.minTemperature,
      this.maxTemperature,
      this.windSpeed,
      this.windDegrees});

  factory WeatherCondition.fromJSON(Map<String, dynamic> json) {
     return WeatherCondition(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      city: json['name'],
      country: json['sys']['country'],
      latitude: json['coord']['lat'],
      longitude: json['coord']['lon'],
      temperature: convertKelvinToFahrenheit(json['main']['temp']),
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      minTemperature: convertKelvinToFahrenheit(json['main']['temp_min']),
      maxTemperature: convertKelvinToFahrenheit(json['main']['temp_max']),
      windSpeed: json['wind']['speed'] * 1.0,
      windDegrees: json['wind']['deg'] * 1.0);
  }
}

double convertKelvinToFahrenheit(double kelvin) {
  return kelvin * 9 / 5 - 459.67;
}
