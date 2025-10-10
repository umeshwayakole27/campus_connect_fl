import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../core/models/location_model.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../data/location_repository.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> with AutomaticKeepAliveClientMixin {
  final LocationRepository _locationRepository = LocationRepository();
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  
  List<CampusLocation> _locations = [];
  Set<Marker> _markers = {};
  CampusLocation? _selectedLocation;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String _selectedCategory = 'all';

  // Default campus center (GECA Chhatrapati Sambhajinagar campus)
  static const LatLng _campusCenter = LatLng(19.8680502, 75.3241057);

  final List<String> _categories = [
    'all',
    'academic',
    'library',
    'cafeteria',
    'hostel',
    'sports',
    'admin',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load locations asynchronously after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadLocations();
      }
    });
  }

  Future<void> _loadLocations({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locations = await _locationRepository.getAllLocations(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoading = false;
          _isInitialized = true;
        });
        _updateMarkers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load locations: ${e.toString()}';
          _isLoading = false;
        });
      }
      AppLogger.logError('Failed to load locations', error: e);
    }
  }

  void _updateMarkers() {
    final filteredLocations = _selectedCategory == 'all'
        ? _locations
        : _locations.where((loc) => loc.category == _selectedCategory).toList();

    final newMarkers = <Marker>{};
    
    for (final location in filteredLocations) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.lat, location.lng),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.buildingCode,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(location.category),
          ),
          onTap: () {
            _showLocationDetails(location);
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  double _getMarkerColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'academic':
        return BitmapDescriptor.hueBlue;
      case 'library':
        return BitmapDescriptor.hueViolet;
      case 'cafeteria':
        return BitmapDescriptor.hueOrange;
      case 'hostel':
        return BitmapDescriptor.hueGreen;
      case 'sports':
        return BitmapDescriptor.hueCyan;
      case 'admin':
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _showLocationDetails(CampusLocation location) {
    setState(() {
      _selectedLocation = location;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLocationDetailsSheet(location),
    );
  }

  Widget _buildLocationDetailsSheet(CampusLocation location) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      location.categoryIcon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (location.buildingCode != null)
                            Text(
                              'Code: ${location.buildingCode}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (location.description != null) ...[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (location.floorInfo != null) ...[
                  Row(
                    children: [
                      Icon(Icons.layers, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Floors: ${location.floorInfo}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${location.lat.toStringAsFixed(6)}, ${location.lng.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _navigateToLocation(location);
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _centerMapOnLocation(location);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.center_focus_strong),
                        label: const Text('Center Map'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToLocation(CampusLocation location) {
    // For now, just animate to the location
    // In a production app, you'd integrate with actual navigation
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.lat, location.lng),
          zoom: 18,
          tilt: 45,
        ),
      ),
    );
    Navigator.pop(context);
    AppUtils.showSnackBar(
      context,
      'Navigation to ${location.name}',
    );
  }

  void _centerMapOnLocation(CampusLocation location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.lat, location.lng),
        17,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category == 'all' ? 'All' : category[0].toUpperCase() + category.substring(1),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _updateMarkers();
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              final controller = await _controllerCompleter.future;
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(_campusCenter, 15),
              );
            },
            tooltip: 'Center on campus',
          ),
          if (_isInitialized)
            IconButton(
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () => _loadLocations(forceRefresh: true),
              tooltip: 'Refresh locations',
            ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadLocations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_isInitialized) _buildCategoryFilter(),
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: _campusCenter,
                          zoom: 15,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) {
                          if (!_controllerCompleter.isCompleted) {
                            _controllerCompleter.complete(controller);
                          }
                          _mapController = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: false,
                        compassEnabled: true,
                        liteModeEnabled: false,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                      ),
                      if (_isLoading && !_isInitialized)
                        Container(
                          color: Colors.white.withValues(alpha: 0.8),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading campus locations...'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
  
  Future<GoogleMapController> get mapController async {
    return _controllerCompleter.future;
  }
}
