import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/models/rating.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/rating_provider.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class RatingSection extends StatefulWidget {
  final Product product;

  const RatingSection({super.key, required this.product});

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  bool _reviewsExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load rating data when the section is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRatingData();
    });
  }

  void _loadRatingData() {
    final ratingProvider = context.ratingProvider;
    final user = context.userProvider.getLoginUsr();

    if (user != null) {
      ratingProvider.getRatingStats(widget.product.sId!);
      ratingProvider.getRatingsForProduct(widget.product.sId!);
      ratingProvider.getUserRating(widget.product.sId!, user.sId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        final stats = ratingProvider.productRatingStats[widget.product.sId!];
        final userRating = ratingProvider.userRatings[widget.product.sId!];
        final ratingsResponse =
            ratingProvider.productRatings[widget.product.sId!];

        final averageRating = stats?.averageRating ?? 0.0;
        final ratingCount = stats?.ratingCount ?? 0;
        final reviews = ratingsResponse?.ratings ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Header
            Row(
              children: [
                // Average Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: averageRating,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
                    ),
                    Text(
                      '($ratingCount ${ratingCount == 1 ? context.l10n.review : context.l10n.reviews})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),

                // Rating Distribution
                Expanded(
                  child: _buildRatingDistribution(stats),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Rate Product Button
            if (userRating == null)
              _buildRateProductButton(context, ratingProvider),

            // User's Rating
            if (userRating != null)
              _buildUserRatingSection(userRating, ratingProvider),

            const SizedBox(height: 16),

            // All Reviews - Collapsible Section
            if (reviews.isNotEmpty)
              _buildCollapsibleReviewsSection(
                  reviews, ratingCount, ratingProvider),

            if (ratingCount == 0) _buildNoReviewsSection(),
          ],
        );
      },
    );
  }

  Widget _buildNoReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        context.l10n.no_reviews_yet,
        style: const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCollapsibleReviewsSection(
      List<Rating> reviews, int ratingCount, RatingProvider ratingProvider) {
    return Card(
      child: Column(
        children: [
          // Header - Always visible
          ListTile(
            title: Text(
              context.l10n.customer_reviews,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '$ratingCount ${ratingCount == 1 ? context.l10n.review : context.l10n.reviews}',
            ),
            trailing: Icon(
              _reviewsExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
            onTap: () {
              setState(() {
                _reviewsExpanded = !_reviewsExpanded;
              });
            },
          ),

          // Reviews List - Collapsible
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _reviewsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...reviews.map((rating) => _buildReviewCard(rating)),

                  // Load More Button
                  if (ratingProvider.productRatings[widget.product.sId!] !=
                          null &&
                      (ratingProvider.productRatings[widget.product.sId!]!
                                  .currentPage ??
                              0) <
                          (ratingProvider.productRatings[widget.product.sId!]!
                                  .totalPages ??
                              0))
                    Center(
                      child: TextButton(
                        onPressed: () {
                          ratingProvider.getRatingsForProduct(
                            widget.product.sId!,
                            page: (ratingProvider
                                        .productRatings[widget.product.sId!]!
                                        .currentPage ??
                                    0) +
                                1,
                          );
                        },
                        child: Text(
                          context.l10n.load_more_reviews,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(RatingStats? stats) {
    if (stats == null || stats.ratingCount == 0) {
      return Text(
        context.l10n.no_ratings_yet,
        style: const TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: [
        _buildRatingBar(
            5, stats.percentage5Star, stats.distribution?['5'] ?? 0),
        _buildRatingBar(
            4, stats.percentage4Star, stats.distribution?['4'] ?? 0),
        _buildRatingBar(
            3, stats.percentage3Star, stats.distribution?['3'] ?? 0),
        _buildRatingBar(
            2, stats.percentage2Star, stats.distribution?['2'] ?? 0),
        _buildRatingBar(
            1, stats.percentage1Star, stats.distribution?['1'] ?? 0),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 12),
          ),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRateProductButton(
      BuildContext context, RatingProvider ratingProvider) {
    final user = context.userProvider.getLoginUsr();

    return ElevatedButton.icon(
      onPressed: user == null
          ? null
          : () {
              _showRatingDialog(context, null);
            },
      icon: const Icon(Icons.star_border),
      label: Text(context.l10n.rate_this_product),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget _buildUserRatingSection(
      Rating userRating, RatingProvider ratingProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.your_rating,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        _showRatingDialog(context, userRating);
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () {
                        _deleteRating(context, userRating);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: userRating.rating?.toDouble() ?? 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 20,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
              ignoreGestures: true,
            ),
            if (userRating.review != null && userRating.review!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  userRating.review!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            if (userRating.verifiedPurchase == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.verified_purchase,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Rating rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rating.userName ?? context.l10n.anonymous,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBar.builder(
                  initialRating: rating.rating?.toDouble() ?? 0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 16,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                  ignoreGestures: true,
                ),
              ],
            ),
            if (rating.verifiedPurchase == true)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.verified_purchase,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            if (rating.review != null && rating.review!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  rating.review!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _formatDate(rating.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Rating? existingRating) {
    int selectedRating = existingRating?.rating ?? 0;
    TextEditingController reviewController = TextEditingController(
      text: existingRating?.review ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existingRating == null
                  ? context.l10n.rate_this_product
                  : context.l10n.edit_your_rating),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: selectedRating.toDouble(),
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        selectedRating = rating.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      labelText: context.l10n.review_optional,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () {
                          _submitRating(
                            selectedRating,
                            reviewController.text,
                            existingRating,
                          );
                          Navigator.pop(context);
                        },
                  child: Text(existingRating == null
                      ? context.l10n.submit
                      : context.l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitRating(int rating, String review, Rating? existingRating) {
    final ratingProvider = context.read<RatingProvider>();
    final user = context.read<UserProvider>().getLoginUsr();

    if (user == null) return;

    if (existingRating == null) {
      // Submit new rating
      ratingProvider
          .submitRating(
        productId: widget.product.sId!,
        userId: user.sId!,
        userName: user.name ?? 'User',
        rating: rating,
        review: review.isNotEmpty ? review : null,
      )
          .then((success) {
        if (success && mounted) {
          // Refresh the rating data
          _loadRatingData();
        }
      });
    } else {
      // Update existing rating
      ratingProvider
          .updateRating(
        ratingId: existingRating.sId!,
        rating: rating,
        review: review.isNotEmpty ? review : null,
      )
          .then((success) {
        if (success && mounted) {
          // Refresh the rating data
          _loadRatingData();
        }
      });
    }
  }

  void _deleteRating(BuildContext context, Rating rating) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.delete_rating),
        content: Text(context.l10n.delete_rating_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<RatingProvider>()
                  .deleteRating(
                    ratingId: rating.sId!,
                  )
                  .then((success) {
                if (success && mounted) {
                  navigator.pop();
                  // Refresh the rating data
                  _loadRatingData();
                }
              });
            },
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
