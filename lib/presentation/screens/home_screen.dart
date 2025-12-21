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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Load products on init
    context.read<ProductBloc>().add(LoadProducts());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
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
          
          if (state is ProductsLoaded) {
            products = state.products;
          } else if (state is ProductSearchResults) {
            products = state.results;
          } else if (state is ProductsFiltered) {
            products = state.products;
          }
          
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              subtitle: 'Tap the + button to add your first product',
              action: ElevatedButton.icon(
                onPressed: _navigateToAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(LoadProducts());
            },
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  productWithDetails: products[index],
                  onTap: () {
                    _navigateToProductDetail(products[index].product.id!);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }
  
  void _navigateToProductDetail(int productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        
        return AlertDialog(
          title: const Text('Search Products'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter product name...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              query = value;
            },
            onSubmitted: (value) {
              _performSearch(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _performSearch(query);
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
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
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategoryOption('All'),
                ...AppConstants.productCategories.map(
                  (category) => _buildCategoryOption(category),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoryOption(String category) {
    final isSelected = _selectedCategory == category;
    
    return ListTile(
      title: Text(category),
      leading: Radio<String>(
        value: category,
        groupValue: _selectedCategory,
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
          
          if (category == 'All') {
            context.read<ProductBloc>().add(LoadProducts());
          } else {
            context.read<ProductBloc>().add(FilterProductsByCategory(category));
          }
          
          Navigator.of(context).pop();
        },
      ),
      selected: isSelected,
    );
  }
}
