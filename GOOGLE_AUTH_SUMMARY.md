# توثيق ميزة تسجيل الدخول والإنشاء بحساب Google (Google Sign-In & Sign-Up)

تم تجهيز وتطبيق ميزة تسجيل الدخول وإنشاء الحساب باستخدام Google بالكامل على تطبيق الموبايل، والربط البرمجي متوقف فقط على استقبال ومعالجة الـ API من خادم الـ Backend.

---

## 1. عناصر الواجهة وتجربة المستخدم (UI / UX)

### أ. شعار Google الفيكتور (`GoogleLogo`)
- **الملف:** `lib/View/Widget/PublicWidget/google_logo.dart`
- **الوصف:** ويدجت `CustomPainter` عالية الأداء ترسم شعار جوجل الرباعي الرسمي بدقة هندسية فيكتور دون الاعتماد على شبكة إنترنت أو ملفات خارجية قابلة للتلف.

### ب. شاشة الـ Bottom Sheet (`showBottomSheetWidget`)
- **الملف:** `lib/View/Widget/PublicWidget/show_bottom_sheet.dart`
- **المكان:** يظهر الزر في شاشتي تسجيل الدخول (`Login`) والخطوة الأولى لإنشاء الحساب (`register2`) أسفل زر "التالي".
- **التصميم:**
  - خط فاصل أنيق يتوسطه نص **"أو / OR"** مع دعم كامل للاتجاهين (RTL و LTR).
  - زر Google متناسق مع هوية التطبيق (`borderRadius: 30`) ومتوافق كلياً مع:
    - **الوضع الليلي (Dark Mode):** خلفية داكنة راقية مع خط أبيض.
    - **الوضع النهاري (Light Mode):** خلفية بيضاء مع حدود ناعمة وظلال خفيفة.
  - نص الزر ديناميكي:
    - في تسجيل الدخول: *"المتابعة باستخدام Google"* / *"Continue with Google"*.
    - في إنشاء الحساب: *"التسجيل باستخدام Google"* / *"Sign up with Google"*.
  - مؤشر تحميل مخصص (`isGoogleLoading`) يظهر داخل الزر أثناء معالجة الطلب لمنع تكرار النقر.

---

## 2. الملفات المعدلة والمنطق البرمجي (Frontend Architecture)

### 1. `pubspec.yaml`
- تم تثبيت حزمة: `google_sign_in: ^6.2.2` مع حزمها الفرعية لكافة المنصات.

### 2. `lib/Core/Constant/app_api.dart`
- تم تعريف المسار:
  ```dart
  static const String googleAuthUrl = "$baseUrl/auth/google";
  ```

### 3. `lib/Data/DataSource/auth_source.dart`
- تم إضافة دالة `googleAuth`:
  ```dart
  googleAuth({
    required String idToken,
    String? accessToken,
    required String email,
    required String name,
    String? avatar,
    required String fcmToken,
  })
  ```
- تقوم بإرسال البيانات مع الـ `device_id` و `mobile_theme` الحالي ("dark" أو "light").

### 4. `lib/Controller/page_start_controller.dart`
- **`signInWithGoogle()`**:
  1. استدعاء `_googleSignIn.signIn()`.
  2. التعامل السلس مع حالات الإلغاء في حال تراجع المستخدم.
  3. استخراج التوكن الأمني (`idToken`) والبيانات الشخصية (`email`, `name`, `photoUrl`).
  4. استخراج توكن الإشعارات (`fcmToken`) للجهاز.
  5. إرسال الطلب إلى الـ Backend ومتابعة حالة الاستجابة.
- **`_saveUserDataAndNavigate(response)`**:
  - تخزين بيانات الحساب في `sharedPreferences` (`name`, `bio`, `id`, `img`, `username`, `email`, `stars`, `token`, `powermodel`, `page: Home`).
  - مسح بيانات جلسة الزائر المؤقتة (`idGust`, `usernameGust`).
  - الانتقال السلس إلى الواجهة الرئيسية `HomeView()`.

---

## 3. الدليل الخاص بمطور الباك إند (Backend Developer Guide)

لإتمام عملية التسجيل وتسجيل الدخول عبر Google، يحتاج الباك إند لتجهيز Endpoint واحد موحد:

### أ. بيانات الطلب (Request Specification):
- **الـ Endpoint:** `POST /api/v1/auth/google?device_id={uuid}`
- **الـ Headers:** `Content-Type: application/json`, `Accept: application/json`
- **الـ Body المرسل:**
  ```json
  {
    "id_token": "eyJhbGciOiJSUzI1NiIsImtp...",
    "access_token": "ya29.a0AfH6...",
    "email": "user@gmail.com",
    "name": "اسم المستخدم",
    "avatar": "https://lh3.googleusercontent.com/...",
    "fcm_token": "fcm_device_token_here",
    "mobile_theme": "dark"
  }
  ```

### ب. منطق العمل المطلوب في السيرفر (Server Logic):
1. **التحقق من التوكن:** فحص صحة `id_token` للتأكد من هوية المستخدم الحقيقية من Google.
2. **فحص وجود البريد:**
   - **إذا كان البريد مسجلاً مسبقاً (Login):** يتم تسجيل دخوله مباشرة وتحديث توكن الإشعارات.
   - **إذا كان البريد جديداً (Sign Up):** يتم إنشاء حساب جديد مباشرة، وتوليد اسم مستخدم تلقائي فريد (Unique Username) مثل `user_1234`، وتفعيل الحساب فوراً دون طلب OTP.
3. **الاستجابة المطلوبة (Expected Response):**
   ```json
   {
     "status": "success",
     "code": 200,
     "message": "تم تسجيل الدخول بنجاح",
     "data": {
       "id": 123,
       "name": "اسم المستخدم",
       "username": "user_1234",
       "email": "user@gmail.com",
       "image": "https://...",
       "bio": "",
       "number_of_stars": 0,
       "token": "BEARER_AUTH_TOKEN_HERE",
       "user_power": {}
     }
   }
   ```

---

## 4. إعدادات المنصات (Platform Settings)

### Android:
- تم ربط بصمات الـ **SHA-1** والـ **SHA-256** في Firebase Console.
- ملف `android/app/google-services.json` تم تحديثه بالشهادات الجديدة.

### iOS (حين الرغبة في تفعيله لاحقاً):
- تنزيل `GoogleService-Info.plist` من Firebase ووضعه في `ios/Runner/`.
- نسخ قيمة `REVERSED_CLIENT_ID` وإضافتها تحت `CFBundleURLTypes` في `ios/Runner/Info.plist`.
