import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/addMosque_view.dart';
import 'package:mosque_locator/views/mosque_detail_view.dart';
import 'package:provider/provider.dart';

class MyMosqueView extends StatefulWidget {
  const MyMosqueView({super.key});

  @override
  State<MyMosqueView> createState() => _MyMosqueViewState();
}

class _MyMosqueViewState extends State<MyMosqueView> {
  Future<void>? _myMosquesFuture;

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
      if (mounted) {
        setState(() {
          _myMosquesFuture = mosqueProvider.loadMyMosques();
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
              child: FutureBuilder<void>(
                future: _myMosquesFuture,
                builder: (context, snapshot) {
                  final mosqueProvider = context.watch<MosqueProvider>();
                  final mosques = mosqueProvider.myMosques;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

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

                  if (mosques.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/empty.png',
                              width: 140,
                              height: 140,
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: const CircleAvatar(
                            backgroundColor: AppStyles.primaryGreen,
                            child: Icon(Icons.mosque, color: Colors.white),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  m.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: m.verified
                                      ? AppStyles.primaryGreen
                                      : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  m.verified ? 'Verified' : 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${m.city}, ${m.area}\n${m.address}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AddMosqueView(mosque: m)),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MosqueDetailView(mosque: m),
                              ),
                            );
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