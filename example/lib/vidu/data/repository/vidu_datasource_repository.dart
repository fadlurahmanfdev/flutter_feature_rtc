import 'package:dio/dio.dart';
import 'package:example/vidu/data/dto/response/connection_response.dart';

class ViduDatasourceRepositoryImpl {
  Dio dio;

  ViduDatasourceRepositoryImpl({
    required this.dio,
  });

  Future<ConnectionResponse> createConnection({required String sessionId, required String basicAuthToken}) async {
    try {
      final respData = await dio.post('openvidu/api/sessions/$sessionId/connection',
          options: Options(headers: {'Authorization': 'Basic $basicAuthToken'}));
      return ConnectionResponse.fromJson(respData.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print("failed createConnection dio: ${e}");
      throw Exception(e.message);
    } on Exception catch (e) {
      print("failed createConnection: ${e}");
      throw Exception('GENERAL');
    }
  }
}
