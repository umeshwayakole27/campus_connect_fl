import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../utils.dart';

class DirectionsService {
  static final DirectionsService _instance = DirectionsService._internal();
  factory DirectionsService() => _instance;
  DirectionsService._internal();

  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  Future<List<LatLng>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      AppLogger.logError('Google Maps API key not found');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=walking'
        '&key=$_apiKey',
      );

      AppLogger.logInfo('Fetching directions from Google Directions API');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          
          // Decode the polyline
          PolylinePoints polylinePointsDecoder = PolylinePoints();
          List<PointLatLng> decodedPoints = 
              polylinePointsDecoder.decodePolyline(polylinePoints);
          
          // Convert to LatLng
          List<LatLng> routeCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          
          AppLogger.logInfo('Successfully fetched route with ${routeCoordinates.length} points');
          return routeCoordinates;
        } else {
          AppLogger.logWarning('No routes found: ${data['status']}');
          return null;
        }
      } else {
        AppLogger.logError('Failed to fetch directions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.logError('Error fetching directions', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDirectionsDetails({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      AppLogger.logError('Google Maps API key not found');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=walking'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return {
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'polyline': route['overview_polyline']['points'],
          };
        }
      }
      return null;
    } catch (e) {
      AppLogger.logError('Error fetching directions details', error: e);
      return null;
    }
  }
}
