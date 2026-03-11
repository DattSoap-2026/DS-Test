import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/ui/shimmer_loading.dart';

class ShimmerListLoader extends StatelessWidget {
  final int itemCount;
  final bool hasAvatar;
  final bool hasSubtitle;
  final bool hasTrailing;
  final double tileHeight;

  const ShimmerListLoader({
    super.key,
    this.itemCount = 10,
    this.hasAvatar = true,
    this.hasSubtitle = true,
    this.hasTrailing = true,
    this.tileHeight = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ShimmerLoading(
            isLoading: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasAvatar)
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasAvatar) const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      if (hasSubtitle) const SizedBox(height: 8.0),
                      if (hasSubtitle)
                        Container(
                          width: 150.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasTrailing) const SizedBox(width: 16.0),
                if (hasTrailing)
                  Container(
                    width: 40.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
