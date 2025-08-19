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
  bool _isLoading = true;



  
  @override
  Widget build(BuildContext context) {
    final mosqueprovider=Provider.of<MosqueProvider>(context, listen:  false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
//final mosqueProvider = Provider.of<MosqueProvider>(context, listen: false);
mosqueprovider.setToken(auth.token!);

    return  Scaffold(

       appBar: AppBar(
        title: const Text('My Mosque'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
       body:
      //_isLoading? Center(child: CircularProgressIndicator()) :
      FutureBuilder(future:mosqueprovider.getMyMosques(), builder:  (context, snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
           return const Center(child: CircularProgressIndicator());
        } if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("No mosques added yet"));
          }
           final mosques = snapshot.data as List<MosqueModel>;

           return ListView.builder(

            itemCount: mosques.length,
            itemBuilder: (context,i){
              final m=mosques[i];
              return Card(
margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
child: ListTile(
                  leading: const Icon(Icons.mosque, color:AppStyles.primaryGreen),
                  title: Text(m.name),
                  subtitle: Text("${m.city}, ${m.area}\n${m.address}"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // details screen ya edit option open karna ho
                  },

),

              );
            });
      })
      ,
    );
  }
}