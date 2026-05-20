import 'package:flutter/material.dart';

import '../../core/table_session.dart';
import '../home/home_page.dart';
import 'qr_entry_page.dart';

class AppBootstrapPage extends StatefulWidget {
  const AppBootstrapPage({super.key});

  @override
  State<AppBootstrapPage> createState() => _AppBootstrapPageState();
}

class _AppBootstrapPageState extends State<AppBootstrapPage> {
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    await TableSession.instance.restore();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!TableSession.instance.initialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F4FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!TableSession.instance.hasTable) {
      return const QrEntryPage();
    }

    return HomePage(
      tableNumber: TableSession.instance.tableNumber!,
    );
  }
}
