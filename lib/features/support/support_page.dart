import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97316);
    const backgroundColor = Color(0xFFF8F4FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFFFB923C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.support_agent,
                        color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      "Destek",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sorularınız için buradayız",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                "Hızlı İşlemler",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.track_changes,
                      label: "Siparişi Takip Et",
                      color: primaryColor,
                      onTap: () => _showSnackBar(
                          context, "Siparişləriniz burada görüntülenecek"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.report_problem,
                      label: "Sorun Bildir",
                      color: primaryColor,
                      onTap: () =>
                          _showSnackBar(context, "Sorun bildirimi gönderildi"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FAQ Section
              Text(
                "Sık Sorulan Sorular",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              _FAQTile(
                question: "Alerjen bilgisi var mı?",
                answer:
                    "Evet! Her ürün detay sayfasında alerjen bilgisi bulunmaktadır. Alerji bilgilerini görmek için ürün üzerine tıklayın.",
                itemNumber: 1,
              ),
              const SizedBox(height: 8),
              _FAQTile(
                question: "Siparişim ne zaman gelir?",
                answer:
                    "Siparişleriniz ortalama 30-45 dakika içinde ulaşmaktadır. Siparişleriniz kütü siteminizin ​​altındaki \"Siparişi Takip Et\" bölümünden canlı olarak takip edebilirsiniz.",
                itemNumber: 2,
              ),
              const SizedBox(height: 8),
              _FAQTile(
                question: "Ödeme nasıl yapılır?",
                answer:
                    "Kredi kartı, banka kartı ve dijital cüzdan yöntemlerini kabul ediyoruz. Tüm ödeme işlemleri güvenlidir.",
                itemNumber: 3,
              ),
              const SizedBox(height: 8),
              _FAQTile(
                question: "Eğer ürün eksik gelmişse?",
                answer:
                    "Lütfen \"Sorun Bildir\" bölümünden şikayetinizi iletiniz. Durumunuzu ivedi şekilde gidereceğiz.",
                itemNumber: 4,
              ),
              const SizedBox(height: 24),

              // Contact Section
              Text(
                "İletişim",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: primaryColor.withOpacity(0.2), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactItem(
                      icon: Icons.phone,
                      title: "Telefonla Bizi Arayın",
                      subtitle: "+90 (123) 456-7890",
                      color: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _ContactItem(
                      icon: Icons.email,
                      title: "E-posta Gönderin",
                      subtitle: "support@menumate.com",
                      color: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _ContactItem(
                      icon: Icons.access_time,
                      title: "Çalışma Saatleri",
                      subtitle: "Her gün 09:00 - 22:00",
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      _showSnackBar(context, "Destek isteği gönderildi!"),
                  child: const Text(
                    "Destek İsteği Gönder",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF97316),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  final int itemNumber;

  const _FAQTile({
    required this.question,
    required this.answer,
    required this.itemNumber,
  });

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97316);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? primaryColor : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ExpansionTile(
        onExpansionChanged: (value) => setState(() => _isExpanded = value),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${widget.itemNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.question,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        children: [
          Text(
            widget.answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
