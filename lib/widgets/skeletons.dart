import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-wrapped placeholder box; used as a building block by the
/// concrete skeleton widgets below.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ShimmerWrapper extends StatelessWidget {
  final Widget child;
  const _ShimmerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHigh,
      highlightColor: scheme.surfaceContainerHighest,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// A list of placeholder currency rows shown while the initial rates
/// list is loading. Matches CurrencyListItem's rough shape so the swap
/// is visually stable.
class CurrencyListSkeleton extends StatelessWidget {
  final int rows;
  const CurrencyListSkeleton({super.key, this.rows = 6});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const _CurrencyRowSkeleton(),
      ),
    );
  }
}

class _CurrencyRowSkeleton extends StatelessWidget {
  const _CurrencyRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 30, radius: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 60, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 10),
              ],
            ),
          ),
          const SkeletonBox(width: 50, height: 20),
          const SizedBox(width: 24),
          const SkeletonBox(width: 50, height: 20),
        ],
      ),
    );
  }
}

/// Placeholder shown while a currency's history is loading in the graph
/// view — a card-shaped area with a rough line-chart silhouette.
class GraphSkeleton extends StatelessWidget {
  const GraphSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 120, height: 20),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 32, radius: 10),
            const SizedBox(height: 24),
            SkeletonBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              radius: 16,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SkeletonBox(width: 60, height: 32, radius: 10),
                SkeletonBox(width: 60, height: 32, radius: 10),
                SkeletonBox(width: 60, height: 32, radius: 10),
                SkeletonBox(width: 60, height: 32, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
