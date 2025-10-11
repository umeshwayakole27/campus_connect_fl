import 'package:flutter/foundation.dart';
import '../../../core/models/faculty_model.dart';
import '../data/faculty_repository.dart';

class FacultyProvider with ChangeNotifier {
  final FacultyRepository _repository = FacultyRepository();

  List<Faculty> _facultyList = [];
  List<Faculty> get facultyList => _facultyList;

  Faculty? _selectedFaculty;
  Faculty? get selectedFaculty => _selectedFaculty;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedDepartment;
  String? get selectedDepartment => _selectedDepartment;

  List<String> _departments = [];
  List<String> get departments => _departments;

  /// Load all faculty members
  Future<void> loadFaculty() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _facultyList = await _repository.getAllFaculty();
      await _loadDepartments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load departments list
  Future<void> _loadDepartments() async {
    try {
      _departments = await _repository.getDepartments();
    } catch (e) {
      // Continue without departments if fetch fails
      _departments = [];
    }
  }

  /// Load faculty by ID
  Future<void> loadFacultyById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedFaculty = await _repository.getFacultyById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load faculty by user ID
  Future<void> loadFacultyByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedFaculty = await _repository.getFacultyByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update faculty profile
  Future<bool> updateFaculty(String id, Faculty faculty) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedFaculty = await _repository.updateFaculty(id, faculty);
      if (updatedFaculty != null) {
        // Update in list
        final index = _facultyList.indexWhere((f) => f.id == id);
        if (index != -1) {
          _facultyList[index] = updatedFaculty;
        }
        _selectedFaculty = updatedFaculty;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set department filter
  void setDepartmentFilter(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  /// Get filtered faculty list
  List<Faculty> get filteredFaculty {
    var filtered = _facultyList;

    // Apply department filter
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      filtered = filtered.where((f) => 
        f.department == _selectedDepartment
      ).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((f) {
        final name = f.userName?.toLowerCase() ?? '';
        final dept = f.department.toLowerCase();
        final designation = f.designation?.toLowerCase() ?? '';
        return name.contains(query) || 
               dept.contains(query) || 
               designation.contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Group faculty by department
  Map<String, List<Faculty>> get facultyByDepartment {
    final grouped = <String, List<Faculty>>{};
    
    for (var faculty in filteredFaculty) {
      final dept = faculty.department;
      if (!grouped.containsKey(dept)) {
        grouped[dept] = [];
      }
      grouped[dept]!.add(faculty);
    }

    return grouped;
  }

  /// Set selected faculty
  void selectFaculty(Faculty? faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh faculty list
  Future<void> refresh() async {
    _repository.clearCache();
    await loadFaculty();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = null;
    notifyListeners();
  }
}
