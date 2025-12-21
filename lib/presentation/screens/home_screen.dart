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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
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
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
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
          if (state is ProductLoading) {
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
          bool isTrulyEmpty = state is ProductsLoaded && products.isEmpty && !isFiltered && !isSearching;
          
          if (isTrulyEmpty) {
            return _buildEmptyState(colorScheme);
          }
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
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
                    child: _buildInlineEmptyMessage(colorScheme, isFiltered: isFiltered, isSearching: isSearching),
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
                              _navigateToProductDetail(products[index].product.id!);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
        elevation: 4,
      ),
    );
  }
  
  Widget _buildHeroSection(List<ProductWithDetails> products, ColorScheme colorScheme) {
    int activeCount = 0;
    int expiringCount = 0;
    int expiredCount = 0;
    
    for (var product in products) {
      final expiryDate = utils.DateTimeUtils.parseISO(product.product.expiryDate);
      if (expiryDate != null) {
        if (utils.DateTimeUtils.isExpired(expiryDate)) {
          expiredCount++;
        } else if (utils.DateTimeUtils.isExpiringSoon(expiryDate, AppConstants.notificationReminderDays)) {
          expiringCount++;
        } else {
          activeCount++;
        }
      }
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Warranties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                'Active',
                activeCount.toString(),
                Icons.check_circle_rounded,
                Colors.green,
                colorScheme,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                'Expiring',
                expiringCount.toString(),
                Icons.warning_rounded,
                Colors.orange,
                colorScheme,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                'Expired',
                expiredCount.toString(),
                Icons.cancel_rounded,
                Colors.red,
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _searchQuery = '';
              });
              context.read<ProductBloc>().add(LoadProducts());
            }
          },
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 17,
              letterSpacing: -0.4,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withOpacity(0.4),
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.4),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: TextStyle(
            fontSize: 17,
            letterSpacing: -0.4,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryChips(ColorScheme colorScheme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', colorScheme),
          ...AppConstants.productCategories.map(
            (category) => _buildCategoryChip(category, colorScheme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String category, ColorScheme colorScheme) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          
          if (category == 'All') {
            context.read<ProductBloc>().add(LoadProducts());
          } else {
            context.read<ProductBloc>().add(FilterProductsByCategory(category));
          }
        },
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  Widget _buildEmptyState(ColorScheme colorScheme) {
    // Only for when database is truly empty
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Products Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start managing your warranties by\nadding your first product',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Your First Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInlineEmptyMessage(ColorScheme colorScheme, {bool isFiltered = false, bool isSearching = false}) {
    String title;
    String subtitle;
    IconData icon;
    
    if (isSearching) {
      title = 'No Results Found';
      subtitle = 'Try different keywords or clear the search';
      icon = Icons.search_off_rounded;
    } else if (isFiltered) {
      title = 'No Products in $_selectedCategory';
      subtitle = 'Select "All" or another category to view products';
      icon = Icons.filter_list_off_rounded;
    } else {
      title = 'No Products';
      subtitle = 'Add your first product to get started';
      icon = Icons.inventory_2_outlined;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToAddProduct() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
    // Reload products when returning from add screen
    if (mounted) {
      context.read<ProductBloc>().add(LoadProducts());
    }
  }
  
  void _navigateToProductDetail(int productId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
    // Reload products when returning from detail screen
    if (mounted) {
      context.read<ProductBloc>().add(LoadProducts());
    }
  }
  

  
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isEmpty) {
      context.read<ProductBloc>().add(LoadProducts());
    } else {
      context.read<ProductBloc>().add(SearchProducts(query));
    }
  }
  

}
