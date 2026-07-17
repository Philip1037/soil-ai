import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/soil_api_service.dart';
import 'workstation_modules.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTopNavIndex = 0; // 0: Home, 1: Analysis Suite, 2: Publications, 3: Team
  int _activeTabIndex = 1; // 1-8: Workstation modules (active when _activeTopNavIndex == 1)
  bool _isSidebarCollapsed = false;
  bool _isServerOnline = false;
  Timer? _pingTimer;

  // Single instantiation of shared state for data bridging
  final SharedGeotechState _sharedState = SharedGeotechState();

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
    _pingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkServerStatus();
    });
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    final status = await SoilApiService.pingServer();
    if (mounted && status != _isServerOnline) {
      setState(() {
        _isServerOnline = status;
      });
    }
  }

  void _onStateUpdated() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {}); // trigger rebuild to update bridges/shortcuts
        }
      });
    }
  }

  // Sidebar labels and icons (Excluding Landing Hub, strictly 8 modules)
  final List<String> _sidebarModuleNames = [
    'Soil Classification',
    'Boreholes',
    'CBR Prediction',
    'Stability Analysis',
    'Foundation Design',
    'Settlement Analysis',
    'Geological Modeling',
    'AI Image Analysis',
  ];

  final List<IconData> _sidebarModuleIcons = [
    Icons.layers_rounded,
    Icons.assignment_rounded,
    Icons.speed_rounded,
    Icons.timeline_rounded,
    Icons.foundation_rounded,
    Icons.compress_rounded,
    Icons.terrain_rounded,
    Icons.psychology_rounded,
  ];

  // Full module names for headers
  final List<String> _fullModuleNames = [
    '',
    'Soil Classification Engine',
    'Borehole & Characterization Workspace',
    'CBR Deflection Prediction',
    'Slope Stability Solver',
    'Foundation Bearing capacity',
    'Consolidation Settlement Rate',
    '3D Geological Strata Model',
    'AI Grain Micrograph Segmenter',
  ];

  final List<Map<String, String>> _publications = [
    {
      'title': 'Explainable AI for Geotechnical Subgrade Characterization',
      'authors': 'N. Tziolas, J. Doe, A. Smith',
      'journal': 'Computers and Geotechnics (2025)',
      'abstract': 'We develop a transparent deep learning framework that predicts compaction behaviors (MDD/OMC) and California Bearing Ratio profiles from Atterberg limits and spectral signals. The model integrates SHAP methodologies to explain feature contributions.',
    },
    {
      'title': 'Real-Time Soil Strata Identification via Satellite Hyper-Spectroscopy',
      'authors': 'N. Tziolas, E. Vance, R. Patel',
      'journal': 'IEEE Transactions on Geoscience and Remote Sensing (2024)',
      'abstract': 'This study introduces the Soil Data Cube architecture, processing multispectral data products to map organic carbon content and soil texture indices across heterogeneous agricultural plots at 10m spatial resolution.',
    },
    {
      'title': 'Terzaghi Shear Zone Optimization using Deep Learning Failures',
      'authors': 'A. Smith, N. Tziolas',
      'journal': 'International Journal of Soil Mechanics (2024)',
      'abstract': 'We optimize footings designs by modeling plastic shear zones beneath shallow foundation structures. Real-time bearing capacity approximations scale live using Terzaghi models mapped with neural networks.',
    },
    {
      'title': 'Consolidation Settlement Modeling on Heterogeneous Clays',
      'authors': 'E. Vance, N. Tziolas',
      'journal': 'Journal of Geotechnical and Geoenvironmental Engineering (2023)',
      'abstract': 'Consolidation settlement rates over a 50-year horizon are modeled with an AI sequence-to-sequence network. Validation using physical soundings shows a reduction of root-mean-squared errors to under 0.35cm.',
    },
  ];

  final List<Map<String, String>> _teamMembers = [
    {
      'name': 'Dr. Nikos Tziolas',
      'role': 'Director & Lead AI Research Scientist',
      'bio': 'Assistant Professor of Soil Science and AI at the University of Florida. Specialized in Explainable AI (XAI), advanced spectroscopy, sensing, and digital soil mapping.',
      'avatar': 'NT',
    },
    {
      'name': 'Dr. Elena Vance',
      'role': 'Senior Geotechnical Engineer',
      'bio': 'Focuses on slope stability physics, Spencer/Bishop sliding circular failures, and bridging physical model parameters with predictive machine learning.',
      'avatar': 'EV',
    },
    {
      'name': 'Dr. Arthur Smith',
      'role': 'Computer Vision Researcher',
      'bio': 'Specialized in computer vision, soil grain micrograph semantic segmentations, and high-performance convolutional architectures for particle classification.',
      'avatar': 'AS',
    },
    {
      'name': 'Raj Patel, MSc',
      'role': 'Data Infrastructure Engineer',
      'bio': 'Manages the Soil Data Cube API integrations, real-time FastAPI bridge performance, and database pipelines mapping remote sensing soundings.',
      'avatar': 'RP',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326), // Dark slate
      body: Column(
        children: [
          // 1. Top Global Header Cloned Navigation from soilslab.ai
          _buildGlobalHeader(),
          
          // Main Body switcher
          Expanded(
            child: _buildMainBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBody() {
    switch (_activeTopNavIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return Row(
          children: [
            // 2. Collapsible Left Sidebar
            _buildSidebar(),
            
            // 3. Main Center Canvas
            Expanded(
              child: Container(
                color: const Color(0xFF0B1326),
                padding: const EdgeInsets.all(24.0),
                child: _buildWorkstationModuleWrapper(),
              ),
            ),
          ],
        );
      case 2:
        return _buildPublicationsView();
      case 3:
        return _buildTeamView();
      default:
        return const Center(child: Text('Invalid View State'));
    }
  }

  // =====================================================================
  // HEADER & SIDEBAR WIDGETS
  // =====================================================================

  Widget _buildGlobalHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool compact = constraints.maxWidth < 900;
        return Container(
          height: 75,
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
          decoration: const BoxDecoration(
            color: Color(0xFF171F33), // Google Stitch Surface Container
            border: Border(
              bottom: BorderSide(color: Color(0xFF424754), width: 1), // outline-variant
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo & Title (soilslab.ai style)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFADC6FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.science_rounded, color: Color(0xFF4CD7F6), size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SOIL AI LAB',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Center: Minimalist navigation tabs (scrollable if very tight)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTopNavButton('HOME', 0, compact),
                      _buildTopNavButton('ANALYSIS SUITE', 1, compact),
                      _buildTopNavButton('PUBLICATIONS', 2, compact),
                      _buildTopNavButton('TEAM', 3, compact),
                    ],
                  ),
                ),
              ),
              
              // Right: Connection Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isServerOnline ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isServerOnline ? const Color(0xFF10B981) : const Color(0xFFFFB4AB),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isServerOnline ? const Color(0xFF10B981) : const Color(0xFFFFB4AB),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 8),
                      Text(
                        _isServerOnline ? 'FASTAPI BRIDGE ONLINE' : 'FASTAPI BRIDGE OFFLINE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: _isServerOnline ? const Color(0xFF10B981) : const Color(0xFFFFB4AB),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopNavButton(String label, int index, bool compact) {
    bool isActive = _activeTopNavIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 6),
      child: TextButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _activeTopNavIndex = index;
              });
            }
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: isActive ? const Color(0xFF4CD7F6) : const Color(0xFFC2C6D6),
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isActive ? const Color(0xFF4CD7F6).withOpacity(0.2) : Colors.transparent,
              width: 1,
            ),
          ),
          backgroundColor: isActive ? const Color(0xFF4CD7F6).withOpacity(0.04) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: compact ? 10 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            letterSpacing: compact ? 0.5 : 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    double width = _isSidebarCollapsed ? 80.0 : 260.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF171F33), // Google Stitch Surface Container
        border: Border(
          right: BorderSide(color: Color(0xFF424754), width: 1), // outline-variant
        ),
      ),
      child: Column(
        children: [
          // Sidebar Toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: _isSidebarCollapsed ? Alignment.center : Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
                icon: Icon(
                  _isSidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                  color: const Color(0xFFC2C6D6), // on-surface-variant
                ),
              ),
            ),
          ),
          
          const Divider(color: Color(0xFF424754), height: 1),
          const SizedBox(height: 12),
          
          // Navigation Items list (8 lab modules)
          Expanded(
            child: ListView.builder(
              itemCount: _sidebarModuleNames.length,
              itemBuilder: (context, index) {
                bool isActive = _activeTabIndex == (index + 1);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  child: InkWell(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _activeTabIndex = index + 1;
                          });
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFADC6FF).withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? const Color(0xFFADC6FF).withOpacity(0.3) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(
                            _sidebarModuleIcons[index],
                            color: isActive ? const Color(0xFF4CD7F6) : const Color(0xFFC2C6D6),
                            size: 20,
                          ),
                          if (!_isSidebarCollapsed) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _sidebarModuleNames[index],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? Colors.white : const Color(0xFFC2C6D6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // HOME PAGE VIEW (TAB 0)
  // =====================================================================

  Widget _buildHomeView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section: 50/50 Split
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Hero Text
                  Expanded(
                    flex: isMobile ? 1 : 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Authoritative Tagline
                        const Text(
                          'The Science of Soil,\nPowered by AI.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Decisions Defined by Data. Algorithm-Driven Engineering.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CD7F6),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome to the Soil AI Lab (Engineering Edition). We bridge physical soil mechanics with advanced machine learning systems. Our workstation suite automates geotechnical classification, slope stability factor safety solvers, bearing envelope designs, and deep subsurface boring log mapping.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Color(0xFFC2C6D6),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFADC6FF), // primary blue
                            foregroundColor: const Color(0xFF002E6A), // on-primary
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _activeTopNavIndex = 1; // Launch Workstation
                                  _activeTabIndex = 1; // Default to Classification
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                          label: const Text(
                            'LAUNCH WORKSTATION ANALYSIS SUITE',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (!isMobile) ...[
                    const SizedBox(width: 40),
                    // Right Column: Hero Banner Image
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 380,
                        decoration: BoxDecoration(
                          color: const Color(0xFF171F33),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF424754)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/hero_banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          
          const SizedBox(height: 48),
          const Divider(color: Color(0xFF424754)),
          const SizedBox(height: 40),
          
          // Capabilities Section Header
          const Text(
            'ANALYSIS CAPABILITIES',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C909F),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          
          // Capabilities Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = 4;
              if (constraints.maxWidth < 650) {
                cols = 1;
              } else if (constraints.maxWidth < 1100) {
                cols = 2;
              } else if (constraints.maxWidth < 1500) {
                cols = 3;
              }
              double gridW = (constraints.maxWidth - (16 * (cols - 1))) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                   _buildHomeCapabilityCard(1, 'Soil Classification', 'Calculate Atterberg limits and identify soil properties via USCS mapping.', Icons.layers_rounded, gridW),
                  _buildHomeCapabilityCard(2, 'Borehole Workspace', 'Manage boring logs, sieve analysis, and foundation bearing capacity.', Icons.assignment_rounded, gridW),
                  _buildHomeCapabilityCard(3, 'CBR Deflection Prediction', 'Predict compaction characteristics and stress deflection curves.', Icons.speed_rounded, gridW),
                  _buildHomeCapabilityCard(4, 'Slope Stability Analysis', 'Model 2D slope profiles and calculate Bishop circular slip surfaces.', Icons.timeline_rounded, gridW),
                  _buildHomeCapabilityCard(5, 'Foundation Design', 'Design shallow footings and map Terzaghi ultimate bearing zones.', Icons.foundation_rounded, gridW),
                  _buildHomeCapabilityCard(6, 'Settlement Estimation', 'Track primary clay consolidation rates and void ratios over a 50-year horizon.', Icons.compress_rounded, gridW),
                  _buildHomeCapabilityCard(7, 'Geological Block Modeler', 'Interpolate CPT sounding logs to view rotatable 3D subsurface block models.', Icons.terrain_rounded, gridW),
                  _buildHomeCapabilityCard(8, 'Micrograph AI Segmenter', 'Analyze soil grains visually with segment overlays and particle size charts.', Icons.psychology_rounded, gridW),
                ],
              );
            },
          ),
          
          const SizedBox(height: 54),
          const Divider(color: Color(0xFF424754)),
          const SizedBox(height: 40),
          
          // Technical Schematics & Layout
          const Text(
            'DIGITAL INSTRUMENTATION SCHEMATICS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C909F),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Boring log schematic
                  Expanded(
                    child: Container(
                      height: 340,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171F33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF424754)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              color: const Color(0xFF0B1326),
                              child: const Text(
                                'Borehole Stratigraphy & CPT Log Diagram',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                            ),
                            Expanded(
                              child: CustomPaint(
                                painter: BoringLogPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Soil Strata schematic
                  Expanded(
                    child: Container(
                      height: 340,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171F33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF424754)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              color: const Color(0xFF0B1326),
                              child: const Text(
                                'Soil Profiling & Layering Schematic',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                            ),
                            Expanded(
                              child: CustomPaint(
                                painter: SoilStrataPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 20),
                    // Micrograph Specimen Image Card
                    Expanded(
                      child: Container(
                        height: 340,
                        decoration: BoxDecoration(
                          color: const Color(0xFF171F33),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF424754)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                color: const Color(0xFF0B1326),
                                child: const Text(
                                  'Micrograph Specimen Capture (Vibrant AI Segment)',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                ),
                              ),
                              Expanded(
                                child: Image.asset(
                                  'assets/micrograph_specimen.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCapabilityCard(int index, String title, String desc, IconData icon, double width) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _activeTopNavIndex = 1; // Analysis Suite
                _activeTabIndex = index; // Module tab matching index
              });
            }
          });
        },
        child: Container(
          width: width,
          height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF171F33),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF424754)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getCapabilityVectorPlaceholder(index),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8C909F), size: 16),
                ],
              ),
              const SizedBox(height: 14),
              // Thin geometric accent line (alternating colors for custom visuals)
              Container(
                width: 40,
                height: 2,
                color: index % 3 == 0 
                    ? const Color(0xFF4CD7F6) // Cyan
                    : index % 3 == 1
                        ? const Color(0xFFFFB786) // Orange
                        : const Color(0xFFADC6FF), // Blue
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  desc,
                  style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 11, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCapabilityVectorPlaceholder(int index) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _getCapabilityPainter(index),
      ),
    );
  }

  CustomPainter _getCapabilityPainter(int index) {
    switch (index) {
      case 1:
        return ClassificationCardPainter();
      case 2:
        return BoreholeCardPainter();
      case 3:
        return CbrCardPainter();
      case 4:
        return SlopeCardPainter();
      case 5:
        return FoundationCardPainter();
      case 6:
        return SettlementCardPainter();
      case 7:
        return GeologyCardPainter();
      case 8:
        return MicrographCardPainter();
      default:
        return ClassificationCardPainter();
    }
  }

  // =====================================================================
  // PUBLICATIONS VIEW (TAB 2)
  // =====================================================================

  Widget _buildPublicationsView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UF SOIL AI LAB PUBLICATIONS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C909F),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Academic & Scientific Contributions',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'We publish code and scientific discoveries detailing how Explainable AI (XAI) and multi-spectral sensors map geotechnics in real-time. Discover our latest publication record below.',
            style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _publications.length,
            itemBuilder: (context, index) {
              final pub = _publications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF171F33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF424754)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pub['title']!,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Authors: ${pub['authors']!} | ${pub['journal']!}',
                      style: const TextStyle(color: Color(0xFF4CD7F6), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const Divider(color: Color(0xFF424754), height: 24),
                    Text(
                      pub['abstract']!,
                      style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // TEAM VIEW (TAB 3)
  // =====================================================================

  Widget _buildTeamView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESEARCH TEAM',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C909F),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Meet Our Research Specialists',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'The Soil AI Lab represents an interdisciplinary group of soil scientists, computer engineers, and geotechnical practitioners working to advance agricultural and civil engineering.',
            style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = 2;
              if (constraints.maxWidth < 750) {
                cols = 1;
              }
              double w = (constraints.maxWidth - (20 * (cols - 1))) / cols;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _teamMembers.map((member) {
                  return Container(
                    width: w,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171F33),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF424754)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF4CD7F6).withOpacity(0.15),
                          child: Text(
                            member['avatar']!,
                            style: const TextStyle(color: Color(0xFF4CD7F6), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['name']!,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                member['role']!,
                                style: const TextStyle(color: Color(0xFFFFB786), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                member['bio']!,
                                style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 12, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // WORKSPACE WORKSTATION SWITCHER (TABS 1-8)
  // =====================================================================

  Widget _buildWorkstationModuleWrapper() {
    Widget activeModuleWidget;
    switch (_activeTabIndex) {
      case 1:
        activeModuleWidget = SoilClassificationModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 2:
        activeModuleWidget = BoreholesModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 3:
        activeModuleWidget = CbrPredictionModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 4:
        activeModuleWidget = StabilityAnalysisModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 5:
        activeModuleWidget = FoundationDesignModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 6:
        activeModuleWidget = SettlementAnalysisModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 7:
        activeModuleWidget = GeologicalModelingModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      case 8:
        activeModuleWidget = AiImageAnalysisModule(
          sharedState: _sharedState,
          onStateUpdated: _onStateUpdated,
        );
        break;
      default:
        activeModuleWidget = const Center(child: Text('Invalid Module State'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Module Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullModuleNames[_activeTabIndex].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Civil Engineering Workstation Module',
                  style: TextStyle(color: const Color(0xFF4CD7F6).withOpacity(0.8), fontSize: 11),
                ),
              ],
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFC2C6D6)),
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _activeTopNavIndex = 0; // Back to Home
                    });
                  }
                });
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 12),
              label: const Text('Back to Home Hub', style: TextStyle(fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 16),
        
        // Active Geotechnical Workstation 50/50 Area
        Expanded(
          child: activeModuleWidget,
        ),
      ],
    );
  }
}

// =====================================================================
// TECHNICAL ILLUSTRATION PAINTERS (FOR ACCREDITED SCHEMATICS)
// =====================================================================

class SoilStrataPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double w = size.width;
    double h = size.height;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF171F33));

    // Layer 1: Topsoil
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.15),
      Paint()..color = const Color(0xFF31394D).withOpacity(0.5),
    );

    // Layer 2: Sand
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.15, w, h * 0.45),
      Paint()..color = const Color(0xFFFFB786).withOpacity(0.08),
    );
    // Draw cross hatching for sand
    final sandHatchPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double x = -h; x < w; x += 25) {
      canvas.drawLine(Offset(x, h * 0.15), Offset(x + h * 0.45, h * 0.6), sandHatchPaint);
    }

    // Layer 3: Clay
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.6, w, h * 0.85),
      Paint()..color = const Color(0xFF4CD7F6).withOpacity(0.06),
    );
    // Draw dots for clay
    final clayDotPaint = Paint()
      ..color = const Color(0xFF4CD7F6).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    for (double x = 15; x < w; x += 30) {
      for (double y = h * 0.6 + 15; y < h * 0.85; y += 20) {
        canvas.drawCircle(Offset(x, y), 1.5, clayDotPaint);
      }
    }

    // Layer 4: Bedrock
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.85, w, h),
      Paint()..color = const Color(0xFF0B1326),
    );
    // Draw bedrock crack lines
    final bedrockCrackPaint = Paint()
      ..color = const Color(0xFF424754).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, h * 0.85), Offset(w * 0.2, h * 0.9), bedrockCrackPaint);
    canvas.drawLine(Offset(w * 0.2, h * 0.9), Offset(w * 0.25, h), bedrockCrackPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.85), Offset(w * 0.58, h * 0.96), bedrockCrackPaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.96), Offset(w * 0.52, h), bedrockCrackPaint);
    canvas.drawLine(Offset(w * 0.8, h * 0.85), Offset(w * 0.9, h * 0.95), bedrockCrackPaint);

    // Draw dynamic measurement ticks and crosshairs
    final measurementPaint = Paint()
      ..color = const Color(0xFFADC6FF).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.75, 10), Offset(w * 0.75, h - 10), measurementPaint);

    // Target crosshair
    canvas.drawCircle(Offset(w * 0.75, h * 0.4), 8, measurementPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.4), 3, Paint()..color = const Color(0xFF4CD7F6));

    // Text labels
    void drawText(String text, double x, double y) {
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }

    drawText("ORGANIC CLAY (OL)", 16, 12);
    drawText("CLAYEY SAND (SC)", 16, h * 0.25);
    drawText("COLLOIDAL CLAY (CL)", 16, h * 0.65);
    drawText("WEATHERED BEDROCK", 16, h * 0.9);
    drawText("PROBE DEPTH: 14.5m", w * 0.75 - 130, h * 0.4 - 5);

    // Grid divider lines on left
    final tickPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double y = 0; y < h; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(8, y), tickPaint);
    }

    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GrainMicrographPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double w = size.width;
    double h = size.height;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF171F33));

    // Draw stylized circular sand grains
    void drawGrain(double cx, double cy, double r, Color color) {
      final fill = Paint()..color = color.withOpacity(0.08);
      final stroke = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), r, fill);
      canvas.drawCircle(Offset(cx, cy), r, stroke);

      // segmentation label
      textPainter.text = TextSpan(
        text: "ID-${cx.toInt()}",
        style: TextStyle(color: color.withOpacity(0.8), fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 4));
    }

    drawGrain(w * 0.25, h * 0.3, 26, const Color(0xFFFFB786));
    drawGrain(w * 0.62, h * 0.45, 34, const Color(0xFF4CD7F6));
    drawGrain(w * 0.38, h * 0.72, 20, const Color(0xFFADC6FF));
    drawGrain(w * 0.78, h * 0.28, 22, const Color(0xFFFFB786));
    drawGrain(w * 0.76, h * 0.76, 18, const Color(0xFF4CD7F6));

    // Draw scan target ticks
    final scanPaint = Paint()
      ..color = const Color(0xFF4CD7F6).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 60, scanPaint);
    canvas.drawLine(Offset(w * 0.5 - 75, h * 0.5), Offset(w * 0.5 - 45, h * 0.5), scanPaint);
    canvas.drawLine(Offset(w * 0.5 + 45, h * 0.5), Offset(w * 0.5 + 75, h * 0.5), scanPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.5 - 75), Offset(w * 0.5, h * 0.5 - 45), scanPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.5 + 45), Offset(w * 0.5, h * 0.5 + 75), scanPaint);

    // Label Info overlay
    textPainter.text = const TextSpan(
      text: "MAGNIFICATION: 400X\nMODEL CONFIDENCE: 94.6%",
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 8, fontFamily: 'monospace', height: 1.4),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(12, 12));

    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoringLogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double w = size.width;
    double h = size.height;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF171F33));

    // Draw vertical column on left (width 40)
    double colW = 40;
    canvas.drawRect(Rect.fromLTWH(12, 12, colW, h - 24), Paint()..color = const Color(0xFF0B1326));
    canvas.drawRect(Rect.fromLTWH(12, 12, colW, h - 24), borderPaint);

    // Draw divisions in the boring column
    double d1 = 12 + (h - 24) * 0.25;
    double d2 = 12 + (h - 24) * 0.65;
    canvas.drawLine(Offset(12, d1), Offset(12 + colW, d1), borderPaint);
    canvas.drawLine(Offset(12, d2), Offset(12 + colW, d2), borderPaint);

    // Fill divisions with patterns
    canvas.drawRect(Rect.fromLTWH(12, 12, colW, d1 - 12), Paint()..color = const Color(0xFFFFB786).withOpacity(0.1));
    canvas.drawRect(Rect.fromLTWH(12, d1, colW, d2 - d1), Paint()..color = const Color(0xFF4CD7F6).withOpacity(0.08));
    canvas.drawRect(Rect.fromLTWH(12, d2, colW, h - 12 - d2), Paint()..color = const Color(0xFFADC6FF).withOpacity(0.08));

    // Draw CPT Tip Resistance Curve (q_c) on the right
    double graphL = 72;
    double graphW = w - graphL - 16;
    final graphBorder = Paint()
      ..color = const Color(0xFF424754).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(graphL, 12, graphW, h - 24), graphBorder);

    // Draw ticks
    final gridPaint = Paint()
      ..color = const Color(0xFF424754).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (double x = graphL + 25; x < graphL + graphW; x += 25) {
      canvas.drawLine(Offset(x, 12), Offset(x, h - 12), gridPaint);
    }

    // Draw curve
    final curvePaint = Paint()
      ..color = const Color(0xFFFFB786)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(graphL + graphW * 0.15, 12);
    // Draw CPT trace
    for (double y = 16; y < h - 12; y += 8) {
      double pct = 0.25 + 0.4 * math.sin(y * 0.04) + 0.15 * math.cos(y * 0.15);
      path.lineTo(graphL + graphW * pct, y);
    }
    canvas.drawPath(path, curvePaint);

    // Labels
    textPainter.text = const TextSpan(
      text: "q_c (MPa)",
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(graphL + graphW / 2 - textPainter.width / 2, h - 22));

    // Depth markers
    for (int d = 10; d <= 30; d += 10) {
      double y = 12 + (h - 24) * (d / 30.0);
      textPainter.text = TextSpan(
        text: "${d}m",
        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 7, fontFamily: 'monospace'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(graphL - textPainter.width - 6, y - 4));
    }

    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================================
// CAPABILITY CARD VECTOR PAINTERS (HIGH-CONTRAST DIGITAL PIPE LINE REPRESENTATION)
// =====================================================================

class ClassificationCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CD7F6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(Rect.fromLTWH(2, 4, size.width - 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(2, 10, size.width - 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(2, 16, size.width - 4, 4), paint);
    
    final detailPaint = Paint()
      ..color = const Color(0xFF4CD7F6).withOpacity(0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(6, 6), Offset(12, 6), detailPaint);
    canvas.drawLine(Offset(size.width - 12, 12), Offset(size.width - 6, 12), detailPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SieveCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB786)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 2, paint);
    
    final gridPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(6, size.height * 0.35), Offset(size.width - 6, size.height * 0.35), gridPaint);
    canvas.drawLine(Offset(4, size.height * 0.5), Offset(size.width - 4, size.height * 0.5), gridPaint);
    canvas.drawLine(Offset(6, size.height * 0.65), Offset(size.width - 6, size.height * 0.65), gridPaint);
    
    canvas.drawLine(Offset(size.width * 0.35, 6), Offset(size.width * 0.35, size.height - 6), gridPaint);
    canvas.drawLine(Offset(size.width * 0.5, 4), Offset(size.width * 0.5, size.height - 4), gridPaint);
    canvas.drawLine(Offset(size.width * 0.65, 6), Offset(size.width * 0.65, size.height - 6), gridPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoreholeCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CD7F6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Draw outer paper/log box
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), const Radius.circular(4)), paint);
    
    final fillPaint = Paint()
      ..color = const Color(0xFF4CD7F6).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Draw three layers inside
    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, 5), fillPaint);
    canvas.drawRect(Rect.fromLTWH(4, 11, size.width - 8, 5), fillPaint..color = const Color(0xFFFFB786).withOpacity(0.2));
    canvas.drawRect(Rect.fromLTWH(4, 18, size.width - 8, size.height - 22), fillPaint..color = const Color(0xFFADC6FF).withOpacity(0.2));
    
    // Draw a vertical drilling line cutting down the middle
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width / 2, 2), Offset(size.width / 2, size.height - 2), linePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CbrCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFADC6FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(4, size.height - 4);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width - 4, 4);
    canvas.drawPath(path, paint);
    
    final axisPaint = Paint()
      ..color = const Color(0xFFADC6FF).withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(2, 2), Offset(2, size.height - 2), axisPaint);
    canvas.drawLine(Offset(2, size.height - 2), Offset(size.width - 2, size.height - 2), axisPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SlopeCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CD7F6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(2, size.height * 0.85);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.lineTo(size.width * 0.75, size.height * 0.15);
    path.lineTo(size.width - 2, size.height * 0.15);
    canvas.drawPath(path, paint);
    
    final arcPaint = Paint()
      ..color = const Color(0xFFFFB786)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final arcPath = Path();
    arcPath.moveTo(size.width * 0.2, size.height * 0.85);
    arcPath.quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.8, size.height * 0.15);
    canvas.drawPath(arcPath, arcPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FoundationCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB786)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, 2, size.width * 0.7, 6), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.35, 8, size.width * 0.3, size.height - 10), paint);
    
    final bulbPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.7, size.height * 0.5),
      0,
      3.1415,
      false,
      bulbPaint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SettlementCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFADC6FF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(Rect.fromLTWH(4, 2, size.width - 8, 3), paint);
    canvas.drawRect(Rect.fromLTWH(4, size.height - 5, size.width - 8, 3), paint);
    
    final path = Path();
    path.moveTo(size.width / 2, 5);
    path.lineTo(size.width * 0.3, size.height * 0.25);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.75);
    path.lineTo(size.width / 2, size.height - 5);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GeologyCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CD7F6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final p = Path();
    p.moveTo(2, size.height * 0.4);
    p.lineTo(size.width * 0.5, size.height * 0.7);
    p.lineTo(size.width * 0.5, size.height - 2);
    p.lineTo(2, size.height * 0.7);
    p.close();
    
    p.moveTo(size.width * 0.5, size.height * 0.7);
    p.lineTo(size.width - 2, size.height * 0.4);
    p.lineTo(size.width - 2, size.height * 0.7);
    p.lineTo(size.width * 0.5, size.height - 2);
    p.close();
    
    p.moveTo(2, size.height * 0.4);
    p.lineTo(size.width * 0.5, 2);
    p.lineTo(size.width - 2, size.height * 0.4);
    p.lineTo(size.width * 0.5, size.height * 0.7);
    p.close();
    
    canvas.drawPath(p, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MicrographCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB786)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 2, paint);
    
    final fillPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.45), 4, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.55), 3, fillPaint);
    
    final crossPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(size.width / 2, 4), Offset(size.width / 2, size.height - 4), crossPaint);
    canvas.drawLine(Offset(4, size.height / 2), Offset(size.width - 4, size.height / 2), crossPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
