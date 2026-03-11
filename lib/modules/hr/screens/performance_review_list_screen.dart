import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/performance_review_service.dart';
import '../models/performance_review_model.dart';
import '../services/hr_service.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class PerformanceReviewListScreen extends StatefulWidget {
  const PerformanceReviewListScreen({super.key});

  @override
  State<PerformanceReviewListScreen> createState() =>
      _PerformanceReviewListScreenState();
}

class _PerformanceReviewListScreenState
    extends State<PerformanceReviewListScreen> {
  List<PerformanceReview> _reviews = [];
  bool _isLoading = true;
  String? _linkedEmployeeId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final auth = context.read<AuthProvider>();
    final service = context.read<PerformanceReviewService>();
    final hrService = context.read<HrService>();
    final userId = auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      setState(() {
        _linkedEmployeeId = null;
        _reviews = const [];
        _isLoading = false;
      });
      return;
    }

    try {
      final employee = await hrService.getEmployeeByUserId(userId);
      final reviews = await service.getVisibleReviewsForUser(
        userId: userId,
        linkedEmployeeId: employee?.employeeId,
      );
      if (!mounted) return;
      setState(() {
        _linkedEmployeeId = employee?.employeeId;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load reviews right now.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Performance Reviews'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReviews),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _buildEmptyState(_loadError!)
          : _reviews.isEmpty
          ? _buildEmptyState(_buildNoReviewsMessage())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _reviews.length,
              itemBuilder: (ctx, i) => _buildReviewCard(_reviews[i]),
            ),
    );
  }

  Widget _buildReviewCard(PerformanceReview review) {
    final rating = review.overallRating ?? review.calculateOverallRating();
    final color = _getRatingColor(rating);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _showReviewDetails(review),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.reviewPeriod,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      review.status,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: _getStatusColor(
                      review.status,
                    ).withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.ratingLabel, style: TextStyle(color: color)),
                      Text(
                        '${review.reviewDate.day}/${review.reviewDate.month}/${review.reviewDate.year}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (review.status == 'Submitted' && _canAcknowledge(review)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _acknowledgeReview(review),
                    child: const Text('Acknowledge'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.blue;
    if (rating >= 2) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Draft':
        return colorScheme.onSurfaceVariant;
      case 'Submitted':
        return Colors.orange;
      case 'Acknowledged':
        return Colors.green;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  bool _canAcknowledge(PerformanceReview review) {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) return false;
    if (review.employeeId == userId) return true; // legacy local data mapping
    return _linkedEmployeeId != null && review.employeeId == _linkedEmployeeId;
  }

  String _buildNoReviewsMessage() {
    final hasLinkedEmployee =
        _linkedEmployeeId != null && _linkedEmployeeId!.isNotEmpty;
    if (hasLinkedEmployee) return 'No reviews yet';
    return 'No reviews yet. Link employee profile with this user in HR employee master.';
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  void _showReviewDetails(PerformanceReview review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                review.reviewPeriod,
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _scoreRow('Quality', review.qualityScore),
              _scoreRow('Productivity', review.productivityScore),
              _scoreRow('Attendance', review.attendanceScore),
              _scoreRow('Teamwork', review.teamworkScore),
              _scoreRow('Initiative', review.initiativeScore),
              const Divider(height: 24),
              if (review.strengths?.isNotEmpty == true) ...[
                Text('Strengths', style: Theme.of(ctx).textTheme.titleSmall),
                Text(review.strengths!),
                const SizedBox(height: 12),
              ],
              if (review.improvements?.isNotEmpty == true) ...[
                Text(
                  'Areas for Improvement',
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                Text(review.improvements!),
                const SizedBox(height: 12),
              ],
              if (review.goals?.isNotEmpty == true) ...[
                Text('Goals', style: Theme.of(ctx).textTheme.titleSmall),
                Text(review.goals!),
                const SizedBox(height: 12),
              ],
              if (review.managerComments?.isNotEmpty == true) ...[
                Text(
                  'Manager Comments',
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                Text(review.managerComments!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(String label, int? score) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < (score ?? 0) ? Icons.star : Icons.star_border,
                size: 20,
                color: i < (score ?? 0)
                    ? Colors.amber
                    : colorScheme.outlineVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledgeReview(PerformanceReview review) async {
    final commentController = TextEditingController();
    final service = context.read<PerformanceReviewService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('Acknowledge Review'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Your Comments (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.acknowledgeReview(review.id, commentController.text);
      _loadReviews();
      if (mounted) {
        AppToast.showSuccess(context, 'Review acknowledged');
      }
    }
  }
}

