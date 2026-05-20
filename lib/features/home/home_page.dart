import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../cart/cart_page.dart';
import '../cart/cart_service.dart';
import '../menu/category_menu_page.dart';
import '../support/support_page.dart';

class HomePage extends StatefulWidget {
  final String tableNumber;

  const HomePage({
    super.key,
    required this.tableNumber,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 1;
  List<String> _categories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref("categories").get();

      final List<String> loadedCategories = [];

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map && value["name"] != null) {
              loadedCategories.add(value["name"].toString());
            }
          });
        }
      }

      loadedCategories.sort();

      if (!mounted) return;
      setState(() {
        _categories = loadedCategories;
        _categoriesLoading = false;
      });
    } catch (e) {
      debugPrint("Kategori verisi alınamadı: $e");

      if (!mounted) return;
      setState(() {
        _categoriesLoading = false;
      });
    }
  }

  void _openLeftDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _openRightDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const CartPage(),
      _HomeContent(
        tableNumber: widget.tableNumber,
        onOpenContact: _openLeftDrawer,
        onOpenCategoryMenu: _openRightDrawer,
        onRefreshCategories: _loadCategories,
      ),
      const SupportPage(),
      const _MenuPlaceholder(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F4FA),
      drawer: _ContactDrawer(
        title: "MenuMate",
        onClose: () => Navigator.of(context).pop(),
      ),
      endDrawer: _CategoryDrawer(
        title: "Kategori Listesi",
        categories: _categories,
        isLoading: _categoriesLoading,
        onClose: () => Navigator.of(context).pop(),
        onSelect: (cat) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryMenuPage(categoryName: cat),
            ),
          );
        },
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF8F4FA),
        selectedItemColor: const Color(0xFFF97316),
        unselectedItemColor: Colors.black.withOpacity(0.55),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Sepetim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            label: "Destek",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: "Menü",
          ),
        ],
        onTap: (index) {
          if (index == 3) {
            _openRightDrawer();
            return;
          }
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final String tableNumber;
  final VoidCallback onOpenContact;
  final VoidCallback onOpenCategoryMenu;
  final Future<void> Function() onRefreshCategories;

  const _HomeContent({
    required this.tableNumber,
    required this.onOpenContact,
    required this.onOpenCategoryMenu,
    required this.onRefreshCategories,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("menu");

  bool _loading = true;
  List<Map<String, dynamic>> _allItems = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final snapshot = await _dbRef.get();

      if (!snapshot.exists) {
        if (!mounted) return;
        setState(() {
          _allItems = [];
          _loading = false;
        });
        return;
      }

      final data = snapshot.value;
      final List<Map<String, dynamic>> loadedItems = [];

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          if (item != null) {
            final mapped = Map<String, dynamic>.from(item);
            mapped["_key"] = i.toString();
            loadedItems.add(mapped);
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          if (value != null) {
            final mapped = Map<String, dynamic>.from(value);
            mapped["_key"] = key.toString();
            loadedItems.add(mapped);
          }
        });
      }

      if (!mounted) return;
      setState(() {
        _allItems = loadedItems;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Ana sayfa verisi alınamadı: $e");

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadHomeData(),
      widget.onRefreshCategories(),
    ]);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Fix Menü":
        return Icons.restaurant_menu;
      case "Kahvaltılar":
        return Icons.free_breakfast;
      case "Specialler":
        return Icons.star_outline;
      case "Salatalar":
        return Icons.eco_outlined;
      case "Soğuk Mezeler":
        return Icons.tapas_outlined;
      case "Ara Sıcaklar":
        return Icons.local_fire_department_outlined;
      case "Balıklar":
        return Icons.set_meal_outlined;
      case "Et Izgaralar":
        return Icons.outdoor_grill;
      case "Tavuk Izgaralar":
        return Icons.lunch_dining_outlined;
      case "Kavurma ve Güveçler":
        return Icons.soup_kitchen_outlined;
      case "Soğuk İçecekler":
        return Icons.local_drink_outlined;
      case "Çaylar ve Kahveler":
        return Icons.coffee_outlined;
      case "Soğuk Kahveler":
        return Icons.icecream_outlined;
      case "Kokteyller":
        return Icons.wine_bar_outlined;
      default:
        return Icons.fastfood_outlined;
    }
  }

  List<Map<String, dynamic>> _getMostViewedItems() {
    final items = List<Map<String, dynamic>>.from(_allItems);
    items.sort((a, b) {
      final aCount = (a["viewCount"] as num?)?.toInt() ?? 0;
      final bCount = (b["viewCount"] as num?)?.toInt() ?? 0;
      return bCount.compareTo(aCount);
    });
    return items.take(6).toList();
  }

  List<Map<String, dynamic>> _getChefRecommendedItems() {
    final items = _allItems.where((item) {
      return item["isChefRecommended"] == true;
    }).toList();

    items.sort((a, b) {
      final aCount = (a["viewCount"] as num?)?.toInt() ?? 0;
      final bCount = (b["viewCount"] as num?)?.toInt() ?? 0;
      return bCount.compareTo(aCount);
    });

    return items.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mostViewedItems = _getMostViewedItems();
    final chefItems = _getChefRecommendedItems();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F4FA),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: widget.onOpenContact,
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF2F2A33),
          ),
        ),
        title: const Text(
          "MenuMate",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Color(0xFF2F2A33),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.table_restaurant_outlined,
                            color: Color(0xFFF97316),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aktif Masa',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6670),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Masa ${widget.tableNumber}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2F2A33),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFFF97316),
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "Ne yemek istersin?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9A4311),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    readOnly: true,
                    onTap: widget.onOpenCategoryMenu,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_outlined),
                      hintText: "Menüye göz at...",
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: const Color(0xFFF6E8D7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "🔥 Öne Çıkan Lezzet",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          mostViewedItems.isNotEmpty
                              ? mostViewedItems.first["name"]?.toString() ??
                                  "Öne çıkan ürün"
                              : "Öne çıkan ürün",
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7C2D12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mostViewedItems.isNotEmpty
                              ? mostViewedItems.first["description"]
                                      ?.toString() ??
                                  "Ürün açıklaması burada görünecek."
                              : "Ürün açıklaması burada görünecek.",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9A3412),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              "₺${mostViewedItems.isNotEmpty ? ((mostViewedItems.first["price"] as num?)?.toInt() ?? 0) : 0}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF97316),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                mostViewedItems.isNotEmpty
                                    ? "${((mostViewedItems.first["viewCount"] as num?)?.toInt() ?? 0)} görüntülenme"
                                    : "0 görüntülenme",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    "Haftanın En Çok Bakılanları",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C2D12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 305,
                    child: mostViewedItems.isEmpty
                        ? const Center(
                            child: Text("Henüz görüntülenme verisi yok."),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: mostViewedItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = mostViewedItems[index];
                              return _FoodCard(
                                item: item,
                                name: item["name"]?.toString() ?? "",
                                price: (item["price"] as num?)?.toInt() ?? 0,
                                subInfo:
                                    "${((item["viewCount"] as num?)?.toInt() ?? 0)} görüntülenme",
                                category: item["category"]?.toString() ?? "",
                                icon: _getCategoryIcon(
                                  item["category"]?.toString() ?? "",
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    "Şefin Önerileri",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C2D12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 305,
                    child: chefItems.isEmpty
                        ? const Center(
                            child: Text("Şef önerisi verisi bulunamadı."),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: chefItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = chefItems[index];
                              return _FoodCard(
                                item: item,
                                name: item["name"]?.toString() ?? "",
                                price: (item["price"] as num?)?.toInt() ?? 0,
                                subInfo:
                                    "${((item["viewCount"] as num?)?.toInt() ?? 0)} görüntülenme",
                                category: item["category"]?.toString() ?? "",
                                icon: _getCategoryIcon(
                                  item["category"]?.toString() ?? "",
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String name;
  final int price;
  final String subInfo;
  final String category;
  final IconData icon;
  final Map<String, dynamic> item;

  const _FoodCard({
    required this.name,
    required this.price,
    required this.subInfo,
    required this.category,
    required this.icon,
    required this.item,
  });

  Widget buildProductImage(Map<String, dynamic> item) {
    final imageUrl = item['imageUrl']?.toString() ?? '';

    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/gozleme.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/gozleme.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: buildProductImage(item),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C2D12),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subInfo,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "₺$price",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          CartService.instance.addItem(
                            name: name,
                            category: category,
                            price: price,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$name sepete eklendi"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPlaceholder extends StatelessWidget {
  const _MenuPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F4FA),
      body: Center(
        child: Text(
          "Menü sekmesine basınca kategori listesi sağdan açılır.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ContactDrawer extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _ContactDrawer({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: const [
                  _InfoCard(
                    title: "Adres",
                    lines: [
                      "Kızılcaşehir Mah. Regülatör Cad.",
                      "No:273 Dimçayı, Alanya, Antalya",
                    ],
                  ),
                  _InfoCard(
                    title: "İletişim",
                    lines: [
                      "+90 532 452 77 07",
                      "info@menumate.com",
                    ],
                  ),
                  _InfoCard(
                    title: "Çalışma Saatleri",
                    lines: [
                      "Hafta içi: 09:00 - 00:00",
                      "Hafta sonu: 09:00 - 00:00",
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "© 2026 MenuMate",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoCard({
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDrawer extends StatelessWidget {
  final String title;
  final List<String> categories;
  final bool isLoading;
  final VoidCallback onClose;
  final void Function(String) onSelect;

  const _CategoryDrawer({
    required this.title,
    required this.categories,
    required this.isLoading,
    required this.onClose,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Kategori bulunamadı.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final c = categories[i];
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => onSelect(c),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFF97316)
                                        .withOpacity(0.25),
                                  ),
                                  color: const Color(0xFFFFF7ED),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
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
