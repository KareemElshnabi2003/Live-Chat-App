// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `تسجيل الدخول`
  String get log_in {
    return Intl.message('تسجيل الدخول', name: 'log_in', desc: '', args: []);
  }
  /// `إعلانات معنا`
  String get adsWithUs {
    return Intl.message('إعلانات معنا', name: 'adsWithUs', desc: '', args: []);
  }  /// `الدردشة العامة`
  String get general_chat {
    return Intl.message('الدردشة العامة', name: 'general_chat', desc: '', args: []);
  }

  /// `الدردشة المثبتة`
  String get positive_chat {
    return Intl.message(
      'الدردشة المثبتة',
      name: 'positive_chat',
      desc: '',
      args: [],
    );
  }
/// `طلبات الصداقة`
  String get frindsRequests {
    return Intl.message(
      'طلبات الصداقة',
      name: 'frindsRequests',
      desc: '',
      args: [],
    );
  }
/// `المرسلة`
  String get sentRequests {
    return Intl.message(
      'المرسلة',
      name: 'sentRequests',
      desc: '',
      args: [],
    );
  }


  /// `إلغاء`
  String get cancel {
    return Intl.message(
      'إلغاء',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

/// `تم إرسال طلب الصداقة`
  String get youSendRequest {
    return Intl.message(
      'تم إرسال طلب الصداقة',
      name: 'youSendRequest',
      desc: '',
      args: [],
    );
  }

  /// `عذراً، لا يمكنك التواصل مع هذا المستخدم حالياً.`
  String get msgYouBlocked {
    return Intl.message(
      'عذراً، لا يمكنك التواصل مع هذا المستخدم حالياً.',
      name: 'msgYouBlocked',
      desc: '',
      args: [],
    );
  }
  /// `لقد قمت بحظر هذا المستخدم مسبقاً. هل ترغب في إلغاء الحظر للتواصل معه؟`
  String get msgIBlocked {
    return Intl.message(
      'لقد قمت بحظر هذا المستخدم مسبقاً. هل ترغب في إلغاء الحظر للتواصل معه؟',
      name: 'msgIBlocked',
      desc: '',
      args: [],
    );
  }  /// `غير مصرح لك بإجراء هذه العملية حالياً.`
  String get msgNotHasPermission {
    return Intl.message(
      'غير مصرح لك بإجراء هذه العملية حالياً.',
      name: 'msgNotHasPermission',
      desc: '',
      args: [],
    );
  }

  /// `قيد المراجعة`
  String get underReview {
    return Intl.message(
      'قيد المراجعة',
      name: 'underReview',
      desc: '',
      args: [],
    );
  }

  /// `الفراعنة العظماء`
  String get the_great_pharaohs {
    return Intl.message(
      'الفراعنة العظماء',
      name: 'the_great_pharaohs',
      desc: '',
      args: [],
    );
  }

  /// `شخصًا مشاركًا`
  String get engaged_people {
    return Intl.message(
      'شخصًا مشاركًا',
      name: 'engaged_people',
      desc: '',
      args: [],
    );
  } /// `الغاء الحظر`
  String get cancelBloc {
    return Intl.message(
      'الغاء الحظر',
      name: 'cancelBloc',
      desc: '',
      args: [],
    );
  }

  /// `انضم الآن`
  String get join_now {
    return Intl.message('انضم الآن', name: 'join_now', desc: '', args: []);
  }

  /// `أحدث الدردشات`
  String get latest_chats {
    return Intl.message(
      'أحدث الدردشات',
      name: 'latest_chats',
      desc: '',
      args: [],
    );
  }

  /// `دردشات أخرى`
  String get other_chats {
    return Intl.message('دردشات أخرى', name: 'other_chats', desc: '', args: []);
  }

  /// `إنشاء حساب`
  String get create_account {
    return Intl.message(
      'إنشاء حساب',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `رجوع`
  String get back {
    return Intl.message('رجوع', name: 'back', desc: '', args: []);
  }

  /// `أدخل الرمز المرسل`
  String get enter_the_code_sent {
    return Intl.message(
      'أدخل الرمز المرسل',
      name: 'enter_the_code_sent',
      desc: '',
      args: [],
    );
  }

  /// `أدخل عنوان بريدك الإلكتروني`
  String get enter_your_email_address {
    return Intl.message(
      'أدخل عنوان بريدك الإلكتروني',
      name: 'enter_your_email_address',
      desc: '',
      args: [],
    );
  }

  /// `يجب عليك التحقق من أنك مالك البريد الإلكتروني`
  String get you_must_verify_email {
    return Intl.message(
      'يجب عليك التحقق من أنك مالك البريد الإلكتروني',
      name: 'you_must_verify_email',
      desc: '',
      args: [],
    );
  }

  /// `املأ التفاصيل، 0 خطوات متبقية فقط`
  String get fill_in_details_zero_steps {
    return Intl.message(
      'املأ التفاصيل، 0 خطوات متبقية فقط',
      name: 'fill_in_details_zero_steps',
      desc: '',
      args: [],
    );
  }

  /// `أدخل البريد الإلكتروني لإكمال عملية التسجيل`
  String get enter_email_to_complete {
    return Intl.message(
      'أدخل البريد الإلكتروني لإكمال عملية التسجيل',
      name: 'enter_email_to_complete',
      desc: '',
      args: [],
    );
  }

  /// `املأ المعلومات، خطوة واحدة متبقية`
  String get fill_in_information_one_step {
    return Intl.message(
      'املأ المعلومات، خطوة واحدة متبقية',
      name: 'fill_in_information_one_step',
      desc: '',
      args: [],
    );
  }

  /// `املأ التفاصيل، خطوتان متبقيتان`
  String get fill_in_details_two_steps {
    return Intl.message(
      'املأ التفاصيل، خطوتان متبقيتان',
      name: 'fill_in_details_two_steps',
      desc: '',
      args: [],
    );
  }

  /// `البريد الإلكتروني`
  String get email {
    return Intl.message('البريد الإلكتروني', name: 'email', desc: '', args: []);
  }

  /// `الاسم الكامل`
  String get full_name {
    return Intl.message('الاسم الكامل', name: 'full_name', desc: '', args: []);
  }

  /// `التالي`
  String get next {
    return Intl.message('التالي', name: 'next', desc: '', args: []);
  }

  /// `من فضلك، أدخل اسمك`
  String get please_enter_your_name {
    return Intl.message(
      'من فضلك، أدخل اسمك',
      name: 'please_enter_your_name',
      desc: '',
      args: [],
    );
  }

  /// `من فضلك، أدخل بريدك الإلكتروني`
  String get please_enter_your_email {
    return Intl.message(
      'من فضلك، أدخل بريدك الإلكتروني',
      name: 'please_enter_your_email',
      desc: '',
      args: [],
    );
  }

  /// `من فضلك، أدخل بريدًا إلكترونيًا صالحًا`
  String get please_enter_valid_email {
    return Intl.message(
      'من فضلك، أدخل بريدًا إلكترونيًا صالحًا',
      name: 'please_enter_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق`
  String get close {
    return Intl.message('إغلاق', name: 'close', desc: '', args: []);
  }

  /// `اختر ما تريد تشغيله`
  String get chooseWhatYouWantToPlay {
    return Intl.message(
      'اختر ما تريد تشغيله',
      name: 'chooseWhatYouWantToPlay',
      desc: '',
      args: [],
    );
  }

  /// `الآن يتم تشغيل: {musicName}`
  String nowPlaying(Object musicName) {
    return Intl.message(
      'الآن يتم تشغيل: $musicName',
      name: 'nowPlaying',
      desc: '',
      args: [musicName],
    );
  }

  /// `فراشة`
  String get butterfly {
    return Intl.message('فراشة', name: 'butterfly', desc: '', args: []);
  }

  /// `سوندير`
  String get sonder {
    return Intl.message('سوندير', name: 'sonder', desc: '', args: []);
  }

  /// `ساكويا`
  String get sakuya {
    return Intl.message('ساكويا', name: 'sakuya', desc: '', args: []);
  }

  /// `إيقاف {musicName}`
  String stopMusic(Object musicName) {
    return Intl.message(
      'إيقاف $musicName',
      name: 'stopMusic',
      desc: '',
      args: [musicName],
    );
  }

  /// `تشغيل {musicName}`
  String playMusic(Object musicName) {
    return Intl.message(
      'تشغيل $musicName',
      name: 'playMusic',
      desc: '',
      args: [musicName],
    );
  }

  /// `الأعضاء`
  String get members {
    return Intl.message('الأعضاء', name: 'members', desc: '', args: []);
  }

  /// `كريم السيد`
  String get kareemElsayed {
    return Intl.message(
      'كريم السيد',
      name: 'kareemElsayed',
      desc: '',
      args: [],
    );
  }

  /// `مراسلة`
  String get correspondent {
    return Intl.message('مراسلة', name: 'correspondent', desc: '', args: []);
  }

  /// `كيف تكون ملاكًا أبيض`
  String get howToBeWhiteAngel {
    return Intl.message(
      'كيف تكون ملاكًا أبيض',
      name: 'howToBeWhiteAngel',
      desc: '',
      args: [],
    );
  }

  /// `مشاركة`
  String get share {
    return Intl.message('مشاركة', name: 'share', desc: '', args: []);
  }

  /// `موسيقى`
  String get music {
    return Intl.message('موسيقى', name: 'music', desc: '', args: []);
  }

  /// `الملف الشخصي`
  String get profile {
    return Intl.message('الملف الشخصي', name: 'profile', desc: '', args: []);
  }

  /// `الإعدادات`
  String get settings {
    return Intl.message('الإعدادات', name: 'settings', desc: '', args: []);
  }

  /// `مكالمة`
  String get call {
    return Intl.message('مكالمة', name: 'call', desc: '', args: []);
  }

  /// `فيديو`
  String get video {
    return Intl.message('فيديو', name: 'video', desc: '', args: []);
  }

  /// `أرسل رسالتك...`
  String get sendYourMessage {
    return Intl.message(
      'أرسل رسالتك...',
      name: 'sendYourMessage',
      desc: '',
      args: [],
    );
  }

  /// `عضو في دردشة الفراعنة`
  String get membersOfChat {
    return Intl.message(
      'عضو في دردشة الفراعنة',
      name: 'membersOfChat',
      desc: '',
      args: [],
    );
  }

  /// `تعديل`
  String get edit {
    return Intl.message('تعديل', name: 'edit', desc: '', args: []);
  }

  /// `أصدقاؤك`
  String get yourFriends {
    return Intl.message('أصدقاؤك', name: 'yourFriends', desc: '', args: []);
  }

  /// `إنشاء دردشة جديدة`
  String get createNewChat {
    return Intl.message(
      'إنشاء دردشة جديدة',
      name: 'createNewChat',
      desc: '',
      args: [],
    );
  }

  /// `صورة الغرفة`
  String get roomImage {
    return Intl.message('صورة الغرفة', name: 'roomImage', desc: '', args: []);
  }

  /// `الاسم`
  String get name {
    return Intl.message('الاسم', name: 'name', desc: '', args: []);
  }

  /// `اختر خاص أو عام`
  String get selectPrivateOrPublic {
    return Intl.message(
      'اختر خاص أو عام',
      name: 'selectPrivateOrPublic',
      desc: '',
      args: [],
    );
  }

  /// `اختر مديرًا من الأعضاء`
  String get selectManager {
    return Intl.message(
      'اختر مديرًا من الأعضاء',
      name: 'selectManager',
      desc: '',
      args: [],
    );
  }

  /// `اختر تنسيق الدردشة`
  String get chooseChatFormat {
    return Intl.message(
      'اختر تنسيق الدردشة',
      name: 'chooseChatFormat',
      desc: '',
      args: [],
    );
  }

  /// `دعوة الأصدقاء`
  String get inviteFriends {
    return Intl.message(
      'دعوة الأصدقاء',
      name: 'inviteFriends',
      desc: '',
      args: [],
    );
  }

  /// `إنشاء`
  String get create {
    return Intl.message('إنشاء', name: 'create', desc: '', args: []);
  }

  /// `حفظ`
  String get save {
    return Intl.message('حفظ', name: 'save', desc: '', args: []);
  }

  /// `حذف`
  String get delete {
    return Intl.message('حذف', name: 'delete', desc: '', args: []);
  }

  /// `إعدادات الدردشة`
  String get settingsOfChat {
    return Intl.message(
      'إعدادات الدردشة',
      name: 'settingsOfChat',
      desc: '',
      args: [],
    );
  }

  /// `ثبت دردشتك`
  String get pinYourChat {
    return Intl.message('ثبت دردشتك', name: 'pinYourChat', desc: '', args: []);
  }

  /// `مرحبًا،`
  String get hello {
    return Intl.message('مرحبًا،', name: 'hello', desc: '', args: []);
  }

  /// `دردشاتك الخاصة`
  String get yourPrivateChats {
    return Intl.message(
      'دردشاتك الخاصة',
      name: 'yourPrivateChats',
      desc: '',
      args: [],
    );
  }

  /// `دردشة جديدة`
  String get newChat {
    return Intl.message('دردشة جديدة', name: 'newChat', desc: '', args: []);
  }

  /// `اعلان`
  String get ad {
    return Intl.message('اعلان', name: 'ad', desc: '', args: []);
  } /// `اضغط هنا للزيارة`
  String get clickHereToVisit {
    return Intl.message('اضغط هنا للزيارة', name: 'clickHereToVisit', desc: '', args: []);
  }

  /// `ابدأ في إنشاء عالم جديد`
  String get startCreatingNewWorld {
    return Intl.message(
      'ابدأ في إنشاء عالم جديد',
      name: 'startCreatingNewWorld',
      desc: '',
      args: [],
    );
  }

  /// `أصدقاء مقترحون`
  String get suggestedFriends {
    return Intl.message(
      'أصدقاء مقترحون',
      name: 'suggestedFriends',
      desc: '',
      args: [],
    );
  }

  /// `قوة`
  String get power {
    return Intl.message('قوة', name: 'power', desc: '', args: []);
  }

  /// `الدردشات`
  String get chats {
    return Intl.message('الدردشات', name: 'chats', desc: '', args: []);
  }

  /// `إضافة دردشة جديدة`
  String get addNewChat {
    return Intl.message(
      'إضافة دردشة جديدة',
      name: 'addNewChat',
      desc: '',
      args: [],
    );
  }

  /// `اللغة`
  String get language {
    return Intl.message('اللغة', name: 'language', desc: '', args: []);
  }

  /// `تم اختيار اللغة الإنجليزية`
  String get englishLanguageSelected {
    return Intl.message(
      'تم اختيار اللغة الإنجليزية',
      name: 'englishLanguageSelected',
      desc: '',
      args: [],
    );
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `الإنجليزية`
  String get english {
    return Intl.message('الإنجليزية', name: 'english', desc: '', args: []);
  }

  /// `الوضع الليلي`
  String get nightMode {
    return Intl.message('الوضع الليلي', name: 'nightMode', desc: '', args: []);
  }

  /// `تم تفعيل الوضع المظلم`
  String get darkModeEnabled {
    return Intl.message(
      'تم تفعيل الوضع المظلم',
      name: 'darkModeEnabled',
      desc: '',
      args: [],
    );
  }

  /// `الوضع الفاتح`
  String get lightMode {
    return Intl.message('الوضع الفاتح', name: 'lightMode', desc: '', args: []);
  }

  /// `الوضع المظلم`
  String get darkMode {
    return Intl.message('الوضع المظلم', name: 'darkMode', desc: '', args: []);
  }

  /// `الإشعارات`
  String get notifications {
    return Intl.message('الإشعارات', name: 'notifications', desc: '', args: []);
  }

  /// `تم تفعيل الإشعارات`
  String get notificationsEnabled {
    return Intl.message(
      'تم تفعيل الإشعارات',
      name: 'notificationsEnabled',
      desc: '',
      args: [],
    );
  }

  /// `تم تعطيل الإشعارات`
  String get notificationsDisabled {
    return Intl.message(
      'تم تعطيل الإشعارات',
      name: 'notificationsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `الخصوصية`
  String get privacy {
    return Intl.message('الخصوصية', name: 'privacy', desc: '', args: []);
  }

  /// `حسابي`
  String get myAccount {
    return Intl.message('حسابي', name: 'myAccount', desc: '', args: []);
  }

  /// `تعديل المعلومات`
  String get editInformation {
    return Intl.message(
      'تعديل المعلومات',
      name: 'editInformation',
      desc: '',
      args: [],
    );
  }

  /// `أدخل اسمك الكامل`
  String get enterFullName {
    return Intl.message(
      'أدخل اسمك الكامل',
      name: 'enterFullName',
      desc: '',
      args: [],
    );
  }

  /// `أدخل اسم المستخدم`
  String get enterUsername {
    return Intl.message(
      'أدخل اسم المستخدم',
      name: 'enterUsername',
      desc: '',
      args: [],
    );
  }

  /// `أدخل بريدك الإلكتروني`
  String get enterEmail {
    return Intl.message(
      'أدخل بريدك الإلكتروني',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `أدخل بلدك`
  String get enterCountry {
    return Intl.message('أدخل بلدك', name: 'enterCountry', desc: '', args: []);
  }

  /// `أدخل عمرك`
  String get enterAge {
    return Intl.message('أدخل عمرك', name: 'enterAge', desc: '', args: []);
  }

  /// `اختر جنسك`
  String get selectGender {
    return Intl.message('اختر جنسك', name: 'selectGender', desc: '', args: []);
  }

  /// `أدخل رقم هاتفك المحمول`
  String get enterMobileNumber {
    return Intl.message(
      'أدخل رقم هاتفك المحمول',
      name: 'enterMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `حفظ التغييرات`
  String get saveChanges {
    return Intl.message(
      'حفظ التغييرات',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `عام`
  String get general {
    return Intl.message('عام', name: 'general', desc: '', args: []);
  }

  /// `معلومات الحساب`
  String get accountInformation {
    return Intl.message(
      'معلومات الحساب',
      name: 'accountInformation',
      desc: '',
      args: [],
    );
  }

  /// `القدرات`
  String get capabilities {
    return Intl.message('القدرات', name: 'capabilities', desc: '', args: []);
  }

  /// `مساعدة`
  String get help {
    return Intl.message('مساعدة', name: 'help', desc: '', args: []);
  }

  /// `الشروط والأحكام`
  String get termsAndConditions {
    return Intl.message(
      'الشروط والأحكام',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الخروج`
  String get logOut {
    return Intl.message('تسجيل الخروج', name: 'logOut', desc: '', args: []);
  }

  /// `نحن في انتظار تأكيدك مرة أخرى!!`
  String get waitingForConfirmation {
    return Intl.message(
      'نحن في انتظار تأكيدك مرة أخرى!!',
      name: 'waitingForConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `سيتم تسجيل خروجك بعد الضغط على تأكيد ..`
  String get willBeLoggedOut {
    return Intl.message(
      'سيتم تسجيل خروجك بعد الضغط على تأكيد ..',
      name: 'willBeLoggedOut',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد`
  String get confirm {
    return Intl.message('تأكيد', name: 'confirm', desc: '', args: []);
  }




  /// `تم الدفع بنجاح!`
  String get paymentSuccessful {
    return Intl.message(
      'تم الدفع بنجاح!',
      name: 'paymentSuccessful',
      desc: '',
      args: [],
    );
  }


  /// `الدفع قيد المراجعة من قبل المسؤولين.`
  String get paymentUnderReview {
    return Intl.message(
      'الدفع قيد المراجعة من قبل المسؤولين.',
      name: 'paymentUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `تم الإرسال بنجاح!`
  String get sentSuccessfully {
    return Intl.message(
      'تم الإرسال بنجاح!',
      name: 'sentSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال النجوم بنجاح.`
  String get starsSentSuccessfully {
    return Intl.message(
      'تم إرسال النجوم بنجاح.',
      name: 'starsSentSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `شراء أو إرسال النجوم`
  String get buyOrSendStars {
    return Intl.message(
      'شراء أو إرسال النجوم',
      name: 'buyOrSendStars',
      desc: '',
      args: [],
    );
  }

  /// `عدد النجوم`
  String get numberOfStars {
    return Intl.message(
      'عدد النجوم',
      name: 'numberOfStars',
      desc: '',
      args: [],
    );
  }

  /// `شراء`
  String get purchase {
    return Intl.message('شراء', name: 'purchase', desc: '', args: []);
  }

  /// `إرسال`
  String get send {
    return Intl.message('إرسال', name: 'send', desc: '', args: []);
  }

  /// `اسم المستخدم`
  String get userName {
    return Intl.message('اسم المستخدم', name: 'userName', desc: '', args: []);
  }

  /// `رقم المحفظة: مثال 0111111111`
  String get walletNumber {
    return Intl.message(
      'رقم المحفظة: مثال 0111111111',
      name: 'walletNumber',
      desc: '',
      args: [],
    );
  }

  /// `اختر الدردشة التي تريد تثبيتها`
  String get chooseChatToPin {
    return Intl.message(
      'اختر الدردشة التي تريد تثبيتها',
      name: 'chooseChatToPin',
      desc: '',
      args: [],
    );
  }

  /// `هل تريد تثبيت إعلان؟`
  String get wantToPinAdd {
    return Intl.message(
      'هل تريد تثبيت إعلان؟',
      name: 'wantToPinAdd',
      desc: '',
      args: [],
    );
  }

  /// `لا`
  String get no {
    return Intl.message('لا', name: 'no', desc: '', args: []);
  }

  /// `نعم`
  String get yes {
    return Intl.message('نعم', name: 'yes', desc: '', args: []);
  }

  /// `العنوان`
  String get title {
    return Intl.message('العنوان', name: 'title', desc: '', args: []);
  }

  /// `وصف الرابط`
  String get descriptionLink {
    return Intl.message(
      'وصف الرابط',
      name: 'descriptionLink',
      desc: '',
      args: [],
    );
  }

  /// `اختر طريقة الدفع المناسبة`
  String get choosePaymentMethod {
    return Intl.message(
      'اختر طريقة الدفع المناسبة',
      name: 'choosePaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `معلومات`
  String get info {
    return Intl.message('معلومات', name: 'info', desc: '', args: []);
  }

  /// `إنستاباي`
  String get instapay {
    return Intl.message('إنستاباي', name: 'instapay', desc: '', args: []);
  }

  /// `فودافون كاش`
  String get vodafoneCash {
    return Intl.message(
      'فودافون كاش',
      name: 'vodafoneCash',
      desc: '',
      args: [],
    );
  }

  /// `باينانس`
  String get binance {
    return Intl.message('باينانس', name: 'binance', desc: '', args: []);
  }

  /// `بيرفكت موني`
  String get perfectMoney {
    return Intl.message(
      'بيرفكت موني',
      name: 'perfectMoney',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق الطاقة`
  String get closeEnergy {
    return Intl.message(
      'إغلاق الطاقة',
      name: 'closeEnergy',
      desc: '',
      args: [],
    );
  }

  /// `إجراء`
  String get procedure {
    return Intl.message('إجراء', name: 'procedure', desc: '', args: []);
  }

  /// `بعد الشراء`
  String get afterPurchase {
    return Intl.message(
      'بعد الشراء',
      name: 'afterPurchase',
      desc: '',
      args: [],
    );
  }

  /// `السعر`
  String get price {
    return Intl.message('السعر', name: 'price', desc: '', args: []);
  }

  /// `المزيد`
  String get more {
    return Intl.message('المزيد', name: 'more', desc: '', args: []);
  }

  /// `عناوين`
  String get titles {
    return Intl.message('عناوين', name: 'titles', desc: '', args: []);
  }

  /// `حركات`
  String get movements {
    return Intl.message('حركات', name: 'movements', desc: '', args: []);
  }

  /// `ألوان`
  String get colors {
    return Intl.message('ألوان', name: 'colors', desc: '', args: []);
  }

  /// `شحن النجوم من هنا`
  String get chargeStars {
    return Intl.message(
      'شحن النجوم من هنا',
      name: 'chargeStars',
      desc: '',
      args: [],
    );
  }

  /// `عدد النجوم {count}`
  String numberOfStarsCount(Object count) {
    return Intl.message(
      'عدد النجوم $count',
      name: 'numberOfStarsCount',
      desc: '',
      args: [count],
    );
  }

  /// `شحن النجوم الآن`
  String get chargeStarsNow {
    return Intl.message(
      'شحن النجوم الآن',
      name: 'chargeStarsNow',
      desc: '',
      args: [],
    );
  }

  /// `عدد الأيام المتبقية: {days} يومًا`
  String daysRemaining(Object days) {
    return Intl.message(
      'عدد الأيام المتبقية: $days يومًا',
      name: 'daysRemaining',
      desc: '',
      args: [days],
    );
  }

  /// `تحقق`
  String get verify {
    return Intl.message('تحقق', name: 'verify', desc: '', args: []);
  }

  /// `تحذير`
  String get warning {
    return Intl.message('تحذير', name: 'warning', desc: '', args: []);
  }

  /// `هل أنت متأكد أنك تريد الخروج؟`
  String get exitConfirmation {
    return Intl.message(
      'هل أنت متأكد أنك تريد الخروج؟',
      name: 'exitConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `خروج`
  String get exit {
    return Intl.message('خروج', name: 'exit', desc: '', args: []);
  }

  /// `خطأ`
  String get error {
    return Intl.message('خطأ', name: 'error', desc: '', args: []);
  }

  /// `يرجى ملء جميع الحقول`
  String get fillAllFields {
    return Intl.message(
      'يرجى ملء جميع الحقول',
      name: 'fillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `نجاح`
  String get success {
    return Intl.message('نجاح', name: 'success', desc: '', args: []);
  }

  /// `تم فك الحظر بنجاح`
  String get msgUnblockedSuccessfully {
    return Intl.message('تم فك الحظر بنجاح',
        name: 'msgUnblockedSuccessfully', desc: '', args: []);
  }

  /// `تم نسخ الرابط`
  String get linkCopied {
    return Intl.message(
      'تم نسخ الرابط',
      name: 'linkCopied',
      desc: '',
      args: [],
    );
  }

  /// `Http/faraena.com`
  String get httpFaraena {
    return Intl.message(
      'Http/faraena.com',
      name: 'httpFaraena',
      desc: '',
      args: [],
    );
  }

  /// `ذكر`
  String get male {
    return Intl.message('ذكر', name: 'male', desc: '', args: []);
  }

  /// `أنثى`
  String get female {
    return Intl.message('أنثى', name: 'female', desc: '', args: []);
  }

  /// `آخر`
  String get other {
    return Intl.message('آخر', name: 'other', desc: '', args: []);
  }

  /// `جاري التحميل...`
  String get loading {
    return Intl.message('جاري التحميل...', name: 'loading', desc: '', args: []);
  }

  /// `انضم الآن`
  String get joinNow {
    return Intl.message('انضم الآن', name: 'joinNow', desc: '', args: []);
  }

  /// `إنشاء الآن`
  String get createNow {
    return Intl.message('إنشاء الآن', name: 'createNow', desc: '', args: []);
  }

  /// `الدردشة الإيجابية`
  String get positiveChat {
    return Intl.message(
      'الدردشة الإيجابية',
      name: 'positiveChat',
      desc: '',
      args: [],
    );
  }

  /// `الفراعنة العظماء`
  String get theGreatPharaohs {
    return Intl.message(
      'الفراعنة العظماء',
      name: 'theGreatPharaohs',
      desc: '',
      args: [],
    );
  }

  /// `{count} شخصًا مشاركًا`
  String engagedPeople(Object count) {
    return Intl.message(
      '$count شخصًا مشاركًا',
      name: 'engagedPeople',
      desc: '',
      args: [count],
    );
  }

  /// `أحدث الدردشات`
  String get latestChats {
    return Intl.message(
      'أحدث الدردشات',
      name: 'latestChats',
      desc: '',
      args: [],
    );
  }

  /// `دردشات أخرى`
  String get otherChats {
    return Intl.message('دردشات أخرى', name: 'otherChats', desc: '', args: []);
  }

  /// `إنشاء حساب`
  String get createAccount {
    return Intl.message(
      'إنشاء حساب',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `أدخل الرمز المرسل`
  String get enterCodeSent {
    return Intl.message(
      'أدخل الرمز المرسل',
      name: 'enterCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `أدخل عنوان بريدك الإلكتروني`
  String get enterEmailAddress {
    return Intl.message(
      'أدخل عنوان بريدك الإلكتروني',
      name: 'enterEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `يجب عليك التحقق من أنك مالك البريد الإلكتروني`
  String get verifyEmailOwner {
    return Intl.message(
      'يجب عليك التحقق من أنك مالك البريد الإلكتروني',
      name: 'verifyEmailOwner',
      desc: '',
      args: [],
    );
  }

  /// `املأ التفاصيل، 0 خطوات متبقية فقط`
  String get fillDetailsZeroSteps {
    return Intl.message(
      'املأ التفاصيل، 0 خطوات متبقية فقط',
      name: 'fillDetailsZeroSteps',
      desc: '',
      args: [],
    );
  }

  /// `أدخل البريد الإلكتروني لإكمال عملية التسجيل`
  String get enterEmailToComplete {
    return Intl.message(
      'أدخل البريد الإلكتروني لإكمال عملية التسجيل',
      name: 'enterEmailToComplete',
      desc: '',
      args: [],
    );
  }

  /// `املأ المعلومات، خطوة واحدة متبقية`
  String get fillInfoOneStep {
    return Intl.message(
      'املأ المعلومات، خطوة واحدة متبقية',
      name: 'fillInfoOneStep',
      desc: '',
      args: [],
    );
  }

  /// `املأ التفاصيل، خطوتان متبقيتان`
  String get fillDetailsTwoSteps {
    return Intl.message(
      'املأ التفاصيل، خطوتان متبقيتان',
      name: 'fillDetailsTwoSteps',
      desc: '',
      args: [],
    );
  }

  /// `من فضلك، أدخل اسمك`
  String get pleaseEnterName {
    return Intl.message(
      'من فضلك، أدخل اسمك',
      name: 'pleaseEnterName',
      desc: '',
      args: [],
    );
  }

  /// `من فضلك، أدخل بريدك الإلكتروني`
  String get pleaseEnterEmail {
    return Intl.message(
      'من فضلك، أدخل بريدك الإلكتروني',
      name: 'pleaseEnterEmail',
      desc: '',
      args: [],
    );
  }

  /// `من فضلك، أدخل بريدًا إلكترونيًا صالحًا`
  String get pleaseEnterValidEmail {
    return Intl.message(
      'من فضلك، أدخل بريدًا إلكترونيًا صالحًا',
      name: 'pleaseEnterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `عضو في دردشة العشاق`
  String get memberOfLoversChat {
    return Intl.message(
      'عضو في دردشة العشاق',
      name: 'memberOfLoversChat',
      desc: '',
      args: [],
    );
  }

  /// `زهرة العالم`
  String get flowerOfWorld {
    return Intl.message(
      'زهرة العالم',
      name: 'flowerOfWorld',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد إشعارات`
  String get noNotifications {
    return Intl.message(
      'لا توجد إشعارات',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `ستظهر جميع الإشعارات هنا...\nفي حال حدوث شيء جديد.`
  String get noNotificationsDescription {
    return Intl.message(
      'ستظهر جميع الإشعارات هنا...\nفي حال حدوث شيء جديد.',
      name: 'noNotificationsDescription',
      desc: '',
      args: [],
    );
  }

  /// `الدردشة 1`
  String get chat_1 {
    return Intl.message('الدردشة 1', name: 'chat_1', desc: '', args: []);
  }

  /// `الدردشة 2`
  String get chat_2 {
    return Intl.message('الدردشة 2', name: 'chat_2', desc: '', args: []);
  }

  /// `الدردشة 3`
  String get chat_3 {
    return Intl.message('الدردشة 3', name: 'chat_3', desc: '', args: []);
  }

  /// `الصفحة الأولى`
  String get first_page {
    return Intl.message(
      'الصفحة الأولى',
      name: 'first_page',
      desc: '',
      args: [],
    );
  }

  /// `خاص`
  String get private {
    return Intl.message('خاص', name: 'private', desc: '', args: []);
  }

  /// `عام`
  String get public {
    return Intl.message('عام', name: 'public', desc: '', args: []);
  }

  /// `المستخدم أ`
  String get user_a {
    return Intl.message('المستخدم أ', name: 'user_a', desc: '', args: []);
  }

  /// `المستخدم ب`
  String get user_b {
    return Intl.message('المستخدم ب', name: 'user_b', desc: '', args: []);
  }

  /// `المستخدم ج`
  String get user_c {
    return Intl.message('المستخدم ج', name: 'user_c', desc: '', args: []);
  }

  /// `النمط 1`
  String get style_1 {
    return Intl.message('النمط 1', name: 'style_1', desc: '', args: []);
  }

  /// `النمط 2`
  String get style_2 {
    return Intl.message('النمط 2', name: 'style_2', desc: '', args: []);
  }

  /// `النمط 3`
  String get style_3 {
    return Intl.message('النمط 3', name: 'style_3', desc: '', args: []);
  }

  /// `النمط 4`
  String get style_4 {
    return Intl.message('النمط 4', name: 'style_4', desc: '', args: []);
  }

  /// `النمط 5`
  String get style_5 {
    return Intl.message('النمط 5', name: 'style_5', desc: '', args: []);
  }

  /// `النمط 6`
  String get style_6 {
    return Intl.message('النمط 6', name: 'style_6', desc: '', args: []);
  }

  /// `النمط 7`
  String get style_7 {
    return Intl.message('النمط 7', name: 'style_7', desc: '', args: []);
  }

  /// `إنشاء دردشة`
  String get creating_chat {
    return Intl.message(
      'إنشاء دردشة',
      name: 'creating_chat',
      desc: '',
      args: [],
    );
  }

  /// `الخصوصية`
  String get privacy_colon {
    return Intl.message('الخصوصية', name: 'privacy_colon', desc: '', args: []);
  }

  /// `المدير`
  String get manager_colon {
    return Intl.message('المدير', name: 'manager_colon', desc: '', args: []);
  }

  /// `التنسيق`
  String get format_colon {
    return Intl.message('التنسيق', name: 'format_colon', desc: '', args: []);
  }

  /// `الصورة`
  String get image_colon {
    return Intl.message('الصورة', name: 'image_colon', desc: '', args: []);
  }

  /// `تم تحديث الملف الشخصي بنجاح`
  String get profile_updated_successfully {
    return Intl.message(
      'تم تحديث الملف الشخصي بنجاح',
      name: 'profile_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `فشل في حفظ الملف الشخصي`
  String get failed_to_save_profile {
    return Intl.message(
      'فشل في حفظ الملف الشخصي',
      name: 'failed_to_save_profile',
      desc: '',
      args: [],
    );
  }

  /// `لا يمكن أن يكون الاسم فارغًا`
  String get name_cannot_be_empty {
    return Intl.message(
      'لا يمكن أن يكون الاسم فارغًا',
      name: 'name_cannot_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `الرجاء إدخال عمر صالح`
  String get please_enter_valid_age {
    return Intl.message(
      'الرجاء إدخال عمر صالح',
      name: 'please_enter_valid_age',
      desc: '',
      args: [],
    );
  }

  /// `فشل في اختيار الصورة`
  String get failed_to_pick_image {
    return Intl.message(
      'فشل في اختيار الصورة',
      name: 'failed_to_pick_image',
      desc: '',
      args: [],
    );
  }

  /// `خطأ في اختيار الصورة`
  String get error_picking_image {
    return Intl.message(
      'خطأ في اختيار الصورة',
      name: 'error_picking_image',
      desc: '',
      args: [],
    );
  }

  /// `الرجاء ملء جميع الحقول`
  String get please_fill_all_fields {
    return Intl.message(
      'الرجاء ملء جميع الحقول',
      name: 'please_fill_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `فشل في تحميل بيانات المستخدم`
  String get failed_to_load_user_data {
    return Intl.message(
      'فشل في تحميل بيانات المستخدم',
      name: 'failed_to_load_user_data',
      desc: '',
      args: [],
    );
  }

  /// `دردشات أخري`
  String get another_chats {
    return Intl.message(
      'دردشات أخري',
      name: 'another_chats',
      desc: '',
      args: [],
    );
  }

  /// `أحدث الدردشات`
  String get updated_chats {
    return Intl.message(
      'أحدث الدردشات',
      name: 'updated_chats',
      desc: '',
      args: [],
    );
  }

  /// `نجمة`
  String get star {
    return Intl.message('نجمة', name: 'star', desc: '', args: []);
  }

  /// `أدخل التاريخ 00-00-0000`
  String get date {
    return Intl.message(
      'أدخل التاريخ 00-00-0000',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `00:00 أدخل الوقت`
  String get time {
    return Intl.message('00:00 أدخل الوقت', name: 'time', desc: '', args: []);
  }

  /// `00:00 أدخل مدة تثبيت الدردشة`
  String get timeToPIN {
    return Intl.message(
      '00:00 أدخل مدة تثبيت الدردشة',
      name: 'timeToPIN',
      desc: '',
      args: [],
    );
  }

  /// `صنــــع بحــــب مــــن أثــــر الـــــى العالـــــم`
  String get splashText {
    return Intl.message(
      'صنــــع بحــــب مــــن أثــــر الـــــى العالـــــم',
      name: 'splashText',
      desc: '',
      args: [],
    );
  }

  /// `البريد المدخل خطأ`
  String get emailError {
    return Intl.message(
      'البريد المدخل خطأ',
      name: 'emailError',
      desc: '',
      args: [],
    );
  }

  /// `الكود المدخل خطأ`
  String get otpError {
    return Intl.message(
      'الكود المدخل خطأ',
      name: 'otpError',
      desc: '',
      args: [],
    );
  }

  /// `تم ارسال الكود بنجاح`
  String get successResend {
    return Intl.message(
      'تم ارسال الكود بنجاح',
      name: 'successResend',
      desc: '',
      args: [],
    );
  }

  /// `الرجاء ادخال اسم مستخدم اخر`
  String get userNameError {
    return Intl.message(
      'الرجاء ادخال اسم مستخدم اخر',
      name: 'userNameError',
      desc: '',
      args: [],
    );
  }

  /// `اعادة الارسال`
  String get resend {
    return Intl.message('اعادة الارسال', name: 'resend', desc: '', args: []);
  }

  /// `طلب امكانية التحدث`
  String get selectCan {
    return Intl.message(
      'طلب امكانية التحدث',
      name: 'selectCan',
      desc: '',
      args: [],
    );
  }

  /// `لا يوجد محادثات بعد`
  String get noChat {
    return Intl.message(
      'لا يوجد محادثات بعد',
      name: 'noChat',
      desc: '',
      args: [],
    );
  }

  /// `تفاعل مع الرسالة`
  String get react {
    return Intl.message('تفاعل مع الرسالة', name: 'react', desc: '', args: []);
  }

  /// `التفاعلات`
  String get reactions {
    return Intl.message('التفاعلات', name: 'reactions', desc: '', args: []);
  }

  /// `الرجاء التحقق من اتصالك بالانترنت`
  String get noInternet {
    return Intl.message(
      'الرجاء التحقق من اتصالك بالانترنت',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `إعادة المحاولة`
  String get retry {
    return Intl.message('إعادة المحاولة', name: 'retry', desc: '', args: []);
  }

  /// `صديق`
  String get friend {
    return Intl.message('صديق', name: 'friend', desc: '', args: []);
  }

  /// `تم ارسال طلب الصداقة`
  String get requestWaiting {
    return Intl.message(
      'تم ارسال طلب الصداقة',
      name: 'requestWaiting',
      desc: '',
      args: [],
    );
  }

  /// `أرسل طلب لتكوين صداقة`
  String get notFriend {
    return Intl.message(
      'أرسل طلب لتكوين صداقة',
      name: 'notFriend',
      desc: '',
      args: [],
    );
  }

  /// `طلبات الصداقة`
  String get requests {
    return Intl.message('طلبات الصداقة', name: 'requests', desc: '', args: []);
  }

  /// `أرسل اليك طلب صداقة`
  String get sendToYouRequest {
    return Intl.message(
      'أرسل اليك طلب صداقة',
      name: 'sendToYouRequest',
      desc: '',
      args: [],
    );
  }

  /// `لا يوجد طلبات صداقة`
  String get notFriendRequest {
    return Intl.message(
      'لا يوجد طلبات صداقة',
      name: 'notFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `الطلبات`
  String get requestToSend {
    return Intl.message('الطلبات', name: 'requestToSend', desc: '', args: []);
  }

  /// `لا يوجد أعضاء`
  String get noMembers {
    return Intl.message('لا يوجد أعضاء', name: 'noMembers', desc: '', args: []);
  }

  /// `عضو`
  String get member {
    return Intl.message('عضو', name: 'member', desc: '', args: []);
  }

  /// `مسؤول`
  String get admin {
    return Intl.message('مسؤول', name: 'admin', desc: '', args: []);
  }

  /// `مالك`
  String get owner {
    return Intl.message('مالك', name: 'owner', desc: '', args: []);
  }

  /// `تحديث الدردشة`
  String get update_chat {
    return Intl.message(
      'تحديث الدردشة',
      name: 'update_chat',
      desc: '',
      args: [],
    );
  }

  /// `اختر المسئولين`
  String get chooseAdmin {
    return Intl.message(
      'اختر المسئولين',
      name: 'chooseAdmin',
      desc: '',
      args: [],
    );
  }

  /// `نقطة`
  String get points {
    return Intl.message('نقطة', name: 'points', desc: '', args: []);
  }

  /// `المدة`
  String get reminingTime {
    return Intl.message('المدة', name: 'reminingTime', desc: '', args: []);
  }

  /// `يوم`
  String get days {
    return Intl.message('يوم', name: 'days', desc: '', args: []);
  }

  /// `يرجى ملء جميع الحقول`
  String get pleaseFillAllFields {
    return Intl.message(
      'يرجى ملء جميع الحقول',
      name: 'pleaseFillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `حدث خطأ ما`
  String get somethingWentWrong {
    return Intl.message(
      'حدث خطأ ما',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `جاري الإرسال...`
  String get sending {
    return Intl.message('جاري الإرسال...', name: 'sending', desc: '', args: []);
  }

  /// `جارى التحميل`
  String get loadingPayment {
    return Intl.message(
      'جارى التحميل',
      name: 'loadingPayment',
      desc: '',
      args: [],
    );
  }

  /// `فشل التحميل`
  String get paymentLoadingError {
    return Intl.message(
      'فشل التحميل',
      name: 'paymentLoadingError',
      desc: '',
      args: [],
    );
  }

  /// `فشلت عملية الدفع`
  String get paymentFailed {
    return Intl.message(
      'فشلت عملية الدفع',
      name: 'paymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `نجمة`
  String get stars {
    return Intl.message('نجمة', name: 'stars', desc: '', args: []);
  }

  /// `اسم المستخدم او البريد مستخدم من قبل`
  String get registerError {
    return Intl.message(
      'اسم المستخدم او البريد مستخدم من قبل',
      name: 'registerError',
      desc: '',
      args: [],
    );
  }

  /// `الرجاء الاننتظار حتي يتم السماح لك بارسال الرسائل`
  String get waitForAccept {
    return Intl.message(
      'الرجاء الاننتظار حتي يتم السماح لك بارسال الرسائل',
      name: 'waitForAccept',
      desc: '',
      args: [],
    );
  }

  /// `موافق`
  String get accept {
    return Intl.message('موافق', name: 'accept', desc: '', args: []);
  }

  /// `حظر`
  String get block {
    return Intl.message('حظر', name: 'block', desc: '', args: []);
  }

  /// `لقد حظرت بواسطة هذا المستخدم`
  String get msgBlockUser {
    return Intl.message(
      'لقد حظرت بواسطة هذا المستخدم',
      name: 'msgBlockUser',
      desc: '',
      args: [],
    );
  }

  /// `لقد حظرت هذا المستخدم`
  String get msgIBlock {
    return Intl.message(
      'لقد حظرت هذا المستخدم',
      name: 'msgIBlock',
      desc: '',
      args: [],
    );
  }

  /// `رفع الحظر`
  String get unBlock {
    return Intl.message('رفع الحظر', name: 'unBlock', desc: '', args: []);
  }

  /// `هل أنت متأكد أنك تريد حذف حسابك ؟`
  String get deletAccMsg {
    return Intl.message(
      'هل أنت متأكد أنك تريد حذف حسابك ؟',
      name: 'deletAccMsg',
      desc: '',
      args: [],
    );
  }

  /// `حذف الحساب`
  String get deleteAccount {
    return Intl.message(
      'حذف الحساب',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `هذا المستخدم يرغب بارسال رسالة اليك`
  String get wantToSendMsg {
    return Intl.message(
      'هذا المستخدم يرغب بارسال رسالة اليك',
      name: 'wantToSendMsg',
      desc: '',
      args: [],
    );
  }

  /// `أنت`
  String get you {
    return Intl.message('أنت', name: 'you', desc: '', args: []);
  }

  /// `هل أنت متأكد أنك تريد حظر هذا المستخدم ؟`
  String get sureToBlock {
    return Intl.message(
      'هل أنت متأكد أنك تريد حظر هذا المستخدم ؟',
      name: 'sureToBlock',
      desc: '',
      args: [],
    );
  }

  /// `النجوم غير كافية`
  String get insufficientStars {
    return Intl.message(
      'النجوم غير كافية',
      name: 'insufficientStars',
      desc: '',
      args: [],
    );
  }

  /// `يرجى شراء المزيد من النجوم لإكمال عملية الشراء.`
  String get pleasePurchaseMoreStars {
    return Intl.message(
      'يرجى شراء المزيد من النجوم لإكمال عملية الشراء.',
      name: 'pleasePurchaseMoreStars',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد الشراء`
  String get confirmPurchase {
    return Intl.message(
      'تأكيد الشراء',
      name: 'confirmPurchase',
      desc: '',
      args: [],
    );
  }

  /// `فشل الشراء. يرجى المحاولة مرة أخرى.`
  String get purchaseFailed {
    return Intl.message(
      'فشل الشراء. يرجى المحاولة مرة أخرى.',
      name: 'purchaseFailed',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد قوة متاحة`
  String get noPowersAvailable {
    return Intl.message(
      'لا توجد قوة متاحة',
      name: 'noPowersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `خطأ انتهاء الوقت`
  String get timeoutError {
    return Intl.message(
      'خطأ انتهاء الوقت',
      name: 'timeoutError',
      desc: '',
      args: [],
    );
  }

  /// `خطأ غير مصرح به`
  String get unauthorizedError {
    return Intl.message(
      'خطأ غير مصرح به',
      name: 'unauthorizedError',
      desc: '',
      args: [],
    );
  }

  /// `خطأ غير قابل للمعالجة`
  String get unprocessableError {
    return Intl.message(
      'خطأ غير قابل للمعالجة',
      name: 'unprocessableError',
      desc: '',
      args: [],
    );
  }

  /// `خطأ الخادم`
  String get serverError {
    return Intl.message('خطأ الخادم', name: 'serverError', desc: '', args: []);
  }

  /// `الحالة`
  String get status {
    return Intl.message('الحالة', name: 'status', desc: '', args: []);
  }

  /// `غير نشط`
  String get Inactive {
    return Intl.message('غير نشط', name: 'Inactive', desc: '', args: []);
  }

  /// `نشط`
  String get Active {
    return Intl.message('نشط', name: 'Active', desc: '', args: []);
  }

  /// `اسحب للالغاء`
  String get slideToCancel {
    return Intl.message(
      'اسحب للالغاء',
      name: 'slideToCancel',
      desc: '',
      args: [],
    );
  }

  /// `رسالة صوتية`
  String get voiceMessage {
    return Intl.message(
      'رسالة صوتية',
      name: 'voiceMessage',
      desc: '',
      args: [],
    );
  }

  /// `صورة`
  String get image {
    return Intl.message('صورة', name: 'image', desc: '', args: []);
  }

  /// `مكالمة صوتية`
  String get audiocall {
    return Intl.message('مكالمة صوتية', name: 'audiocall', desc: '', args: []);
  }

  /// `مكالمة فيديو`
  String get videocall {
    return Intl.message('مكالمة فيديو', name: 'videocall', desc: '', args: []);
  }

  /// `الرجاء تسجيل الدخول`
  String get errorLogin {
    return Intl.message(
      'الرجاء تسجيل الدخول',
      name: 'errorLogin',
      desc: '',
      args: [],
    );
  }

  /// `هذه المكالمة تم اغلاقها ..`
  String get closeCall {
    return Intl.message(
      'هذه المكالمة تم اغلاقها ..',
      name: 'closeCall',
      desc: '',
      args: [],
    );
  }

  /// `التشغيل الحالي`
  String get currentlyPlaying {
    return Intl.message(
      'التشغيل الحالي',
      name: 'currentlyPlaying',
      desc: '',
      args: [],
    );
  }

  /// `محطات الراديو`
  String get radioStations {
    return Intl.message(
      'محطات الراديو',
      name: 'radioStations',
      desc: '',
      args: [],
    );
  }

  /// `فشل في تحميل محطات الراديو`
  String get failedToLoadRadioStations {
    return Intl.message(
      'فشل في تحميل محطات الراديو',
      name: 'failedToLoadRadioStations',
      desc: '',
      args: [],
    );
  }

  /// `راديو`
  String get radio {
    return Intl.message('راديو', name: 'radio', desc: '', args: []);
  }

  /// `موسيقى الخلفية`
  String get backgroundMusic {
    return Intl.message(
      'موسيقى الخلفية',
      name: 'backgroundMusic',
      desc: '',
      args: [],
    );
  }

  /// `جاري التشغيل`
  String get playing {
    return Intl.message('جاري التشغيل', name: 'playing', desc: '', args: []);
  }

  /// `مكالمة صوتية`
  String get audioCall {
    return Intl.message('مكالمة صوتية', name: 'audioCall', desc: '', args: []);
  }

  /// `المشتركين`
  String get participants {
    return Intl.message('المشتركين', name: 'participants', desc: '', args: []);
  }

  /// `خطأ في الاتصال`
  String get connectionError {
    return Intl.message(
      'خطأ في الاتصال',
      name: 'connectionError',
      desc: '',
      args: [],
    );
  }

  /// `مكتوم`
  String get muted {
    return Intl.message('مكتوم', name: 'muted', desc: '', args: []);
  }

  /// `جاري الاتصال...`
  String get connecting {
    return Intl.message(
      'جاري الاتصال...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء الكتم`
  String get unmute {
    return Intl.message('إلغاء الكتم', name: 'unmute', desc: '', args: []);
  }

  /// `كتم الصوت`
  String get mute {
    return Intl.message('كتم الصوت', name: 'mute', desc: '', args: []);
  }

  /// `استخدام السماعة`
  String get useEarpiece {
    return Intl.message(
      'استخدام السماعة',
      name: 'useEarpiece',
      desc: '',
      args: [],
    );
  }

  /// `استخدام السماعة الخارجية`
  String get useSpeaker {
    return Intl.message(
      'استخدام السماعة الخارجية',
      name: 'useSpeaker',
      desc: '',
      args: [],
    );
  }

  /// `إنهاء المكالمة`
  String get endCall {
    return Intl.message('إنهاء المكالمة', name: 'endCall', desc: '', args: []);
  }

  /// `إضافة مشارك`
  String get addParticipant {
    return Intl.message(
      'إضافة مشارك',
      name: 'addParticipant',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق الموسيقى`
  String get musicPlayerClose {
    return Intl.message(
      'إغلاق الموسيقى',
      name: 'musicPlayerClose',
      desc: '',
      args: [],
    );
  }

  /// `جاري الانضمام ...`
  String get joining {
    return Intl.message(
      'جاري الانضمام ...',
      name: 'joining',
      desc: '',
      args: [],
    );
  }

  /// `تنبيه`
  String get alert {
    return Intl.message('تنبيه', name: 'alert', desc: '', args: []);
  }

  /// `الرجاء تسجيل الدخول للوصول`
  String get pleaseLoginToAccess {
    return Intl.message(
      'الرجاء تسجيل الدخول للوصول',
      name: 'pleaseLoginToAccess',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الدخول`
  String get login {
    return Intl.message('تسجيل الدخول', name: 'login', desc: '', args: []);
  }

  /// `خطأ في التشغيل`
  String get playbackError {
    return Intl.message(
      'خطأ في التشغيل',
      name: 'playbackError',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get imageViewerTitle {
    return Intl.message('', name: 'imageViewerTitle', desc: '', args: []);
  }

  /// `+{count}`
  String reactionCount(Object count) {
    return Intl.message(
      '+$count',
      name: 'reactionCount',
      desc: '',
      args: [count],
    );
  }

  /// `{minutes}:{seconds}`
  String audioTimerFormat(Object minutes, Object seconds) {
    return Intl.message(
      '$minutes:$seconds',
      name: 'audioTimerFormat',
      desc: '',
      args: [minutes, seconds],
    );
  }

  /// `الأعضاء المحظورون >>>> {id}`
  String debugMemberBlock(Object id) {
    return Intl.message(
      'الأعضاء المحظورون >>>> $id',
      name: 'debugMemberBlock',
      desc: '',
      args: [id],
    );
  }

  /// `إضافة مخصص`
  String get addCustom {
    return Intl.message('إضافة مخصص', name: 'addCustom', desc: '', args: []);
  }

  /// `تحديث المحادثة`
  String get updateChat {
    return Intl.message(
      'تحديث المحادثة',
      name: 'updateChat',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد أعضاء`
  String get noMembersFound {
    return Intl.message(
      'لا توجد أعضاء',
      name: 'noMembersFound',
      desc: '',
      args: [],
    );
  }

  /// `{count} = {members}`
  String membersCount(Object count, Object members) {
    return Intl.message(
      '$count = $members',
      name: 'membersCount',
      desc: '',
      args: [count, members],
    );
  }

  /// `تم تحميل جميع الأعضاء`
  String get allMembersLoaded {
    return Intl.message(
      'تم تحميل جميع الأعضاء',
      name: 'allMembersLoaded',
      desc: '',
      args: [],
    );
  }

  /// `مالك`
  String get ownerBadge {
    return Intl.message('مالك', name: 'ownerBadge', desc: '', args: []);
  }

  /// `حذف السمة المخصصة`
  String get deleteCustomTheme {
    return Intl.message(
      'حذف السمة المخصصة',
      name: 'deleteCustomTheme',
      desc: '',
      args: [],
    );
  }

  /// `هل أنت متأكد من حذف هذه السمة المخصصة؟`
  String get confirmDeleteCustomTheme {
    return Intl.message(
      'هل أنت متأكد من حذف هذه السمة المخصصة؟',
      name: 'confirmDeleteCustomTheme',
      desc: '',
      args: [],
    );
  }

  /// `مكالمة فيديو جماعية`
  String get groupVideoCall {
    return Intl.message(
      'مكالمة فيديو جماعية',
      name: 'groupVideoCall',
      desc: '',
      args: [],
    );
  }

  /// `فشل الاتصال`
  String get connectionFailed {
    return Intl.message(
      'فشل الاتصال',
      name: 'connectionFailed',
      desc: '',
      args: [],
    );
  }

  /// `{status}`
  String permissionStatus(Object status) {
    return Intl.message(
      '$status',
      name: 'permissionStatus',
      desc: '',
      args: [status],
    );
  }

  /// `مستخدم {uid}`
  String user(Object uid) {
    return Intl.message('مستخدم $uid', name: 'user', desc: '', args: [uid]);
  }

  /// `بدء الفيديو`
  String get startVideo {
    return Intl.message('بدء الفيديو', name: 'startVideo', desc: '', args: []);
  }

  /// `إيقاف الفيديو`
  String get stopVideo {
    return Intl.message('إيقاف الفيديو', name: 'stopVideo', desc: '', args: []);
  }

  /// `تبديل الكاميرا`
  String get switchCamera {
    return Intl.message(
      'تبديل الكاميرا',
      name: 'switchCamera',
      desc: '',
      args: [],
    );
  }

  /// `الفيديو مغلق`
  String get videoOff {
    return Intl.message('الفيديو مغلق', name: 'videoOff', desc: '', args: []);
  }

  /// `الكاميرا مغلقة`
  String get cameraOff {
    return Intl.message(
      'الكاميرا مغلقة',
      name: 'cameraOff',
      desc: '',
      args: [],
    );
  }

  /// `في انتظار انضمام الآخرين...`
  String get waitingForOthers {
    return Intl.message(
      'في انتظار انضمام الآخرين...',
      name: 'waitingForOthers',
      desc: '',
      args: [],
    );
  }

  /// `{status}`
  String connectionStatus(Object status) {
    return Intl.message(
      '$status',
      name: 'connectionStatus',
      desc: '',
      args: [status],
    );
  }

  /// `جيد`
  String get networkGood {
    return Intl.message('جيد', name: 'networkGood', desc: '', args: []);
  }

  /// `الأوقات المتاحة`
  String get availableTimes {
    return Intl.message(
      'الأوقات المتاحة',
      name: 'availableTimes',
      desc: '',
      args: [],
    );
  }

  /// `الأوقات المختارة: {count}`
  String selectedTimes(Object count) {
    return Intl.message(
      'الأوقات المختارة: $count',
      name: 'selectedTimes',
      desc: '',
      args: [count],
    );
  }

  /// `تحميل المزيد من المحادثات...`
  String get loadMoreChats {
    return Intl.message(
      'تحميل المزيد من المحادثات...',
      name: 'loadMoreChats',
      desc: '',
      args: [],
    );
  }

  /// `خطأ`
  String get genericError {
    return Intl.message('خطأ', name: 'genericError', desc: '', args: []);
  }

  /// `طلب صداقة`
  String get friendRequestTitle {
    return Intl.message(
      'طلب صداقة',
      name: 'friendRequestTitle',
      desc: '',
      args: [],
    );
  }

  /// `أرسل إليك `
  String get friendRequestBody {
    return Intl.message(
      'أرسل إليك ',
      name: 'friendRequestBody',
      desc: '',
      args: [],
    );
  }

  /// `تم قبول طلب الصداقة الذي أرسلته إلى `
  String get friendRequestAcceptedBody {
    return Intl.message(
      'تم قبول طلب الصداقة الذي أرسلته إلى ',
      name: 'friendRequestAcceptedBody',
      desc: '',
      args: [],
    );
  }

  /// `انضم إلى المحادثة: `
  String get joinChatBody {
    return Intl.message(
      'انضم إلى المحادثة: ',
      name: 'joinChatBody',
      desc: '',
      args: [],
    );
  }

  /// `مطلوب إذن الميكروفون`
  String get microphonePermissionRequired {
    return Intl.message(
      'مطلوب إذن الميكروفون',
      name: 'microphonePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `هذا التطبيق يحتاج إلى إذن الميكروفون للمكالمات الصوتية. يرجى تفعيله في الإعدادات.`
  String get permissionRequiredMessage {
    return Intl.message(
      'هذا التطبيق يحتاج إلى إذن الميكروفون للمكالمات الصوتية. يرجى تفعيله في الإعدادات.',
      name: 'permissionRequiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `فتح الإعدادات`
  String get openSettings {
    return Intl.message(
      'فتح الإعدادات',
      name: 'openSettings',
      desc: '',
      args: [],
    );
  }

  /// `تم شراؤها`
  String get isBuy {
    return Intl.message('تم شراؤها', name: 'isBuy', desc: '', args: []);
  }

  /// `تجديد`
  String get renewal {
    return Intl.message('تجديد', name: 'renewal', desc: '', args: []);
  }

  /// `انتظر حتي يتم قبول طلب انضمامك للمحادثة`
  String get waitAccept {
    return Intl.message(
      'انتظر حتي يتم قبول طلب انضمامك للمحادثة',
      name: 'waitAccept',
      desc: '',
      args: [],
    );
  }

  /// `يجب أن يتطابق حقل التاريخ مع التنسيق Y-m-d. أو يجب أن يكون حقل التاريخ تاريخًا بعد اليوم أو يساويه`
  String get errorPin {
    return Intl.message(
      'يجب أن يتطابق حقل التاريخ مع التنسيق Y-m-d. أو يجب أن يكون حقل التاريخ تاريخًا بعد اليوم أو يساويه',
      name: 'errorPin',
      desc: '',
      args: [],
    );
  }

  /// `بحث`
  String get search {
    return Intl.message('بحث', name: 'search', desc: '', args: []);
  }

  /// `مكالمة فيديو`
  String get videoCall {
    return Intl.message('مكالمة فيديو', name: 'videoCall', desc: '', args: []);
  }

  /// `مكالمة صوتية جماعية`
  String get groupAudioCall {
    return Intl.message(
      'مكالمة صوتية جماعية',
      name: 'groupAudioCall',
      desc: '',
      args: [],
    );
  }

  /// `طلبك قيد المراجعة`
  String get succsesPin {
    return Intl.message(
      'طلبك قيد المراجعة',
      name: 'succsesPin',
      desc: '',
      args: [],
    );
  }

  /// `عدد النجوم غير كافى ، سيتم تحويلك لشراء النجوم ثم حاول مره اخرى بعد الشراء`
  String get errorBuyStars {
    return Intl.message(
      'عدد النجوم غير كافى ، سيتم تحويلك لشراء النجوم ثم حاول مره اخرى بعد الشراء',
      name: 'errorBuyStars',
      desc: '',
      args: [],
    );
  }

  /// `لا يوجد اتصال بالإنترنت`
  String get noInternetTitle {
    return Intl.message(
      'لا يوجد اتصال بالإنترنت',
      name: 'noInternetTitle',
      desc: '',
      args: [],
    );
  }

  /// `يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.`
  String get noInternetMessage {
    return Intl.message(
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      name: 'noInternetMessage',
      desc: '',
      args: [],
    );
  }

  /// `أنت`
  String get You {
    return Intl.message('أنت', name: 'You', desc: '', args: []);
  }

  /// `مستخدم`
  String get User {
    return Intl.message('مستخدم', name: 'User', desc: '', args: []);
  }

  // skipped getter for the 'Checking permissions...' key

  // skipped getter for the 'Initialization error: {{error}}' key

  // skipped getter for the 'Microphone: {{status}}' key

  // skipped getter for the 'After request - Microphone: {{status}}' key

  // skipped getter for the 'Microphone permission denied! Please enable in settings.' key

  // skipped getter for the 'Initializing Agora...' key

  // skipped getter for the 'Agora initialization error: {{error}}' key

  // skipped getter for the 'Joining audio channel...' key

  // skipped getter for the 'Connected! Local UID: {{uid}}' key

  // skipped getter for the 'Token expired! Generate a new token from Agora Console' key

  // skipped getter for the 'Agora Error: {{code}} - {{msg}}' key

  // skipped getter for the 'Token expiring soon - please renew!' key

  // skipped getter for the 'Add Participant' key

  // skipped getter for the 'Invite link copied to clipboard' key

  // skipped getter for the 'Remove Participant' key

  // skipped getter for the 'This feature requires server-side implementation' key

  // skipped getter for the 'Mode Switch' key

  // skipped getter for the 'Please end the current call to switch modes' key

  // skipped getter for the 'Call ended' key

  // skipped getter for the 'Waiting for others to join...' key

  /// `مشاركين في المكالمة`
  String get participantsincall {
    return Intl.message(
      'مشاركين في المكالمة',
      name: 'participantsincall',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'In call with {{name}}' key

  // skipped getter for the 'Waiting for {{name}} to join...' key

  // skipped getter for the 'Connecting...' key

  // skipped getter for the 'Retrying connection...' key

  /// `دردشه مايو لايف \nعيشها لايف`
  String get mayolivechat {
    return Intl.message(
      'دردشه مايو لايف \nعيشها لايف',
      name: 'mayolivechat',
      desc: '',
      args: [],
    );
  }

  /// `اختيار باقات النجوم`
  String get selectStarsPackages {
    return Intl.message(
      'اختيار باقات النجوم',
      name: 'selectStarsPackages',
      desc: '',
      args: [],
    );
  }

  /// `الإجمالي: {stars} نجمة`
  String totalStars(Object stars) {
    return Intl.message(
      'الإجمالي: $stars نجمة',
      name: 'totalStars',
      desc: '',
      args: [stars],
    );
  }

  /// `اختر طريقة الدفع`
  String get selectPaymentMethod {
    return Intl.message(
      'اختر طريقة الدفع',
      name: 'selectPaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `رفع إيصال الدفع`
  String get uploadPaymentReceipt {
    return Intl.message(
      'رفع إيصال الدفع',
      name: 'uploadPaymentReceipt',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل الدفع:`
  String get paymentDetails {
    return Intl.message(
      'تفاصيل الدفع:',
      name: 'paymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `النجوم: {count}`
  String starsCount(Object count) {
    return Intl.message(
      'النجوم: $count',
      name: 'starsCount',
      desc: '',
      args: [count],
    );
  }

  /// `السعر: {amount} جنيه`
  String priceAmount(Object amount) {
    return Intl.message(
      'السعر: $amount جنيه',
      name: 'priceAmount',
      desc: '',
      args: [amount],
    );
  }

  /// `الطريقة:`
  String get paymentMethod {
    return Intl.message('الطريقة:', name: 'paymentMethod', desc: '', args: []);
  }

  /// `انقر لرفع الإيصال`
  String get tapToUploadReceipt {
    return Intl.message(
      'انقر لرفع الإيصال',
      name: 'tapToUploadReceipt',
      desc: '',
      args: [],
    );
  }

  /// `إنهاء`
  String get finish {
    return Intl.message('إنهاء', name: 'finish', desc: '', args: []);
  }

  /// `طلبك قيد المراجعة`
  String get orderUnderReview {
    return Intl.message(
      'طلبك قيد المراجعة',
      name: 'orderUnderReview',
      desc: '',
      args: [],
    );
  }



  /// `موافق`
  String get ok {
    return Intl.message('موافق', name: 'ok', desc: '', args: []);
  }



}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
