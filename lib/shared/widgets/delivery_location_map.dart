import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Interactive, keyless map used to select a delivery address.
///
/// OpenStreetMap's standard tile service requires visible attribution and
/// respectful caching. flutter_map's native tile provider caches tiles using
/// the server's HTTP cache headers.
class DeliveryLocationMap extends StatelessWidget {
  const DeliveryLocationMap({
    required this.initialCenter,
    required this.selectedPoint,
    required this.onPointSelected,
    this.initialZoom = 15,
    super.key,
  });

  static const addisAbaba = LatLng(9.0108, 38.7612);
  static const tileUrlTemplate = String.fromEnvironment(
    'OSM_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  final LatLng initialCenter;
  final LatLng? selectedPoint;
  final ValueChanged<LatLng> onPointSelected;
  final double initialZoom;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onTap: (_, point) => onPointSelected(point),
      ),
      children: [
        TileLayer(
          urlTemplate: tileUrlTemplate,
          userAgentPackageName: 'com.yomobiles.client',
        ),
        if (selectedPoint case final point?)
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 44,
                height: 48,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_pin,
                  color: Color(0xFF0759C7),
                  size: 44,
                  shadows: [Shadow(color: Colors.white, blurRadius: 3)],
                ),
              ),
            ],
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: Colors.white.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(5),
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  child: Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(
                      color: Color(0xFF263746),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
