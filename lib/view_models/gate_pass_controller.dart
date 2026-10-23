import 'package:get/get.dart';
import 'package:security_manager/api_service/dashboard_service.dart';
import 'package:security_manager/models/gate_pass_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class GatePassController extends GetxController {
  final DashboardService _service = DashboardService();

  final RxBool isLoading = false.obs;
  final RxList<GatePass> gatePasses = <GatePass>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGatePasses();
  }

  Future<void> fetchGatePasses() async {
    final token = AuthController.authToken;

    if (token.isEmpty) {
      App.showSnackBar(
        title: 'Session Expired',
        message: 'Please login again.',
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _service.getGatePasses(token);
      if (response.success) {
        gatePasses.assignAll(response.data);
      } else {
        App.showSnackBar(
          title: 'Error',
          message: 'Failed to load gate passes',
          isError: true,
        );
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
