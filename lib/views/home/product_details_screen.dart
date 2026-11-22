import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../cart/cart_screen.dart';
import '../main_navigation_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  bool _isAddingToCart = false;
  bool _addedToCart = false;
  bool _showViewBag = false;

  late final AnimationController _entryController;
  late final Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _imageAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  // Change product quantity
  void _changeQuantity(int amount) {
    setState(() {
      _quantity = (_quantity + amount).clamp(1, 99);
      _addedToCart = false;
      _showViewBag = false;
    });
  }

  // Add product to cart
  Future<void> _addToCart() async {
    if (_isAddingToCart || _addedToCart || _showViewBag) return;

    setState(() {
      _isAddingToCart = true;
    });

    for (int i = 0; i < _quantity; i++) {
      CartController.instance.addToCart(widget.product);
    }

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    setState(() {
      _isAddingToCart = false;
      _addedToCart = true;
    });

    // Show brief success confirmation
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _addedToCart = false;
      _showViewBag = true;
    });
  }

  // Open cart and check product availability when returning
  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );

    if (!mounted) return;

    final productExists = CartController.instance.items.any(
      (item) => item.product.id == widget.product.id,
    );

    setState(() {
      _showViewBag = productExists;
      _addedToCart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlist = WishlistController.instance;

    final isClothing =
        product.category == "men's clothing" ||
        product.category == "women's clothing";

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'PRODUCT DETAILS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: wishlist,
            builder: (context, child) {
              final isSaved = wishlist.isWishlisted(product.id);

              return IconButton(
                onPressed: () {
                  wishlist.toggleWishlist(product);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isSaved),
                    color: isSaved ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            FadeTransition(
              opacity: _imageAnimation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.94,
                  end: 1,
                ).animate(_imageAnimation),
                child: Container(
                  height: 350,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Hero(
                            tag: 'product-${product.id}',
                            child: Image.network(
                              product.image,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;

                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 45,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    product.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Divider(color: AppColors.surfaceLight),

                  const SizedBox(height: 20),

                  const Text(
                    'PRODUCT DESCRIPTION',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (isClothing) ...[
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Clothing item',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            'Size details unavailable',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // Quantity Selector
                  const Text(
                    'QUANTITY',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 13),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _quantityButton(
                          icon: Icons.remove,
                          onTap: _quantity > 1
                              ? () => _changeQuantity(-1)
                              : null,
                        ),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: SizedBox(
                            key: ValueKey(_quantity),
                            width: 48,
                            child: Text(
                              '$_quantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        _quantityButton(
                          icon: Icons.add,
                          onTap: _quantity < 99
                              ? () => _changeQuantity(1)
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL PRICE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.3,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '\$${(product.price * _quantity).toStringAsFixed(2)}',
                          key: ValueKey(_quantity),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Buttons
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Changing Button
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAddingToCart
                      ? null
                      : _showViewBag
                      ? _openCart
                      : _addedToCart
                      ? null
                      : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _addedToCart
                        ? AppColors.surfaceLight
                        : AppColors.primary,
                    foregroundColor: _addedToCart
                        ? AppColors.primary
                        : AppColors.background,
                    disabledBackgroundColor: _addedToCart
                        ? AppColors.surfaceLight
                        : AppColors.primary,
                    disabledForegroundColor: _addedToCart
                        ? AppColors.primary
                        : AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _isAddingToCart
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Row(
                            key: ValueKey(
                              _showViewBag
                                  ? 'view'
                                  : _addedToCart
                                  ? 'added'
                                  : 'add',
                            ),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showViewBag
                                    ? Icons.shopping_bag_outlined
                                    : _addedToCart
                                    ? Icons.check_circle_outline
                                    : Icons.shopping_bag_outlined,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _showViewBag
                                    ? 'VIEW BAG'
                                    : _addedToCart
                                    ? 'ADDED TO BAG'
                                    : 'ADD TO BAG',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (_showViewBag) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),

              // Continue Shopping Button
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showViewBag
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              MainNavigationScreen.selectedTab.value = 0;

                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.surfaceLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'CONTINUE SHOPPING',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quantity Button
  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? AppColors.textSecondary.withValues(alpha: 0.35)
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
