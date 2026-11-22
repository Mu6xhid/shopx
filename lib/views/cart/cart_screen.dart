import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cart = CartController.instance;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late List<CartItemModel> _displayedItems;

  @override
  void initState() {
    super.initState();

    _displayedItems = List<CartItemModel>.from(_cart.items);
    _cart.addListener(_handleCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_handleCartChanged);
    super.dispose();
  }

  // Synchronize the animated list with the cart controller.
  void _handleCartChanged() {
    if (!mounted) return;

    final currentItems = _cart.items;
    final currentIds = currentItems.map((item) => item.product.id).toSet();

    // Remove products that are no longer in the cart.
    for (int i = _displayedItems.length - 1; i >= 0; i--) {
      if (!currentIds.contains(_displayedItems[i].product.id)) {
        final removedItem = _displayedItems.removeAt(i);

        _listKey.currentState?.removeItem(i, (context, animation) {
          return _buildAnimatedItem(removedItem, animation);
        }, duration: const Duration(milliseconds: 350));
      }
    }

    // Insert newly added products.
    for (int i = 0; i < currentItems.length; i++) {
      final item = currentItems[i];

      final alreadyExists = _displayedItems.any(
        (existing) => existing.product.id == item.product.id,
      );

      if (!alreadyExists) {
        final insertIndex = i.clamp(0, _displayedItems.length);

        _displayedItems.insert(insertIndex, item);

        _listKey.currentState?.insertItem(
          insertIndex,
          duration: const Duration(milliseconds: 450),
        );
      }
    }

    setState(() {});
  }

  Widget _buildAnimatedItem(CartItemModel item, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SizeTransition(
      sizeFactor: curvedAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CartItemCard(item: item, cart: _cart),
          ),
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
          'MY BAG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, child) {
          final isEmpty = _cart.items.isEmpty;

          return Column(
            children: [
              // Cart Header
              if (!isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          '${_cart.totalItems} ITEMS IN YOUR BAG',
                          key: ValueKey(_cart.totalItems),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _cart.clearCart();
                        },
                        child: const Text(
                          'CLEAR ALL',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Animated Cart List and Empty State
              Expanded(
                child: Stack(
                  children: [
                    AnimatedList(
                      key: _listKey,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      initialItemCount: _displayedItems.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _displayedItems.length) {
                          return const SizedBox.shrink();
                        }

                        final item = _displayedItems[index];

                        return _buildAnimatedItem(item, animation);
                      },
                    ),

                    if (isEmpty)
                      Center(
                        child: _EmptyCart(
                          onContinueShopping: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Order Summary
              if (!isEmpty) _OrderSummary(cart: _cart),
            ],
          );
        },
      ),
    );
  }
}

// Empty Cart
class _EmptyCart extends StatelessWidget {
  final VoidCallback onContinueShopping;

  const _EmptyCart({required this.onContinueShopping});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 75,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'YOUR BAG IS EMPTY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Discover something you love.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),

        const SizedBox(height: 25),

        ElevatedButton(
          onPressed: onContinueShopping,
          child: const Text('CONTINUE SHOPPING'),
        ),
      ],
    );
  }
}

// Cart Item Card
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final CartController cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 95,
                height: 115,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Image.network(
                  item.product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      item.product.title,
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
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onTap: () {
                            cart.decreaseQuantity(item.product.id);
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '${item.quantity}',
                              key: ValueKey(item.quantity),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        _QuantityButton(
                          icon: Icons.add,
                          onTap: () {
                            cart.increaseQuantity(item.product.id);
                          },
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: () {
                            cart.removeFromCart(item.product.id);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Quantity Button
class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 30,
            width: 30,
            child: Icon(widget.icon, color: AppColors.primary, size: 16),
          ),
        ),
      ),
    );
  }
}

// Order Summary
class _OrderSummary extends StatelessWidget {
  final CartController cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final total = cart.totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER SUMMARY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            _SummaryRow(title: 'Total items', value: '${cart.totalItems}'),

            const SizedBox(height: 12),

            _SummaryRow(
              title: 'Subtotal',
              value: '\$${total.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 12),

            const _SummaryRow(
              title: 'Shipping',
              value: 'Calculated at checkout',
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                TweenAnimationBuilder<double>(
                  tween: Tween(begin: total, end: total),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Checkout is not implemented yet.
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.surfaceLight,
                  disabledForegroundColor: AppColors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CHECKOUT COMING SOON'),
                    SizedBox(width: 10),
                    Icon(Icons.lock_outline, size: 17),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Row
class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
