// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Core/Constant/app_api.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:flutter_html/flutter_html.dart';

class TermCondation extends StatefulWidget {
  const TermCondation({super.key});

  @override
  State<TermCondation> createState() => _TermCondationState();
}

class _TermCondationState extends State<TermCondation> {
  String? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchTermsAndConditions();
  }

  Future<void> fetchTermsAndConditions() async {
    final url =
        Uri.parse(AppApi.terms);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _content = data['data']['content'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data. Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final textColor = pref! ? AppColors.whiteColor : AppColors.blackTextColor;
    final subTextColor =
        pref! ? Colors.grey.shade400 : Colors.grey.shade800.withOpacity(0.9);

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        isRtl
                            ? IconsaxPlusLinear.arrow_right_3
                            : IconsaxPlusLinear.arrow_left_1,
                        size: 5.5.w,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    textNormal(
                      S.of(context).termsAndConditions,
                      textColor,
                      4.5.w,
                      FontWeight.w600,
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: TextStyle(color: textColor),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Html(
                                data: _content ?? '',
                                style: {
                                  "body": Style(
                                    color: subTextColor,
                                    fontSize: FontSize(3.8.w),
                                    lineHeight: const LineHeight(1.5),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  "p": Style(
                                    margin: Margins.only(bottom: 6),
                                  ),
                                  "h1": Style(
                                    color: textColor,
                                    fontSize: FontSize(5.w),
                                    fontWeight: FontWeight.w700,
                                    margin: Margins.only(bottom: 10, top: 10),
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.3,
                                      ),
                                    ),
                                  ),
                                  "h2": Style(
                                    color: textColor,
                                    fontSize: FontSize(4.5.w),
                                    fontWeight: FontWeight.w600,
                                    margin: Margins.only(bottom: 6, top: 10),
                                  ),
                                  "h3": Style(
                                    color: textColor,
                                    fontSize: FontSize(4.2.w),
                                    fontWeight: FontWeight.w500,
                                    margin: Margins.only(bottom: 4, top: 8),
                                  ),
                                  "ul": Style(
                                    margin: Margins.only(bottom: 4, top: 4),
                                    padding: HtmlPaddings.only(left: 14),
                                  ),
                                  "li": Style(
                                    color: subTextColor,
                                    fontSize: FontSize(3.8.w),
                                    margin: Margins.only(bottom: 4),
                                  ),
                                  "hr": Style(
                                    margin: Margins.only(top: 8, bottom: 8),
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.2,
                                      ),
                                    ),
                                  ),
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
