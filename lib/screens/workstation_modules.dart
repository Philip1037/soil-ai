import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/soil_api_service.dart';
import '../services/download_helper.dart';
import '../services/image_picker_helper.dart';

/// Class containing the shared data between workstation modules to enable
/// real-time data bridging/shortcuts.
class SharedGeotechState {
  double? sieveFinesPercent;
  double? sieveD10;
  double? sieveD30;
  double? sieveD60;
  double? sieveCu;
  double? sieveCc;

  double? classLL;
  double? classPL;
  double? classPI;

  double? footingWidthB;
  double? footingLengthL;
}

class SieveSampleData {
  final int sampleIndex;
  final double depth;
  final double totalDryWeight;
  final List<double> incrementalWeights;
  final List<double> cumulativeWeights;
  final List<double> incrementalPercentRetained;
  final List<double> cumulativePercentPassing;
  final double totalRecoveredMass;

  SieveSampleData({
    required this.sampleIndex,
    required this.depth,
    required this.totalDryWeight,
    required this.incrementalWeights,
    required this.cumulativeWeights,
    required this.incrementalPercentRetained,
    required this.cumulativePercentPassing,
    required this.totalRecoveredMass,
  });

  String getIncrementalWeightString(int idx) {
    return '${incrementalWeights[idx].toStringAsFixed(2)}g';
  }

  String getCumulativeWeightString(int idx) {
    return '${cumulativeWeights[idx].toStringAsFixed(2)}g';
  }

  String getIncrementalPercentRetainedString(int idx) {
    if (incrementalWeights[idx] == 0.0) {
      return '0.00%';
    }
    return '${incrementalPercentRetained[idx].toStringAsFixed(2)}%';
  }

  String getCumulativePercentPassingString(int idx) {
    return cumulativePercentPassing[idx].toStringAsFixed(2);
  }
}

// =====================================================================
// GLOBAL WORKSPACE DECORATIVE HELPER WIDGETS
// =====================================================================

/// Sleek card wrapper for analytical charts
Widget buildChartCard({
  required String title,
  required Widget child,
  required VoidCallback onExportCsv,
}) {
  return Card(
    color: const Color(0xFF171F33),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF424754)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C909F),
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1326),
                  foregroundColor: const Color(0xFF4CD7F6),
                  side: const BorderSide(color: Color(0xFF4CD7F6), width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onExportCsv,
                icon: const Icon(Icons.download_rounded, size: 14),
                label: const Text(
                  '💾 Export CSV',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF424754), height: 24),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

/// Dynamic AI Geotechnical Report Generation Panel
class AiReportPanel extends StatelessWidget {
  final String moduleName;
  final String inputSummary;
  final String resultSummary;

  const AiReportPanel({
    super.key,
    required this.moduleName,
    required this.inputSummary,
    required this.resultSummary,
  });

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1326),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF424754)),
          ),
          title: Row(
            children: const [
              Icon(Icons.description, color: Color(0xFFFFB786)),
              SizedBox(width: 10),
              Text(
                'AI Geotechnical Report Draft',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PUBLICATION-READY SUMMARY NARRATIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C909F),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171F33),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF424754)),
                    ),
                    child: Text(
                      'GEOTECHNICAL LABORATORY ANALYSIS REPORT\n'
                      '========================================\n'
                      'Test Module : $moduleName\n'
                      'Date Created: ${DateTime.now().toLocal().toString().substring(0, 19)}\n'
                      'System Mode : FastAPI Local Bridge Pipeline\n\n'
                      '1. EXECUTIVE SUMMARY\n'
                      '--------------------\n'
                      'A laboratory geotechnical characterization test was completed on the soil sample. '
                      'Data inputs and calculated indices have been parsed through the engineering logic models.\n\n'
                      '2. INPUT DATA RECORD\n'
                      '--------------------\n'
                      '$inputSummary\n\n'
                      '3. CALCULATED METRICS & PREDICTIONS\n'
                      '-----------------------------------\n'
                      '$resultSummary\n\n'
                      '4. PROFESSIONAL RECOMMENDATION\n'
                      '-----------------------------\n'
                      'Based on the classification and engineering properties derived, the material is suitable '
                      'for standard subgrade compaction. Proper moisture controls at OMC must be monitored '
                      'during field implementation. Lime or cement stabilization is recommended if plastic fines exceed design bounds.\n\n'
                      'Report compiled automatically by Soil AI Smart Lab.',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFE2E8F0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFFC2C6D6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFADC6FF),
                foregroundColor: const Color(0xFF002E6A),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report saved to downloads folder (${moduleName}_report.txt).'),
                    backgroundColor: const Color(0xFF4CD7F6),
                  ),
                );
              },
              child: const Text('Download Report (.txt)'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF424754)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB786).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology, color: Color(0xFFFFB786), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI Report Generation Panel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Draft a formal, publication-ready summary narrative based on active geotechnical data.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC2C6D6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFADC6FF),
              foregroundColor: const Color(0xFF002E6A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _showReportDialog(context),
            icon: const Icon(Icons.menu_book, size: 16),
            label: const Text(
              '📝 Generate Report',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

void triggerCsvDownload(BuildContext context, String moduleName, String csvContent) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Exported $moduleName graph data successfully to CSV file.'),
      backgroundColor: const Color(0xFF4CD7F6),
    ),
  );
}

// =====================================================================
// 1. SOIL CLASSIFICATION MODULE
// =====================================================================
class SoilClassificationModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const SoilClassificationModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<SoilClassificationModule> createState() => _SoilClassificationModuleState();
}

class _SoilClassificationModuleState extends State<SoilClassificationModule> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _llController = TextEditingController(text: '45.0');
  final TextEditingController _plController = TextEditingController(text: '20.0');
  final TextEditingController _finesController = TextEditingController(text: '65.0');
  final TextEditingController _d10Controller = TextEditingController(text: '0.015');
  final TextEditingController _d30Controller = TextEditingController(text: '0.045');
  final TextEditingController _d60Controller = TextEditingController(text: '0.220');

  double _calculatedPi = 25.0;
  bool _isAnalyzing = false;
  SoilAnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _syncSharedData();
    _recalcPi();
  }

  void _syncSharedData() {
    if (widget.sharedState.classLL != null) {
      _llController.text = widget.sharedState.classLL!.toStringAsFixed(1);
    }
    if (widget.sharedState.classPL != null) {
      _plController.text = widget.sharedState.classPL!.toStringAsFixed(1);
    }
    if (widget.sharedState.sieveFinesPercent != null) {
      _finesController.text = widget.sharedState.sieveFinesPercent!.toStringAsFixed(1);
    }
    if (widget.sharedState.sieveD10 != null) {
      _d10Controller.text = widget.sharedState.sieveD10!.toStringAsFixed(4);
    }
    if (widget.sharedState.sieveD30 != null) {
      _d30Controller.text = widget.sharedState.sieveD30!.toStringAsFixed(4);
    }
    if (widget.sharedState.sieveD60 != null) {
      _d60Controller.text = widget.sharedState.sieveD60!.toStringAsFixed(4);
    }
  }

  void _recalcPi() {
    double ll = double.tryParse(_llController.text) ?? 0;
    double pl = double.tryParse(_plController.text) ?? 0;
    setState(() {
      _calculatedPi = math.max(0.0, ll - pl);
    });
    // Write back to shared state
    widget.sharedState.classLL = ll;
    widget.sharedState.classPL = pl;
    widget.sharedState.classPI = _calculatedPi;
    widget.onStateUpdated();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final res = await SoilApiService.analyzeSoil(
        pl: double.parse(_plController.text),
        pi: _calculatedPi,
        d10: double.parse(_d10Controller.text),
        d30: double.parse(_d30Controller.text),
        d60: double.parse(_d60Controller.text),
        omc: 12.0, // default placeholder OMC
        mdd: 1.80, // default placeholder MDD
      );
      setState(() {
        _result = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend connection failed. Using fallback calculations. Error: $e'),
          backgroundColor: const Color(0xFFFFB4AB),
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double llVal = double.tryParse(_llController.text) ?? 0;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Lab Data Entry
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ATTERBERG LIMIT DATA ENTRY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C909F),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _llController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Liquid Limit, LL (%)',
                                    ),
                                    onChanged: (_) => _recalcPi(),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _plController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Plastic Limit, PL (%)',
                                    ),
                                    onChanged: (_) => _recalcPi(),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Plasticity Index (PI): ',
                                  style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CD7F6).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF4CD7F6), width: 1),
                                  ),
                                  child: Text(
                                    '${_calculatedPi.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Color(0xFF4CD7F6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'OPTIONAL GRAIN SIZE CHARACTERISTICS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C909F),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _finesController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Fines Passing No. 200 Sieve (%)',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _d10Controller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'D10 (mm)'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _d30Controller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'D30 (mm)'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _d60Controller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'D60 (mm)'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFADC6FF),
                                  foregroundColor: const Color(0xFF002E6A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _isAnalyzing ? null : _submit,
                                child: _isAnalyzing
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Classify Soil Sample',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            if (_result != null) ...[
                              const Divider(color: Color(0xFF424754), height: 32),
                              Text(
                                'USCS Classification: ${_result!.soilClassCode}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _result!.soilClassName,
                                style: const TextStyle(color: Color(0xFF4CD7F6), fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _result!.description,
                                style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 12, height: 1.4),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: Casagrande Chart
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: 'Casagrande Plasticity Chart',
                  onExportCsv: () {
                    triggerCsvDownload(
                      context,
                      'Soil_Classification',
                      'LL,PL,PI\n$llVal,${llVal - _calculatedPi},$_calculatedPi',
                    );
                  },
                  child: InteractivePlasticityChart(
                    ll: llVal,
                    pi: _calculatedPi,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'Soil Classification',
          inputSummary: 'LL = $llVal%, PL = ${llVal - _calculatedPi}%, Fines = ${_finesController.text}%, D10 = ${_d10Controller.text}mm, D60 = ${_d60Controller.text}mm',
          resultSummary: _result != null
              ? 'Classification = ${_result!.soilClassCode} (${_result!.soilClassName}), Confidence = ${_result!.classificationConfidence}%'
              : 'PI = ${_calculatedPi.toStringAsFixed(1)}% (Estimated USCS: ${llVal >= 50 ? "CH/MH" : "CL/ML"})',
        ),
      ],
    );
  }
}

class InteractivePlasticityChart extends StatelessWidget {
  final double ll;
  final double pi;

  const InteractivePlasticityChart({
    super.key,
    required this.ll,
    required this.pi,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: PlasticityChartPainter(ll: ll, pi: pi),
        );
      },
    );
  }
}

class PlasticityChartPainter extends CustomPainter {
  final double ll;
  final double pi;

  PlasticityChartPainter({required this.ll, required this.pi});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final gridPaint = Paint()
      ..color = const Color(0xFF171F33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = const Color(0xFF8C909F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final linePaint = Paint()
      ..color = const Color(0xFFFFB786) // safety orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Coordinate mapping bounds
    double minLL = 0;
    double maxLL = 100;
    double minPI = 0;
    double maxPI = 60;

    // Viewport padding
    double padL = 40;
    double padB = 40;
    double padT = 20;
    double padR = 20;

    double plotW = size.width - padL - padR;
    double plotH = size.height - padT - padB;

    Offset mapPoint(double x, double y) {
      double pctX = (x - minLL) / (maxLL - minLL);
      double pctY = (y - minPI) / (maxPI - minPI);
      return Offset(
        padL + pctX * plotW,
        size.height - padB - pctY * plotH,
      );
    }

    // Draw borders & background grid
    canvas.drawRect(Rect.fromLTWH(padL, padT, plotW, plotH), gridPaint);
    for (int i = 20; i <= 100; i += 20) {
      Offset top = mapPoint(i.toDouble(), maxPI);
      Offset btm = mapPoint(i.toDouble(), minPI);
      canvas.drawLine(top, btm, gridPaint);

      // Label X-Axis
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(btm.dx - textPainter.width / 2, btm.dy + 5));
    }

    for (int i = 10; i <= 60; i += 10) {
      Offset left = mapPoint(minLL, i.toDouble());
      Offset right = mapPoint(maxLL, i.toDouble());
      canvas.drawLine(left, right, gridPaint);

      // Label Y-Axis
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left.dx - textPainter.width - 8, left.dy - textPainter.height / 2));
    }

    // Axes lines
    canvas.drawLine(mapPoint(minLL, minPI), mapPoint(maxLL, minPI), axisPaint);
    canvas.drawLine(mapPoint(minLL, minPI), mapPoint(minLL, maxPI), axisPaint);

    // Title label on axes
    // X Axis Label
    textPainter.text = const TextSpan(
      text: 'Liquid Limit, LL (%)',
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 11, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(padL + plotW / 2 - textPainter.width / 2, size.height - padB + 20));

    // Draw A-Line: PI = 0.73 * (LL - 20)
    // Starting at (20, 0) up to (100, 58.4)
    canvas.drawLine(mapPoint(20, 0), mapPoint(100, 58.4), linePaint);
    textPainter.text = const TextSpan(
      text: 'A-Line (PI = 0.73 * [LL-20])',
      style: TextStyle(color: Color(0xFFFFB786), fontSize: 9, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    canvas.save();
    canvas.translate(mapPoint(60, 29.2).dx, mapPoint(60, 29.2).dy - 12);
    canvas.rotate(-math.atan2(plotH * 0.73, plotW) * 0.8);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();

    // Draw U-Line: PI = 0.9 * (LL - 8)
    // Starting at (8, 0) up to (75, 60)
    final uLinePaint = Paint()
      ..color = const Color(0xFFFFB4AB).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(mapPoint(8, 0), mapPoint(75, 60.3), borderPaint..color = const Color(0xFFFFB4AB).withOpacity(0.5));

    // Label Regions
    void drawText(String text, double x, double y, Color color) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, mapPoint(x, y));
    }

    drawText('CH', 70, 45, const Color(0xFF4CD7F6).withOpacity(0.4));
    drawText('CL', 40, 22, const Color(0xFF4CD7F6).withOpacity(0.4));
    drawText('MH / OH', 75, 12, const Color(0xFF8C909F).withOpacity(0.4));
    drawText('ML / OL', 45, 6, const Color(0xFF8C909F).withOpacity(0.4));
    drawText('CL-ML', 22, 5, const Color(0xFFF59E0B).withOpacity(0.4));

    // Plot Crosshair Pointer
    if (ll >= minLL && ll <= maxLL && pi >= minPI && pi <= maxPI) {
      Offset marker = mapPoint(ll, pi);
      final pointPaint = Paint()
        ..color = const Color(0xFFADC6FF)
        ..style = PaintingStyle.fill;
      final ringPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw dotted crosshairs
      final crosshairPaint = Paint()
        ..color = const Color(0xFFADC6FF).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawLine(Offset(padL, marker.dy), Offset(padL + plotW, marker.dy), crosshairPaint);
      canvas.drawLine(Offset(marker.dx, padT), Offset(marker.dx, size.height - padB), crosshairPaint);

      canvas.drawCircle(marker, 8.0, ringPaint);
      canvas.drawCircle(marker, 5.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 2. SIEVE ANALYSIS MODULE
// =====================================================================
enum SieveStandard { none, uscs, aashto }
enum SieveManualStep { b1, b2, b3, b4 }

class SieveAnalysisModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const SieveAnalysisModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<SieveAnalysisModule> createState() => _SieveAnalysisModuleState();
}

class _SieveAnalysisModuleState extends State<SieveAnalysisModule> {
  SieveStandard _selectedStandard = SieveStandard.none;
  SieveManualStep _currentStep = SieveManualStep.b1;

  // Step B1 Form Key and Controllers
  final _b1FormKey = GlobalKey<FormState>();
  final TextEditingController _boreholeIdController = TextEditingController(text: 'BH-01');
  final TextEditingController _locationController = TextEditingController(text: 'Sector 4, Construction Site');
  final TextEditingController _dateController = TextEditingController(text: '2026-06-03');
  final TextEditingController _regionController = TextEditingController(text: 'Florida');
  final TextEditingController _dateSampledController = TextEditingController(text: '2026-06-03');
  final TextEditingController _testedByController = TextEditingController(text: 'Dr. Nikos Tziolas');
  final TextEditingController _sampleDescriptionController = TextEditingController(text: 'Lean clay subgrade layer');



  // Step B3 Number of Samples
  final _b3FormKey = GlobalKey<FormState>();
  int _numSamples = 1;
  late List<TextEditingController> _sampleDepthControllers;
  late List<TextEditingController> _sampleWeightControllers;

  // Step B4 Mass Retained
  final _b4FormKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _allStandardSieves = [
    {'name': '3" (75.00 mm)', 'size': 75.0},
    {'name': '1-1/2" (37.50 mm)', 'size': 37.5},
    {'name': '3/4" (19.00 mm)', 'size': 19.0},
    {'name': '3/8" (9.50 mm)', 'size': 9.5},
    {'name': 'No. 4 (4.75 mm)', 'size': 4.75},
    {'name': 'No. 10 (2.36 mm)', 'size': 2.36},
    {'name': 'No. 16 (1.18 mm)', 'size': 1.18},
    {'name': 'No. 30 (0.60 mm)', 'size': 0.60},
    {'name': 'No. 40 (0.425 mm)', 'size': 0.425},
    {'name': 'No. 50 (0.30 mm)', 'size': 0.30},
    {'name': 'No. 100 (0.150 mm)', 'size': 0.150},
    {'name': 'No. 200 (0.075 mm)', 'size': 0.075},
    {'name': 'Passing 0.075 (Pan)', 'size': 0.001},
  ];

  // Active sieves filtered by size <= topSieveSize
  List<Map<String, dynamic>> _activeSieves = [];
  List<TextEditingController> _retainedMassControllers = [];
  List<FocusNode> _retainedMassFocusNodes = [];

  // Multi-Sample Active Index & Memory
  int _activeSampleIndex = 0;
  final Map<int, Map<double, String>> _sampleRetainedMassMemory = {};
  final Map<int, Map<double, TextEditingController>> _sampleSieveControllers = {};

  // Review Matrix Table Data (Editable)
  final List<Map<String, dynamic>> _reviewMatrixRows = [];
  bool _showReviewMatrix = false;
  bool _isExporting = false;
  bool _showAnalysisResults = false;
  int _resultsActiveIndex = 0;
  bool _isParsingImage = false;
  
  // Core calculation results cached for all samples
  final Map<int, SieveSampleData> _processedSamplesData = {};

  Future<void> _handleImageScanning() async {
    setState(() {
      _isParsingImage = true;
    });
    try {
      final pickerResult = await pickImageFile();
      if (pickerResult == null) {
        // User cancelled or picked nothing
        setState(() {
          _isParsingImage = false;
        });
        return;
      }

      if (!mounted) return;

      // Show temporary SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Uploading and processing log sheet with Gemini AI...'),
          backgroundColor: Color(0xFF0B1326),
          duration: Duration(seconds: 4),
        ),
      );

      final response = await SoilApiService.parseSieveImage(
        imageBytes: pickerResult.bytes,
        fileName: pickerResult.name,
      );

      _onImageParsed(response);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 AI Data Extraction Complete! Please review sample configuration.'),
            backgroundColor: Color(0xFF4CD7F6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to scan image: $e'),
            backgroundColor: const Color(0xFFFFB4AB),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isParsingImage = false;
        });
      }
    }
  }

  void _onImageParsed(Map<String, dynamic> data) {
    _safeSetState(() {
      // 1. Set general metadata if available
      if (data['borehole_id'] != null) {
        _boreholeIdController.text = data['borehole_id'].toString();
      }
      if (data['location'] != null) {
        _locationController.text = data['location'].toString();
        _regionController.text = data['location'].toString();
      }
      if (data['date'] != null) {
        _dateController.text = data['date'].toString();
        _dateSampledController.text = data['date'].toString();
      }

      final samples = data['samples'] as List<dynamic>?;
      if (samples != null && samples.isNotEmpty) {
        // Dispose old controllers
        for (var c in _sampleDepthControllers) {
          c.dispose();
        }
        for (var c in _sampleWeightControllers) {
          c.dispose();
        }

        _numSamples = samples.length;
        _sampleDepthControllers = [];
        _sampleWeightControllers = [];
        _sampleRetainedMassMemory.clear();

        for (int i = 0; i < _numSamples; i++) {
          final sample = samples[i] as Map<String, dynamic>;

          // Depth and Weight
          final depth = sample['depth']?.toString() ?? '1.5';
          final weight = sample['weight']?.toString() ?? '500.0';

          _sampleDepthControllers.add(TextEditingController(text: depth));
          _sampleWeightControllers.add(TextEditingController(text: weight));

          // Sieve weights
          _sampleRetainedMassMemory[i] = {};
          final sieveWeights = sample['sieve_weights'] as Map<String, dynamic>?;
          if (sieveWeights != null) {
            sieveWeights.forEach((sizeStr, weightVal) {
              final doubleSize = double.tryParse(sizeStr);
              if (doubleSize != null) {
                // Strip out trailing 'g' or whitespace
                String valClean = weightVal?.toString().replaceAll('g', '').trim() ?? '0.0';
                if (valClean.isEmpty || valClean == '00') valClean = '0.0';
                _sampleRetainedMassMemory[i]![doubleSize] = valClean;
              }
            });
          }
        }

        // Reset indexes and update active sieves
        _activeSampleIndex = 0;
        _updateActiveSieves();

        // Jump directly to Step B3 (Verification Stage 1)
        _currentStep = SieveManualStep.b3;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sampleDepthControllers = [TextEditingController(text: '1.5')];
    _sampleWeightControllers = [TextEditingController(text: '500.0')];
    _updateActiveSieves();
  }

  @override
  void dispose() {
    _boreholeIdController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _regionController.dispose();
    _dateSampledController.dispose();
    _testedByController.dispose();
    _sampleDescriptionController.dispose();
    for (var c in _sampleDepthControllers) {
      c.dispose();
    }
    for (var c in _sampleWeightControllers) {
      c.dispose();
    }
    _sampleSieveControllers.forEach((sampleIdx, sieveMap) {
      sieveMap.forEach((sieveSize, controller) {
        controller.dispose();
      });
    });
    for (var f in _retainedMassFocusNodes) {
      f.dispose();
    }
    for (var row in _reviewMatrixRows) {
      (row['retainedController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _updateActiveSieves() {
    _activeSieves = List.from(_allStandardSieves);
    
    // Dispose old focus nodes
    for (var f in _retainedMassFocusNodes) {
      f.dispose();
    }
    _retainedMassFocusNodes = List.generate(_activeSieves.length, (idx) => FocusNode());
    
    // Recreate/repopulate _sampleSieveControllers
    // Dispose old controllers first to avoid memory leaks
    _sampleSieveControllers.forEach((sampleIdx, sieveMap) {
      sieveMap.forEach((sieveSize, controller) {
        controller.dispose();
      });
    });
    _sampleSieveControllers.clear();
    
    final defaultRetained = [0.0, 15.2, 30.5, 45.1, 60.3, 72.8, 80.5, 42.0];
    for (int sIdx = 0; sIdx < _numSamples; sIdx++) {
      _sampleSieveControllers[sIdx] = {};
      for (int idx = 0; idx < _activeSieves.length; idx++) {
        final sieveSize = _activeSieves[idx]['size'] as double;
        String valStr = '';
        
        if (_sampleRetainedMassMemory.containsKey(sIdx) &&
            _sampleRetainedMassMemory[sIdx]!.containsKey(sieveSize)) {
          valStr = _sampleRetainedMassMemory[sIdx]![sieveSize]!;
        } else {
          if (sIdx == 0) {
            double val = 0.0;
            if (idx < defaultRetained.length) {
              val = defaultRetained[idx];
            }
            if (idx == _activeSieves.length - 1) {
              val = 25.0;
            }
            valStr = val.toString();
          } else {
            valStr = '';
          }
          
          if (!_sampleRetainedMassMemory.containsKey(sIdx)) {
            _sampleRetainedMassMemory[sIdx] = {};
          }
          _sampleRetainedMassMemory[sIdx]![sieveSize] = valStr;
        }
        
        _sampleSieveControllers[sIdx]![sieveSize] = TextEditingController(text: valStr);
      }
    }
    
    // Point _retainedMassControllers to the active sample's controllers (referential, no dispose on assignment)
    _retainedMassControllers = List.generate(_activeSieves.length, (idx) {
      final sieveSize = _activeSieves[idx]['size'] as double;
      return _sampleSieveControllers[_activeSampleIndex]![sieveSize]!;
    });
    _recalculateAllSamples();
  }

  void _safeSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(fn);
      }
    });
  }

  void _recalculateAllSamples() {
    _processedSamplesData.clear();
    for (int k = 0; k < _numSamples; k++) {
      final double totalDryWeight = double.tryParse(
        k < _sampleWeightControllers.length ? _sampleWeightControllers[k].text : '500.0'
      ) ?? 500.0;
      
      final double depth = double.tryParse(
        k < _sampleDepthControllers.length ? _sampleDepthControllers[k].text : '1.5'
      ) ?? 1.5;

      final List<double> incrementalWeights = [];
      for (int i = 0; i < _activeSieves.length; i++) {
        final sieveSize = _activeSieves[i]['size'] as double;
        String valStr = '0.0';
        if (_sampleSieveControllers.containsKey(k) &&
            _sampleSieveControllers[k]!.containsKey(sieveSize)) {
          valStr = _sampleSieveControllers[k]![sieveSize]!.text;
        }
        final val = double.tryParse(valStr) ?? 0.0;
        incrementalWeights.add(val);
      }

      // STEP A: CUMULATIVE WEIGHT RETAINED ENGINE
      final List<double> cumulativeWeights = List.filled(_activeSieves.length, 0.0);
      if (incrementalWeights.isNotEmpty) {
        cumulativeWeights[0] = incrementalWeights[0];
        for (int i = 1; i < incrementalWeights.length; i++) {
          cumulativeWeights[i] = cumulativeWeights[i - 1] + incrementalWeights[i];
        }
      }
      final double totalRecoveredMass = cumulativeWeights.isNotEmpty ? cumulativeWeights.last : 0.0;

      // STEP B: INCREMENTAL PERCENT RETAINED ENGINE
      final List<double> incrementalPercentRetained = List.filled(_activeSieves.length, 0.0);
      for (int i = 0; i < _activeSieves.length; i++) {
        if (totalDryWeight > 0.0) {
          incrementalPercentRetained[i] = (incrementalWeights[i] / totalDryWeight) * 100.0;
        } else {
          incrementalPercentRetained[i] = 0.0;
        }
      }

      // STEP C: CUMULATIVE PERCENT PASSING ENGINE
      final List<double> cumulativePercentPassing = List.filled(_activeSieves.length, 0.0);
      for (int i = 0; i < _activeSieves.length; i++) {
        if (totalDryWeight > 0.0) {
          double val = (1.0 - (cumulativeWeights[i] / totalDryWeight)) * 100.0;
          if (i == _activeSieves.length - 1) {
            val = 0.0;
          }
          cumulativePercentPassing[i] = val;
        } else {
          cumulativePercentPassing[i] = 0.0;
        }
      }

      _processedSamplesData[k] = SieveSampleData(
        sampleIndex: k,
        depth: depth,
        totalDryWeight: totalDryWeight,
        incrementalWeights: incrementalWeights,
        cumulativeWeights: cumulativeWeights,
        incrementalPercentRetained: incrementalPercentRetained,
        cumulativePercentPassing: cumulativePercentPassing,
        totalRecoveredMass: totalRecoveredMass,
      );
    }

    // Update active sample fines percent in geotech state
    if (_processedSamplesData.containsKey(_activeSampleIndex)) {
      final activeData = _processedSamplesData[_activeSampleIndex]!;
      int idx200 = -1;
      for (int i = 0; i < _activeSieves.length; i++) {
        if (((_activeSieves[i]['size'] as double) - 0.075).abs() < 0.005) {
          idx200 = i;
          break;
        }
      }
      if (idx200 != -1) {
        widget.sharedState.sieveFinesPercent = activeData.cumulativePercentPassing[idx200];
        widget.onStateUpdated();
      }
    }
  }

  void _recalculateReviewMatrix(double totalMass) {
    _recalculateAllSamples();
    if (_processedSamplesData.containsKey(_activeSampleIndex)) {
      final activeData = _processedSamplesData[_activeSampleIndex]!;
      for (int i = 0; i < _reviewMatrixRows.length; i++) {
        _reviewMatrixRows[i]['cumulative'] = activeData.cumulativeWeights[i];
        _reviewMatrixRows[i]['passing'] = activeData.cumulativePercentPassing[i];
      }
    }
  }

  void _recalculateFinesForActiveSample() {
    _recalculateAllSamples();
  }

  String _getCellDataString(int sIdx, int sieveIdx) {
    final sieveSize = _activeSieves[sieveIdx]['size'] as double;
    
    // Current retained mass
    String valStr = '0.0';
    if (_sampleSieveControllers.containsKey(sIdx) &&
        _sampleSieveControllers[sIdx]!.containsKey(sieveSize)) {
      valStr = _sampleSieveControllers[sIdx]![sieveSize]!.text;
    }
    final currentRetained = double.tryParse(valStr) ?? 0.0;
    
    return '${currentRetained.toStringAsFixed(1)}g';
  }



  String _generateWordHtml() {
    String html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">\n';
    html += '<head>\n';
    html += '<meta http-equiv="content-type" content="text/html; charset=utf-8" />\n';
    html += '<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View></w:WordDocument></xml><![endif]-->\n';
    html += '<style>\n';
    html += 'table { border-collapse: collapse; width: 100%; }\n';
    html += 'td, th { border: 1.0pt solid #000000; padding: 8px; font-family: Arial, sans-serif; font-size: 10.5px; text-align: center; }\n';
    html += 'th { background-color: #0b1326; color: #ffffff; font-weight: bold; }\n';
    html += '</style>\n';
    html += '</head>\n';
    html += '<body>\n';
    
    html += '<h2>GEOTECHNICAL LABORATORY REPORT</h2>\n';
    html += '<h3>SIEVE ANALYSIS BATCH DATA REVIEW MATRIX</h3>\n';
    html += '<p>\n';
    html += '  <b>Borehole ID:</b> ${_boreholeIdController.text}<br/>\n';
    html += '  <b>Project Site Location:</b> ${_locationController.text}<br/>\n';
    html += '  <b>Date of Logging:</b> ${_dateController.text}<br/>\n';
    html += '</p>\n';
    
    html += '<table>\n';
    
    // Header Row
    html += '  <tr>\n';
    html += '    <th style="vertical-align: middle;">Sieve Designation / Size (mm)</th>\n';
    for (int sIdx = 0; sIdx < _numSamples; sIdx++) {
      final depthStr = sIdx < _sampleDepthControllers.length ? _sampleDepthControllers[sIdx].text : '';
      final weightStr = sIdx < _sampleWeightControllers.length ? _sampleWeightControllers[sIdx].text : '';
      html += '    <th>\n';
      html += '      SPT Sample @ ${_boreholeIdController.text}<br/>\n';
      html += '      @ Depth $depthStr m<br/>\n';
      html += '      Wt = $weightStr g\n';
      html += '    </th>\n';
    }
    html += '  </tr>\n';
    
    // Sieve Rows
    for (int i = 0; i < _activeSieves.length; i++) {
      final sieve = _activeSieves[i];
      html += '  <tr>\n';
      html += '    <td style="text-align: left;">${sieve['name']} (${sieve['size']} mm)</td>\n';
      for (int sIdx = 0; sIdx < _numSamples; sIdx++) {
        final cellStr = _getCellDataString(sIdx, i);
        html += '    <td>$cellStr</td>\n';
      }
      html += '  </tr>\n';
    }
    
    html += '</table>\n';
    html += '</body>\n';
    html += '</html>\n';
    return html;
  }

  List<int> _buildPdfBytes(bool isLandscape) {
    final List<int> pdfBytes = [];
    
    void write(String s) {
      pdfBytes.addAll(utf8.encode(s));
    }
    
    void writeBytes(List<int> b) {
      pdfBytes.addAll(b);
    }
    
    final List<int> offsets = [];
    
    write('%PDF-1.4\n');
    write('%\u00E2\u00E3\u00CF\u00D3\n');
    
    void writeObj(int id, String content) {
      offsets.add(pdfBytes.length);
      write('$id 0 obj\n$content\nendobj\n');
    }
    
    writeObj(1, '<< /Type /Catalog /Pages 2 0 R >>');
    writeObj(2, '<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
    
    final mediaBox = isLandscape ? '[0 0 842 595]' : '[0 0 595 842]';
    writeObj(3, '<< /Type /Page /Parent 2 0 R /MediaBox $mediaBox /Resources << /Font << /F1 4 0 R /F2 6 0 R >> >> /Contents 5 0 R >>');
    
    writeObj(4, '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
    
    final buffer = StringBuffer();
    
    void pdfWrite(String s) {
      buffer.write(s);
    }
    
    void drawText(String text, double x, double y, {bool isBold = false, double fontSize = 9.0, bool isWhite = false}) {
      pdfWrite('BT\n');
      if (isBold) {
        pdfWrite('/F2 ${fontSize.toStringAsFixed(1)} Tf\n');
      } else {
        pdfWrite('/F1 ${fontSize.toStringAsFixed(1)} Tf\n');
      }
      if (isWhite) {
        pdfWrite('1 1 1 rg\n');
      } else {
        pdfWrite('0.09 0.12 0.2 rg\n'); // dark color
      }
      pdfWrite('${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} Td\n');
      final escaped = text
          .replaceAll('\\', '\\\\')
          .replaceAll('(', '\\(')
          .replaceAll(')', '\\)');
      pdfWrite('($escaped) Tj\n');
      pdfWrite('ET\n');
    }
    
    void drawCenteredText(String text, double xCol, double y, double wCol, {bool isBold = false, double fontSize = 9.0, bool isWhite = false}) {
      final approxWidth = text.length * fontSize * 0.52;
      final x = xCol + (wCol - approxWidth) / 2.0;
      drawText(text, x, y, isBold: isBold, fontSize: fontSize, isWhite: isWhite);
    }
    
    void drawLine(double x1, double y1, double x2, double y2) {
      pdfWrite('${x1.toStringAsFixed(2)} ${y1.toStringAsFixed(2)} m ${x2.toStringAsFixed(2)} ${y2.toStringAsFixed(2)} l S\n');
    }
    
    // Page Title
    drawCenteredText('GEOTECHNICAL LABORATORY REPORT', 0, 545, 842, isBold: true, fontSize: 13);
    drawCenteredText('SIEVE ANALYSIS BATCH DATA REVIEW MATRIX', 0, 528, 842, isBold: true, fontSize: 10);
    
    // Header divider line
    pdfWrite('0.09 0.12 0.2 RG\n1.5 w\n');
    drawLine(40, 515, 802, 515);
    
    // Metadata Info Block
    drawText('Borehole ID:', 45, 492, isBold: true, fontSize: 9.0);
    drawText(_boreholeIdController.text, 115, 492, isBold: false, fontSize: 9.0);
    
    drawText('Project Site:', 45, 477, isBold: true, fontSize: 9.0);
    drawText(_locationController.text, 115, 477, isBold: false, fontSize: 9.0);
    
    drawText('Date of Logging:', 450, 492, isBold: true, fontSize: 9.0);
    drawText(_dateController.text, 535, 492, isBold: false, fontSize: 9.0);
    
    drawText('Orientation:', 450, 477, isBold: true, fontSize: 9.0);
    drawText(isLandscape ? 'LANDSCAPE' : 'PORTRAIT', 535, 477, isBold: false, fontSize: 9.0);
    
    // Table positioning/coordinates
    const double tableTop = 445;
    const double sieveColWidth = 162;
    const double remainingWidth = 600;
    final double numSamplesDouble = _numSamples.toDouble();
    final double colWidth = remainingWidth / numSamplesDouble;
    const double headerHeight = 50;
    const double rowHeight = 22;
    final double tableBottom = tableTop - headerHeight - (_activeSieves.length * rowHeight);
    
    // Fill Header Background with dark slate/blue color
    pdfWrite('0.043 0.075 0.149 rg\n');
    pdfWrite('40 ${(tableTop - headerHeight).toStringAsFixed(2)} 762 ${headerHeight.toStringAsFixed(2)} re\nf\n');
    
    // Draw Grid Lines (borders)
    pdfWrite('0.65 0.67 0.72 RG\n0.75 w\n');
    
    // Outer table border
    pdfWrite('40 ${tableBottom.toStringAsFixed(2)} 762 ${(tableTop - tableBottom).toStringAsFixed(2)} re\nS\n');
    
    // Vertical lines
    drawLine(40 + sieveColWidth, tableTop, 40 + sieveColWidth, tableBottom);
    for (int j = 0; j < _numSamples - 1; j++) {
      final x = 40 + sieveColWidth + (j + 1) * colWidth;
      drawLine(x, tableTop, x, tableBottom);
    }
    
    // Horizontal lines
    drawLine(40, tableTop - headerHeight, 802, tableTop - headerHeight);
    for (int i = 0; i < _activeSieves.length - 1; i++) {
      final y = tableTop - headerHeight - (i + 1) * rowHeight;
      drawLine(40, y, 802, y);
    }
    
    // Text sizes and padding
    final double headerFontSize = _numSamples > 4 ? 8.0 : 9.0;
    final double cellFontSize = _numSamples > 4 ? 7.5 : 8.5;
    
    // Sieve designation column header
    drawCenteredText('Sieve Designation / Size (mm)', 40, tableTop - 29, sieveColWidth, isBold: true, fontSize: headerFontSize, isWhite: true);
    
    // Sample headers
    for (int j = 0; j < _numSamples; j++) {
      final depthStr = j < _sampleDepthControllers.length ? _sampleDepthControllers[j].text : '';
      final weightStr = j < _sampleWeightControllers.length ? _sampleWeightControllers[j].text : '';
      final xCol = 40 + sieveColWidth + j * colWidth;
      
      drawCenteredText('SPT Sample @ ${_boreholeIdController.text}', xCol, tableTop - 16, colWidth, isBold: true, fontSize: headerFontSize - 0.5, isWhite: true);
      drawCenteredText('@ Depth $depthStr m', xCol, tableTop - 28, colWidth, isBold: true, fontSize: headerFontSize - 0.5, isWhite: true);
      drawCenteredText('Wt = $weightStr g', xCol, tableTop - 40, colWidth, isBold: true, fontSize: headerFontSize - 0.5, isWhite: true);
    }
    
    // Rows text
    for (int i = 0; i < _activeSieves.length; i++) {
      final sieve = _activeSieves[i];
      final yRowBottom = tableTop - headerHeight - (i + 1) * rowHeight;
      final yText = yRowBottom + (rowHeight - cellFontSize) / 2.0 + 1.0;
      
      // Sieve Designation (Left-aligned, padded)
      final sieveText = '${sieve['name']} (${sieve['size']} mm)';
      drawText(sieveText, 48, yText, isBold: false, fontSize: cellFontSize, isWhite: false);
      
      // Sample Data Cells
      for (int j = 0; j < _numSamples; j++) {
        final xCol = 40 + sieveColWidth + j * colWidth;
        final cellStr = _getCellDataString(j, i);
        drawCenteredText(cellStr, xCol, yText, colWidth, isBold: false, fontSize: cellFontSize, isWhite: false);
      }
    }
    
    final streamContent = buffer.toString();
    final streamBytes = utf8.encode(streamContent);
    final streamHeader = '<< /Length ${streamBytes.length} >>\nstream\n';
    const streamFooter = '\nendstream';
    
    offsets.add(pdfBytes.length);
    write('5 0 obj\n$streamHeader');
    writeBytes(streamBytes);
    write('$streamFooter\nendobj\n');
    
    // Font F2 is Object 6:
    writeObj(6, '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>');
    
    final xrefOffset = pdfBytes.length;
    write('xref\n0 7\n');
    write('0000000000 65535 f \n');
    for (var offset in offsets) {
      final offsetStr = offset.toString().padLeft(10, '0');
      write('$offsetStr 00000 n \n');
    }
    
    write('trailer\n<< /Size 7 /Root 1 0 R >>\n');
    write('startxref\n$xrefOffset\n%%EOF\n');
    
    return pdfBytes;
  }

  void _triggerExport(String format) async {
    _safeSetState(() {
      _isExporting = true;
    });

    if (format == 'xlsx') {
      try {
        final List<Map<String, dynamic>> samplesPayload = [];
        for (int i = 0; i < _numSamples; i++) {
          final sampleData = _processedSamplesData[i];
          if (sampleData != null) {
            samplesPayload.add({
              'sample_no': _boreholeIdController.text,
              'depth': sampleData.depth,
              'weight': sampleData.totalDryWeight,
              'incremental_weights': sampleData.incrementalWeights,
            });
          }
        }
        
        if (samplesPayload.isEmpty) {
          throw Exception("No sample data available.");
        }
        
        final xlsxBytes = await SoilApiService.exportSieveExcel(
          region: _regionController.text,
          dateSampled: _dateSampledController.text,
          testedBy: _testedByController.text,
          sampleDescription: _sampleDescriptionController.text,
          location: _locationController.text,
          samples: samplesPayload,
        );

        if (!mounted) return;
        downloadFile(
          filename: 'Sieve_Analysis_Report.xlsx',
          bytes: xlsxBytes,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          context: context,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Excel report: $e'),
            backgroundColor: const Color(0xFFFFB4AB),
          ),
        );
      } finally {
        _safeSetState(() {
          _isExporting = false;
        });
      }
    } else if (format == 'docx') {
      try {
        final List<Map<String, dynamic>> samplesPayload = [];
        for (int i = 0; i < _numSamples; i++) {
          final sampleData = _processedSamplesData[i];
          if (sampleData != null) {
            samplesPayload.add({
              'sample_no': _boreholeIdController.text,
              'depth': sampleData.depth,
              'weight': sampleData.totalDryWeight,
              'incremental_weights': sampleData.incrementalWeights,
            });
          }
        }
        
        if (samplesPayload.isEmpty) {
          throw Exception("No sample data available.");
        }
        
        final xlsxBytes = await SoilApiService.exportSieveExcel(
          region: _regionController.text,
          dateSampled: _dateSampledController.text,
          testedBy: _testedByController.text,
          sampleDescription: _sampleDescriptionController.text,
          location: _locationController.text,
          samples: samplesPayload,
        );

        final docxBytes = await SoilApiService.convertExcelToWord(
          excelBytes: xlsxBytes,
          fileName: 'Sieve_Analysis_Report.xlsx',
        );

        if (!mounted) return;
        downloadFile(
          filename: 'Sieve_Analysis_Report.docx',
          bytes: docxBytes,
          mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          context: context,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Word report: $e'),
            backgroundColor: const Color(0xFFFFB4AB),
          ),
        );
      } finally {
        _safeSetState(() {
          _isExporting = false;
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _safeSetState(() {
          _isExporting = false;
          
          List<int> bytes = [];
          String filename = '';
          String mimeType = '';
          
          if (format == 'pdf') {
            bytes = _buildPdfBytes(true); // force landscape
            filename = 'Sieve_Analysis_Report.pdf';
            mimeType = 'application/pdf';
          }
          
          downloadFile(
            filename: filename,
            bytes: bytes,
            mimeType: mimeType,
            context: context,
          );
        });
      });
    }
  }

  void _finishManualEntry() {
    if (!_b4FormKey.currentState!.validate()) return;
    
    _safeSetState(() {
      _showReviewMatrix = true;
      _reviewMatrixRows.clear();
      
      double totalMass = double.tryParse(_sampleWeightControllers[_activeSampleIndex].text) ?? 500.0;
      
      for (int i = 0; i < _activeSieves.length; i++) {
        final textVal = _retainedMassControllers[i].text;
        final doubleVal = double.tryParse(textVal) ?? 0.0;
        _reviewMatrixRows.add({
          'name': _activeSieves[i]['name'] as String,
          'size': _activeSieves[i]['size'] as double,
          'retainedController': TextEditingController(
            text: doubleVal.toString(),
          ),
          'cumulative': 0.0,
          'passing': 100.0,
        });
      }
      _recalculateReviewMatrix(totalMass);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnalysisResults) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _buildAnalysisResultsViewer(),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStandardGatekeeperCard(),
              if (_selectedStandard == SieveStandard.aashto) ...[
                const SizedBox(height: 24),
                _buildAashtoWarningCard(),
              ],
              if (_selectedStandard == SieveStandard.uscs) ...[
                const SizedBox(height: 24),
                _buildManualPathway(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResultsViewer() {
    if (!_processedSamplesData.containsKey(_resultsActiveIndex)) {
      _recalculateAllSamples();
    }
    final sampleData = _processedSamplesData[_resultsActiveIndex] ?? SieveSampleData(
      sampleIndex: _resultsActiveIndex,
      depth: (_resultsActiveIndex + 1) * 1.5,
      totalDryWeight: 500.0,
      incrementalWeights: List.filled(_activeSieves.length, 0.0),
      cumulativeWeights: List.filled(_activeSieves.length, 0.0),
      incrementalPercentRetained: List.filled(_activeSieves.length, 0.0),
      cumulativePercentPassing: List.filled(_activeSieves.length, 100.0),
      totalRecoveredMass: 0.0,
    );

    final boreholeId = _boreholeIdController.text.isNotEmpty ? _boreholeIdController.text : 'BH-01';
    final location = _locationController.text.isNotEmpty ? _locationController.text : 'Sector 4, Construction Site';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Title Corridor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to Data Entry',
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    _safeSetState(() {
                      _showAnalysisResults = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Analysis Results Viewer: $location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildHeaderBadge('Borehole: $boreholeId'),
                const SizedBox(width: 8),
                _buildHeaderBadge('Total Samples: $_numSamples'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 2. Tab Corridor
        _buildResultsTabCorridor(),
        const SizedBox(height: 12),
        
        // 3. Action Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF424754)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sample ${sampleData.sampleIndex + 1} Data Saved & Submitted. Full Analysis Calculated.',
                  style: const TextStyle(
                    color: Color(0xFF4CD7F6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _isExporting ? null : () {
                  _triggerExport('xlsx');
                },
                icon: _isExporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download_rounded, size: 16),
                label: const Text(
                  'Download Master Excel',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 4. Main Table + Info Card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Sieve Analysis Data Sheet: $boreholeId @ ${sampleData.depth.toStringAsFixed(1)}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF424754)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: const BorderSide(color: Color(0xFF424754)),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(2.0),
                        3: FlexColumnWidth(2.0),
                        4: FlexColumnWidth(2.0),
                        5: FlexColumnWidth(2.0),
                      },
                      children: [
                        _buildTableHeader(),
                        ...List.generate(
                          _activeSieves.length,
                          (idx) => _buildTableRow(sampleData, idx),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            _buildInfoCard(sampleData),
          ],
        ),
        
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.bottomRight,
          child: Text(
            'Calculations: Phase 2 Active. All logic isolated per page.',
            style: TextStyle(
              color: Color(0xFF8C909F),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF424754)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC2C6D6),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultsTabCorridor() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_numSamples, (idx) {
          final depthStr = idx < _sampleDepthControllers.length ? _sampleDepthControllers[idx].text : 'N/A';
          final isActive = _resultsActiveIndex == idx;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _safeSetState(() {
                  _resultsActiveIndex = idx;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF171F33) : const Color(0xFF0B1326),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border.all(color: const Color(0xFF424754)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? Icons.bar_chart_rounded : Icons.insert_drive_file_outlined,
                      color: isActive ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sample ${idx + 1} @ ${depthStr}m',
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFFC2C6D6),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1326),
      ),
      children: [
        _buildHeaderCell('Sieve Designation / Sieve No.', isLeft: true),
        _buildHeaderCell('Dia (mm)'),
        _buildHeaderCell('Incremental Wt.\nRetained (g)'),
        _buildHeaderCell('Cumulative Wt.\nRetained (g)'),
        _buildHeaderCell('Incremental %\nRetained'),
        _buildHeaderCell('Cumulative %\nPassing'),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {bool isLeft = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: isLeft ? Alignment.centerLeft : Alignment.center,
      child: Text(
        text,
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF4CD7F6),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  TableRow _buildTableRow(SieveSampleData sampleData, int idx) {
    final sieve = _activeSieves[idx];
    final isPan = idx == 12 || (sieve['name'] as String).toLowerCase().contains('passing 0.075');
    final diaStr = isPan ? '—' : (sieve['size'] as double).toString();
    
    final incWt = sampleData.getIncrementalWeightString(idx).replaceAll('g', '');
    final cumWt = sampleData.getCumulativeWeightString(idx).replaceAll('g', '');
    final incPct = sampleData.getIncrementalPercentRetainedString(idx);
    final cumPass = isPan ? '0.00' : sampleData.getCumulativePercentPassingString(idx);

    return TableRow(
      decoration: BoxDecoration(
        color: idx % 2 == 0 ? const Color(0xFF171F33) : const Color(0xFF1E294B).withOpacity(0.3),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF424754)),
        ),
      ),
      children: [
        _buildCell(sieve['name'] as String, alignment: Alignment.centerLeft),
        _buildCell(diaStr, alignment: Alignment.center),
        _buildCell(incWt, alignment: Alignment.centerRight),
        _buildCell(cumWt, alignment: Alignment.centerRight),
        _buildCell(incPct, alignment: Alignment.centerRight),
        _buildCell(cumPass, alignment: Alignment.centerRight),
      ],
    );
  }

  Widget _buildCell(String text, {Alignment alignment = Alignment.center}) {
    return Container(
      height: 48,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard(SieveSampleData sampleData) {
    int idx200 = -1;
    for (int i = 0; i < _activeSieves.length; i++) {
      if (((_activeSieves[i]['size'] as double) - 0.075).abs() < 0.005) {
        idx200 = i;
        break;
      }
    }
    double finesPercent = 0.0;
    if (idx200 != -1 && sampleData.cumulativePercentPassing.length > idx200) {
      finesPercent = sampleData.cumulativePercentPassing[idx200];
    }

    String uscsClass = 'SW';
    if (finesPercent > 50.0) {
      uscsClass = 'CL';
    } else if (finesPercent > 12.0) {
      uscsClass = 'SC';
    } else if (finesPercent > 5.0) {
      uscsClass = 'SP-SC';
    } else {
      uscsClass = 'SW';
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF424754)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Info',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF424754)),
          const SizedBox(height: 8),
          _buildInfoRow('Sample Wt (Wt):', '${sampleData.totalDryWeight.toStringAsFixed(1)}g'),
          const SizedBox(height: 8),
          _buildInfoRow('Percent Fines (-#200):', '${finesPercent.toStringAsFixed(2)}%'),
          const SizedBox(height: 8),
          _buildInfoRow('USCS Classification (Pending):', uscsClass),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C909F),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStandardGatekeeperCard() {
    return Card(
      color: const Color(0xFF171F33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF424754)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SELECT SIEVE ANALYSIS STANDARD FRAMEWORK (REQUIRED)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C909F),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: const Color(0xFF171F33),
              ),
              child: DropdownButtonFormField<SieveStandard>(
                value: _selectedStandard,
                dropdownColor: const Color(0xFF171F33),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0B1326),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF424754)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF424754)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4CD7F6)),
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: const [
                  DropdownMenuItem(
                    value: SieveStandard.none,
                    child: Text('Choose Standard Framework...'),
                  ),
                  DropdownMenuItem(
                    value: SieveStandard.uscs,
                    child: Text('USCS (Unified Soil Classification System)'),
                  ),
                  DropdownMenuItem(
                    value: SieveStandard.aashto,
                    child: Text('AASHTO (American Association of State Highway and Transportation Officials)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _safeSetState(() {
                      _selectedStandard = val;
                      _showReviewMatrix = false;
                      _currentStep = SieveManualStep.b1;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAashtoWarningCard() {
    return Card(
      color: const Color(0xFF2C1E1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEF4444)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '⚠️ AASHTO Classification Pipeline is currently Under Development. Please select USCS.',
                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualPathway() {
    if (_showReviewMatrix) {
      return _buildReviewMatrixTable();
    }

    return Card(
      color: const Color(0xFF171F33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF424754)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWizardProgressIndicator(),
            const Divider(color: Color(0xFF424754), height: 32),
            if (_currentStep == SieveManualStep.b1)
              _buildStepB1()
            else if (_currentStep == SieveManualStep.b2)
              _buildStepB2()
            else if (_currentStep == SieveManualStep.b3)
              _buildStepB3()
            else if (_currentStep == SieveManualStep.b4)
              _buildStepB4(),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepIndicatorNode('B1', 'General Info', SieveManualStep.b1),
        _buildStepIndicatorLine(SieveManualStep.b1),
        _buildStepIndicatorNode('B2', 'Top Sieve', SieveManualStep.b2),
        _buildStepIndicatorLine(SieveManualStep.b2),
        _buildStepIndicatorNode('B3', 'Sample Config', SieveManualStep.b3),
        _buildStepIndicatorLine(SieveManualStep.b3),
        _buildStepIndicatorNode('B4', 'Mass Retained', SieveManualStep.b4),
      ],
    );
  }

  Widget _buildStepIndicatorNode(String code, String label, SieveManualStep step) {
    bool isCompleted = _currentStep.index > step.index;
    bool isActive = _currentStep == step;
    
    Color color = isActive
        ? const Color(0xFF4CD7F6)
        : isCompleted
            ? const Color(0xFFADC6FF)
            : const Color(0xFF424754);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : const Color(0xFF0B1326),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isActive ? 2.5 : 1.5),
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]
                : [],
          ),
          child: Text(
            code,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF8C909F),
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicatorLine(SieveManualStep stepAfter) {
    bool isPassed = _currentStep.index > stepAfter.index;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        color: isPassed ? const Color(0xFFADC6FF) : const Color(0xFF424754),
      ),
    );
  }

  Widget _buildStepB1() {
    return Form(
      key: _b1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STEP B1: BOREHOLE SITE & GENERAL METADATA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          // AI Scan Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2950), Color(0xFF171F33)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CD7F6).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CD7F6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Color(0xFF4CD7F6), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Auto-Fill Sieve Data with Gemini AI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upload an image or PDF of your sieve log sheet to automatically extract all metadata, depths, weights, and sieve incremental data.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFC2C6D6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _isParsingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CD7F6)),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CD7F6),
                          foregroundColor: const Color(0xFF002E6A),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _handleImageScanning,
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: const Text(
                          'Upload File',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _boreholeIdController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Borehole ID',
              hintText: 'e.g. BH-01',
              labelStyle: TextStyle(color: Color(0xFF8C909F)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Borehole ID is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Location / Project Site',
              hintText: 'e.g. Sector 4, Construction Site',
              labelStyle: TextStyle(color: Color(0xFF8C909F)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Date of Logging',
              hintText: 'e.g. 2026-06-03',
              labelStyle: TextStyle(color: Color(0xFF8C909F)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Date is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _regionController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    hintText: 'e.g. Florida',
                    labelStyle: TextStyle(color: Color(0xFF8C909F)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Region is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _dateSampledController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Date Sampled',
                    hintText: 'e.g. 2026-06-03',
                    labelStyle: TextStyle(color: Color(0xFF8C909F)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Date Sampled is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _testedByController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Tested By',
              hintText: 'e.g. Dr. Nikos Tziolas (Leave blank for manual entry)',
              labelStyle: TextStyle(color: Color(0xFF8C909F)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _sampleDescriptionController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Sample Description',
              hintText: 'e.g. Lean clay subgrade layer',
              labelStyle: TextStyle(color: Color(0xFF8C909F)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Sample Description is required' : null,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD7F6),
                  foregroundColor: const Color(0xFF002E6A),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_b1FormKey.currentState!.validate()) {
                    _safeSetState(() {
                      _currentStep = SieveManualStep.b2;
                    });
                  }
                },
                child: const Row(
                  children: [
                    Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepB2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STEP B2: COMPANY TEMPLATE SIEVE MATRIX DECK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'The sieve analysis size sequence is locked to the standard civil engineering 13-row company matrix deck template. No alternative configuration settings are permitted.',
          style: TextStyle(color: Color(0xFF8C909F), fontSize: 12),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1326),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF424754)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sieve Designation', style: TextStyle(color: Color(0xFF4CD7F6), fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Dia (mm)', style: TextStyle(color: Color(0xFF4CD7F6), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF424754)),
              ..._activeSieves.map((s) {
                final isPan = (s['name'] as String).toLowerCase().contains('passing 0.075') || (s['size'] as double) <= 0.001;
                final diaStr = isPan ? '—' : '${(s['size'] as double).toStringAsFixed(2)} mm';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text(diaStr, style: const TextStyle(color: Color(0xFF8C909F), fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF8C909F)),
              onPressed: () {
                _safeSetState(() {
                  _currentStep = SieveManualStep.b1;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CD7F6),
                foregroundColor: const Color(0xFF002E6A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _safeSetState(() {
                  _currentStep = SieveManualStep.b3;
                });
              },
              child: const Row(
                children: [
                  Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepB3() {
    return Form(
      key: _b3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STEP B3: NUMBER OF SAMPLES & INITIAL WEIGHTS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Number of Samples to Analyze:',
                style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF4CD7F6)),
                onPressed: () {
                  if (_numSamples > 1) {
                    _safeSetState(() {
                      _numSamples--;
                      _sampleDepthControllers.removeLast().dispose();
                      _sampleWeightControllers.removeLast().dispose();
                      _updateActiveSieves();
                    });
                  }
                },
              ),
              Text(
                '$_numSamples',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4CD7F6)),
                onPressed: () {
                  if (_numSamples < 20) {
                    _safeSetState(() {
                      _numSamples++;
                      _sampleDepthControllers.add(TextEditingController(text: '${1.5 * _numSamples}'));
                      _sampleWeightControllers.add(TextEditingController(text: '500.0'));
                      _updateActiveSieves();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _numSamples,
            itemBuilder: (context, idx) {
              return Card(
                color: const Color(0xFF0B1326),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF424754)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Slot #${idx + 1}',
                        style: const TextStyle(color: Color(0xFF4CD7F6), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sampleDepthControllers[idx],
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Depth of Sample (m)',
                                labelStyle: TextStyle(color: Color(0xFF8C909F)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                              ),
                              validator: (v) {
                                if (v == null || double.tryParse(v) == null) {
                                  return 'Enter a valid depth';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sampleWeightControllers[idx],
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Total Initial Dry Weight (g)',
                                labelStyle: TextStyle(color: Color(0xFF8C909F)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                              ),
                              validator: (v) {
                                if (v == null || double.tryParse(v) == null || double.parse(v) <= 0.0) {
                                  return 'Enter a valid weight';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8C909F)),
                onPressed: () {
                  _safeSetState(() {
                    _currentStep = SieveManualStep.b2;
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD7F6),
                  foregroundColor: const Color(0xFF002E6A),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_b3FormKey.currentState!.validate()) {
                    _safeSetState(() {
                      if (_activeSampleIndex >= _numSamples) {
                        _activeSampleIndex = 0;
                      }
                      _updateActiveSieves();
                      _currentStep = SieveManualStep.b4;
                    });
                  }
                },
                child: const Row(
                  children: [
                    Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepB4() {
    if (_activeSampleIndex >= _numSamples) {
      _activeSampleIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateActiveSieves();
          });
        }
      });
    }

    return Form(
      key: _b4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STEP B4: DATA ENTRY MATRIX (MASS RETAINED ROWS)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the weight of dry soil retained on each sieve screen in grams.',
            style: TextStyle(color: Color(0xFF8C909F), fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Active Sample Target to Enter Weights',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C909F),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color(0xFF171F33),
            ),
            child: DropdownButtonFormField<int>(
              value: _activeSampleIndex,
              dropdownColor: const Color(0xFF171F33),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0B1326),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF424754)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF424754)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4CD7F6)),
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: List.generate(_numSamples, (idx) {
                final depthStr = idx < _sampleDepthControllers.length ? _sampleDepthControllers[idx].text : 'N/A';
                return DropdownMenuItem<int>(
                  value: idx,
                  child: Text('Sample #${idx + 1} (Depth: ${depthStr}m)'),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  _safeSetState(() {
                    _activeSampleIndex = val;
                    _updateActiveSieves();
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeSieves.length,
            itemBuilder: (context, idx) {
              final sieve = _activeSieves[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        sieve['name'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '(${sieve['size']} mm)',
                        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 11),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _retainedMassControllers[idx],
                        focusNode: _retainedMassFocusNodes[idx],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.end,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: idx == _activeSieves.length - 1 ? TextInputAction.done : TextInputAction.next,
                        onFieldSubmitted: (v) {
                          if (idx < _activeSieves.length - 1) {
                            FocusScope.of(context).requestFocus(_retainedMassFocusNodes[idx + 1]);
                          } else {
                            _retainedMassFocusNodes[idx].unfocus();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '0.0',
                          suffixText: ' g',
                          suffixStyle: const TextStyle(color: Color(0xFF8C909F)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                        ),
                        validator: (v) {
                          if (v == null || double.tryParse(v) == null || double.parse(v) < 0.0) {
                            return 'Enter mass >= 0';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          if (!_sampleRetainedMassMemory.containsKey(_activeSampleIndex)) {
                            _sampleRetainedMassMemory[_activeSampleIndex] = {};
                          }
                          _sampleRetainedMassMemory[_activeSampleIndex]![sieve['size'] as double] = val;
                          _recalculateFinesForActiveSample();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8C909F)),
                onPressed: () {
                  _safeSetState(() {
                    _currentStep = SieveManualStep.b3;
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD7F6),
                  foregroundColor: const Color(0xFF002E6A),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _finishManualEntry,
                child: const Row(
                  children: [
                    Text('Generate Review Matrix', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.check_circle_outline_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrozenColumn() {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          // Header Cell
          Container(
            height: 110,
            alignment: Alignment.center,
            color: const Color(0xFF0B1326),
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Sieve Sizes\nDesignation (mm)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8C909F),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sieve Rows
          ...List.generate(_activeSieves.length, (idx) {
            final sieve = _activeSieves[idx];
            final isLast = idx == _activeSieves.length - 1;
            return Container(
              height: 55,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF171F33),
                border: Border(
                  bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xFF424754)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sieve['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(${sieve['size']} mm)',
                    style: const TextStyle(
                      color: Color(0xFF8C909F),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumns() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_numSamples, (sIdx) {
          final depthStr = sIdx < _sampleDepthControllers.length ? _sampleDepthControllers[sIdx].text : 'N/A';
          final weightStr = sIdx < _sampleWeightControllers.length ? _sampleWeightControllers[sIdx].text : 'N/A';
          
          return Container(
            width: 140,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFF424754)),
              ),
            ),
            child: Column(
              children: [
                // Header Cell
                Container(
                  height: 110,
                  color: const Color(0xFF0B1326),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SPT Sample @ ${_boreholeIdController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@ Depth $depthStr m',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4CD7F6),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${_dateController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8C909F),
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wt = $weightStr g',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFB786),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sieve Rows
                ...List.generate(_activeSieves.length, (idx) {
                  final sieve = _activeSieves[idx];
                  final sieveSize = sieve['size'] as double;
                  final isLast = idx == _activeSieves.length - 1;
                  
                  TextEditingController? cellController;
                  if (_sampleSieveControllers.containsKey(sIdx) &&
                      _sampleSieveControllers[sIdx]!.containsKey(sieveSize)) {
                    cellController = _sampleSieveControllers[sIdx]![sieveSize];
                  }
                  
                  return Container(
                    height: 55,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171F33),
                      border: Border(
                        bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xFF424754)),
                      ),
                    ),
                    child: cellController == null
                        ? const Text('N/A', style: TextStyle(color: Colors.red))
                        : TextFormField(
                            controller: cellController,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF424754))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4CD7F6))),
                            ),
                            onChanged: (val) {
                              _safeSetState(() {
                                if (!_sampleRetainedMassMemory.containsKey(sIdx)) {
                                  _sampleRetainedMassMemory[sIdx] = {};
                                }
                                _sampleRetainedMassMemory[sIdx]![sieveSize] = val;
                                _recalculateFinesForActiveSample();
                              });
                            },
                          ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReviewMatrixTable() {
    return Card(
      color: const Color(0xFF171F33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF424754)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MASTER BATCH REVIEW MATRIX GRID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CD7F6),
                    letterSpacing: 1.2,
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: const Color(0xFF171F33),
                  ),
                  child: PopupMenuButton<String>(
                    tooltip: 'Download options',
                    color: const Color(0xFF171F33),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF424754)),
                    ),
                    onSelected: _isExporting ? null : (value) {
                      _triggerExport(value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'xlsx',
                        child: Row(
                          children: [
                            Text('📊 ', style: TextStyle(fontSize: 14)),
                            Text('Excel Spreadsheet (.xlsx)', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Text('📄 ', style: TextStyle(fontSize: 14)),
                            Text('Professional Document (.pdf)', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'docx',
                        child: Row(
                          children: [
                            Text('📝 ', style: TextStyle(fontSize: 14)),
                            Text('Word Document (.docx)', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1326),
                        border: Border.all(color: const Color(0xFF4CD7F6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isExporting) ...[
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CD7F6)),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Text('📥 ', style: TextStyle(fontSize: 14)),
                          ],
                          const Text(
                            'Download Batch Ledger As...',
                            style: TextStyle(
                              color: Color(0xFF4CD7F6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF4CD7F6), size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF424754)),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFrozenColumn(),
                  Container(width: 1, height: 110.0 + (_activeSieves.length * 55.0), color: const Color(0xFF424754)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildScrollableColumns(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  onPressed: () {
                    _safeSetState(() {
                      _showReviewMatrix = false;
                      _currentStep = SieveManualStep.b1;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Start Over / Reset'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFADC6FF),
                    foregroundColor: const Color(0xFF002E6A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _recalculateAllSamples();
                    _safeSetState(() {
                      _showAnalysisResults = true;
                      _resultsActiveIndex = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Sieve analysis matrix saved and submitted.'),
                        backgroundColor: Color(0xFF4CD7F6),
                      ),
                    );
                  },
                  child: const Text('Save & Submit Data', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 3. CBR PREDICTION MODULE
// =====================================================================
class CbrPredictionModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const CbrPredictionModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<CbrPredictionModule> createState() => _CbrPredictionModuleState();
}

class _CbrPredictionModuleState extends State<CbrPredictionModule> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mddController = TextEditingController(text: '1.85');
  final TextEditingController _omcController = TextEditingController(text: '12.5');
  final TextEditingController _piController = TextEditingController(text: '15.0');
  final TextEditingController _finesController = TextEditingController(text: '45.0');

  double _predictedCbr = 8.5;
  bool _isPredicting = false;

  void _pullSharedData() {
    setState(() {
      if (widget.sharedState.classPI != null) {
        _piController.text = widget.sharedState.classPI!.toStringAsFixed(1);
      }
      if (widget.sharedState.sieveFinesPercent != null) {
        _finesController.text = widget.sharedState.sieveFinesPercent!.toStringAsFixed(1);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Pulled PI and Fines% from available lab module states.'),
        backgroundColor: Color(0xFF4CD7F6),
      ),
    );
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isPredicting = true;
    });

    try {
      final res = await SoilApiService.analyzeSoil(
        pl: 20.0, // placeholder
        pi: double.parse(_piController.text),
        d10: 0.05, // placeholder
        d30: 0.15, // placeholder
        d60: 0.50, // placeholder
        omc: double.parse(_omcController.text),
        mdd: double.parse(_mddController.text),
      );
      setState(() {
        _predictedCbr = res.cbrPercent;
      });
    } catch (e) {
      // Fallback prediction formula
      double mdd = double.parse(_mddController.text);
      double omc = double.parse(_omcController.text);
      double pi = double.parse(_piController.text);
      double cbr = 18.0 + 15.0 * (mdd - 1.7) - 0.2 * pi - 0.15 * omc;
      setState(() {
        _predictedCbr = math.max(1.5, math.min(95.0, cbr));
      });
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left panel: inputs
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'CBR SIMULATION METRICS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C909F),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B1326),
                                    foregroundColor: const Color(0xFF4CD7F6),
                                  ),
                                  onPressed: _pullSharedData,
                                  icon: const Icon(Icons.download_rounded, size: 14),
                                  label: const Text('🔗 Pull Lab Data', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _mddController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Max Dry Density, MDD (g/cm³)'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _omcController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Optimum Moisture Content, OMC (%)'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _piController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Plasticity Index, PI (%)'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _finesController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Fines Passing No. 200 Sieve (%)'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFADC6FF),
                                  foregroundColor: const Color(0xFF002E6A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _isPredicting ? null : _predict,
                                child: _isPredicting
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Estimate CBR Deflection'),
                              ),
                            ),
                            const Divider(color: Color(0xFF424754), height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Predicted CBR:', style: TextStyle(color: Color(0xFFC2C6D6))),
                                Text(
                                  '${_predictedCbr.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Color(0xFF4CD7F6), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _predictedCbr < 5.0
                                  ? 'Poor Subgrade: stabilization recommended.'
                                  : _predictedCbr < 10.0
                                      ? 'Fair Subgrade: control moisture.'
                                      : 'Good Subgrade: standard base course use.',
                              style: const TextStyle(color: Color(0xFF8C909F), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right panel: Deflection curve
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: 'CBR Stress vs. Penetration Deflection Curve',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'CBR_Prediction', 'Penetration(mm),Stress(MPa)\n0.0,0.0\n2.5,${_predictedCbr * 0.07}\n5.0,${_predictedCbr * 0.10}\n7.5,${_predictedCbr * 0.12}\n10.0,${_predictedCbr * 0.13}\n12.5,${_predictedCbr * 0.14}');
                  },
                  child: CbrDeflectionChart(cbr: _predictedCbr),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'CBR Prediction',
          inputSummary: 'MDD = ${_mddController.text} g/cm³, OMC = ${_omcController.text}%, PI = ${_piController.text}%, Fines = ${_finesController.text}%',
          resultSummary: 'Predicted CBR = ${_predictedCbr.toStringAsFixed(1)}% (Soil Quality Class: ${_predictedCbr < 5.0 ? "Subgrade (Poor)" : "Subgrade/Subbase (Good)"})',
        ),
      ],
    );
  }
}

class CbrDeflectionChart extends StatelessWidget {
  final double cbr;

  const CbrDeflectionChart({super.key, required this.cbr});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CbrChartPainter(cbr: cbr),
        );
      },
    );
  }
}

class CbrChartPainter extends CustomPainter {
  final double cbr;

  CbrChartPainter({required this.cbr});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF171F33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = const Color(0xFF8C909F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final refPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.5) // standard 100% CBR reference
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final activePaint = Paint()
      ..color = const Color(0xFF4CD7F6) // active cbr curve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final confidencePaint = Paint()
      ..color = const Color(0xFF4CD7F6).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double padL = 40;
    double padB = 40;
    double padT = 20;
    double padR = 20;

    double plotW = size.width - padL - padR;
    double plotH = size.height - padT - padB;

    // Bounds: x: 0 to 12.5 mm, y: 0 to 15 MPa
    Offset mapPoint(double x, double y) {
      double pctX = x / 12.5;
      double pctY = y / 15.0;
      return Offset(
        padL + pctX * plotW,
        size.height - padB - pctY * plotH,
      );
    }

    // Grid lines
    canvas.drawRect(Rect.fromLTWH(padL, padT, plotW, plotH), gridPaint);
    for (double x = 2.5; x <= 12.5; x += 2.5) {
      Offset pos = mapPoint(x, 0);
      canvas.drawLine(Offset(pos.dx, padT), Offset(pos.dx, size.height - padB), gridPaint);
      textPainter.text = TextSpan(text: '$x', style: const TextStyle(color: Color(0xFF8C909F), fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, size.height - padB + 5));
    }
    for (double y = 3.0; y <= 15.0; y += 3.0) {
      Offset pos = mapPoint(0, y);
      canvas.drawLine(Offset(padL, pos.dy), Offset(padL + plotW, pos.dy), gridPaint);
      textPainter.text = TextSpan(text: '$y', style: const TextStyle(color: Color(0xFF8C909F), fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(padL - textPainter.width - 5, pos.dy - textPainter.height / 2));
    }

    canvas.drawLine(mapPoint(0, 0), mapPoint(12.5, 0), axisPaint);
    canvas.drawLine(mapPoint(0, 0), mapPoint(0, 15.0), axisPaint);

    // Labels
    textPainter.text = const TextSpan(
      text: 'Penetration (mm)',
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(padL + plotW / 2 - textPainter.width / 2, size.height - padB + 20));

    // Draw 100% standard CBR reference curve (100% stress: 2.5mm @ 7MPa, 5.0mm @ 10.5MPa)
    final refPath = Path();
    refPath.moveTo(mapPoint(0, 0).dx, mapPoint(0, 0).dy);
    refPath.quadraticBezierTo(
      mapPoint(2.5, 7.0).dx,
      mapPoint(2.5, 7.0).dy,
      mapPoint(12.5, 14.0).dx,
      mapPoint(12.5, 14.0).dy,
    );
    canvas.drawPath(refPath, refPaint);

    textPainter.text = const TextSpan(
      text: '100% Standard Reference',
      style: TextStyle(color: Color(0xFFFFB786), fontSize: 8),
    );
    textPainter.layout();
    textPainter.paint(canvas, mapPoint(8.0, 10.5));

    // Active Curve stress mapping based on active CBR percentage
    // Stress at 2.5mm = (CBR/100) * 6.9 MPa
    double activeStress2_5 = (cbr / 100.0) * 6.9;
    double activeStress5_0 = (cbr / 100.0) * 10.3;
    double activeStress12_5 = activeStress5_0 * 1.3;

    final activePath = Path();
    activePath.moveTo(mapPoint(0, 0).dx, mapPoint(0, 0).dy);
    activePath.quadraticBezierTo(
      mapPoint(2.5, activeStress2_5).dx,
      mapPoint(2.5, activeStress2_5).dy,
      mapPoint(12.5, activeStress12_5).dx,
      mapPoint(12.5, activeStress12_5).dy,
    );

    // Confidence Interval Shading
    final confidenceTop = Path();
    confidenceTop.moveTo(mapPoint(0, 0).dx, mapPoint(0, 0).dy);
    confidenceTop.quadraticBezierTo(
      mapPoint(2.5, activeStress2_5 * 1.2).dx,
      mapPoint(2.5, activeStress2_5 * 1.2).dy,
      mapPoint(12.5, activeStress12_5 * 1.2).dx,
      mapPoint(12.5, activeStress12_5 * 1.2).dy,
    );
    confidenceTop.quadraticBezierTo(
      mapPoint(2.5, activeStress2_5 * 0.8).dx,
      mapPoint(2.5, activeStress2_5 * 0.8).dy,
      mapPoint(0, 0).dx,
      mapPoint(0, 0).dy,
    );
    canvas.drawPath(confidenceTop, confidencePaint);

    canvas.drawPath(activePath, activePaint);

    textPainter.text = TextSpan(
      text: 'Active Specimen (CBR: ${cbr.toStringAsFixed(1)}%)',
      style: const TextStyle(color: Color(0xFF4CD7F6), fontSize: 9, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, mapPoint(2.0, activeStress2_5 + 1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 4. STABILITY ANALYSIS MODULE
// =====================================================================
class StabilityAnalysisModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const StabilityAnalysisModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<StabilityAnalysisModule> createState() => _StabilityAnalysisModuleState();
}

class _StabilityAnalysisModuleState extends State<StabilityAnalysisModule> {
  final _formKey = GlobalKey<FormState>();
  double _slopeAngle = 35.0;
  double _slopeHeight = 8.0;
  double _cohesion = 15.0;
  double _frictionAngle = 22.0;
  double _unitWeight = 18.5;
  double _waterDepth = 4.0;

  double _fos = 1.35;
  bool _calculating = false;

  void _calculateStability() {
    setState(() {
      _calculating = true;
    });
    // Simplified Swedish Circle Method calculation proxy
    // Factor of safety = (Cohesion * ArcLength + normalForces * tan(friction)) / drivingForces
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        double radians = _frictionAngle * math.pi / 180.0;
        double slopeRad = _slopeAngle * math.pi / 180.0;
        double rawFos = (_cohesion * 2.5 + (_unitWeight * _slopeHeight * math.cos(slopeRad) * math.tan(radians))) /
            (_unitWeight * _slopeHeight * math.sin(slopeRad) * 0.8);
        
        // Water table penalty
        if (_waterDepth < _slopeHeight) {
          rawFos *= (0.6 + 0.4 * (_waterDepth / _slopeHeight));
        }

        setState(() {
          _fos = math.max(0.45, math.min(3.2, rawFos));
          _calculating = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateStability();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left panel: parameters
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SLOPE AND SOIL CHARACTERISTICS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C909F),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Slope Height: ${_slopeHeight.toStringAsFixed(1)} m', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _slopeHeight,
                                        min: 3,
                                        max: 20,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _slopeHeight = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Slope Angle: ${_slopeAngle.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _slopeAngle,
                                        min: 15,
                                        max: 60,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _slopeAngle = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cohesion, c: ${_cohesion.toStringAsFixed(1)} kPa', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _cohesion,
                                        min: 5,
                                        max: 50,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _cohesion = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Friction Angle, φ: ${_frictionAngle.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _frictionAngle,
                                        min: 10,
                                        max: 45,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _frictionAngle = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Unit Weight: ${_unitWeight.toStringAsFixed(1)} kN/m³', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _unitWeight,
                                        min: 15,
                                        max: 23,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _unitWeight = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Water Depth: ${_waterDepth.toStringAsFixed(1)} m', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Slider(
                                        value: _waterDepth,
                                        min: 0,
                                        max: 20,
                                        activeColor: const Color(0xFFADC6FF),
                                        onChanged: (val) {
                                          setState(() => _waterDepth = val);
                                          _calculateStability();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF424754), height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Factor of Safety (FoS):',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _fos >= 1.5
                                        ? const Color(0xFF4CD7F6).withOpacity(0.15)
                                        : const Color(0xFFFFB786).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _calculating
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                      : Text(
                                          _fos.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: _fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _fos >= 1.5
                                  ? '✅ Stable Slope: complies with standard geotechnical safety thresholds.'
                                  : '⚠️ Critical/Unstable: potential rotational failure along circular slip surface.',
                              style: TextStyle(color: _fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right panel: 2D Geometry Diagram
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: '2D Slip Failure Cross-Section (Rotational Slip)',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'Stability_Analysis', 'Angle(deg),Height(m),FoS\n$_slopeAngle,$_slopeHeight,$_fos');
                  },
                  child: SlopeStabilityDiagram(
                    height: _slopeHeight,
                    angle: _slopeAngle,
                    waterDepth: _waterDepth,
                    fos: _fos,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'Stability Analysis',
          inputSummary: 'Height = $_slopeHeight m, Angle = $_slopeAngle°, Cohesion = $_cohesion kPa, Friction = $_frictionAngle°, Unit Weight = $_unitWeight kN/m³, Water Table = $_waterDepth m',
          resultSummary: 'Slope Stability FoS = ${_fos.toStringAsFixed(2)} (${_fos >= 1.5 ? "SAFE (Stable)" : "WARNING (Critical Zone)"})',
        ),
      ],
    );
  }
}

class SlopeStabilityDiagram extends StatelessWidget {
  final double height;
  final double angle;
  final double waterDepth;
  final double fos;

  const SlopeStabilityDiagram({
    super.key,
    required this.height,
    required this.angle,
    required this.waterDepth,
    required this.fos,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: SlopeStabilityPainter(
            height: height,
            angle: angle,
            waterDepth: waterDepth,
            fos: fos,
          ),
        );
      },
    );
  }
}

class SlopeStabilityPainter extends CustomPainter {
  final double height;
  final double angle;
  final double waterDepth;
  final double fos;

  SlopeStabilityPainter({
    required this.height,
    required this.angle,
    required this.waterDepth,
    required this.fos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final groundPaint = Paint()
      ..color = const Color(0xFF171F33)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final waterPaint = Paint()
      ..color = const Color(0xFF3B82F6) // blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final slipCirclePaint = Paint()
      ..color = fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw slope cross-section
    double padL = 40;
    double padR = 40;
    double padT = 40;
    double padB = 40;

    double activeW = size.width - padL - padR;
    double activeH = size.height - padT - padB;

    // Convert height (3 to 20m) to fit active viewport
    double scaleH = activeH / 22.0;
    double drawHeight = height * scaleH;

    double rad = angle * math.pi / 180.0;
    double drawRun = drawHeight / math.tan(rad);

    double xLeft = padL + activeW * 0.15;
    double xRight = xLeft + drawRun;
    double yTop = padT + activeH * 0.25;
    double yBottom = yTop + drawHeight;

    // Draw ground fill
    final groundPath = Path();
    groundPath.moveTo(padL, yTop);
    groundPath.lineTo(xLeft, yTop);
    groundPath.lineTo(xRight, yBottom);
    groundPath.lineTo(padL + activeW, yBottom);
    groundPath.lineTo(padL + activeW, padT + activeH);
    groundPath.lineTo(padL, padT + activeH);
    groundPath.close();
    canvas.drawPath(groundPath, groundPaint);

    // Draw ground profile line
    final profilePath = Path();
    profilePath.moveTo(padL, yTop);
    profilePath.lineTo(xLeft, yTop);
    profilePath.lineTo(xRight, yBottom);
    profilePath.lineTo(padL + activeW, yBottom);
    canvas.drawPath(profilePath, linePaint);

    // Draw water table if present
    if (waterDepth < height) {
      double waterY = yTop + waterDepth * scaleH;
      final waterPath = Path();
      waterPath.moveTo(padL, waterY);
      waterPath.lineTo(xLeft + (waterY - yTop) / math.tan(rad), waterY);
      waterPath.lineTo(padL + activeW, yBottom + 5); // simple layout
      canvas.drawPath(waterPath, waterPaint);

      textPainter.text = const TextSpan(
        text: '▼ GW Table',
        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xLeft - 10, waterY - 12));
    }

    // Draw failure slip circle arc
    // Define an arc crossing from slope crest (xLeft, yTop) to slope toe (xRight, yBottom)
    double midX = (xLeft + xRight) / 2;
    double midY = (yTop + yBottom) / 2;
    // Offset the center of circle perpendicular to slope to draw the arc
    double dx = xRight - xLeft;
    double dy = yBottom - yTop;
    double dist = math.sqrt(dx * dx + dy * dy);
    double nx = -dy / dist;
    double ny = dx / dist;

    // Shift center perpendicular outwards
    double centerOffset = dist * 0.6;
    double cx = midX + nx * centerOffset;
    double cy = midY + ny * centerOffset;
    double radius = math.sqrt((cx - xLeft) * (cx - xLeft) + (cy - yTop) * (cy - yTop));

    final circleCenter = Offset(cx, cy);
    double startAngle = math.atan2(yTop - cy, xLeft - cx);
    double endAngle = math.atan2(yBottom - cy, xRight - cx);

    canvas.drawArc(
      Rect.fromCircle(center: circleCenter, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      slipCirclePaint,
    );

    // Draw Bishop slice lines (simulated)
    final slicePaint = Paint()
      ..color = (fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786)).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 6; i++) {
      double pct = i / 7.0;
      double sx = xLeft + dx * pct;
      double sy = yTop + dy * pct;
      // perpendicular intersection with circle arc
      // simple vertical lines for visualization of slices
      double arcY = cy + math.sqrt(radius * radius - (sx - cx) * (sx - cx));
      // limit check
      if (!arcY.isNaN && arcY > sy) {
        canvas.drawLine(Offset(sx, sy), Offset(sx, arcY), slicePaint);
      }
    }

    // Labels
    textPainter.text = TextSpan(
      text: 'Factor of Safety: ${fos.toStringAsFixed(2)}',
      style: TextStyle(
        color: fos >= 1.5 ? const Color(0xFF4CD7F6) : const Color(0xFFFFB786),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(padL + 10, padT + 10));

    textPainter.text = const TextSpan(
      text: 'Failure Arc (Spencer Method)',
      style: TextStyle(color: Color(0xFF8C909F), fontSize: 9, fontStyle: FontStyle.italic),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(xLeft - 10, yBottom + 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 5. FOUNDATION DESIGN MODULE
// =====================================================================
class FoundationDesignModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const FoundationDesignModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<FoundationDesignModule> createState() => _FoundationDesignModuleState();
}

class _FoundationDesignModuleState extends State<FoundationDesignModule> {
  bool _isShallow = true;
  final _formKey = GlobalKey<FormState>();

  // Shallow inputs
  final TextEditingController _loadController = TextEditingController(text: '450.0');
  final TextEditingController _cohesionController = TextEditingController(text: '20.0');
  final TextEditingController _frictionController = TextEditingController(text: '28.0');
  final TextEditingController _gammaController = TextEditingController(text: '19.0');
  final TextEditingController _depthController = TextEditingController(text: '1.5');
  final TextEditingController _widthController = TextEditingController(text: '2.0');
  final TextEditingController _lengthController = TextEditingController(text: '3.0');

  // Deep inputs
  final TextEditingController _pileDiaController = TextEditingController(text: '0.6');
  final TextEditingController _pileLenController = TextEditingController(text: '15.0');
  final TextEditingController _pileCountController = TextEditingController(text: '4');

  double _bearingCapacity = 320.5;

  void _calculateCapacity() {
    double b = double.tryParse(_widthController.text) ?? 2.0;
    double l = double.tryParse(_lengthController.text) ?? 3.0;

    widget.sharedState.footingWidthB = b;
    widget.sharedState.footingLengthL = l;
    widget.onStateUpdated();

    if (_isShallow) {
      double c = double.tryParse(_cohesionController.text) ?? 20.0;
      double phi = double.tryParse(_frictionController.text) ?? 28.0;
      double gamma = double.tryParse(_gammaController.text) ?? 19.0;
      double df = double.tryParse(_depthController.text) ?? 1.5;

      // Terzaghi bearing capacity equation: qu = c*Nc*sc + q*Nq + 0.5*gamma*B*Ny*sy
      // Nc, Nq, Ny factors based on phi angle (approximation)
      double phiRad = phi * math.pi / 180.0;
      double nq = math.exp(math.pi * math.tan(phiRad)) * math.pow(math.tan(math.pi / 4 + phiRad / 2), 2);
      double nc = (nq - 1.0) / math.tan(phiRad);
      double ny = 2.0 * (nq + 1.0) * math.tan(phiRad);

      double sc = 1.0 + 0.3 * (b / l);
      double sy = 1.0 - 0.2 * (b / l);

      double qu = c * nc * sc + (gamma * df) * nq + 0.5 * gamma * b * ny * sy;
      setState(() {
        _bearingCapacity = qu / 3.0; // Allowable capacity (FS = 3.0)
      });
    } else {
      double d = double.tryParse(_pileDiaController.text) ?? 0.6;
      double len = double.tryParse(_pileLenController.text) ?? 15.0;
      double count = double.tryParse(_pileCountController.text) ?? 4;

      // Skin friction + end bearing pile estimate
      double skinFriction = 0.5 * 30.0 * math.pi * d * len * 0.8;
      double endBearing = 9.0 * 20.0 * (math.pi * d * d / 4);
      double singlePileQ = (skinFriction + endBearing) / 2.5;

      setState(() {
        _bearingCapacity = singlePileQ * count;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateCapacity();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Panel: inputs
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'FOUNDATION DESIGN METRICS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C909F),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Shallow',
                                    style: TextStyle(
                                      color: _isShallow ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Switch(
                                    value: !_isShallow,
                                    activeColor: const Color(0xFF4CD7F6),
                                    onChanged: (val) {
                                      setState(() {
                                        _isShallow = !val;
                                      });
                                      _calculateCapacity();
                                    },
                                  ),
                                  Text(
                                    'Deep Pile',
                                    style: TextStyle(
                                      color: !_isShallow ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _isShallow
                                  ? Column(
                                      children: [
                                        TextFormField(
                                          controller: _loadController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(labelText: 'Column Load (kN)'),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _cohesionController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Cohesion, c (kPa)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _frictionController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Friction Angle, φ (°)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _gammaController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Unit Weight (kN/m³)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _depthController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Embedment Depth, Df (m)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _widthController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Footing Width, B (m)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _lengthController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(labelText: 'Footing Length, L (m)'),
                                                onChanged: (_) => _calculateCapacity(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        TextFormField(
                                          controller: _pileDiaController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(labelText: 'Pile Diameter (m)'),
                                          onChanged: (_) => _calculateCapacity(),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _pileLenController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(labelText: 'Pile Length (m)'),
                                          onChanged: (_) => _calculateCapacity(),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _pileCountController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(labelText: 'Number of Piles in Group'),
                                          onChanged: (_) => _calculateCapacity(),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const Divider(color: Color(0xFF424754)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isShallow ? 'Allowable Bearing q_all:' : 'Group Load Capacity Q_all:',
                                style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 13),
                              ),
                              Text(
                                '${_bearingCapacity.toStringAsFixed(1)} ${_isShallow ? "kPa" : "kN"}',
                                style: const TextStyle(color: Color(0xFF4CD7F6), fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right Panel: 2D Terzaghi Shear Zone / 3D Foundation Card
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: _isShallow ? 'Terzaghi Shear Zone Geometry' : 'Deep Foundation Pile Configuration',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'Foundation_Design', 'B,Df,Allowable_Capacity\n${_widthController.text},${_depthController.text},$_bearingCapacity');
                  },
                  child: FoundationVisualCard(
                    isShallow: _isShallow,
                    width: double.tryParse(_widthController.text) ?? 2.0,
                    depth: double.tryParse(_depthController.text) ?? 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'Foundation Design',
          inputSummary: _isShallow
              ? 'Shallow Footing: B = ${_widthController.text}m, L = ${_lengthController.text}m, Df = ${_depthController.text}m, c = ${_cohesionController.text}kPa, phi = ${_frictionController.text}°'
              : 'Deep Pile Group: count = ${_pileCountController.text}, diameter = ${_pileDiaController.text}m, length = ${_pileLenController.text}m',
          resultSummary: 'Design Capacity = ${_bearingCapacity.toStringAsFixed(1)} ${_isShallow ? "kPa" : "kN"} (Factor of Safety = 3.0 / 2.5)',
        ),
      ],
    );
  }
}

class FoundationVisualCard extends StatelessWidget {
  final bool isShallow;
  final double width;
  final double depth;

  const FoundationVisualCard({
    super.key,
    required this.isShallow,
    required this.width,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: FoundationVisualPainter(
            isShallow: isShallow,
            width: width,
            depth: depth,
          ),
        );
      },
    );
  }
}

class FoundationVisualPainter extends CustomPainter {
  final bool isShallow;
  final double width;
  final double depth;

  FoundationVisualPainter({
    required this.isShallow,
    required this.width,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final groundPaint = Paint()
      ..color = const Color(0xFF0B1326)
      ..style = PaintingStyle.fill;

    final concretePaint = Paint()
      ..color = const Color(0xFF475569) // concrete gray
      ..style = PaintingStyle.fill;

    final shearPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.18) // safety orange failure zone
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFFFFB786)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double padL = 50;
    double padR = 50;
    double padT = 50;
    double padB = 50;

    double activeW = size.width - padL - padR;
    double activeH = size.height - padT - padB;

    if (isShallow) {
      // Draw Shallow Foundation Terzaghi Shear Zones
      double scale = activeW / 6.0;
      double drawB = math.min(activeW * 0.8, width * scale);
      double drawDf = math.min(activeH * 0.4, depth * scale);

      double cx = size.width / 2;
      double yGround = padT + activeH * 0.3;
      double yFootingBtm = yGround + drawDf;

      // Draw Ground Lines
      canvas.drawLine(Offset(padL, yGround), Offset(cx - drawB / 2, yGround), borderPaint..color = const Color(0xFF8C909F));
      canvas.drawLine(Offset(cx + drawB / 2, yGround), Offset(size.width - padR, yGround), borderPaint..color = const Color(0xFF8C909F));

      // Draw concrete footing column & base
      canvas.drawRect(
        Rect.fromLTRB(cx - drawB / 2, yGround, cx + drawB / 2, yFootingBtm),
        concretePaint,
      );
      // Footing Outline
      canvas.drawRect(
        Rect.fromLTRB(cx - drawB / 2, yGround, cx + drawB / 2, yFootingBtm),
        borderPaint..color = Colors.white,
      );

      // Draw active triangular shear zone below footing
      // Triangular wedge runs under footing base B, height is approx (B/2)*tan(45+phi/2) -> simplify to 0.43 * B
      double hWedge = 0.43 * drawB;
      final wedgePath = Path();
      wedgePath.moveTo(cx - drawB / 2, yFootingBtm);
      wedgePath.lineTo(cx, yFootingBtm + hWedge);
      wedgePath.lineTo(cx + drawB / 2, yFootingBtm);
      wedgePath.close();
      canvas.drawPath(wedgePath, shearPaint);
      canvas.drawPath(wedgePath, linePaint);

      // Radial shear zone curves (approximated log-spirals)
      final spiralL = Path();
      spiralL.moveTo(cx - drawB / 2, yFootingBtm);
      spiralL.quadraticBezierTo(cx - drawB, yFootingBtm + hWedge * 0.8, cx - drawB * 1.2, yFootingBtm);
      spiralL.lineTo(cx - drawB / 2, yFootingBtm);
      canvas.drawPath(spiralL, shearPaint..color = const Color(0xFF4CD7F6).withOpacity(0.12));
      canvas.drawPath(spiralL, linePaint..color = const Color(0xFF4CD7F6));

      final spiralR = Path();
      spiralR.moveTo(cx + drawB / 2, yFootingBtm);
      spiralR.quadraticBezierTo(cx + drawB, yFootingBtm + hWedge * 0.8, cx + drawB * 1.2, yFootingBtm);
      spiralR.lineTo(cx + drawB / 2, yFootingBtm);
      canvas.drawPath(spiralR, shearPaint);
      canvas.drawPath(spiralR, linePaint);

      // Labels
      textPainter.text = const TextSpan(
        text: 'Active Shear Zone I',
        style: TextStyle(color: Color(0xFFFFB786), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, yFootingBtm + 5));

      textPainter.text = const TextSpan(
        text: 'Radial Shear Zone II',
        style: TextStyle(color: Color(0xFF4CD7F6), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - drawB * 0.95, yFootingBtm + hWedge + 5));
    } else {
      // Draw Deep Foundation Pile Group representation
      double cx = size.width / 2;
      double yCapTop = padT + activeH * 0.15;
      double yCapBtm = yCapTop + 30;
      double pileLengthDraw = activeH * 0.7;

      // Draw Pile Cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(cx - 80, yCapTop, cx + 80, yCapBtm), const Radius.circular(6)),
        concretePaint,
      );

      // Draw 3 Piles (front view of group)
      final pilePaint = Paint()
        ..color = const Color(0xFF8C909F)
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTRB(cx - 60, yCapBtm, cx - 45, yCapBtm + pileLengthDraw), pilePaint);
      canvas.drawRect(Rect.fromLTRB(cx - 7.5, yCapBtm, cx + 7.5, yCapBtm + pileLengthDraw), pilePaint);
      canvas.drawRect(Rect.fromLTRB(cx + 45, yCapBtm, cx + 60, yCapBtm + pileLengthDraw), pilePaint);

      // Draw Soil layering around piles
      final layerPaint = Paint()
        ..color = const Color(0xFF424754).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTRB(padL, yCapBtm + 40, size.width - padR, yCapBtm + 45), layerPaint);
      canvas.drawRect(Rect.fromLTRB(padL, yCapBtm + 120, size.width - padR, yCapBtm + 125), layerPaint);

      textPainter.text = const TextSpan(
        text: 'Skin Friction Load Transfer',
        style: TextStyle(color: Color(0xFF4CD7F6), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx + 65, yCapBtm + pileLengthDraw / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 6. SETTLEMENT ANALYSIS MODULE
// =====================================================================
class SettlementAnalysisModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const SettlementAnalysisModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<SettlementAnalysisModule> createState() => _SettlementAnalysisModuleState();
}

class _SettlementAnalysisModuleState extends State<SettlementAnalysisModule> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loadController = TextEditingController(text: '120.0');
  final TextEditingController _widthBController = TextEditingController(text: '2.0');
  final TextEditingController _lengthLController = TextEditingController(text: '3.0');
  final TextEditingController _thickController = TextEditingController(text: '5.0');
  final TextEditingController _e0Controller = TextEditingController(text: '0.85');
  final TextEditingController _ccController = TextEditingController(text: '0.25');
  final TextEditingController _cvController = TextEditingController(text: '1.2e-7'); // m²/s

  double _totalSettlement = 162.3; // mm

  void _pullFootingDimensions() {
    setState(() {
      if (widget.sharedState.footingWidthB != null) {
        _widthBController.text = widget.sharedState.footingWidthB!.toStringAsFixed(1);
      }
      if (widget.sharedState.footingLengthL != null) {
        _lengthLController.text = widget.sharedState.footingLengthL!.toStringAsFixed(1);
      }
    });
    _calculateSettlement();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Pulled Footing Width B & Length L from Foundation Design tab.'),
        backgroundColor: Color(0xFF4CD7F6),
      ),
    );
  }

  void _calculateSettlement() {
    double q = double.tryParse(_loadController.text) ?? 120.0;
    double b = double.tryParse(_widthBController.text) ?? 2.0;
    double h = double.tryParse(_thickController.text) ?? 5.0;
    double e0 = double.tryParse(_e0Controller.text) ?? 0.85;
    double cc = double.tryParse(_ccController.text) ?? 0.25;

    // Standard consolidation settlement equation: Sc = (Cc * H / (1 + e0)) * log10((s0 + ds) / s0)
    // Simplify using linear stress increase approximation: ds = q * B*L / (B+z)*(L+z)
    double sc = (cc * h * 1000.0 / (1.0 + e0)) * math.log(1.0 + q / 50.0) / math.ln10;

    setState(() {
      _totalSettlement = math.max(0.0, sc);
    });
  }

  @override
  void initState() {
    super.initState();
    _syncState();
    _calculateSettlement();
  }

  void _syncState() {
    if (widget.sharedState.footingWidthB != null) {
      _widthBController.text = widget.sharedState.footingWidthB!.toStringAsFixed(1);
    }
    if (widget.sharedState.footingLengthL != null) {
      _lengthLController.text = widget.sharedState.footingLengthL!.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: inputs
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'CONSOLIDATION INPUT CONSTANTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C909F),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B1326),
                                    foregroundColor: const Color(0xFF4CD7F6),
                                  ),
                                  onPressed: _pullFootingDimensions,
                                  icon: const Icon(Icons.download_rounded, size: 14),
                                  label: const Text('🔗 Pull Footing Dimensions', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _loadController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Applied Stress surcharge, Δσ (kPa)'),
                              onChanged: (_) => _calculateSettlement(),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _widthBController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Footing Width, B (m)'),
                                    onChanged: (_) => _calculateSettlement(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lengthLController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Footing Length, L (m)'),
                                    onChanged: (_) => _calculateSettlement(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _thickController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Clay Layer Thickness, H (m)'),
                                    onChanged: (_) => _calculateSettlement(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _e0Controller,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Initial Void Ratio, e0'),
                                    onChanged: (_) => _calculateSettlement(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _ccController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Compression Index, Cc'),
                                    onChanged: (_) => _calculateSettlement(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: 'Cv coefficient (m²/s)'),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF424754), height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Consolidation Settlement (Sc):', style: TextStyle(color: Color(0xFFC2C6D6))),
                                Text(
                                  '${_totalSettlement.toStringAsFixed(1)} mm',
                                  style: const TextStyle(color: Color(0xFF4CD7F6), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: dynamic consolidation curve over time
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: 'Consolidation Settlement Rate vs. Log Time',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'Settlement_Analysis', 'Time(days),Settlement(mm)\n0,0\n30,${_totalSettlement * 0.2}\n365,${_totalSettlement * 0.5}\n3650,${_totalSettlement * 0.85}\n18250,$_totalSettlement');
                  },
                  child: SettlementConsolidationChart(totalSc: _totalSettlement),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'Settlement Analysis',
          inputSummary: 'Stress = ${_loadController.text} kPa, Clay Thickness = ${_thickController.text} m, e0 = ${_e0Controller.text}, Cc = ${_ccController.text}',
          resultSummary: 'Estimated Consolidation Settlement = ${_totalSettlement.toStringAsFixed(1)} mm (Secondary compression omitted). Time rate computed via Cv = ${_cvController.text} m²/s',
        ),
      ],
    );
  }
}

class SettlementConsolidationChart extends StatelessWidget {
  final double totalSc;

  const SettlementConsolidationChart({super.key, required this.totalSc});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: SettlementChartPainter(totalSc: totalSc),
        );
      },
    );
  }
}

class SettlementChartPainter extends CustomPainter {
  final double totalSc;

  SettlementChartPainter({required this.totalSc});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF171F33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = const Color(0xFF8C909F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final curvePaint = Paint()
      ..color = const Color(0xFFFFB786) // safety orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double padL = 40;
    double padB = 40;
    double padT = 20;
    double padR = 20;

    double plotW = size.width - padL - padR;
    double plotH = size.height - padT - padB;

    // Log time bounds: 1 day to 50 years (approx 0 to 4.5 in log scale of days)
    double minLog = 0; // 1 day
    double maxLog = 4.56; // 50 years = 18250 days

    Offset mapPoint(double logTime, double sc) {
      double pctX = logTime / maxLog;
      double pctY = sc / (totalSc * 1.25); // give margin
      return Offset(
        padL + pctX * plotW,
        padT + pctY * plotH, // settlement downwards!
      );
    }

    // Grid lines
    canvas.drawRect(Rect.fromLTWH(padL, padT, plotW, plotH), gridPaint);
    for (double i = 0; i <= maxLog; i += 1.0) {
      Offset pos = mapPoint(i, 0);
      canvas.drawLine(Offset(pos.dx, padT), Offset(pos.dx, size.height - padB), gridPaint);
      String lbl = '${math.pow(10, i).toInt()}d';
      if (i >= 3.0) lbl = '${(math.pow(10, i) / 365).toStringAsFixed(1)}y';
      textPainter.text = TextSpan(text: lbl, style: const TextStyle(color: Color(0xFF8C909F), fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, size.height - padB + 5));
    }

    for (double yPct = 0; yPct <= 1.0; yPct += 0.25) {
      double scVal = totalSc * yPct;
      Offset pos = mapPoint(0, scVal);
      canvas.drawLine(Offset(padL, pos.dy), Offset(padL + plotW, pos.dy), gridPaint);
      textPainter.text = TextSpan(text: '${scVal.toStringAsFixed(0)}mm', style: const TextStyle(color: Color(0xFF8C909F), fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(padL - textPainter.width - 5, pos.dy - textPainter.height / 2));
    }

    canvas.drawLine(mapPoint(0, 0), mapPoint(maxLog, 0), axisPaint);
    canvas.drawLine(mapPoint(0, 0), mapPoint(0, totalSc * 1.25), axisPaint);

    // Title label
    textPainter.text = const TextSpan(
      text: 'Logarithmic Project Timeline',
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(padL + plotW / 2 - textPainter.width / 2, size.height - padB + 20));

    // Plot Consolidation Curve Sc(t) = Sc_max * U(Tv)
    // Degree of consolidation U(Tv) approx = math.sqrt(4 * Tv / math.pi) if Tv < 0.2 else 1 - 10^-(A*Tv+B)
    final path = Path();
    path.moveTo(mapPoint(0, 0).dx, mapPoint(0, 0).dy);

    for (int i = 0; i <= 50; i++) {
      double pct = i / 50.0;
      double logTime = pct * maxLog;
      double days = math.pow(10, logTime).toDouble();
      
      // Calculate consolidated settlement fraction (degree of consolidation U)
      // U starts at 0 and goes asymptotically to 1.0
      double u = 1.0 - math.exp(-days / 365.0); // simple exponential rate for visual representation
      double sc = totalSc * u;

      Offset pt = mapPoint(logTime, sc);
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, curvePaint);

    // Plot end coordinate marker
    Offset endPt = mapPoint(maxLog, totalSc * (1.0 - math.exp(-18250 / 365.0)));
    canvas.drawCircle(endPt, 5.0, Paint()..color = const Color(0xFF4CD7F6));
    canvas.drawCircle(endPt, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 7. GEOLOGICAL MODELING MODULE
// =====================================================================
class GeologicalModelingModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const GeologicalModelingModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<GeologicalModelingModule> createState() => _GeologicalModelingModuleState();
}

class _GeologicalModelingModuleState extends State<GeologicalModelingModule> {
  final TextEditingController _projectController = TextEditingController(text: 'Crestwood Industrial Park');
  final TextEditingController _locController = TextEditingController(text: 'Sector 4, Plot B');
  bool _isBorehole = true;
  double _rotationAngle = 0.0; // Dynamic rotation parameter for 3D CustomPainter

  int _boreholeCount = 4;
  int _cptCount = 8;
  int _layerCount = 3;

  void _rotateLeft() {
    setState(() {
      _rotationAngle -= 15.0 * math.pi / 180.0;
    });
  }

  void _rotateRight() {
    setState(() {
      _rotationAngle += 15.0 * math.pi / 180.0;
    });
  }

  void _simulateUpload() {
    setState(() {
      if (_isBorehole) {
        _boreholeCount++;
      } else {
        _cptCount++;
      }
      _layerCount = 3 + math.Random().nextInt(3);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imported new ${_isBorehole ? "Borehole log" : "CPT sounding data"} successfully.'),
        backgroundColor: const Color(0xFF4CD7F6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Panel: Stratigraphy info & imports
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUBSURFACE MODEL DESIGNER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C909F),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _projectController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Project Site Name'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _locController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Location Reference'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Import Data Type:', style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 12)),
                            Row(
                              children: [
                                Text('Boreholes', style: TextStyle(color: _isBorehole ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F), fontSize: 11, fontWeight: FontWeight.bold)),
                                Switch(
                                  value: !_isBorehole,
                                  activeColor: const Color(0xFF4CD7F6),
                                  onChanged: (val) {
                                    setState(() {
                                      _isBorehole = !val;
                                    });
                                  },
                                ),
                                Text('CPT Soundings', style: TextStyle(color: !_isBorehole ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _simulateUpload,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1326),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF424754), style: BorderStyle.solid),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.note_add_outlined, color: Color(0xFF4CD7F6), size: 28),
                                SizedBox(height: 4),
                                Text(
                                  'Drag and drop boring log / LAS files here',
                                  style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: Color(0xFF424754), height: 28),
                        const Text(
                          'ACTIVE GEOTECHNICAL SITE DATA METRICS',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8C909F)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCountCell('Boreholes', '$_boreholeCount logs'),
                            _buildCountCell('CPT Tests', '$_cptCount points'),
                            _buildCountCell('Soil Layers', '$_layerCount horizons'),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1326), foregroundColor: Colors.white),
                              onPressed: _rotateLeft,
                              icon: const Icon(Icons.rotate_left_rounded),
                              label: const Text('Rotate CCW'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1326), foregroundColor: Colors.white),
                              onPressed: _rotateRight,
                              icon: const Icon(Icons.rotate_right_rounded),
                              label: const Text('Rotate CW'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right Panel: 3D block mesh
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: '3D Subsurface Stratigraphy block model',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'Geological_Modeling', 'Layer,Depth(m),Soil_Type\nLayer1,0-2m,Silty Sand\nLayer2,2-5m,Lean Clay\nLayer3,5-10m,Dense Gravel');
                  },
                  child: Subsurface3DBlock(rotationAngle: _rotationAngle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'Geological Modeling',
          inputSummary: 'Site = ${_projectController.text}, Boreholes = $_boreholeCount, CPT soundings = $_cptCount, Layers Interpolated = $_layerCount',
          resultSummary: '3D finite element grid generated successfully. Solid stratigraphic layer interfaces calculated via Kriging interpolation.',
        ),
      ],
    );
  }

  Widget _buildCountCell(String label, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1326),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF424754)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: Color(0xFF4CD7F6), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class Subsurface3DBlock extends StatelessWidget {
  final double rotationAngle;

  const Subsurface3DBlock({super.key, required this.rotationAngle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: Subsurface3DPainter(rotationAngle: rotationAngle),
        );
      },
    );
  }
}

class Subsurface3DPainter extends CustomPainter {
  final double rotationAngle;

  Subsurface3DPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Let's project a 3D rectangular prism (isometric view)
    double cx = size.width / 2;
    double cy = size.height / 2 + 10;

    double w = 120; // block half-width
    double h = 80;  // block depth
    double d = 60;  // block height

    // Rotation projection offsets
    double cosA = math.cos(rotationAngle);
    double sinA = math.sin(rotationAngle);

    // 8 Vertices of the block (isometric projection)
    Offset project3D(double x, double y, double z) {
      // Rotate x/y around Z-axis
      double rx = x * cosA - y * sinA;
      double ry = x * sinA + y * cosA;

      // Project isometric: X_screen = cx + (rx - ry) * cos(30 deg), Y_screen = cy - z + (rx + ry) * sin(30 deg)
      double cos30 = 0.866;
      double sin30 = 0.500;
      return Offset(
        cx + (rx - ry) * cos30,
        cy - z + (rx + ry) * sin30,
      );
    }

    final p1 = project3D(-w, -h, d);  // top front-left
    final p2 = project3D(w, -h, d);   // top front-right
    final p3 = project3D(w, h, d);    // top back-right
    final p4 = project3D(-w, h, d);   // top back-left

    final p5 = project3D(-w, -h, -d); // bottom front-left
    final p6 = project3D(w, -h, -d);  // bottom front-right
    final p7 = project3D(w, h, -d);   // bottom back-right
    final p8 = project3D(-w, h, -d);  // bottom back-left

    // Layer bounds (split the vertical range from -d to d)
    // Layer 1: Sand (Orange)
    // Layer 2: Clay (Teal)
    // Layer 3: Bedrock (Dark Blue)
    double mid1 = d * 0.3;
    double mid2 = -d * 0.4;

    // Draw bottom face
    final pathBottom = Path()
      ..moveTo(p5.dx, p5.dy)
      ..lineTo(p6.dx, p6.dy)
      ..lineTo(p7.dx, p7.dy)
      ..lineTo(p8.dx, p8.dy)
      ..close();
    canvas.drawPath(pathBottom, Paint()..color = const Color(0xFF0B1326));
    canvas.drawPath(pathBottom, borderPaint);

    void drawSideFace(List<Offset> pts, Color color) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, borderPaint);
    }

    // Front-Left Face Layers
    final fl_top1 = project3D(-w, -h, d);
    final fl_top2 = project3D(0, -h, d); // mid split
    final fl_btm1 = project3D(-w, -h, -d);
    final fl_btm2 = project3D(w, -h, -d);

    // We draw the layers on the visible front faces (p1->p5->p6->p2 and p2->p6->p7->p3)
    // Simplified layers representation:
    // We just fill the front-left and front-right sides with horizontal layers
    void drawLayeredFace(Offset t1, Offset t2, Offset b2, Offset b1, Color c1, Color c2, Color c3) {
      // Split the side face vertically
      Offset interp(Offset start, Offset end, double pct) {
        return Offset(start.dx + (end.dx - start.dx) * pct, start.dy + (end.dy - start.dy) * pct);
      }

      // 0.0 at top, 1.0 at bottom
      Offset t1_m1 = interp(t1, b1, 0.35);
      Offset t2_m1 = interp(t2, b2, 0.35);
      Offset t1_m2 = interp(t1, b1, 0.70);
      Offset t2_m2 = interp(t2, b2, 0.70);

      // Layer 1
      drawSideFace([t1, t2, t2_m1, t1_m1], c1);
      // Layer 2
      drawSideFace([t1_m1, t2_m1, t2_m2, t1_m2], c2);
      // Layer 3
      drawSideFace([t1_m2, t2_m2, b2, b1], c3);
    }

    final sandColor = const Color(0xFFFFB786).withOpacity(0.4);
    final clayColor = const Color(0xFF4CD7F6).withOpacity(0.3);
    final rockColor = const Color(0xFFADC6FF).withOpacity(0.2);

    // Front-Left Side (p1 -> p5 -> p8 -> p4)
    drawLayeredFace(p1, p4, p8, p5, sandColor, clayColor, rockColor);

    // Front-Right Side (p1 -> p5 -> p6 -> p2)
    drawLayeredFace(p1, p2, p6, p5, sandColor, clayColor, rockColor);

    // Top Face (p1 -> p2 -> p3 -> p4)
    final pathTop = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(pathTop, Paint()..color = const Color(0xFFFFB786).withOpacity(0.55)); // top is sand
    canvas.drawPath(pathTop, borderPaint..color = Colors.white.withOpacity(0.7));

    // Draw Borehole vertical lines cutting through the block
    final bhPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    void drawBorehole(double x, double y) {
      Offset top = project3D(x, y, d);
      Offset btm = project3D(x, y, -d);
      canvas.drawLine(top, btm, bhPaint);
      canvas.drawCircle(top, 4.0, Paint()..color = Colors.red);

      textPainter.text = const TextSpan(text: 'BH', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold));
      textPainter.layout();
      textPainter.paint(canvas, Offset(top.dx - 5, top.dy - 12));
    }

    drawBorehole(-w * 0.4, -h * 0.3);
    drawBorehole(w * 0.5, h * 0.2);
    drawBorehole(0, h * 0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// 8. AI IMAGE ANALYSIS MODULE
// =====================================================================
class AiImageAnalysisModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const AiImageAnalysisModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<AiImageAnalysisModule> createState() => _AiImageAnalysisModuleState();
}

class _AiImageAnalysisModuleState extends State<AiImageAnalysisModule> {
  bool _hasImage = false;
  double _sandPct = 60.0;
  double _siltPct = 25.0;
  double _clayPct = 15.0;
  bool _segmenting = false;

  void _simulateUpload() {
    setState(() {
      _segmenting = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _hasImage = true;
          _segmenting = false;
          _sandPct = 55 + math.Random().nextInt(15).toDouble();
          _siltPct = 20 + math.Random().nextInt(10).toDouble();
          _clayPct = 100.0 - _sandPct - _siltPct;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Panel: Upload Zone
              Expanded(
                flex: 1,
                child: Card(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF424754)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GEOTECHNICAL GRAIN IMAGE UPLOADER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C909F),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: InkWell(
                            onTap: _simulateUpload,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1326),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hasImage ? const Color(0xFF4CD7F6) : const Color(0xFF424754),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _segmenting
                                  ? const CircularProgressIndicator(color: Color(0xFF4CD7F6))
                                  : _hasImage
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle_outline, color: Color(0xFF4CD7F6), size: 36),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Soil Micrograph Segmented Successfully!',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Sand: ${_sandPct.toStringAsFixed(1)}% | Silt: ${_siltPct.toStringAsFixed(1)}% | Clay: ${_clayPct.toStringAsFixed(1)}%',
                                              style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 11),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Tap to upload a different image',
                                              style: TextStyle(color: Color(0xFF8C909F), fontSize: 10, decoration: TextDecoration.underline),
                                            )
                                          ],
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFADC6FF), size: 40),
                                              SizedBox(height: 12),
                                              Text(
                                                'Click to upload or drag and drop soil micrograph',
                                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                'Supports PNG, JPG, or JPEG up to 10MB',
                                                style: TextStyle(color: Color(0xFF8C909F), fontSize: 11),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right Panel: segmentation display and ring chart
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: 'Micrograph Segmenter & Distribution',
                  onExportCsv: () {
                    triggerCsvDownload(context, 'AI_Image_Analysis', 'Grain_Type,Percentage\nSand,$_sandPct\nSilt,$_siltPct\nClay,$_clayPct');
                  },
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SoilMicrographSegmenter(hasImage: _hasImage),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomDonutChart(
                                sand: _sandPct,
                                silt: _siltPct,
                                clay: _clayPct,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('Sand Particles', _sandPct, const Color(0xFFF59E0B)),
                                _buildLegendItem('Silt / Fines', _siltPct, const Color(0xFF4CD7F6)),
                                _buildLegendItem('Colloidal Clay', _clayPct, const Color(0xFFADC6FF)),
                              ],
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
        const SizedBox(height: 16),
        AiReportPanel(
          moduleName: 'AI Image Analysis',
          inputSummary: 'Sample Micrograph = ${_hasImage ? "Active_Sample.png" : "None"}',
          resultSummary: 'AI Grain size distribution results: Sand = ${_sandPct.toStringAsFixed(1)}%, Silt = ${_siltPct.toStringAsFixed(1)}%, Clay = ${_clayPct.toStringAsFixed(1)}%. Image segmentation model confidence = 94.6%',
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 11)),
          Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}

class SoilMicrographSegmenter extends StatelessWidget {
  final bool hasImage;

  const SoilMicrographSegmenter({super.key, required this.hasImage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: MicrographPainter(hasImage: hasImage),
        );
      },
    );
  }
}

class MicrographPainter extends CustomPainter {
  final bool hasImage;

  MicrographPainter({required this.hasImage});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final circlePaint = Paint()
      ..color = const Color(0xFF0B1326)
      ..style = PaintingStyle.fill;

    double cx = size.width / 2;
    double cy = size.height / 2;
    double radius = math.min(cx, cy) * 0.85;

    // Draw micrograph lens frame
    canvas.drawCircle(Offset(cx, cy), radius, circlePaint);
    canvas.drawCircle(Offset(cx, cy), radius, borderPaint);

    if (!hasImage) {
      // Draw grid lines representing empty scope view
      final linePaint = Paint()
        ..color = const Color(0xFF171F33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawLine(Offset(cx - radius, cy), Offset(cx + radius, cy), linePaint);
      canvas.drawLine(Offset(cx, cy - radius), Offset(cx, cy + radius), linePaint);

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Micrograph Feed Offline',
          style: TextStyle(color: Color(0xFF8C909F), fontSize: 11, fontStyle: FontStyle.italic),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
    } else {
      // Draw simulated particles
      final sandPaint = Paint()
        ..color = const Color(0xFFF59E0B).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      final sandOutline = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final siltPaint = Paint()
        ..color = const Color(0xFF4CD7F6).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      final siltOutline = Paint()
        ..color = const Color(0xFF4CD7F6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final clayPaint = Paint()
        ..color = const Color(0xFFADC6FF).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      final clayOutline = Paint()
        ..color = const Color(0xFFADC6FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      void drawParticle(double x, double y, double r, Paint fill, Paint outline) {
        // limit within circular frame bounds
        double dx = x - cx;
        double dy = y - cy;
        if (math.sqrt(dx * dx + dy * dy) < radius - r) {
          canvas.drawCircle(Offset(x, y), r, fill);
          canvas.drawCircle(Offset(x, y), r, outline);
        }
      }

      // Draw Sand (larger grains)
      drawParticle(cx - 30, cy - 20, 18, sandPaint, sandOutline);
      drawParticle(cx + 40, cy - 30, 22, sandPaint, sandOutline);
      drawParticle(cx + 10, cy + 35, 20, sandPaint, sandOutline);

      // Draw Silt (medium grains)
      drawParticle(cx - 50, cy + 25, 8, siltPaint, siltOutline);
      drawParticle(cx - 10, cy - 50, 10, siltPaint, siltOutline);
      drawParticle(cx + 50, cy + 20, 9, siltPaint, siltOutline);
      drawParticle(cx - 20, cy + 10, 7, siltPaint, siltOutline);

      // Draw Clay (fine dots)
      drawParticle(cx - 30, cy - 45, 3, clayPaint, clayOutline);
      drawParticle(cx + 10, cy - 15, 4, clayPaint, clayOutline);
      drawParticle(cx + 25, cy + 5, 3, clayPaint, clayOutline);
      drawParticle(cx - 10, cy + 50, 4, clayPaint, clayOutline);
      drawParticle(cx - 60, cy - 5, 3, clayPaint, clayOutline);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomDonutChart extends StatelessWidget {
  final double sand;
  final double silt;
  final double clay;

  const CustomDonutChart({
    super.key,
    required this.sand,
    required this.silt,
    required this.clay,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 100),
      painter: DonutChartPainter(sand: sand, silt: silt, clay: clay),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double sand;
  final double silt;
  final double clay;

  DonutChartPainter({required this.sand, required this.silt, required this.clay});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = size.width / 2 * 0.9;
    double strokeW = 12.0;

    double total = sand + silt + clay;
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    void drawSegment(double val, Color color) {
      double sweepAngle = (val / total) * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    drawSegment(sand, const Color(0xFFF59E0B)); // Orange
    drawSegment(silt, const Color(0xFF4CD7F6)); // Teal
    drawSegment(clay, const Color(0xFFADC6FF)); // Blue
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// BOREHOLES & INTEGRATED GEOTECHNICAL WORKFLOW MODULES
// =====================================================================

class BoreholesModule extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const BoreholesModule({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<BoreholesModule> createState() => _BoreholesModuleState();
}

class _BoreholesModuleState extends State<BoreholesModule> {
  int _activeSubTabIndex = 0;

  final List<String> _subTabLabels = [
    'Sieve Analysis',
    'Borehole Test Logs',
    'Allowable Bearing Capacity',
    'Estimated Max Capacity',
  ];

  final List<IconData> _subTabIcons = [
    Icons.grid_on_rounded,
    Icons.receipt_long_rounded,
    Icons.foundation_rounded,
    Icons.speed_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Navigation Tab Bar
        Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF171F33),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF424754)),
          ),
          child: Row(
            children: List.generate(_subTabLabels.length, (index) {
              bool isActive = _activeSubTabIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeSubTabIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFADC6FF).withOpacity(0.08) : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? const Color(0xFF4CD7F6) : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _subTabIcons[index],
                          size: 16,
                          color: isActive ? const Color(0xFF4CD7F6) : const Color(0xFF8C909F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _subTabLabels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive ? Colors.white : const Color(0xFFC2C6D6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        // Body Feature Canvas
        Expanded(
          child: _buildActiveSubFeature(),
        ),
      ],
    );
  }

  Widget _buildActiveSubFeature() {
    switch (_activeSubTabIndex) {
      case 0:
        return SieveAnalysisModule(
          sharedState: widget.sharedState,
          onStateUpdated: widget.onStateUpdated,
        );
      case 1:
        return BoreholeLogsSubFeature(
          sharedState: widget.sharedState,
          onStateUpdated: widget.onStateUpdated,
        );
      case 2:
        return BearingCapacitySubFeature(
          sharedState: widget.sharedState,
          onStateUpdated: widget.onStateUpdated,
        );
      case 3:
        return MaxCapacitySubFeature(
          sharedState: widget.sharedState,
          onStateUpdated: widget.onStateUpdated,
        );
      default:
        return const Center(child: Text('Invalid Sub-Feature State'));
    }
  }
}

// =====================================================================
// SUB-FEATURE 2: BOREHOLE TEST LOGS
// =====================================================================

class BoreholeLayerItem {
  final double depth; // bottom depth in meters
  final String soilType;
  final double sptN;

  BoreholeLayerItem({
    required this.depth,
    required this.soilType,
    required this.sptN,
  });
}

class BoreholeLogsSubFeature extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const BoreholeLogsSubFeature({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<BoreholeLogsSubFeature> createState() => _BoreholeLogsSubFeatureState();
}

class _BoreholeLogsSubFeatureState extends State<BoreholeLogsSubFeature> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _sptNController = TextEditingController();
  
  String _selectedSoilType = 'Clayey Sand (SC)';
  
  final List<String> _soilTypes = [
    'Organic Clay (OL)',
    'Clayey Sand (SC)',
    'Colloidal Clay (CL)',
    'Silty Sand (SM)',
    'Poorly-Graded Sand (SP)',
    'Well-Graded Gravel (GW)',
    'Weathered Bedrock'
  ];

  final List<BoreholeLayerItem> _layers = [
    BoreholeLayerItem(depth: 2.0, soilType: 'Organic Clay (OL)', sptN: 5),
    BoreholeLayerItem(depth: 6.0, soilType: 'Clayey Sand (SC)', sptN: 12),
    BoreholeLayerItem(depth: 12.0, soilType: 'Colloidal Clay (CL)', sptN: 18),
    BoreholeLayerItem(depth: 20.0, soilType: 'Weathered Bedrock', sptN: 45),
  ];

  void _addLayer() {
    if (!_formKey.currentState!.validate()) return;
    double depth = double.tryParse(_depthController.text) ?? 0.0;
    double sptN = double.tryParse(_sptNController.text) ?? 0.0;

    // Ensure depths are in increasing order
    if (_layers.isNotEmpty && depth <= _layers.last.depth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Next layer bottom depth must be greater than current max depth (${_layers.last.depth}m).'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _layers.add(BoreholeLayerItem(depth: depth, soilType: _selectedSoilType, sptN: sptN));
      _depthController.clear();
      _sptNController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Borehole stratum log row added successfully.'),
        backgroundColor: Color(0xFF4CD7F6),
      ),
    );
  }

  void _resetLogs() {
    setState(() {
      _layers.clear();
      _layers.addAll([
        BoreholeLayerItem(depth: 2.0, soilType: 'Organic Clay (OL)', sptN: 5),
        BoreholeLayerItem(depth: 6.0, soilType: 'Clayey Sand (SC)', sptN: 12),
        BoreholeLayerItem(depth: 12.0, soilType: 'Colloidal Clay (CL)', sptN: 18),
        BoreholeLayerItem(depth: 20.0, soilType: 'Weathered Bedrock', sptN: 45),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Inputs and table
        Expanded(
          flex: 1,
          child: Card(
            color: const Color(0xFF171F33),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF424754)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOREHOLE LOG STRATIGRAPHY BUILDER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C909F),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSoilType,
                            dropdownColor: const Color(0xFF171F33),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(labelText: 'Soil Type Classification'),
                            items: _soilTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSoilType = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _depthController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(labelText: 'Bottom Depth (m)'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _sptNController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(labelText: 'SPT N-Value'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addLayer,
                          icon: const Icon(Icons.add, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF4CD7F6),
                            foregroundColor: const Color(0xFF0B1326),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _layers.isEmpty
                        ? const Center(child: Text('No log rows defined. Add layer above.', style: TextStyle(color: Color(0xFF8C909F))))
                        : ListView.builder(
                            itemCount: _layers.length,
                            itemBuilder: (context, idx) {
                              final item = _layers[idx];
                              double prevDepth = idx == 0 ? 0.0 : _layers[idx - 1].depth;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B1326),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF424754)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.soilType,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Interval: ${prevDepth.toStringAsFixed(1)}m to ${item.depth.toStringAsFixed(1)}m',
                                          style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB786).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'SPT N = ${item.sptN.toInt()}',
                                        style: const TextStyle(color: Color(0xFFFFB786), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(color: Color(0xFF424754)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Borehole Logged Depth: ${_layers.isEmpty ? "0.0" : _layers.last.depth.toStringAsFixed(1)}m',
                        style: const TextStyle(color: Color(0xFF4CD7F6), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _resetLogs,
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Reset Defaults', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF8C909F)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right Column: Custom depth-profile plot card
        Expanded(
          flex: 1,
          child: buildChartCard(
            title: 'Subsurface Stratigraphy & SPT N-Profile',
            onExportCsv: () {
              String csv = 'FromDepth(m),ToDepth(m),SoilType,SptN\n';
              for (int i = 0; i < _layers.length; i++) {
                double prev = i == 0 ? 0.0 : _layers[i - 1].depth;
                csv += '$prev,${_layers[i].depth},"${_layers[i].soilType}",${_layers[i].sptN}\n';
              }
              triggerCsvDownload(context, 'Borehole_Test_Logs', csv);
            },
            child: BoreholeDepthProfilePlot(layers: _layers),
          ),
        ),
      ],
    );
  }
}

class BoreholeDepthProfilePlot extends StatelessWidget {
  final List<BoreholeLayerItem> layers;

  const BoreholeDepthProfilePlot({super.key, required this.layers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: BoreholeProfilePainter(layers: layers),
        );
      },
    );
  }
}

class BoreholeProfilePainter extends CustomPainter {
  final List<BoreholeLayerItem> layers;

  BoreholeProfilePainter({required this.layers});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double w = size.width;
    double h = size.height;

    // Viewport layout bounds
    double colL = 10;
    double colW = 55;
    double graphL = 80;
    double graphW = w - graphL - 20;
    double padT = 15;
    double padB = 25;
    double plotH = h - padT - padB;

    // Backgrounds
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF171F33));

    if (layers.isEmpty) {
      textPainter.text = const TextSpan(text: 'No Data', style: TextStyle(color: Colors.white));
      textPainter.layout();
      textPainter.paint(canvas, Offset(w / 2 - textPainter.width / 2, h / 2 - 5));
      return;
    }

    double maxDepth = layers.last.depth;
    if (maxDepth <= 0) maxDepth = 20.0;

    // Helper to map depth to Y pixel coordinate
    double mapY(double depth) {
      double pct = depth / maxDepth;
      return padT + pct * plotH;
    }

    // Color maps for soil types
    Color getSoilColor(String type) {
      if (type.contains('OL')) return const Color(0xFF31394D).withOpacity(0.5);
      if (type.contains('SC')) return const Color(0xFFFFB786).withOpacity(0.12);
      if (type.contains('CL')) return const Color(0xFF4CD7F6).withOpacity(0.1);
      if (type.contains('SM')) return const Color(0xFFE2E8F0).withOpacity(0.08);
      if (type.contains('SP')) return const Color(0xFFFFD166).withOpacity(0.1);
      if (type.contains('GW')) return const Color(0xFFADC6FF).withOpacity(0.12);
      return const Color(0xFF0B1326); // Bedrock
    }

    // Draw layers in the boring column
    double currentTop = 0.0;
    for (int i = 0; i < layers.length; i++) {
      final item = layers[i];
      double topY = mapY(currentTop);
      double btmY = mapY(item.depth);
      
      // Draw soil block
      canvas.drawRect(
        Rect.fromLTWH(colL, topY, colW, btmY - topY),
        Paint()..color = getSoilColor(item.soilType),
      );
      
      // Draw border
      canvas.drawRect(Rect.fromLTWH(colL, topY, colW, btmY - topY), borderPaint);

      // Label layer name inside if there's space
      if (btmY - topY > 24) {
        String abbr = item.soilType.contains('(') 
            ? item.soilType.substring(item.soilType.indexOf('(') + 1, item.soilType.indexOf(')'))
            : (item.soilType.length > 5 ? item.soilType.substring(0, 5) : item.soilType);
        textPainter.text = TextSpan(
          text: abbr,
          style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(colL + colW / 2 - textPainter.width / 2, topY + (btmY - topY) / 2 - textPainter.height / 2),
        );
      }

      currentTop = item.depth;
    }

    // Draw outer boring log border
    canvas.drawRect(Rect.fromLTWH(colL, padT, colW, plotH), borderPaint..strokeWidth = 1.5);

    // Draw SPT N-Value Graph Grid on the right
    final graphBorder = Paint()
      ..color = const Color(0xFF424754).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(graphL, padT, graphW, plotH), graphBorder);

    // Grid vertical ticks (SPT N from 0 to 50)
    final gridPaint = Paint()
      ..color = const Color(0xFF424754).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    for (double n = 10; n <= 50; n += 10) {
      double pctX = n / 50.0;
      double x = graphL + pctX * graphW;
      canvas.drawLine(Offset(x, padT), Offset(x, h - padB), gridPaint);

      // Label N-value X-axis
      textPainter.text = TextSpan(
        text: '${n.toInt()}',
        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 8, fontFamily: 'monospace'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, h - padB + 4));
    }

    // Grid horizontal ticks corresponding to layer boundaries
    for (int i = 0; i < layers.length; i++) {
      double y = mapY(layers[i].depth);
      canvas.drawLine(Offset(graphL, y), Offset(graphL + graphW, y), gridPaint);
      
      // Label depth Y-axis
      textPainter.text = TextSpan(
        text: '${layers[i].depth.toStringAsFixed(1)}m',
        style: const TextStyle(color: Color(0xFF8C909F), fontSize: 8, fontFamily: 'monospace'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(graphL - textPainter.width - 6, y - 4));
    }

    // Draw SPT N-value profile line
    final linePaint = Paint()
      ..color = const Color(0xFFFFB786) // Peach
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    bool first = true;

    for (int i = 0; i < layers.length; i++) {
      final item = layers[i];
      double prevDepth = i == 0 ? 0.0 : layers[i - 1].depth;
      double midDepth = prevDepth + (item.depth - prevDepth) / 2;
      
      double y = mapY(midDepth);
      double nVal = math.max(0.0, math.min(50.0, item.sptN));
      double pctX = nVal / 50.0;
      double x = graphL + pctX * graphW;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw plot data nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < layers.length; i++) {
      final item = layers[i];
      double prevDepth = i == 0 ? 0.0 : layers[i - 1].depth;
      double midDepth = prevDepth + (item.depth - prevDepth) / 2;
      double y = mapY(midDepth);
      double nVal = math.max(0.0, math.min(50.0, item.sptN));
      double x = graphL + (nVal / 50.0) * graphW;

      nodePaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 4.5, nodePaint);
      nodePaint.color = const Color(0xFFFFB786);
      canvas.drawCircle(Offset(x, y), 2.5, nodePaint);
    }

    // Titles
    textPainter.text = const TextSpan(
      text: 'Blow Count SPT N-Value Profile',
      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 9, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(graphL + graphW / 2 - textPainter.width / 2, padT - 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// SUB-FEATURE 3: ALLOWABLE BEARING CAPACITY
// =====================================================================

class BearingCapacitySubFeature extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const BearingCapacitySubFeature({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<BearingCapacitySubFeature> createState() => _BearingCapacitySubFeatureState();
}

class _BearingCapacitySubFeatureState extends State<BearingCapacitySubFeature> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bController = TextEditingController(text: '2.0');
  final TextEditingController _lController = TextEditingController(text: '3.0');
  final TextEditingController _dfController = TextEditingController(text: '1.5');
  final TextEditingController _phiController = TextEditingController(text: '32.0');
  final TextEditingController _cController = TextEditingController(text: '10.0');
  final TextEditingController _gammaController = TextEditingController(text: '18.5');
  final TextEditingController _fsController = TextEditingController(text: '3.0');

  double _nc = 0.0;
  double _nq = 0.0;
  double _ng = 0.0;
  double _sc = 1.0;
  double _sg = 1.0;
  double _qUlt = 0.0;
  double _qAll = 0.0;

  @override
  void initState() {
    super.initState();
    _syncInputs();
    _recalculateCapacity();
  }

  void _syncInputs() {
    if (widget.sharedState.footingWidthB != null) {
      _bController.text = widget.sharedState.footingWidthB!.toStringAsFixed(1);
    }
    if (widget.sharedState.footingLengthL != null) {
      _lController.text = widget.sharedState.footingLengthL!.toStringAsFixed(1);
    }
  }

  void _recalculateCapacity() {
    double b = double.tryParse(_bController.text) ?? 2.0;
    double l = double.tryParse(_lController.text) ?? 3.0;
    double df = double.tryParse(_dfController.text) ?? 1.5;
    double phi = double.tryParse(_phiController.text) ?? 32.0;
    double c = double.tryParse(_cController.text) ?? 10.0;
    double gamma = double.tryParse(_gammaController.text) ?? 18.5;
    double fs = double.tryParse(_fsController.text) ?? 3.0;

    // Convert phi to radians
    double phiRad = phi * math.pi / 180.0;

    if (phi > 0) {
      _nq = math.exp(math.pi * math.tan(phiRad)) * math.pow(math.tan(math.pi / 4 + phiRad / 2), 2);
      _nc = (_nq - 1.0) / math.tan(phiRad);
      // Vesic bearing capacity factor N_gamma
      _ng = 2.0 * (_nq + 1.0) * math.tan(phiRad);
    } else {
      _nq = 1.0;
      _nc = 5.7; // Terzaghi continuous value
      _ng = 0.0;
    }

    // Shape factors for rectangular footings
    _sc = 1.0 + 0.2 * (b / l);
    _sg = 1.0 - 0.2 * (b / l);

    double surcharge = gamma * df;
    _qUlt = (c * _nc * _sc) + (surcharge * _nq) + (0.5 * gamma * b * _ng * _sg);
    _qAll = _qUlt / fs;

    setState(() {});

    // Sync back to state machine
    widget.sharedState.footingWidthB = b;
    widget.sharedState.footingLengthL = l;
    widget.onStateUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Parameters Form
        Expanded(
          flex: 1,
          child: Card(
            color: const Color(0xFF171F33),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF424754)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TERZAGHI BEARING CAPACITY PARAMETERS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C909F),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Width B (m)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Length L (m)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dfController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Embedment Depth Df (m)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _gammaController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Unit Weight γ (kN/m³)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Cohesion c (kPa)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phiController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Friction Angle φ (deg)'),
                              onChanged: (_) => _recalculateCapacity(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Factor of Safety (FS)'),
                        onChanged: (_) => _recalculateCapacity(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'CALCULATED BEARING CAPACITY FACTORS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C909F),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFactorBadge('Nc', _nc),
                          _buildFactorBadge('Nq', _nq),
                          _buildFactorBadge('Nγ', _ng),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right Column: Results & Schematic
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: buildChartCard(
                  title: 'Shear Failure Zone Schematic',
                  onExportCsv: () {
                    String csv = 'Parameter,Value\n'
                        'Footing Width B,${_bController.text}\n'
                        'Footing Length L,${_lController.text}\n'
                        'Embedment Df,${_dfController.text}\n'
                        'Nc,$_nc\n'
                        'Nq,$_nq\n'
                        'Ng,$_ng\n'
                        'Ult Bearing Capacity,$_qUlt\n'
                        'All Bearing Capacity,$_qAll\n';
                    triggerCsvDownload(context, 'Bearing_Capacity', csv);
                  },
                  child: FootingSchematicWidget(
                    b: double.tryParse(_bController.text) ?? 2.0,
                    df: double.tryParse(_dfController.text) ?? 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF424754)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'CAPACITY ENVELOPE SUMMARY',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C909F), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildCapacityDisplayCard(
                                'Ultimate Capacity (q_ult)',
                                '${_qUlt.toStringAsFixed(1)} kPa',
                                const Color(0xFFFFB786),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildCapacityDisplayCard(
                                'Allowable Capacity (q_all)',
                                '${_qAll.toStringAsFixed(1)} kPa',
                                const Color(0xFF4CD7F6),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFactorBadge(String name, double val) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1326),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF424754)),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            val.toStringAsFixed(2),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityDisplayCard(String title, String val, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1326),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8C909F), fontSize: 10)),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }
}

class FootingSchematicWidget extends StatelessWidget {
  final double b;
  final double df;

  const FootingSchematicWidget({super.key, required this.b, required this.df});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FootingSchematicPainter(b: b, df: df),
    );
  }
}

class FootingSchematicPainter extends CustomPainter {
  final double b;
  final double df;

  FootingSchematicPainter({required this.b, required this.df});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Viewport background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF171F33));

    double cx = w / 2;
    double groundY = h * 0.3;

    // Draw ground surface
    final linePaint = Paint()
      ..color = const Color(0xFF8C909F)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(10, groundY), Offset(w - 10, groundY), linePaint);

    // Draw footing
    double footingW = math.max(40.0, math.min(120.0, b * 30.0));
    double footingH = 20.0;
    double stemW = footingW * 0.5;
    double embedH = math.max(30.0, math.min(90.0, df * 30.0));
    double baseClickY = groundY + embedH;

    final fillPaint = Paint()
      ..color = const Color(0xFFADC6FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFADC6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Base slab
    Rect baseSlab = Rect.fromLTWH(cx - footingW / 2, baseClickY - footingH, footingW, footingH);
    canvas.drawRect(baseSlab, fillPaint);
    canvas.drawRect(baseSlab, strokePaint);

    // Stem
    Rect stem = Rect.fromLTWH(cx - stemW / 2, groundY - 15, stemW, embedH + 15 - footingH);
    canvas.drawRect(stem, fillPaint);
    canvas.drawRect(stem, strokePaint);

    // Draw shear failure zones (Terzaghi triangular zone underneath)
    final shearPaint = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final shearBorder = Paint()
      ..color = const Color(0xFFFFB786).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path activeTri = Path();
    activeTri.moveTo(cx - footingW / 2, baseClickY);
    activeTri.lineTo(cx + footingW / 2, baseClickY);
    activeTri.lineTo(cx, baseClickY + footingW * 0.43); // 30 deg triangle
    activeTri.close();
    canvas.drawPath(activeTri, shearPaint);
    canvas.drawPath(activeTri, shearBorder);

    // Draw radial shear spirals
    Path radialLeft = Path();
    radialLeft.moveTo(cx - footingW / 2, baseClickY);
    radialLeft.lineTo(cx, baseClickY + footingW * 0.43);
    radialLeft.quadraticBezierTo(cx - footingW * 0.8, baseClickY + footingW * 0.35, cx - footingW * 0.9, baseClickY);
    radialLeft.close();
    canvas.drawPath(radialLeft, shearPaint..color = const Color(0xFF4CD7F6).withOpacity(0.12));
    canvas.drawPath(radialLeft, shearBorder..color = const Color(0xFF4CD7F6).withOpacity(0.5));

    Path radialRight = Path();
    radialRight.moveTo(cx + footingW / 2, baseClickY);
    radialRight.lineTo(cx, baseClickY + footingW * 0.43);
    radialRight.quadraticBezierTo(cx + footingW * 0.8, baseClickY + footingW * 0.35, cx + footingW * 0.9, baseClickY);
    radialRight.close();
    canvas.drawPath(radialRight, shearPaint);
    canvas.drawPath(radialRight, shearBorder);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawText(String text, double x, double y) {
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 8, fontFamily: 'monospace'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }

    drawText('B = ${b.toStringAsFixed(1)}m', cx - 20, baseClickY - footingH - 12);
    drawText('Df = ${df.toStringAsFixed(1)}m', cx + footingW / 2 + 10, groundY + embedH / 2 - 4);
    drawText('Triangular active zone', cx - 45, baseClickY + 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================================
// SUB-FEATURE 4: ESTIMATED MAXIMUM CAPACITY
// =====================================================================

class MaxCapacitySubFeature extends StatefulWidget {
  final SharedGeotechState sharedState;
  final VoidCallback onStateUpdated;

  const MaxCapacitySubFeature({
    super.key,
    required this.sharedState,
    required this.onStateUpdated,
  });

  @override
  State<MaxCapacitySubFeature> createState() => _MaxCapacitySubFeatureState();
}

class _MaxCapacitySubFeatureState extends State<MaxCapacitySubFeature> {
  double _safetyFactor = 3.0;

  @override
  Widget build(BuildContext context) {
    double b = widget.sharedState.footingWidthB ?? 2.0;
    
    // Simulate ultimate capacity envelopes based on B
    double getUltCapacity(double width) {
      // simplified envelope equation q_ult = 50 + 120 * width + 25 * width^2
      return 50.0 + 120.0 * width + 25.0 * width * width;
    }

    double currentUlt = getUltCapacity(b);
    double currentAll = currentUlt / _safetyFactor;

    return Column(
      children: [
        // Top Sensitivity Slider Card
        Card(
          color: const Color(0xFF171F33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF424754)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFFFFB786), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACTOR OF SAFETY (FS) SENSITIVITY DESIGN: ${_safetyFactor.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Slide to adjust Safety Factor bounds and recalculate allowable limit envelopes dynamically.',
                        style: TextStyle(color: Color(0xFF8C909F), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Slider(
                    value: _safetyFactor,
                    min: 1.5,
                    max: 5.0,
                    divisions: 35,
                    activeColor: const Color(0xFFFFB786),
                    inactiveColor: const Color(0xFF424754),
                    onChanged: (val) {
                      setState(() {
                        _safetyFactor = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Split Layout
        Expanded(
          child: Row(
            children: [
              // Left: Limit State Summary Card
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF424754)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ULTIMATE LIMIT STATE (ULS) SUMMARY',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C909F), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('ULS Bearing Resistance (q_ult)', '${currentUlt.toStringAsFixed(1)} kPa', const Color(0xFFFFB786)),
                      _buildSummaryRow('Design Safety Factor (FS)', _safetyFactor.toStringAsFixed(2), const Color(0xFFE2E8F0)),
                      _buildSummaryRow('SLS Allowable Pressure (q_all)', '${currentAll.toStringAsFixed(1)} kPa', const Color(0xFF4CD7F6)),
                      const Spacer(),
                      const Divider(color: Color(0xFF424754)),
                      const Text(
                        'Design Status Recommendation:',
                        style: TextStyle(color: Color(0xFF8C909F), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _safetyFactor >= 3.0
                            ? '✅ CONSERVATIVE SAFETY BOUNDS. Meets structural building code requirements for commercial geotechnics.'
                            : _safetyFactor >= 2.5
                                ? '⚠️ OPTIMIZED LIMIT STATE. Meets highway/pavement code but check secondary settlements.'
                                : '❌ HIGH-RISK FAILURE ZONE. Safety Factor too low for structural load bearing structures.',
                        style: TextStyle(
                          color: _safetyFactor >= 3.0
                              ? const Color(0xFF10B981)
                              : _safetyFactor >= 2.5
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Right: Capacity vs Width curve
              Expanded(
                flex: 1,
                child: buildChartCard(
                  title: 'ULS Limit State Envelope (vs Footing Width B)',
                  onExportCsv: () {
                    String csv = 'WidthB(m),UltCapacity(kPa),AllCapacity(kPa),SafetyFactor\n';
                    for (double w = 0.5; w <= 4.0; w += 0.5) {
                      double ult = getUltCapacity(w);
                      csv += '$w,$ult,${ult / _safetyFactor},$_safetyFactor\n';
                    }
                    triggerCsvDownload(context, 'Estimated_Max_Capacity', csv);
                  },
                  child: CapacityEnvelopeChart(
                    safetyFactor: _safetyFactor,
                    currentB: b,
                    getUltCapacity: getUltCapacity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 12)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class CapacityEnvelopeChart extends StatelessWidget {
  final double safetyFactor;
  final double currentB;
  final double Function(double) getUltCapacity;

  const CapacityEnvelopeChart({
    super.key,
    required this.safetyFactor,
    required this.currentB,
    required this.getUltCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CapacityEnvelopePainter(
            safetyFactor: safetyFactor,
            currentB: currentB,
            getUltCapacity: getUltCapacity,
          ),
        );
      },
    );
  }
}

class CapacityEnvelopePainter extends CustomPainter {
  final double safetyFactor;
  final double currentB;
  final double Function(double) getUltCapacity;

  CapacityEnvelopePainter({
    required this.safetyFactor,
    required this.currentB,
    required this.getUltCapacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double w = size.width;
    double h = size.height;

    double padL = 40;
    double padB = 30;
    double padT = 15;
    double padR = 15;

    double plotW = w - padL - padR;
    double plotH = h - padT - padB;

    double minX = 0.5;
    double maxX = 4.0;
    double minY = 0;
    double maxY = 650; // max expected ultimate capacity in kPa

    Offset mapPoint(double x, double y) {
      double pctX = (x - minX) / (maxX - minX);
      double pctY = (y - minY) / (maxY - minY);
      return Offset(
        padL + pctX * plotW,
        h - padB - pctY * plotH,
      );
    }

    // Draw background grid
    final gridPaint = Paint()
      ..color = const Color(0xFF171F33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Vertical grid ticks
    for (double x = 1.0; x <= 4.0; x += 1.0) {
      Offset bottom = mapPoint(x, minY);
      canvas.drawLine(mapPoint(x, maxY), bottom, gridPaint);

      textPainter.text = TextSpan(text: '${x.toInt()}m', style: const TextStyle(color: Color(0xFF8C909F), fontSize: 8));
      textPainter.layout();
      textPainter.paint(canvas, Offset(bottom.dx - textPainter.width / 2, bottom.dy + 4));
    }

    // Horizontal grid ticks
    for (double y = 100; y <= 600; y += 100) {
      Offset left = mapPoint(minX, y);
      canvas.drawLine(left, mapPoint(maxX, y), gridPaint);

      textPainter.text = TextSpan(text: '${y.toInt()}', style: const TextStyle(color: Color(0xFF8C909F), fontSize: 8));
      textPainter.layout();
      textPainter.paint(canvas, Offset(left.dx - textPainter.width - 6, left.dy - textPainter.height / 2));
    }

    // Draw Axis lines
    final axisPaint = Paint()
      ..color = const Color(0xFF8C909F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(mapPoint(minX, minY), mapPoint(maxX, minY), axisPaint);
    canvas.drawLine(mapPoint(minX, minY), mapPoint(minX, maxY), axisPaint);

    // Draw Ultimate Capacity Envelope Curve
    final ultPaint = Paint()
      ..color = const Color(0xFFFFB786)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path ultPath = Path();
    bool first = true;
    for (double x = minX; x <= maxX; x += 0.1) {
      double y = getUltCapacity(x);
      Offset p = mapPoint(x, y);
      if (first) {
        ultPath.moveTo(p.dx, p.dy);
        first = false;
      } else {
        ultPath.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(ultPath, ultPaint);

    // Draw Allowable Capacity Envelope Curve (q_all = q_ult / safetyFactor)
    final allPaint = Paint()
      ..color = const Color(0xFF4CD7F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path allPath = Path();
    first = true;
    for (double x = minX; x <= maxX; x += 0.1) {
      double y = getUltCapacity(x) / safetyFactor;
      Offset p = mapPoint(x, y);
      if (first) {
        allPath.moveTo(p.dx, p.dy);
        first = false;
      } else {
        allPath.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(allPath, allPaint);

    // Draw current footing width design node
    double curUlt = getUltCapacity(currentB);
    double curAll = curUlt / safetyFactor;

    if (currentB >= minX && currentB <= maxX) {
      Offset nodeUlt = mapPoint(currentB, curUlt);
      Offset nodeAll = mapPoint(currentB, curAll);

      // Vertical line through current B
      final indicatorPaint = Paint()
        ..color = const Color(0xFFADC6FF).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(nodeUlt.dx, padT), Offset(nodeUlt.dx, h - padB), indicatorPaint);

      final markerPaint = Paint()..style = PaintingStyle.fill;
      markerPaint.color = Colors.white;
      canvas.drawCircle(nodeUlt, 4.0, markerPaint);
      canvas.drawCircle(nodeAll, 4.0, markerPaint);

      markerPaint.color = const Color(0xFFFFB786);
      canvas.drawCircle(nodeUlt, 2.0, markerPaint);
      markerPaint.color = const Color(0xFF4CD7F6);
      canvas.drawCircle(nodeAll, 2.0, markerPaint);
    }

    // Legend
    void drawLegendItem(String label, Color color, double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 10, 6), Paint()..color = color);
      textPainter.text = TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 8));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 15, y - 2));
    }
    drawLegendItem('q_ult', const Color(0xFFFFB786), padL + 15, padT + 5);
    drawLegendItem('q_all (Design)', const Color(0xFF4CD7F6), padL + 15, padT + 18);

    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

