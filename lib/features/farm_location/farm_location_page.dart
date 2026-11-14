import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_location.dart';
import '../../data/repositories/farm_location_search_service.dart';

class FarmLocationPage extends StatefulWidget {
  const FarmLocationPage({
    required this.initialLocation,
    required this.isArabic,
    required this.onSave,
    super.key,
  });

  final FarmLocation initialLocation;
  final bool isArabic;
  final Future<void> Function(FarmLocation) onSave;

  @override
  State<FarmLocationPage> createState() => _FarmLocationPageState();
}

class _FarmLocationPageState extends State<FarmLocationPage> {
  final _mapController = MapController();
  final _placeController = TextEditingController();
  final _searchService = FarmLocationSearchService();
  late String _countryCode;
  late String _countryName;
  late String _localizedCountryName;
  LatLng? _selectedPoint;
  List<FarmLocationSearchResult> _results = const [];
  bool _isSearching = false;
  bool _isSaving = false;
  String? _searchError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialLocation.countryCode;
    _countryName = widget.initialLocation.countryName;
    _localizedCountryName = widget.initialLocation.localizedCountryName;
    _placeController.text = widget.isArabic
        ? widget.initialLocation.localizedPlaceName
        : widget.initialLocation.placeName;
    _selectedPoint = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
  }

  @override
  void dispose() {
    _placeController.dispose();
    _searchService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isArabic = strings.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('farmLocationTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            strings.text('farmLocationIntro'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedInk,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            strings.text('country'),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _chooseCountry,
            icon: const Icon(Icons.public),
            label: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isArabic ? _localizedCountryName : _countryName,
                textAlign: TextAlign.start,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: AlignmentDirectional.centerStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _placeController,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _searchLocations(),
            decoration: InputDecoration(
              labelText: strings.text('cityOrRegion'),
              hintText: strings.text('cityOrRegionHint'),
              prefixIcon: const Icon(Icons.location_city_outlined),
              suffixIcon: IconButton(
                tooltip: strings.text('searchLocation'),
                onPressed: _isSearching ? null : _searchLocations,
                icon: _isSearching
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
            ),
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 8),
            Text(
              _searchError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final result in _results)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const Icon(Icons.place_outlined),
                title: Text(result.name, maxLines: 2),
                onTap: () => _selectPoint(result.point),
              ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.text('pinFarmOnMap'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                strings.text('mapTapHint'),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: SizedBox(
              height: 280,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    widget.initialLocation.latitude,
                    widget.initialLocation.longitude,
                  ),
                  initialZoom: 12,
                  onTap: (_, point) => _selectPoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fieldshift.ai',
                  ),
                  if (_selectedPoint case final point?)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 42,
                          height: 42,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppTheme.coral,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  const RichAttributionWidget(
                    attributions: [TextSourceAttribution('OpenStreetMap')],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_selectedPoint case final point?)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: AppTheme.paleSage,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${strings.text('latitude')}: ${point.latitude.toStringAsFixed(6)}   '
                '${strings.text('longitude')}: ${point.longitude.toStringAsFixed(6)}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          if (_saveError != null) ...[
            const SizedBox(height: 8),
            Text(
              _saveError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _canSave && !_isSaving ? _saveLocation : null,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(strings.text('saveFarmLocation')),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSave =>
      _placeController.text.trim().isNotEmpty && _selectedPoint != null;

  void _chooseCountry() {
    final strings = AppLocalizations.of(context);
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      favorite: const ['EG'],
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        textStyle: Theme.of(context).textTheme.bodyMedium,
        inputDecoration: InputDecoration(
          hintText: strings.text('searchCountry'),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
      onSelect: (country) {
        final englishName =
            CountryLocalizations(
              const Locale('en'),
            ).countryName(countryCode: country.countryCode) ??
            country.name;
        final arabicName =
            CountryLocalizations(
              const Locale('ar'),
            ).countryName(countryCode: country.countryCode) ??
            country.name;
        setState(() {
          _countryCode = country.countryCode;
          _countryName = englishName;
          _localizedCountryName = arabicName;
          _placeController.clear();
          _selectedPoint = null;
          _results = const [];
          _searchError = null;
        });
      },
    );
  }

  Future<void> _searchLocations() async {
    final place = _placeController.text.trim();
    if (place.isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
      _results = const [];
    });
    try {
      final results = await _searchService.search(
        place: place,
        countryCode: _countryCode,
        languageCode: AppLocalizations.of(context).isArabic ? 'ar' : 'en',
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) {
          _searchError = AppLocalizations.of(context).text('noLocationResults');
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _searchError =
            '${AppLocalizations.of(context).text('locationSearchFailed')} $error',
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectPoint(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _results = const [];
      _searchError = null;
    });
    _mapController.move(point, 14);
  }

  Future<void> _saveLocation() async {
    final point = _selectedPoint;
    if (point == null || !_canSave) return;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await widget.onSave(
        FarmLocation(
          countryCode: _countryCode,
          countryName: _countryName,
          localizedCountryName: _localizedCountryName,
          placeName: _placeController.text.trim(),
          localizedPlaceName: _placeController.text.trim(),
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError =
            '${AppLocalizations.of(context).text('locationSaveFailed')} $error';
      });
    }
  }
}
