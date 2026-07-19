import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/failures.dart';
import '../../data/models/city.dart';
import '../../data/weather_repository.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

// Lets the user search for a city and returns the chosen City via Navigator.pop.
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<City> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final repository = context.read<WeatherRepository>();
    try {
      final results = await repository.searchCities(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        _searched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Failure ? e.message : 'Could not search for that city.';
        _loading = false;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search for a city…',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
          onSubmitted: _search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: () => _search(_controller.text),
      );
    }

    if (!_searched) {
      return const ErrorView(
        icon: Icons.search,
        message: 'Search for a city to see its weather.',
      );
    }

    if (_results.isEmpty) {
      return const ErrorView(
        icon: Icons.location_off,
        message: 'No cities found. Try a different search.',
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final city = _results[index];
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(city.name),
          subtitle: Text(city.displayName),
          onTap: () => Navigator.of(context).pop(city),
        );
      },
    );
  }
}
