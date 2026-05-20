import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  final String selectedCategory;

  const MenuPage({
    super.key,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      {"name": "Mercimek Çorbası", "cat": "Çorbalar", "price": 90},
      {"name": "Adana Kebap", "cat": "Izgaralar", "price": 280},
      {"name": "Künefe", "cat": "Tatlılar", "price": 160},
      {"name": "Ayran", "cat": "İçecekler", "price": 40},
      {"name": "Karışık Izgara", "cat": "Izgaralar", "price": 420},
    ];

    final filteredItems = items.where((item) {
      if (selectedCategory == "Tümü") return true;
      return item["cat"] == selectedCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Kategori: $selectedCategory",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = filteredItems[i];
              final name = item["name"] as String;
              final cat = item["cat"] as String;
              final price = item["price"] as int;

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(cat),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₺$price",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      FilledButton.tonal(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$name sepete eklendi (demo)"),
                            ),
                          );
                        },
                        child: const Text("Ekle"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
