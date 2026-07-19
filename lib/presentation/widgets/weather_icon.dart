import 'package:flutter/material.dart';

import '../../core/utils/weather_code_mapper.dart';

// Icon for a WMO weather code, with an accessible label.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.code,
    this.isDay = true,
    this.size = 32,
    this.color,
  });

  final int code;
  final bool isDay;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: WeatherCodeMapper.description(code),
      child: Icon(
        WeatherCodeMapper.icon(code, isDay: isDay),
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
