import 'package:get/get.dart';
import 'package:live_chat/Controller/Home_navigator_controller.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/Controller/base_chats_controller.dart';

class UpdatedChatsController extends BaseChatsController {
  @override
  Future<dynamic> fetchChatsFromApi(int page, int perPage, String token) {
    return chatsRemoteData.getRecentChatGust( perPage: perPage, page: page);
  }
}

// 2. كونترولر المحادثات الأخرى (للزوار)
class AnotherChatsController extends BaseChatsController {
  @override
  Future<dynamic> fetchChatsFromApi(int page, int perPage, String token) {
    return chatsRemoteData.getSystemChatsGust( perPage: perPage, page: page == 1 ? null : page);
  }
}

// 3. كونترولر المحادثات الخاصة (للمسجلين)
class PrivateChatsController extends BaseChatsController {
  @override
  Future<dynamic> fetchChatsFromApi(int page, int perPage, String token) {
    return chatsRemoteData.getuserChats(
        perPage: perPage,
        page: page
    );
  }

  @override
  void onChatsLoaded(List<UserChatModel> newChats) {
    if (Get.isRegistered<HomeNavigationController>()) {
      final homeCtrl = Get.find<HomeNavigationController>();
      homeCtrl.joinedChatIds.addAll(
        newChats.where((c) => c.id != null).map((c) => c.id!),
      );
      for (var c in newChats) {
        if (!homeCtrl.myChats.any((m) => m.id == c.id)) {
          homeCtrl.myChats.add(c);
        }
      }
      homeCtrl.update();
    }
  }
}

// 4. كونترولر محادثات النظام (للمسجلين)
class OtherChatsUserController extends BaseChatsController {
  @override
  Future<dynamic> fetchChatsFromApi(int page, int perPage, String token) {
    return chatsRemoteData.getSystemChatsGust(
        perPage: perPage,
        page: page == 1 ? null : page
    );
  }
}