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