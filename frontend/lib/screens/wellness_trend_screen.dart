import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/wellness_assessment.dart';
import '../services/auth_service.dart';
import '../services/wellness_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/loading_indicator.dart';

class WellnessTrendScreen extends StatefulWidget {
  const WellnessTrendScreen({super.key});

  @override
  State<WellnessTrendScreen> createState() => _WellnessTrendScreenState();
}

class _WellnessTrendScreenState extends State<WellnessTrendScreen> {
  Future<List<WellnessAssessment>>? _trendFuture;

  bool _showAllTime = false;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  // ===========================================================
  // Load Trend
  // Retrieves all saved wellness assessments once.
  // Filtering is handled locally for low complexity and speed.
  // ===========================================================
  void _loadTrend() {
    final user = AuthService.currentUser;

    if (user == null) {
      _trendFuture = Future.value([]);
      return;
    }

    _trendFuture = WellnessService.getAssessmentTrend(user.uid);
  }

  // ===========================================================
  // Filter Assessments
  // Returns either all assessments or the selected year only.
  // ===========================================================
  List<WellnessAssessment> _filteredAssessments(
    List<WellnessAssessment> assessments,
  ) {
    if (_showAllTime) {
      return assessments;
    }

    return assessments
        .where(
          (assessment) => assessment.year == _selectedYear,
        )
        .toList();
  }

  // ===========================================================
  // Available Years
  // Extracts unique assessment years.
  // ===========================================================
  List<int> _availableYears(
    List<WellnessAssessment> assessments,
  ) {
    final years = assessments
        .map(
          (assessment) => assessment.year,
        )
        .toSet()
        .toList();

    years.sort((a, b) => b.compareTo(a));

    return years;
  }

  // ===========================================================
  // Month Name
  // ===========================================================
  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  // ===========================================================
  // Short Month Name
  // Used for compact chart labels.
  // ===========================================================
  String _monthShortName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  // ===========================================================
  // Chart Spots
  // Converts assessment scores into line chart points.
  // ===========================================================
  List<FlSpot> _buildChartSpots(
    List<WellnessAssessment> assessments,
  ) {
    return List.generate(
      assessments.length,
      (index) => FlSpot(
        index.toDouble(),
        assessments[index].score.toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // ===========================================================
      appBar: AppBar(
        title: const Text('Wellness Trends'),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: FutureBuilder<List<WellnessAssessment>>(
            future: _trendFuture,
            builder: (context, snapshot) {
              // ===========================================================
              // Loading State
              // ===========================================================
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingIndicator(),
                );
              }

              // ===========================================================
              // Error State
              // ===========================================================
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load your wellness history.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _loadTrend();
                          });
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final assessments = snapshot.data ?? [];

              // ===========================================================
              // Empty State
              // ===========================================================
              if (assessments.isEmpty) {
                return const Center(
                  child: Text(
                    'No wellness assessments yet.',
                    style: AppTextStyles.body,
                  ),
                );
              }

              final availableYears = _availableYears(assessments);

              if (!availableYears.contains(_selectedYear)) {
                _selectedYear = availableYears.first;
              }

              final filteredAssessments = _filteredAssessments(assessments);

              final chartSpots = _buildChartSpots(filteredAssessments);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================================================
                  // Trend Header
                  // =========================================================
                  const Text(
                    'Your Wellness Trend',
                    style: AppTextStyles.heading1,
                  ),

                  const SizedBox(height: AppSpacing.medium),

                  // =========================================================
                  // Trend View Selector
                  // =========================================================
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Yearly'),
                        icon: Icon(
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('All Time'),
                        icon: Icon(
                          Icons.timeline,
                        ),
                      ),
                    ],
                    selected: {_showAllTime},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _showAllTime = selection.first;
                      });
                    },
                  ),

                  // =========================================================
                  // Year Selector
                  // =========================================================
                  if (!_showAllTime) ...[
                    const SizedBox(
                      height: AppSpacing.medium,
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(
                          Icons.calendar_month_outlined,
                        ),
                      ),
                      items: availableYears
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ),
                          )
                          .toList(),
                      onChanged: (year) {
                        if (year == null) return;

                        setState(() {
                          _selectedYear = year;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.large),

                  // =========================================================
                  // No Data for Selected Period
                  // =========================================================
                  if (filteredAssessments.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No assessments were completed during this period.',
                          style: AppTextStyles.body,
                        ),
                      ),
                    )
                  else ...[
                    // =======================================================
                    // Wellness Trend Chart
                    // GHQ score range is fixed from 0 to 12.
                    // =======================================================
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 12,
                          gridData: const FlGridData(
                            show: true,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 2,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 1,
                                getTitlesWidget: (
                                  value,
                                  meta,
                                ) {
                                  final index = value.toInt();

                                  if (index < 0 ||
                                      index >= filteredAssessments.length) {
                                    return const SizedBox.shrink();
                                  }

                                  final assessment = filteredAssessments[index];

                                  final label = _showAllTime
                                      ? '${_monthShortName(assessment.month)} '
                                          '${assessment.year}'
                                      : _monthShortName(
                                          assessment.month,
                                        );

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.xSmall,
                                    ),
                                    child: Text(
                                      label,
                                      style: AppTextStyles.caption,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartSpots,
                              isCurved: true,
                              barWidth: 3,
                              dotData: const FlDotData(
                                show: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // =======================================================
                    // Previous Assessments
                    // =======================================================
                    const Text(
                      'Previous Assessments',
                      style: AppTextStyles.heading2,
                    ),

                    const SizedBox(
                      height: AppSpacing.medium,
                    ),

                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredAssessments.length,
                        separatorBuilder: (
                          context,
                          index,
                        ) {
                          return const Divider();
                        },
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final reversedAssessments =
                              filteredAssessments.reversed.toList();

                          final assessment = reversedAssessments[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.insights_outlined,
                            ),
                            title: Text(
                              '${_monthName(assessment.month)} '
                              '${assessment.year}',
                              style: AppTextStyles.title,
                            ),
                            subtitle: const Text(
                              'Monthly wellness assessment',
                            ),
                            trailing: Text(
                              '${assessment.score} / 12',
                              style: AppTextStyles.heading2,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
