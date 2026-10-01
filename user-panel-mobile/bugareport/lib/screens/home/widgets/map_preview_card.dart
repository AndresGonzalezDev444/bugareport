import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';
import '../../../../config/app_constants.dart';
import '../../../../models/incident.dart';
import '../../../../widgets/shared/incident_map_pin.dart';

/// Interactive OpenStreetMap card showing live citizen-reported incidents.
/// Centered on Guadalajara de Buga. Incidents come from Supabase (no hardcoding).
/// Matches Figma node #3826:8696.
class MapPreviewCard extends StatelessWidget {
  final List<Incident> incidents;

  const MapPreviewCard({super.key, required this.incidents});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderCard.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 176,
        child: Stack(
          children: [
            // ── OpenStreetMap ──
            FlutterMap(
              options: MapOptions(
                initialCenter: AppConstants.bugaCenter,
                initialZoom: AppConstants.defaultMapZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Preview only, no interaction
                ),
              ),
              children: [
                // OSM Tile Layer
                TileLayer(
                  urlTemplate: AppConstants.osmTileUrl,
                  userAgentPackageName: 'com.bugareport.app',
                ),

                // Incident markers from database
                MarkerLayer(
                  markers: incidents.map((incident) {
                    return Marker(
                      point: LatLng(incident.latitude, incident.longitude),
                      width: 28,
                      height: 34,
                      child: IncidentMapPin(
                        incident: incident,
                        onTap: () => _showIncidentTooltip(context, incident),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // ── Dark gradient at bottom ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 88,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),

            // ── Badge: "X reportes activos cerca" ──
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${incidents.length} reportes activos cerca',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 14 / 11,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA bar ──
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location label
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Comuna 1, Centro Histórico',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 14 / 11,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    // Explore map CTA
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to full map screen
                      },
                      child: Row(
                        children: [
                          Text(
                            'Explorar mapa',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 14 / 11,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a tooltip dialog for the tapped incident.
  void _showIncidentTooltip(BuildContext context, Incident incident) {
    final color = AppColors.pinForCategory(incident.category);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  incident.categoryLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  incident.timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (incident.description != null) ...[
              const SizedBox(height: 4),
              Text(
                incident.description!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (incident.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Text(
                    incident.address!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
