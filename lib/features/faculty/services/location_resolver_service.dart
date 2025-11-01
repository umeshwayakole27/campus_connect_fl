import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/location_model.dart';
import '../../campus_map/data/location_repository.dart';

/// Service to resolve faculty office locations to map coordinates
class LocationResolverService {
  final LocationRepository _locationRepository = LocationRepository();
  
  /// Resolve office location string to LatLng coordinates
  /// Returns null if location cannot be resolved
  Future<LatLng?> resolveOfficeLocation(String officeLocation) async {
    try {
      // Get all campus locations
      final locations = await _locationRepository.getAllLocations();
      
      // Try to find a matching location
      final searchTerm = officeLocation.toLowerCase().trim();
      
      // First, try exact building code match
      final exactMatch = locations.where((loc) => 
        loc.buildingCode?.toLowerCase() == searchTerm
      ).firstOrNull;
      
      if (exactMatch != null) {
        return LatLng(exactMatch.lat, exactMatch.lng);
      }
      
      // Try matching building code within the office location string
      for (var location in locations) {
        if (location.buildingCode != null) {
          final code = location.buildingCode!.toLowerCase();
          if (searchTerm.contains(code)) {
            return LatLng(location.lat, location.lng);
          }
        }
      }
      
      // Try matching location name
      final nameMatch = locations.where((loc) => 
        searchTerm.contains(loc.name.toLowerCase()) ||
        loc.name.toLowerCase().contains(searchTerm)
      ).firstOrNull;
      
      if (nameMatch != null) {
        return LatLng(nameMatch.lat, nameMatch.lng);
      }
      
      // Try partial matching with common building identifiers
      final patterns = [
        RegExp(r'building\s+(\w+)', caseSensitive: false),
        RegExp(r'block\s+(\w+)', caseSensitive: false),
        RegExp(r'dept\.\s+(\w+)', caseSensitive: false),
        RegExp(r'department\s+(\w+)', caseSensitive: false),
      ];
      
      for (var pattern in patterns) {
        final match = pattern.firstMatch(searchTerm);
        if (match != null && match.groupCount > 0) {
          final identifier = match.group(1)!.toLowerCase();
          
          final partialMatch = locations.where((loc) => 
            loc.buildingCode?.toLowerCase().contains(identifier) == true ||
            loc.name.toLowerCase().contains(identifier)
          ).firstOrNull;
          
          if (partialMatch != null) {
            return LatLng(partialMatch.lat, partialMatch.lng);
          }
        }
      }
      
      // No match found
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Find the closest matching location by name or building code
  Future<CampusLocation?> findLocation(String searchTerm) async {
    try {
      final locations = await _locationRepository.getAllLocations();
      final term = searchTerm.toLowerCase().trim();
      
      // Try exact matches first
      var match = locations.where((loc) => 
        loc.buildingCode?.toLowerCase() == term ||
        loc.name.toLowerCase() == term
      ).firstOrNull;
      
      if (match != null) return match;
      
      // Try partial matches
      match = locations.where((loc) => 
        loc.buildingCode?.toLowerCase().contains(term) == true ||
        loc.name.toLowerCase().contains(term) ||
        term.contains(loc.buildingCode?.toLowerCase() ?? '') ||
        term.contains(loc.name.toLowerCase())
      ).firstOrNull;
      
      return match;
    } catch (e) {
      return null;
    }
  }
}
