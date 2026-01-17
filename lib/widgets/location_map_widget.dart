import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../services/firebase_service.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class LocationMapWidget extends StatefulWidget {
  final double scale;
  final double cardWidth;
  final bool isMobile;

  const LocationMapWidget({
    super.key,
    required this.scale,
    required this.cardWidth,
    required this.isMobile,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  LatLng? _location;
  String _locationName = 'Lahore, Pakistan';
  bool _isLoading = true;
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _loadLocationData();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime =
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _loadLocationData() async {
    try {
      final config = await _firebaseService.getConfig('location');
      if (config != null && mounted) {
        setState(() {
          final lat = config['latitude'] as double? ?? 31.5204;
          final lng = config['longitude'] as double? ?? 74.3587;
          _location = LatLng(lat, lng);
          _locationName = config['name'] as String? ?? 'Lahore, Pakistan';
          _isLoading = false;
        });
      } else {
        setState(() {
          _location = const LatLng(31.5204, 74.3587);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _location = const LatLng(31.5204, 74.3587);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _location == null) {
      return Container(
        width: widget.cardWidth,
        height: widget.isMobile ? null : 250 * widget.scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: widget.cardWidth,
      height: widget.isMobile ? 250 : 250 * widget.scale,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Currently Based In',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.push_pin, color: Colors.red, size: 16),
              ],
            ),
          ),
          // Map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _location!,
                initialZoom: 11.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hassankamran.portfolio',
                  maxZoom: 19,
                  retinaMode: RetinaMode.isHighDensity(context),
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _location!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0E15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _locationName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
