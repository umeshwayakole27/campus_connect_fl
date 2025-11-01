import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/location_model.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../core/services/directions_service.dart';
import '../../../core/providers/theme_provider.dart';
import '../data/location_repository.dart';

class CampusMapScreen extends StatefulWidget {
  final LatLng? targetLocation;
  final String? targetLocationName;
  
  const CampusMapScreen({
    super.key,
    this.targetLocation,
    this.targetLocationName,
  });

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> with AutomaticKeepAliveClientMixin {
  final LocationRepository _locationRepository = LocationRepository();
  final DirectionsService _directionsService = DirectionsService();
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  
  List<CampusLocation> _locations = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String _selectedCategory = 'all';
  LatLng? _currentUserLocation;
  bool _isNavigating = false;
  bool _isFetchingRoute = false;
  
  // Map type and style
  MapType _currentMapType = MapType.normal;
  String _mapStyleMode = 'auto'; // 'auto', 'light', 'dark'

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
    // Load locations and map styles asynchronously after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadLocations();
        _getCurrentLocation();
        _loadMapStyles();
        _handleTargetLocation();
      }
    });
  }
  
  Future<void> _handleTargetLocation() async {
    if (widget.targetLocation != null) {
      // Wait for controller to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_mapController != null && mounted) {
        // Add marker for target location
        setState(() {
          _markers.add(
            Marker(
              markerId: const MarkerId('target_location'),
              position: widget.targetLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(
                title: widget.targetLocationName ?? 'Target Location',
                snippet: 'Faculty Office',
              ),
            ),
          );
        });
        
        // Animate camera to target location
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(widget.targetLocation!, 18),
        );
        
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Showing ${widget.targetLocationName ?? "location"} on map',
          );
        }
      }
    }
  }
  
  Future<void> _loadMapStyles() async {
    try {
      final lightStyle = await rootBundle.loadString('assets/map_styles/light_style.json');
      final darkStyle = await rootBundle.loadString('assets/map_styles/dark_style.json');
      
      if (mounted) {
        setState(() {
          // Store both styles for later use
          _lightStyle = lightStyle;
          _darkStyle = darkStyle;
        });
        _applyMapStyle();
      }
    } catch (e) {
      AppLogger.logError('Failed to load map styles', error: e);
    }
  }
  
  String? _lightStyle;
  String? _darkStyle;
  
  Future<void> _applyMapStyle() async {
    if (_mapController == null) return;
    
    try {
      String? styleToApply;
      
      if (_mapStyleMode == 'auto') {
        // Use app theme
        final themeProvider = context.read<ThemeProvider>();
        final isDark = themeProvider.isDarkMode(context);
        styleToApply = isDark ? _darkStyle : _lightStyle;
      } else if (_mapStyleMode == 'dark') {
        styleToApply = _darkStyle;
      } else if (_mapStyleMode == 'light') {
        styleToApply = _lightStyle;
      }
      
      if (styleToApply != null) {
        await _mapController!.setMapStyle(styleToApply);
      } else {
        await _mapController!.setMapStyle(null); // Reset to default
      }
    } catch (e) {
      AppLogger.logError('Failed to apply map style', error: e);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          final shouldOpen = await _showLocationServiceDialog();
          if (shouldOpen) {
            await Geolocator.openLocationSettings();
          }
        }
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            AppUtils.showSnackBar(
              context,
              'Location permission is required to show your position',
              isError: true,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          final shouldOpen = await _showPermissionDeniedDialog();
          if (shouldOpen) {
            await openAppSettings();
          }
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (mounted) {
        setState(() {
          _currentUserLocation = LatLng(position.latitude, position.longitude);
        });
        _updateMarkers();
      }
    } catch (e) {
      AppLogger.logError('Failed to get current location', error: e);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to get your location: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  // Method to move camera to user's current location
  Future<void> _moveToMyLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Please enable location services',
            isError: true,
          );
          final shouldOpen = await _showLocationServiceDialog();
          if (shouldOpen) {
            await Geolocator.openLocationSettings();
          }
        }
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Location permission required',
            isError: true,
          );
        }
        return;
      }

      // Show loading
      if (mounted) {
        AppUtils.showSnackBar(context, 'Getting your location...');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final userLocation = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentUserLocation = userLocation;
        });
        _updateMarkers();
        
        // Animate camera to user location
        final controller = await _controllerCompleter.future;
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation, 18),
        );
      }
    } catch (e) {
      AppLogger.logError('Failed to move to current location', error: e);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to get your location. Please try again.',
          isError: true,
        );
      }
    }
  }

  Future<bool> _showLocationServiceDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are turned off. Please enable them to use navigation features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showPermissionDeniedDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it from app settings to use navigation features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
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
    
    // Add user's current location marker if available
    if (_currentUserLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentUserLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }
    
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

  void _navigateToLocation(CampusLocation location) async {
    if (_currentUserLocation == null) {
      AppUtils.showSnackBar(
        context,
        'Getting your location...',
      );
      await _getCurrentLocation();
      if (_currentUserLocation == null) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Unable to get your location. Please enable location services.',
            isError: true,
          );
        }
        return;
      }
    }

    setState(() {
      _isFetchingRoute = true;
    });

    Navigator.pop(context); // Close the bottom sheet

    try {
      // Fetch route from Google Directions API
      final routeCoordinates = await _directionsService.getDirections(
        origin: _currentUserLocation!,
        destination: LatLng(location.lat, location.lng),
      );

      if (routeCoordinates != null && routeCoordinates.isNotEmpty) {
        final polyline = Polyline(
          polylineId: const PolylineId('navigation_route'),
          color: AppTheme.primaryColor,
          width: 5,
          points: routeCoordinates,
          geodesic: true,
        );

        setState(() {
          _polylines = {polyline};
          _isNavigating = true;
          _isFetchingRoute = false;
        });

        // Calculate bounds to show the entire route
        final bounds = _calculateBounds(routeCoordinates);

        // Animate camera to show the route
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );

        // Calculate distance
        final distanceInMeters = Geolocator.distanceBetween(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
          location.lat,
          location.lng,
        );

        if (mounted) {
          final distance = distanceInMeters < 1000
              ? '${distanceInMeters.toStringAsFixed(0)} meters'
              : '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
          
          AppUtils.showSnackBar(
            context,
            'Route to ${location.name} (Distance: $distance)',
          );
        }
      } else {
        // Fallback to straight line if API fails
        _drawStraightLine(location);
      }
    } catch (e) {
      AppLogger.logError('Error fetching route', error: e);
      // Fallback to straight line
      _drawStraightLine(location);
    }
  }

  void _drawStraightLine(CampusLocation location) {
    if (_currentUserLocation == null) return;

    final polylineCoordinates = <LatLng>[
      _currentUserLocation!,
      LatLng(location.lat, location.lng),
    ];

    final polyline = Polyline(
      polylineId: const PolylineId('navigation_route'),
      color: AppTheme.primaryColor,
      width: 5,
      points: polylineCoordinates,
      patterns: [
        PatternItem.dash(30),
        PatternItem.gap(20),
      ],
    );

    setState(() {
      _polylines = {polyline};
      _isNavigating = true;
      _isFetchingRoute = false;
    });

    // Calculate bounds
    final bounds = _calculateBounds(polylineCoordinates);

    // Animate camera to show the route
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );

    // Calculate distance
    final distanceInMeters = Geolocator.distanceBetween(
      _currentUserLocation!.latitude,
      _currentUserLocation!.longitude,
      location.lat,
      location.lng,
    );

    if (mounted) {
      final distance = distanceInMeters < 1000
          ? '${distanceInMeters.toStringAsFixed(0)} meters'
          : '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
      
      AppUtils.showSnackBar(
        context,
        'Showing straight line to ${location.name} (Distance: $distance)',
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> coordinates) {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (var coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _clearNavigation() {
    setState(() {
      _polylines.clear();
      _isNavigating = false;
    });
  }

  void _centerMapOnLocation(CampusLocation location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.lat, location.lng),
        17,
      ),
    );
  }
  
  void _showMapSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMapSettingsSheet(),
    );
  }
  
  Widget _buildMapSettingsSheet() {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    const Text(
                      'Map Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Map Type Section
                    const Text(
                      'Map Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Default'),
                          selected: _currentMapType == MapType.normal,
                          labelStyle: TextStyle(
                            color: _currentMapType == MapType.normal
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _currentMapType = MapType.normal;
                              });
                              setState(() {
                                _currentMapType = MapType.normal;
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Satellite'),
                          selected: _currentMapType == MapType.satellite,
                          labelStyle: TextStyle(
                            color: _currentMapType == MapType.satellite
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _currentMapType = MapType.satellite;
                              });
                              setState(() {
                                _currentMapType = MapType.satellite;
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Hybrid'),
                          selected: _currentMapType == MapType.hybrid,
                          labelStyle: TextStyle(
                            color: _currentMapType == MapType.hybrid
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _currentMapType = MapType.hybrid;
                              });
                              setState(() {
                                _currentMapType = MapType.hybrid;
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Terrain'),
                          selected: _currentMapType == MapType.terrain,
                          labelStyle: TextStyle(
                            color: _currentMapType == MapType.terrain
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _currentMapType = MapType.terrain;
                              });
                              setState(() {
                                _currentMapType = MapType.terrain;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Map Style Section
                    const Text(
                      'Map Style',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Auto (Follow App Theme)'),
                          selected: _mapStyleMode == 'auto',
                          labelStyle: TextStyle(
                            color: _mapStyleMode == 'auto'
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _mapStyleMode = 'auto';
                              });
                              setState(() {
                                _mapStyleMode = 'auto';
                              });
                              _applyMapStyle();
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Light'),
                          selected: _mapStyleMode == 'light',
                          labelStyle: TextStyle(
                            color: _mapStyleMode == 'light'
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _mapStyleMode = 'light';
                              });
                              setState(() {
                                _mapStyleMode = 'light';
                              });
                              _applyMapStyle();
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Dark'),
                          selected: _mapStyleMode == 'dark',
                          labelStyle: TextStyle(
                            color: _mapStyleMode == 'dark'
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.secondaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _mapStyleMode = 'dark';
                              });
                              setState(() {
                                _mapStyleMode = 'dark';
                              });
                              _applyMapStyle();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
              labelStyle: TextStyle(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface,
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[200]
                : Colors.grey[800],
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
                        mapType: _currentMapType,
                        initialCameraPosition: const CameraPosition(
                          target: _campusCenter,
                          zoom: 15,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated: (controller) {
                          if (!_controllerCompleter.isCompleted) {
                            _controllerCompleter.complete(controller);
                          }
                          _mapController = controller;
                          _applyMapStyle();
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,  // Disable Google's built-in button
                        zoomControlsEnabled: false,
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
                      if (_isFetchingRoute)
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Calculating route...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // My Location Button - Takes you to YOUR current location
                      Positioned(
                        bottom: _isNavigating ? 80 : 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              heroTag: 'mapSettings',
                              onPressed: _showMapSettings,
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                              tooltip: 'Map Settings',
                              child: const Icon(Icons.layers),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              heroTag: 'myLocation',
                              onPressed: _moveToMyLocation,
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                              tooltip: 'Go to my location',
                              child: const Icon(Icons.my_location),
                            ),
                          ],
                        ),
                      ),
                      // Clear Route Button (only shown when navigating)
                      if (_isNavigating)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.extended(
                            heroTag: 'clearRoute',
                            onPressed: _clearNavigation,
                            icon: const Icon(Icons.close),
                            label: const Text('Clear Route'),
                            backgroundColor: Colors.red,
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
