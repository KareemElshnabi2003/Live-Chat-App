import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/Constant/app_api.dart';

class MarketRemoteData {
  final Api api; // إضافة final لأفضل أداء وممارسات Clean Code
  MarketRemoteData({required this.api});

  // ملاحظ التوكن والـ headers اختفوا؟ الكلاس Api بتاعنا بيحطهم أوتوماتيك!
  closePower({required String status, required String powerId}) async {
    var response = await api.updatePatchData("${AppApi.baseUrl}/store_users/$powerId", {
      "status": status
    });
    return response.fold((l) => l, (r) => r);
  }
}