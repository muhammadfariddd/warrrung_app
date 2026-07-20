import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Standard Shimmer wrapper using sleek grey gradient shades.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}

/// Generic skeleton box helper widget with custom dimensions and border radius.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    if (shape != null) {
      return Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey.shade300,
          shape: shape!,
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton loading layout for Home Page (matching bima+ reference style).
class HomeSkeletonWidget extends StatelessWidget {
  const HomeSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Carousel / Stats Cards Skeleton Container (Bordered card with 3 pills inside)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      SkeletonBox(width: 60, height: 12, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 45, height: 10, borderRadius: 5),
                      SizedBox(height: 10),
                      SkeletonBox(width: 80, height: 36, borderRadius: 18),
                    ],
                  ),
                  Column(
                    children: [
                      SkeletonBox(width: 60, height: 12, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 45, height: 10, borderRadius: 5),
                      SizedBox(height: 10),
                      SkeletonBox(width: 80, height: 36, borderRadius: 18),
                    ],
                  ),
                  Column(
                    children: [
                      SkeletonBox(width: 60, height: 12, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 45, height: 10, borderRadius: 5),
                      SizedBox(height: 10),
                      SkeletonBox(width: 80, height: 36, borderRadius: 18),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Large Promo Banner Skeleton
            const SkeletonBox(
              width: double.infinity,
              height: 160,
              borderRadius: 24,
            ),
            const SizedBox(height: 24),

            // 3. Circle Quick Menu Icons Row Skeleton (5 Circles)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 54, height: 54, shape: CircleBorder()),
                SkeletonBox(width: 54, height: 54, shape: CircleBorder()),
                SkeletonBox(width: 54, height: 54, shape: CircleBorder()),
                SkeletonBox(width: 54, height: 54, shape: CircleBorder()),
                SkeletonBox(width: 54, height: 54, shape: CircleBorder()),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Two Horizontal Pill Bars Skeleton
            const Row(
              children: [
                Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Product Grid / Special Section Skeleton (3 Vertical Rounded Cards)
            const Row(
              children: [
                Expanded(child: SkeletonBox(height: 160, borderRadius: 20)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 160, borderRadius: 20)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 160, borderRadius: 20)),
              ],
            ),
            const SizedBox(height: 24),

            // 6. Bottom Double Pill Bars Skeleton
            const Row(
              children: [
                Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading layout for Menu Page.
class MenuSkeletonWidget extends StatelessWidget {
  const MenuSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tabs Row Skeleton
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  SkeletonBox(width: 90, height: 36, borderRadius: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 100, height: 36, borderRadius: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 80, height: 36, borderRadius: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 110, height: 36, borderRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Cards List Skeleton
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: double.infinity,
                          height: 110,
                          borderRadius: 12,
                        ),
                        SizedBox(height: 12),
                        SkeletonBox(width: 110, height: 14, borderRadius: 6),
                        SizedBox(height: 6),
                        SkeletonBox(width: 70, height: 12, borderRadius: 6),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonBox(width: 60, height: 16, borderRadius: 6),
                            SkeletonBox(width: 32, height: 32, shape: CircleBorder()),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading layout for Location Selection Page.
class LocationSkeletonWidget extends StatelessWidget {
  const LocationSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SkeletonBox(width: 42, height: 42, shape: CircleBorder()),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 16, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 200, height: 12, borderRadius: 6),
                      SizedBox(height: 6),
                      SkeletonBox(width: 100, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                SkeletonBox(width: 60, height: 32, borderRadius: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
