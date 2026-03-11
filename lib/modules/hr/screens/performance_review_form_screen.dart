import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/performance_review_service.dart';
import '../models/performance_review_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';

class PerformanceReviewFormScreen extends StatefulWidget {
  final String? reviewId; // null for new review
  final String? employeeId; // Required for new review
  final String? employeeName;

  const PerformanceReviewFormScreen({
    super.key,
    this.reviewId,
    this.employeeId,
    this.employeeName,
  });

  @override
  State<PerformanceReviewFormScreen> createState() =>
      _PerformanceReviewFormScreenState();
}

class _PerformanceReviewFormScreenState
    extends State<PerformanceReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _periodController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _improvementsController = TextEditingController();
  final _goalsController = TextEditingController();
  final _commentsController = TextEditingController();

  int _qualityScore = 3;
  int _productivityScore = 3;
  int _attendanceScore = 3;
  int _teamworkScore = 3;
  int _initiativeScore = 3;

  bool _isLoading = false;
  PerformanceReview? _existingReview;

  @override
  void initState() {
    super.initState();
    if (widget.reviewId != null) {
      _loadExistingReview();
    }
  }

  Future<void> _loadExistingReview() async {
    setState(() => _isLoading = true);
    final service = context.read<PerformanceReviewService>();
    final review = await service.getReviewById(widget.reviewId!);

    if (review != null) {
      setState(() {
        _existingReview = review;
        _periodController.text = review.reviewPeriod;
        _qualityScore = review.qualityScore ?? 3;
        _productivityScore = review.productivityScore ?? 3;
        _attendanceScore = review.attendanceScore ?? 3;
        _teamworkScore = review.teamworkScore ?? 3;
        _initiativeScore = review.initiativeScore ?? 3;
        _strengthsController.text = review.strengths ?? '';
        _improvementsController.text = review.improvements ?? '';
        _goalsController.text = review.goals ?? '';
        _commentsController.text = review.managerComments ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _periodController.dispose();
    _strengthsController.dispose();
    _improvementsController.dispose();
    _goalsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewId != null ? 'Edit Review' : 'New Review'),
        actions: [
          if (_existingReview?.status == 'Draft')
            TextButton(
              onPressed: _submitReview,
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.employeeName != null)
                      Text(
                        'Employee: ${widget.employeeName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _periodController,
                      decoration: const InputDecoration(
                        labelText: 'Review Period',
                        hintText: 'e.g., Q1-2026, 2025-Annual',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Performance Scores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildScoreSlider(
                      'Quality of Work',
                      _qualityScore,
                      (v) => setState(() => _qualityScore = v),
                    ),
                    _buildScoreSlider(
                      'Productivity',
                      _productivityScore,
                      (v) => setState(() => _productivityScore = v),
                    ),
                    _buildScoreSlider(
                      'Attendance',
                      _attendanceScore,
                      (v) => setState(() => _attendanceScore = v),
                    ),
                    _buildScoreSlider(
                      'Teamwork',
                      _teamworkScore,
                      (v) => setState(() => _teamworkScore = v),
                    ),
                    _buildScoreSlider(
                      'Initiative',
                      _initiativeScore,
                      (v) => setState(() => _initiativeScore = v),
                    ),
                    const Divider(height: 32),
                    _buildOverallRating(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _strengthsController,
                      decoration: const InputDecoration(
                        labelText: 'Strengths',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _improvementsController,
                      decoration: const InputDecoration(
                        labelText: 'Areas for Improvement',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalsController,
                      decoration: const InputDecoration(
                        labelText: 'Goals for Next Period',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentsController,
                      decoration: const InputDecoration(
                        labelText: 'Manager Comments',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveReview,
                        child: Text(
                          widget.reviewId != null ? 'Update' : 'Save as Draft',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScoreSlider(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: value.toString(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text('$value', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
    final avg =
        (_qualityScore +
            _productivityScore +
            _attendanceScore +
            _teamworkScore +
            _initiativeScore) /
        5;
    final label = _getRatingLabel(avg);

    return Card(
      color: _getRatingColor(avg).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getRatingColor(avg),
                  ),
                ),
                Text(label, style: TextStyle(color: _getRatingColor(avg))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Outstanding';
    if (rating >= 3.5) return 'Exceeds Expectations';
    if (rating >= 2.5) return 'Meets Expectations';
    if (rating >= 1.5) return 'Needs Improvement';
    return 'Unsatisfactory';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.blue;
    if (rating >= 2) return Colors.orange;
    return Colors.red;
  }

  Future<void> _saveReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final service = context.read<PerformanceReviewService>();

      if (widget.reviewId == null) {
        // Create new review
        final review = await service.createReview(
          employeeId: widget.employeeId!,
          reviewerId: auth.currentUser!.id,
          reviewPeriod: _periodController.text,
        );
        await service.updateScores(
          reviewId: review.id,
          qualityScore: _qualityScore,
          productivityScore: _productivityScore,
          attendanceScore: _attendanceScore,
          teamworkScore: _teamworkScore,
          initiativeScore: _initiativeScore,
          strengths: _strengthsController.text,
          improvements: _improvementsController.text,
          goals: _goalsController.text,
          managerComments: _commentsController.text,
        );
      } else {
        await service.updateScores(
          reviewId: widget.reviewId!,
          qualityScore: _qualityScore,
          productivityScore: _productivityScore,
          attendanceScore: _attendanceScore,
          teamworkScore: _teamworkScore,
          initiativeScore: _initiativeScore,
          strengths: _strengthsController.text,
          improvements: _improvementsController.text,
          goals: _goalsController.text,
          managerComments: _commentsController.text,
        );
      }

      if (mounted) {
        AppToast.showSuccess(context, 'Review saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<PerformanceReviewService>();
      await service.submitReview(widget.reviewId!);

      if (mounted) {
        AppToast.showSuccess(context, 'Review submitted');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
