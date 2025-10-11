import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// Shimmer loading widget for skeleton screens
class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxShape shape;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius ?? AppDecorations.radiusSM)
              : null,
        ),
      ),
    );
  }
}

/// Skeleton loader for list items
class SkeletonListItem extends StatelessWidget {
  final bool hasImage;
  final int lines;

  const SkeletonListItem({
    super.key,
    this.hasImage = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDecorations.spaceMD,
        vertical: AppDecorations.spaceSM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            const ShimmerLoading(
              width: 60,
              height: 60,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: AppDecorations.spaceMD),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: AppDecorations.spaceSM),
                for (int i = 0; i < lines - 1; i++) ...[
                  ShimmerLoading(
                    height: 14,
                    width: i == lines - 2 ? 200.0 : double.infinity,
                  ),
                  const SizedBox(height: AppDecorations.spaceSM),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for cards
class SkeletonCard extends StatelessWidget {
  final double? height;
  final bool hasImage;

  const SkeletonCard({
    super.key,
    this.height,
    this.hasImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            const ShimmerLoading(
              height: 200,
              width: double.infinity,
              borderRadius: 0,
            ),
          Padding(
            padding: const EdgeInsets.all(AppDecorations.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(
                  height: 20,
                  width: 200,
                ),
                const SizedBox(height: AppDecorations.spaceSM),
                const ShimmerLoading(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: AppDecorations.spaceSM),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for grid items
class SkeletonGridItem extends StatelessWidget {
  const SkeletonGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: ShimmerLoading(
              width: double.infinity,
              borderRadius: 0,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppDecorations.spaceSM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  height: 16,
                  width: double.infinity,
                ),
                SizedBox(height: AppDecorations.spaceSM),
                ShimmerLoading(
                  height: 14,
                  width: 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full page skeleton loader
class SkeletonPage extends StatelessWidget {
  final int itemCount;
  final bool hasAppBar;

  const SkeletonPage({
    super.key,
    this.itemCount = 5,
    this.hasAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hasAppBar)
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDecorations.spaceMD,
            ),
            child: const Row(
              children: [
                ShimmerLoading(width: 24, height: 24),
                SizedBox(width: AppDecorations.spaceMD),
                Expanded(
                  child: ShimmerLoading(height: 20),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) => const SkeletonListItem(),
          ),
        ),
      ],
    );
  }
}
