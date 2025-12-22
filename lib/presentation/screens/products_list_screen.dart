import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/models/product_with_details.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/common_widgets.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'settings_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart' as utils;

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    // Load products on init
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Reload products after operation
            context.read<ProductBloc>().add(LoadProducts());
          }
        },
        builder: (context, state) {
          if (state is ProductLoading || state is ProductOperationSuccess) {
            return const LoadingIndicator(message: 'Loading products...');
          }

          if (state is ProductError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(LoadProducts());
              },
            );
          }

          List<ProductWithDetails> products = [];
          bool isFiltered = false;
          bool isSearching = false;

          if (state is ProductsLoaded) {
            products = state.products;
          } else if (state is ProductSearchResults) {
            products = state.results;
            isSearching = true;
          } else if (state is ProductsFiltered) {
            products = state.products;
            isFiltered = true;
          } else if (state is ProductDetailsLoaded) {
            // Use cached products list if available when returning from detail view
            products = state.allProducts ?? [];
          }

          // Check if truly empty (no products in database at all)
          bool isTrulyEmpty = state is ProductsLoaded &&
              products.isEmpty &&
              !isFiltered &&
              !isSearching;

          if (isTrulyEmpty) {
            return _buildEmptyState(colorScheme);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: _buildTopBar(colorScheme),
                ),

                // Hero Section with Stats (show only if there are products)
                if (products.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildHeroSection(products, colorScheme),
                  ),

                // Search Bar
                SliverToBoxAdapter(
                  child: _buildSearchBar(colorScheme),
                ),

                // Category Chips
                SliverToBoxAdapter(
                  child: _buildCategoryChips(colorScheme),
                ),

                // Products Grid or Empty Message
                if (products.isEmpty)
                  SliverFillRemaining(
                    child: _buildInlineEmptyMessage(colorScheme,
                        isFiltered: isFiltered, isSearching: isSearching),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: products.length,
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: 1.0,
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          curve: Curves.easeOut,
                          child: ProductCard(
                            productWithDetails: products[index],
                            onTap: () {
                              _navigateToProductDetail(
                                  products[index].product.id!);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your warranties',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: colorScheme.onSurface,
                size: 22,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
      List<ProductWithDetails> products, ColorScheme colorScheme) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    int activeCount = 0;
    int expiringCount = 0;
    int expiredCount = 0;

    for (var product in products) {
      final expiryDate = utils.DateTimeUtils.parseISO(product.product.expiryDate);
      if (expiryDate != null) {
        if (utils.DateTimeUtils.isExpired(expiryDate)) {
          expiredCount++;
        } else if (utils.DateTimeUtils.isExpiringSoon(
            expiryDate, AppConstants.notificationReminderDays)) {
          expiringCount++;
        } else {
          activeCount++;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isLight
            ? const []
            : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${activeCount}',
                  'Active',
                  const Color(0xFF4ECDC4),
                  Icons.check_circle_outline,
                  colorScheme,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outline.withOpacity(0.6)),
              Expanded(
                child: _buildStatItem(
                  '${expiringCount}',
                  'Expiring',
                  const Color(0xFFFF9800),
                  Icons.warning_amber_outlined,
                  colorScheme,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outline.withOpacity(0.6)),
              Expanded(
                child: _buildStatItem(
                  '${expiredCount}',
                  'Expired',
                  const Color(0xFFF44336),
                  Icons.cancel_outlined,
                  colorScheme,
                ),
              ),
            ],
          ),
        );

  }

  Widget _buildStatItem(
      String value, String label, Color color, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLight
              ? const []
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            
            // Cancel previous timer
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            
            // Create new timer
            _debounce = Timer(const Duration(milliseconds: 500), () {
              if (value.isEmpty) {
                context.read<ProductBloc>().add(LoadProducts());
              } else {
                context.read<ProductBloc>().add(SearchProducts(value));
              }
            });
          },
          onSubmitted: _performSearch,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme colorScheme) {
    // Example categories
    final categories = [
      'All',
      'Electronics',
      'Furniture',
      'Clothing',
      'Appliances'
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  if (category == 'All') {
                    context.read<ProductBloc>().add(LoadProducts());
                  } else {
                    context
                        .read<ProductBloc>()
                        .add(FilterProductsByCategory(category));
                  }
                }
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the + button to add your first product warranty.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );
            },
            icon: Icon(Icons.add, color: colorScheme.onPrimary),
            label: Text(
              'Add Product',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEmptyMessage(ColorScheme colorScheme,
      {required bool isFiltered, required bool isSearching}) {
    String message = "No products found.";
    if (isSearching) {
      message = "No products match your search for '$_searchQuery'.";
    } else if (isFiltered) {
      message = "No products found in the '$_selectedCategory' category.";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProducts(query));
    }
  }

  void _navigateToProductDetail(int productId) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productId: productId,
        ),
      ),
    )
        .then((_) {
      // Optional: Reload products when returning if changes might have occurred
      // context.read<ProductBloc>().add(LoadProducts());
    });
  }
}
