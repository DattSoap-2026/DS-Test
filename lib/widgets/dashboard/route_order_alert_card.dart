import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/types/route_order_types.dart';
import '../../services/route_order_service.dart';

class RouteOrderAlertCard extends StatefulWidget {
  final RouteOrderProductionStatus? productionStatus;
  final RouteOrderDispatchStatus? dispatchStatus;
  final Duration rotateEvery;
  final int limit;

  const RouteOrderAlertCard({
    super.key,
    this.productionStatus = RouteOrderProductionStatus.pending,
    this.dispatchStatus = RouteOrderDispatchStatus.pending,
    this.rotateEvery = const Duration(seconds: 4),
    this.limit = 150,
  });

  @override
  State<RouteOrderAlertCard> createState() => _RouteOrderAlertCardState();
}

class _RouteOrderAlertCardState extends State<RouteOrderAlertCard> {
  late final RouteOrderService _routeOrderService;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  Timer? _rotateTimer;
  int _currentIndex = 0;
  int _activeOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _routeOrderService = context.read<RouteOrderService>();
  }

  @override
  void dispose() {
    _stopRotation();
    super.dispose();
  }

  void _startRotation() {
    if (_rotateTimer != null) return;
    _rotateTimer = Timer.periodic(widget.rotateEvery, (_) {
      if (!mounted || _activeOrderCount <= 1) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _activeOrderCount;
      });
    });
  }

  void _stopRotation() {
    _rotateTimer?.cancel();
    _rotateTimer = null;
  }

  void _syncRotation(int orderCount) {
    _activeOrderCount = orderCount;
    if (orderCount <= 1) {
      _stopRotation();
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= orderCount) {
      _currentIndex = 0;
    }
    _startRotation();
  }

  String _resolveCustomer(RouteOrder order) {
    final dealerName = order.dealerName.trim();
    if (dealerName.isNotEmpty && dealerName != '-') {
      return dealerName;
    }
    final salesmanName = order.salesmanName.trim();
    if (salesmanName.isNotEmpty) {
      return salesmanName;
    }
    return 'Unknown Customer';
  }

  String _resolveRoute(RouteOrder order) {
    final routeName = order.routeName.trim();
    return routeName.isEmpty ? 'Unknown Route' : routeName;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RouteOrder>>(
      stream: _routeOrderService.watchOrders(
        productionStatus: widget.productionStatus,
        dispatchStatus: widget.dispatchStatus,
        limit: widget.limit,
      ),
      builder: (context, snapshot) {
        final orders = (snapshot.data ?? const <RouteOrder>[])
            .where((order) => !order.isCancelled && !order.isDispatched)
            .toList()
          ..sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));

        _syncRotation(orders.length);

        if (orders.isEmpty) {
          return const SizedBox.shrink();
        }

        final safeIndex = _currentIndex % orders.length;
        final order = orders[safeIndex];
        final theme = Theme.of(context);
        final isMobile = MediaQuery.sizeOf(context).width < 700;

        final routeName = _resolveRoute(order);
        final customerName = _resolveCustomer(order);
        final amountText = _currencyFormat.format(order.totalAmount);
        final orderNoText = order.orderNo.trim().isEmpty
            ? order.id
            : order.orderNo.trim();
        final orderNoDisplay = orderNoText.startsWith('#')
            ? orderNoText
            : '#$orderNoText';
        final showCounter = orders.length > 1;
        final counterLabel = '${safeIndex + 1}/${orders.length}';

        final isDark = theme.brightness == Brightness.dark;
        final cardGradient = isDark
            ? const [Color(0xFF0B1D4D), Color(0xFF08153A)]
            : const [Color(0xFFEAF2FF), Color(0xFFDDEBFF)];
        final borderColor = isDark
            ? const Color(0xFF2C64F5)
            : const Color(0xFF7AA6FF);
        final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final detailColor = isDark
            ? const Color(0xFFAEC3F5)
            : const Color(0xFF334155);
        final amountColor = isDark
            ? const Color(0xFFFDE68A)
            : const Color(0xFFB45309);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cardGradient,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor.withValues(alpha: 0.9)),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: isDark ? 0.25 : 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF22D3EE), Color(0xFF2563EB)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    isMobile ? 12 : 14,
                    14,
                    isMobile ? 12 : 14,
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardBody(
                              context: context,
                              order: order,
                              headingColor: headingColor,
                              detailColor: detailColor,
                              amountColor: amountColor,
                              routeName: routeName,
                              customerName: customerName,
                              orderNoText: orderNoDisplay,
                              amountText: amountText,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (showCounter) ...[
                                  _buildCounterChip(
                                    context,
                                    counterLabel,
                                    detailColor,
                                    isDark,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                _buildViewOrderButton(),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildCardBody(
                                context: context,
                                order: order,
                                headingColor: headingColor,
                                detailColor: detailColor,
                                amountColor: amountColor,
                                routeName: routeName,
                                customerName: customerName,
                                orderNoText: orderNoDisplay,
                                amountText: amountText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (showCounter) ...[
                              _buildCounterChip(
                                context,
                                counterLabel,
                                detailColor,
                                isDark,
                              ),
                              const SizedBox(width: 10),
                            ],
                            _buildViewOrderButton(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBody({
    required BuildContext context,
    required RouteOrder order,
    required Color headingColor,
    required Color detailColor,
    required Color amountColor,
    required String routeName,
    required String customerName,
    required String orderNoText,
    required String amountText,
  }) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slideTween = Tween<Offset>(
          begin: const Offset(0, -0.06),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideTween.animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<String>('route_order_${order.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '\u{1F4E6}',
                style: const TextStyle(
                  fontSize: 22,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFF87171).withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        child: Text(
                          'NEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFCA5A5),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        'New Order Received',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: headingColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$routeName \u2022 $customerName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: detailColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        orderNoText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: detailColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        amountText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterChip(
    BuildContext context,
    String label,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark
                ? const Color(0xFF1E3A8A)
                : const Color(0xFFDBEAFE))
            .withValues(alpha: isDark ? 0.5 : 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (isDark
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF93C5FD))
              .withValues(alpha: isDark ? 0.7 : 0.9),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildViewOrderButton() {
    return FilledButton(
      onPressed: () => context.push('/dashboard/orders/route-management'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'View Order',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
