import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';

class AiResponseBubble extends StatelessWidget {
  final AiResponse response;
  final bool isError;

  const AiResponseBubble({
    super.key,
    required this.response,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.recommendation ??
                      'An error occurred while processing your query.',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Normal (success) response
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.history,
                    size: 16, color: AppColors.textSecondary.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 12),
            response.isGeneralInventory
                ? _buildGeneralInventoryUI(response)
                : response.isTrendResponse
                    ? _buildTrendUI(response)
                    : _buildInventoryUI(response),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInventoryUI(AiResponse response) {
    final topCategories = response.topCategories ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.blueLight.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.dashboard_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Overall Inventory Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Key Metrics Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.inventory_2_outlined,
                label: 'Total Products',
                value: response.totalProducts?.toString() ?? '0',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.trending_up,
                label: 'Total Stock',
                value: response.currentStock?.toString() ?? '0',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.warning_amber_outlined,
                label: 'Low Stock',
                value: response.lowStockItems?.toString() ?? '0',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.error_outline,
                label: 'Out of Stock',
                value: response.outOfStockItems?.toString() ?? '0',
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Average Daily Sales
        _buildDataRow(
          icon: Icons.analytics_outlined,
          label: 'Avg. Daily Sales',
          value: '${response.averageDailySales?.toStringAsFixed(2) ?? '0'} units/day',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        
        // Top Categories
        if (topCategories.isNotEmpty) ...[
          const Text(
            'Top Categories by Stock:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...topCategories.take(5).map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${cat.stock} units',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        
        // Summary
        if (response.summary != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    response.summary!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Recommendation
        if (response.recommendation != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (response.restockNeeded ?? false)
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  (response.restockNeeded ?? false)
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (response.restockNeeded ?? false)
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  (response.restockNeeded ?? false)
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
                  size: 20,
                  color: (response.restockNeeded ?? false)
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommendation: ${response.recommendation}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryUI(AiResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.grayLight,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.item ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildDataRow(
            icon: Icons.trending_up_outlined,
            label: 'Current Stock',
            value: response.currentStock.toString(),
            color: AppColors.success),
        const SizedBox(height: 8),
        _buildDataRow(
            icon: Icons.analytics_outlined,
            label: 'Avg. Daily Sales',
            value: response.averageDailySales.toString(),
            color: AppColors.warning),
        const SizedBox(height: 8),
        _buildDataRow(
          icon: Icons.warning_amber_outlined,
          label: 'Restock Needed',
          value: (response.restockNeeded ?? false) ? 'Yes' : 'No',
          color: (response.restockNeeded ?? false)
              ? AppColors.error
              : AppColors.success,
          isBold: true,
        ),
        const SizedBox(height: 12),
        // Recommendation box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.blueLight.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recommendation: ${response.recommendation}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendUI(AiResponse response) {
    final trends = response.predictedTrends ?? [];
    final suggestions = response.restockSuggestions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.overallPrediction ?? 'No prediction available.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Top Predicted Trends:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (trends.isNotEmpty) ...[
          SizedBox(height: 180, child: _buildHotScoresChart(trends)),
          const SizedBox(height: 12),
          ...trends.take(5).map((trend) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${trend.hotScore.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _extractKeyPhrase(trend.keyword),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            trend.suggestion,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ] else
          const Text('No trends found.',
              style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        if (suggestions.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Restock Suggestions:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              ...suggestions.map(
                (sug) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sug,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHotScoresChart(List<PredictedTrend> trends) {
    final maxScore =
        trends.map((t) => t.hotScore).reduce((a, b) => a > b ? a : b);
    final barData = trends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      final normalizedScore = (trend.hotScore / maxScore) * 100;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: normalizedScore,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.success],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: AppColors.lightGray,
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < trends.length) {
                  // Extract short label for chart (first 15 chars or first word)
                  String label = _extractKeyPhrase(trends[index].keyword);
                  if (label.length > 15) {
                    final words = label.split(' ');
                    label = words.isNotEmpty ? words[0] : label.substring(0, 15);
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barData,
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  /// Extract key phrase from long keyword text
  /// Removes "Christmas" prefix and extracts meaningful content
  String _extractKeyPhrase(String keyword) {
    // Remove "Christmas" prefix if present
    String cleaned = keyword.replaceFirst(RegExp(r'^Christmas\s+', caseSensitive: false), '');
    
    // If still too long, try to extract the main topic
    if (cleaned.length > 60) {
      // Look for patterns like "The X Key..." or "X Fashion Trends"
      final trendMatch = RegExp(r'(\d+\s+Key\s+[^—]+)|([^—]+Fashion\s+Trends)', caseSensitive: false).firstMatch(cleaned);
      if (trendMatch != null) {
        cleaned = trendMatch.group(0) ?? cleaned;
      } else {
        // Take first 60 characters
        cleaned = cleaned.substring(0, 60);
      }
    }
    
    // Clean up common prefixes
    cleaned = cleaned
        .replaceFirst(RegExp(r'^It May Be\s+', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^But\s+', caseSensitive: false), '')
        .trim();
    
    return cleaned;
  }
}
