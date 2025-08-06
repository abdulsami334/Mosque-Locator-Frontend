import 'package:mosque_locator/models/mosque_model.dart';

class MosqueService {

  Future<List<MosqueModel>> fetchMosque()async{
     // Mock data – Replace with HTTP fetch from your backend later
    return [
      MosqueModel(
        id: '1',
        name: 'Masjid Noor',
        latitude: 24.8607,
        longitude: 67.0011,
        address: 'Block 11, Karachi',
      ),
      MosqueModel(
        id: '2',
        name: 'Masjid Quba',
        latitude: 24.8612,
        longitude: 67.0002,
        address: 'Block 11, Karachi',
      ),
    ];
  }
}
