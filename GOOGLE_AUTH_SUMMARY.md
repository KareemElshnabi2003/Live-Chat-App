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
- تم تحديث دالة `googleAuth`:
  ```dart
  googleAuth({
    required String credential,
    String? fcmToken,
  })
  ```
- تقوم بإرسال الـ `credential` (ID token) مع `mobile_theme` ("dark" أو "light") و `fcm_token` إلى `POST /api/v1/auth/google?device_id=$deviceId`.

### 4. `lib/Controller/page_start_controller.dart`
- **`signInWithGoogle()`**:
  1. تهيئة `_googleSignIn` مع `serverClientId` لضمان توليد الـ `idToken`.
  2. استدعاء `_googleSignIn.signIn()`.
  3. استخراج الـ `credential` (`idToken`) وتوكن الإشعارات `fcmToken`.
  4. إرسال الطلب إلى الـ Backend ومتابعة حالة الاستجابة:
     - **الحالة الأولى (`status: "authenticated"`):** البريد مسجل وموثق، يتم حفظ الـ `token` وبيانات الحساب والانتقال مباشرة إلى `HomeView()`.
     - **الحالة الثانية (`status: "otp_required"`):** حساب جديد، يتم تحويل الشاشة فوراً إلى إدخال كود التحقق `verifyLogin` مع تعيين البريد وعرض إشعار بنجاح إرسال الكود إلى بريده.
- **التحقق من الكود (`verifyLogin` / `checkOTP`)**:
  - يتم استدعاء `POST /api/v1/auth/check-otp` بالبيانات `{ "email": "...", "token": "123456", "fcm_token": "...", "mobile_theme": "..." }`.
  - عند النجاح، يتم استلام بيانات المستخدم مع الـ `token` وحفظها والانتقال للشاشة الرئيسية.
  - عند الخطأ (404)، يتم عرض رسالة الخطأ الواضحة من السيرفر.

---

## 3. مواصفات الـ API الفعلي (Backend API Specification)

### أ. تسجيل الدخول بجوجل (Google Sign-In)
- **الـ Endpoint:** `POST /api/v1/auth/google`
- **الـ Headers:**
  - `Content-Type: application/json`
  - `Accept: application/json`
  - `Accept-Language: ar` (أو `en`)
- **الـ Body المرسل:**
  ```json
  {
    "credential": "<Google ID Token>",
    "fcm_token": "...",
    "mobile_theme": "light"
  }
  ```
- **حالات الاستجابة:**
  1. **إيميل مسجل وموثق:**
     ```json
     {
       "data": {
         "status": "authenticated",
         "id": 1,
         "name": "...",
         "username": "...",
         "image": "...",
         "email": "...",
         "bio": "...",
         "token": "xxxxx",
         "number_of_stars": 0,
         "user_power": 0
       }
     }
     ```
  2. **إيميل جديد (أول مرة):**
     ```json
     {
       "data": {
         "status": "otp_required",
         "email": "user@gmail.com"
       }
     }
     ```

### ب. التحقق من كود الـ OTP (Check OTP)
- **الـ Endpoint:** `POST /api/v1/auth/check-otp`
- **الـ Body المرسل:**
  ```json
  {
    "email": "user@gmail.com",
    "token": "123456",
    "fcm_token": "...",
    "mobile_theme": "light"
  }
  ```
- **الاستجابة:**
  - **نجاح (200):** يرجع بيانات المستخدم كـ LoginResource متضمناً الـ `token` دون وجود مفتاح `status`.
  - **فشل (404):** رسالة خطأ بعدم صحة الكود أو انتهاء صلاحيته.

---

## 4. إعدادات المنصات (Platform Settings)

### Android:
- تم ربط بصمات الـ **SHA-1** والـ **SHA-256** في Firebase Console.
- ملف `android/app/google-services.json` تم تحديثه بالشهادات الجديدة.

### iOS (حين الرغبة في تفعيله لاحقاً):
- تنزيل `GoogleService-Info.plist` من Firebase ووضعه في `ios/Runner/`.
- نسخ قيمة `REVERSED_CLIENT_ID` وإضافتها تحت `CFBundleURLTypes` في `ios/Runner/Info.plist`.
