import 'package:flutter/material.dart';

import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../home/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _wishlist = WishlistController.instance;

  final GlobalKey<AnimatedGridState> _gridKey = GlobalKey<AnimatedGridState>();

  late List<ProductModel> _displayedProducts;

  @override
  void initState() {
    super.initState();

    _displayedProducts = List<ProductModel>.from(_wishlist.items);
    _wishlist.addListener(_handleWishlistChanged);
  }

  @override
  void dispose() {
    _wishlist.removeListener(_handleWishlistChanged);
    super.dispose();
  }

  // Synchronize the animated grid with the wishlist controller.
  void _handleWishlistChanged() {
    if (!mounted) return;

    final currentProducts = _wishlist.items;

    final currentIds = currentProducts.map((p) => p.id).toSet();

    // Remove products that are no longer wishlisted.
    for (int i = _displayedProducts.length - 1; i >= 0; i--) {
      if (!currentIds.contains(_displayedProducts[i].id)) {
        final removedProduct = _displayedProducts.removeAt(i);

        _gridKey.currentState?.removeItem(i, (context, animation) {
          return _buildAnimatedCard(removedProduct, animation);
        }, duration: const Duration(milliseconds: 350));
      }
    }

    // Insert newly wishlisted products.
    for (int i = 0; i < currentProducts.length; i++) {
      final product = currentProducts[i];

      final alreadyExists = _displayedProducts.any((p) => p.id == product.id);

      if (!alreadyExists) {
        final insertIndex = i.clamp(0, _displayedProducts.length);

        _displayedProducts.insert(insertIndex, product);

        _gridKey.currentState?.insertItem(
          insertIndex,
          duration: const Duration(milliseconds: 450),
        );
      }
    }

    setState(() {});
  }

  Widget _buildAnimatedCard(ProductModel product, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curvedAnimation),
          child: _WishlistCard(product: product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'SAVED ITEMS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          AnimatedBuilder(
            animation: _wishlist,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      '${_wishlist.items.length} ITEMS',
                      key: ValueKey(_wishlist.items.length),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _displayedProducts.isEmpty
            ? const _EmptyWishlist(key: ValueKey('empty'))
            : AnimatedGrid(
                key: _gridKey,
                initialItemCount: _displayedProducts.length,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index, animation) {
                  if (index >= _displayedProducts.length) {
                    return const SizedBox.shrink();
                  }

                  return _buildAnimatedCard(
                    _displayedProducts[index],
                    animation,
                  );
                },
              ),
      ),
    );
  }
}

// Wishlist Product Card
class _WishlistCard extends StatefulWidget {
  final ProductModel product;

  const _WishlistCard({required this.product});

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard> {
  bool _isMovingToBag = false;
  bool _isPressed = false;

  Future<void> _moveToBag() async {
    if (_isMovingToBag) return;

    setState(() {
      _isMovingToBag = true;
    });

    // Add product to cart.
    CartController.instance.addToCart(widget.product);

    // Remove it from wishlist.
    WishlistController.instance.removeFromWishlist(widget.product.id);

    // Brief button feedback.
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _isMovingToBag = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 130),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: Image.network(
                            product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.textSecondary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Remove from Wishlist
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            WishlistController.instance.removeFromWishlist(
                              product.id,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(9),
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product Information
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Move to Bag
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: _isMovingToBag ? null : _moveToBag,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.surfaceLight,
                          disabledForegroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _isMovingToBag
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Row(
                                  key: ValueKey('move'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_bag_outlined, size: 15),
                                    SizedBox(width: 6),
                                    Text(
                                      'MOVE TO BAG',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Empty Wishlist
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'NOTHING SAVED YET',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Save the pieces you love.\nThey will be waiting here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.6),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                // Return to the root screen (Home).
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('EXPLORE PRODUCTS'),
            ),
          ],
        ),
      ),
    );
  }
}
