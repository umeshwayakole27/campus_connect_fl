import 'package:flutter/foundation.dart';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<int>> _measurements = {};

  /// Start tracking a performance metric
  void startTracking(String metricName) {
    _startTimes[metricName] = DateTime.now();
  }

  /// Stop tracking and log the duration
  void stopTracking(String metricName) {
    final startTime = _startTimes[metricName];
    if (startTime == null) {
      debugPrint('⚠️ Performance: No start time found for $metricName');
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _measurements.putIfAbsent(metricName, () => []).add(duration);
    
    debugPrint('⏱️ Performance: $metricName took ${duration}ms');
    _startTimes.remove(metricName);
  }

  /// Get average duration for a metric
  double getAverageDuration(String metricName) {
    final measurements = _measurements[metricName];
    if (measurements == null || measurements.isEmpty) return 0;
    
    final sum = measurements.reduce((a, b) => a + b);
    return sum / measurements.length;
  }

  /// Log all performance metrics
  void logAllMetrics() {
    debugPrint('\n📊 === Performance Metrics Summary ===');
    _measurements.forEach((metric, durations) {
      final avg = getAverageDuration(metric);
      final min = durations.reduce((a, b) => a < b ? a : b);
      final max = durations.reduce((a, b) => a > b ? a : b);
      debugPrint('  $metric: avg=${avg.toStringAsFixed(2)}ms, min=${min}ms, max=${max}ms, count=${durations.length}');
    });
    debugPrint('=====================================\n');
  }

  /// Clear all metrics
  void clearMetrics() {
    _startTimes.clear();
    _measurements.clear();
  }
}

/// Extension to measure async function performance
extension PerformanceTracking<T> on Future<T> {
  Future<T> trackPerformance(String metricName) async {
    final monitor = PerformanceMonitor();
    monitor.startTracking(metricName);
    try {
      final result = await this;
      monitor.stopTracking(metricName);
      return result;
    } catch (e) {
      monitor.stopTracking(metricName);
      rethrow;
    }
  }
}
