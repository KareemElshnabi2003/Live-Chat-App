import 'package:get/get.dart';
import 'package:live_chat/Core/Class/api.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Api(), permanent: true);
  }
}