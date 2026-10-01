import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/incident_service.dart';
import '../../models/incident.dart';
import 'widgets/top_app_bar.dart';
import 'widgets/greeting_section.dart';
import 'widgets/map_preview_card.dart';
import 'widgets/hero_report_button.dart';
import 'widgets/action_grid.dart';
import 'widgets/categories_section.dart';
import 'widgets/emergency_bar.dart';
import 'widgets/bottom_nav_bar.dart';

/// Main citizen home screen of BugaReport.
/// Shows a live OSM map with incidents from Supabase (Waze-style),
/// quick-action grid, categories, and emergency bar.
/// Matches Figma frame "BugaReport - Inicio Ciudadano" (node #3826:8684).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _incidentService = IncidentService();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Make status bar transparent so the app feels full-bleed
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── No default AppBar — we use a custom one inside the scroll ──
      body: Stack(
        children: [
          // ── Scrollable main content ──
          _buildScrollableBody(),

          // ── Fixed TopAppBar (floats above scroll) ──
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BugaTopAppBar(),
          ),

          // ── Fixed BottomNavBar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BugaBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) => setState(() => _currentNavIndex = index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableBody() {
    return StreamBuilder<List<Incident>>(
      // Real-time stream from Supabase — new incidents appear instantly
      stream: _incidentService.streamActiveIncidents(),
      builder: (context, snapshot) {
        final incidents = snapshot.data ?? [];

        return SingleChildScrollView(
          // Add top padding for TopAppBar height + safe area
          // Add bottom padding for BottomNavBar
          padding: const EdgeInsets.only(bottom: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacer for fixed TopAppBar (approx 64px)
              const SizedBox(height: 64),

              // ── All sections padded 12px top, 16px horizontal, 20px gap ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Greeting
                    const GreetingSection(),

                    const SizedBox(height: 20),

                    // 2. Live OSM map with incidents from Supabase
                    MapPreviewCard(incidents: incidents),

                    const SizedBox(height: 20),

                    // 3. Hero "Reportar Incidente" button
                    const HeroReportButton(),

                    const SizedBox(height: 12),

                    // 4. 2-column action grid (Mis Reportes + Borradores)
                    ActionGrid(incidentService: _incidentService),

                    const SizedBox(height: 20),

                    // 5. Categories horizontal scroll
                    const CategoriesSection(),

                    const SizedBox(height: 24),

                    // 6. Emergency bar
                    const EmergencyBar(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
