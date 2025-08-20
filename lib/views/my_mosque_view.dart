import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:provider/provider.dart';

class MyMosqueView extends StatefulWidget {
  const MyMosqueView({super.key});

  @override
  State<MyMosqueView> createState() => _MyMosqueViewState();
}

class _MyMosqueViewState extends State<MyMosqueView> {
  Future<List<MosqueModel>>? _myMosquesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMosques());
  }

Future<void> _loadMosques() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final mosqueProvider = Provider.of<MosqueProvider>(context, listen: false);

  if (auth.token != null) {
    mosqueProvider.setToken(auth.token!);

    // 1) Async work bahar
    final result = await mosqueProvider.getMyMosques();

    // 2) setState mein sirf assignment
    if (mounted) {
      setState(() {
        _myMosquesFuture = Future.value(result);
      });
    }
  } else {
    if (mounted) {
      setState(() {
        _myMosquesFuture = Future.error('Token not available');
      });
    }
  }
}

  Future<void> _retry() async => _loadMosques();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mosques'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _myMosquesFuture == null
          ? const Center(child: Text('Please login first'))
          : RefreshIndicator(
              onRefresh: _retry,
              child: FutureBuilder<List<MosqueModel>>(
                future: _myMosquesFuture,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text('Error: ${snapshot.error}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            onPressed: _retry,
                          ),
                        ],
                      ),
                    );
                  }

                  final mosques = snapshot.data ?? [];
                  if (mosques.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/empty.png',
                              width: 140, height: 140,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.mosque_outlined,
                                      size: 100, color: Colors.grey)),
                          const SizedBox(height: 16),
                          const Text('No mosques added yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  // Success list
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: mosques.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = mosques[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: const CircleAvatar(
                            backgroundColor: AppStyles.primaryGreen,
                            child: Icon(Icons.mosque, color: Colors.white),
                          ),
                          title: Text(m.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('${m.city}, ${m.area}\n${m.address}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.grey),
                          onTap: () {
                            // TODO: open details / edit
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}