// ignore_for_file: deprecated_member_use, must_be_immutable
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Data/Model/power_model.dart';

class PowerTextWidget extends StatefulWidget {
  final PowerModel powerModel;
  double? height;
  final String? displyText;
  PowerTextWidget({
    super.key,
    required this.powerModel,
    this.height,
    this.displyText,
  });
  @override
  State<PowerTextWidget> createState() => _PowerTextWidgetState();
}

class _PowerTextWidgetState extends State<PowerTextWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _gradientController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotationAnimation;

  // Bio animations - using same structure as main animations
  late AnimationController _bioAnimationController;
  late AnimationController _bioGradientController;
  Animation<double>? _bioFadeAnimation;
  Animation<Offset>? _bioSlideAnimation;
  Animation<double>? _bioScaleAnimation;
  Animation<double>? _bioRotationAnimation;

  // Typing animation for remove_word
  AnimationController? _typingController;
  // ignore: unused_field
  late Animation<double> _typingAnimation;
  late String _currentText;
  late bool _isDeleting;
  Timer? _typingTimer;

  // Bio typing animation
  AnimationController? _bioTypingController;
  late String _bioCurrentText;
  // ignore: unused_field
  late bool _bioIsDeleting;
  Timer? _bioTypingTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Main power text animation controller
    _animationController = AnimationController(
      duration: Duration(
        milliseconds:
            _parseDuration(widget.powerModel.effects?.power?.duration) ?? 1000,
      ),
      vsync: this,
    );

    // Bio text animation controller
    _bioAnimationController = AnimationController(
      duration: Duration(
        milliseconds:
            _parseDuration(widget.powerModel.effects?.bio?.duration) ?? 1000,
      ),
      vsync: this,
    );

    // Gradient animation controllers
    _gradientController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bioGradientController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Setup different animation types based on data
    _setupPowerAnimationsByType();
    _setupBioAnimationsByType();

    // Start power animations based on type
    String? powerType = widget.powerModel.effects?.power?.type?.toLowerCase();
    if (powerType != null && powerType != 'none') {
      if (powerType == 'remove_word') {
        _startTypingAnimation();
      } else {
        if (_shouldRepeat(widget.powerModel.effects?.power?.repeat)) {
          if (powerType == 'shake' ||
              powerType == 'pulse' ||
              powerType == 'wave' ||
              powerType == 'swing') {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.repeat();
          }
        } else {
          _animationController.forward();
        }
      }
    }

    // Start bio animations based on type - EXACTLY SAME LOGIC AS POWER
    String? bioType = widget.powerModel.effects?.bio?.type?.toLowerCase();
    if (bioType != null && bioType != 'none') {
      if (bioType == 'remove_word') {
        _startBioTypingAnimation();
      } else {
        if (_shouldRepeat(widget.powerModel.effects?.bio?.repeat)) {
          if (bioType == 'shake' ||
              bioType == 'pulse' ||
              bioType == 'wave' ||
              bioType == 'swing') {
            _bioAnimationController.repeat(reverse: true);
          } else {
            _bioAnimationController.repeat();
          }
        } else {
          _bioAnimationController.forward();
        }
      }
    }

    // Start gradient animations if enabled
    if (widget.powerModel.effects?.power?.gradientMovementStatus == true) {
      _gradientController.repeat();
    }
    if (widget.powerModel.effects?.bio?.gradientMovementStatus == true) {
      _bioGradientController.repeat();
    }
  }

  void _startTypingAnimation() {
    String fullText = widget.displyText ?? "";
    int totalChars = fullText.length;
    if (totalChars == 0) return;

    _currentText = "";
    _isDeleting = false;

    _typingController?.dispose();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _typingLoop(fullText);
  }

  void _startBioTypingAnimation() {
    String fullText = widget.powerModel.effects?.bio?.text ?? "";
    if (fullText.isEmpty) return;

    _bioCurrentText = "";
    _bioIsDeleting = false;

    _bioTypingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _bioTypingLoop(fullText);
  }

  void _typingLoop(String fullText) {
    const typingSpeed = Duration(milliseconds: 150);
    const deletingSpeed = Duration(milliseconds: 100);
    const pauseDuration = Duration(milliseconds: 1000);

    late VoidCallback typeNext;
    late VoidCallback deleteNext;

    deleteNext = () {
      if (_currentText.isNotEmpty) {
        setState(() {
          _currentText = _currentText.substring(0, _currentText.length - 1);
        });
        _typingTimer = Timer(deletingSpeed, deleteNext);
      } else {
        _typingTimer = Timer(pauseDuration, typeNext);
      }
    };

    typeNext = () {
      if (_currentText.length < fullText.length) {
        setState(() {
          _currentText = fullText.substring(0, _currentText.length + 1);
        });
        _typingTimer = Timer(typingSpeed, typeNext);
      } else {
        _typingTimer = Timer(pauseDuration, deleteNext);
      }
    };

    typeNext();
  }

  void _bioTypingLoop(String fullText) {
    const typingSpeed = Duration(milliseconds: 150);
    const deletingSpeed = Duration(milliseconds: 100);
    const pauseDuration = Duration(milliseconds: 1000);

    late VoidCallback typeNext;
    late VoidCallback deleteNext;

    deleteNext = () {
      if (_bioCurrentText.isNotEmpty) {
        setState(() {
          _bioCurrentText =
              _bioCurrentText.substring(0, _bioCurrentText.length - 1);
        });
        _bioTypingTimer = Timer(deletingSpeed, deleteNext);
      } else {
        _bioTypingTimer = Timer(pauseDuration, typeNext);
      }
    };

    typeNext = () {
      if (_bioCurrentText.length < fullText.length) {
        setState(() {
          _bioCurrentText = fullText.substring(0, _bioCurrentText.length + 1);
        });
        _bioTypingTimer = Timer(typingSpeed, typeNext);
      } else {
        _bioTypingTimer = Timer(pauseDuration, deleteNext);
      }
    };

    typeNext();
  }

  void _setupPowerAnimationsByType() {
    String? type = widget.powerModel.effects?.power?.type?.toLowerCase();
    String? direction = widget.powerModel.effects?.power?.direction;

    switch (type) {
      case 'shake':
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-0.1, 0.0),
          end: const Offset(0.1, 0.0),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticIn,
        ));
        break;
      case 'bounce':
        _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.bounceInOut),
        );
        break;
      case 'fade':
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case 'pulse':
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case 'rotate':
        _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );
        break;
      case 'scale':
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.elasticOut),
        );
        break;
      case 'slide':
        Offset beginOffset = _getSlideOffset(direction);
        _slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case 'flip':
        _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case 'zoom':
        _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeOutBack),
        );
        break;
      case 'swing':
        _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case 'wave':
        // Wave animation is handled by custom painter
        break;
      case 'move_vertical':
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, -1.0),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.linear,
        ));
        break;
      case 'move_horizontal':
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(1.0, 0.0),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.linear,
        ));
        break;
      case 'remove_word':
        // Handled separately via _startTypingAnimation()
        break;
      case 'none':
        break;
      default:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
    }
  }

  void _setupBioAnimationsByType() {
    String? type = widget.powerModel.effects?.bio?.type?.toLowerCase();
    String? direction = widget.powerModel.effects?.bio?.direction;

    // EXACT SAME LOGIC AS _setupPowerAnimationsByType
    switch (type) {
      case 'shake':
        _bioSlideAnimation = Tween<Offset>(
          begin: const Offset(-0.1, 0.0),
          end: const Offset(0.1, 0.0),
        ).animate(CurvedAnimation(
          parent: _bioAnimationController,
          curve: Curves.elasticIn,
        ));
        break;
      case 'bounce':
        _bioScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.bounceInOut),
        );
        break;
      case 'fade':
        _bioFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
        break;
      case 'pulse':
        _bioScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
        break;
      case 'rotate':
        _bioRotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.linear),
        );
        break;
      case 'scale':
        _bioScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.elasticOut),
        );
        break;
      case 'slide':
        Offset beginOffset = _getSlideOffset(direction);
        _bioSlideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
        break;
      case 'flip':
        _bioRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
        break;
      case 'zoom':
        _bioScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeOutBack),
        );
        break;
      case 'swing':
        _bioRotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
        break;
      case 'wave':
        // Wave animation is handled by custom painter
        break;
      case 'move_vertical':
        _bioSlideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, -1.0),
        ).animate(CurvedAnimation(
          parent: _bioAnimationController,
          curve: Curves.linear,
        ));
        break;
      case 'move_horizontal':
        _bioSlideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(1.0, 0.0),
        ).animate(CurvedAnimation(
          parent: _bioAnimationController,
          curve: Curves.linear,
        ));
        break;
      case 'remove_word':
        // Handled separately via _startBioTypingAnimation()
        break;
      case 'none':
        break;
      default:
        _bioFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _bioAnimationController, curve: Curves.easeInOut),
        );
    }
  }

  Offset _getSlideOffset(String? direction) {
    switch (direction?.toLowerCase()) {
      case 'left':
      case 'x':
        return const Offset(-1.0, 0.0);
      case 'right':
        return const Offset(1.0, 0.0);
      case 'up':
      case 'y':
        return const Offset(0.0, -1.0);
      case 'down':
        return const Offset(0.0, 1.0);
      default:
        return const Offset(0.0, -1.0);
    }
  }

  bool _shouldRepeat(String? repeat) {
    return repeat?.toLowerCase() == 'true' ||
        repeat == '1' ||
        repeat?.toLowerCase() == 'infinite';
  }

  int? _parseDuration(String? duration) {
    if (duration == null) return null;
    String cleanDuration =
        duration.toLowerCase().replaceAll('s', '').replaceAll('m', '');
    double? value = double.tryParse(cleanDuration);
    if (value != null) {
      if (duration.toLowerCase().contains('s')) {
        return (value * 1000).round();
      }
      return value.round();
    }
    return null;
  }

  double _parseOpacity(String? opacity) {
    if (opacity == null) return 1.0;
    double? value = double.tryParse(opacity);
    return (value ?? 1.0).clamp(0.0, 1.0);
  }

  double _parseFontSize(String? fontSize) {
    if (fontSize == null) return 16.0;
    String cleanSize =
        fontSize.toLowerCase().replaceAll('px', '').replaceAll('pt', '');
    return double.tryParse(cleanSize) ?? 16.0;
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.black;
    colorString = colorString.replaceAll('#', '');
    try {
      if (colorString.length == 6) {
        return Color(int.parse('FF$colorString', radix: 16));
      } else if (colorString.length == 8) {
        return Color(int.parse(colorString, radix: 16));
      }
    } catch (e) {
      return Colors.black;
    }
    return Colors.black;
  }

  List<Color> _getGradientColors(List<GradientColors>? gradientColors) {
    if (gradientColors == null || gradientColors.isEmpty) {
      return [Colors.blue, Colors.purple];
    }
    return gradientColors.map((gc) => _parseColor(gc.color)).toList();
  }

  Gradient? _buildGradient(
      List<GradientColors>? gradientColors, String? direction) {
    if (gradientColors == null || gradientColors.isEmpty) {
      return null;
    }
    List<Color> colors = _getGradientColors(gradientColors);
    if (colors.length < 2) {
      if (colors.length == 1) {
        colors = [colors[0], colors[0]];
      } else {
        return null;
      }
    }
    switch (direction?.toLowerCase()) {
      case 'horizontal':
      case 'to right':
        return LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'vertical':
      case 'to bottom':
        return LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'diagonal':
      case 'to bottom right':
        return LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'to left':
        return LinearGradient(
          colors: colors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        );
      case 'to top':
        return LinearGradient(
          colors: colors,
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        );
      case 'to top left':
        return LinearGradient(
          colors: colors,
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        );
      default:
        return LinearGradient(colors: colors);
    }
  }

  TextStyle _buildTextStyle() {
    Power? power = widget.powerModel.effects?.power;
    bool hasGradientColors =
        power?.gradientColors != null && power!.gradientColors!.isNotEmpty;
    Color? textColor = hasGradientColors ? null : _parseColor(power?.color);
    if (textColor == null && !hasGradientColors) {
      textColor = Colors.blue;
    }
    TextStyle baseStyle = TextStyle(
      fontSize: _parseFontSize(power?.fontSize),
      color: textColor,
      fontWeight: _getTextWeight(power?.textStyle),
      shadows: _buildTextShadows(power?.shadow),
    );
    String? fontName = power?.fontName;
    if (fontName != null && fontName.isNotEmpty) {
      try {
        return _getGoogleFont(fontName).copyWith(
          fontSize: baseStyle.fontSize,
          color: baseStyle.color,
          fontWeight: baseStyle.fontWeight,
          shadows: baseStyle.shadows,
        );
      } catch (e) {
        return baseStyle;
      }
    }
    return baseStyle;
  }

  TextStyle _buildBioTextStyle() {
    Bio? bio = widget.powerModel.effects?.bio;
    bool hasGradientColors =
        bio?.gradientColors != null && bio!.gradientColors!.isNotEmpty;
    Color? textColor = hasGradientColors ? null : _parseColor(bio?.color);
    if (textColor == null && !hasGradientColors) {
      return const TextStyle(color: Colors.transparent);
    }
    TextStyle baseStyle = TextStyle(
      fontSize: _parseFontSize(bio?.fontSize),
      color: textColor,
      fontWeight: _getTextWeight(bio?.textStyle),
      shadows: _buildTextShadows(bio?.shadow),
    );
    String? fontName = bio?.fontName;
    if (fontName != null && fontName.isNotEmpty) {
      try {
        return _getGoogleFont(fontName).copyWith(
          fontSize: baseStyle.fontSize,
          color: baseStyle.color,
          fontWeight: baseStyle.fontWeight,
          shadows: baseStyle.shadows,
        );
      } catch (e) {
        return baseStyle;
      }
    }
    return baseStyle;
  }

  TextStyle _getGoogleFont(String fontName) {
    String cleanFontName = _normalizeFontName(fontName);
    switch (cleanFontName.toLowerCase()) {
      case 'roboto':
        return GoogleFonts.roboto();
      case 'opensans':
      case 'open sans':
        return GoogleFonts.openSans();
      case 'lato':
        return GoogleFonts.lato();
      case 'montserrat':
        return GoogleFonts.montserrat();
      case 'sourcesanspro':
      case 'source sans pro':
        return GoogleFonts.sourceSans3();
      case 'raleway':
        return GoogleFonts.raleway();
      case 'poppins':
        return GoogleFonts.poppins();
      case 'nunito':
        return GoogleFonts.nunito();
      case 'ubuntu':
        return GoogleFonts.ubuntu();
      case 'playfairdisplay':
      case 'playfair display':
        return GoogleFonts.playfairDisplay();
      case 'inter':
        return GoogleFonts.inter();
      case 'merriweather':
        return GoogleFonts.merriweather();
      case 'ptserif':
      case 'pt serif':
        return GoogleFonts.ptSerif();
      case 'crimsontext':
      case 'crimson text':
        return GoogleFonts.crimsonText();
      case 'satisfy':
        return GoogleFonts.satisfy();
      case 'montez':
        return GoogleFonts.montez();
      case 'libreoastyle':
      case 'libre baskerville':
        return GoogleFonts.libreBaskerville();
      case 'dancingscript':
      case 'dancing script':
        return GoogleFonts.dancingScript();
      case 'pacifico':
        return GoogleFonts.pacifico();
      case 'lobster':
        return GoogleFonts.lobster();
      case 'greatvibes':
      case 'great vibes':
        return GoogleFonts.greatVibes();
      case 'sacramento':
        return GoogleFonts.sacramento();
      case 'shadowsintolight':
      case 'shadows into light':
        return GoogleFonts.shadowsIntoLight();
      case 'kalam':
        return GoogleFonts.kalam();
      case 'comfortaa':
        return GoogleFonts.comfortaa();
      case 'quicksand':
        return GoogleFonts.quicksand();
      case 'oswald':
        return GoogleFonts.oswald();
      case 'anton':
        return GoogleFonts.anton();
      case 'firasans':
      case 'fira sans':
        return GoogleFonts.firaSans();
      case 'rubik':
        return GoogleFonts.rubik();
      case 'worksans':
      case 'work sans':
        return GoogleFonts.workSans();
      case 'dmsans':
      case 'dm sans':
        return GoogleFonts.dmSans();
      case 'ibmplexsans':
      case 'ibm plex sans':
        return GoogleFonts.ibmPlexSans();
      case 'notosans':
      case 'noto sans':
        return GoogleFonts.notoSans();
      case 'manrope':
        return GoogleFonts.manrope();
      case 'outfit':
        return GoogleFonts.outfit();
      case 'plusjakartasans':
      case 'plus jakarta sans':
        return GoogleFonts.plusJakartaSans();
      case 'spacegrotesk':
      case 'space grotesk':
        return GoogleFonts.spaceGrotesk();
      case 'lexend':
        return GoogleFonts.lexend();
      case 'jost':
        return GoogleFonts.jost();
      case 'bevietnampro':
      case 'be vietnam pro':
        return GoogleFonts.beVietnamPro();
      case 'librebaskerville':
        return GoogleFonts.libreBaskerville();
      case 'lora':
        return GoogleFonts.lora();
      case 'cormorantgaramond':
      case 'cormorant garamond':
        return GoogleFonts.cormorantGaramond();
      case 'ebgaramond':
      case 'eb garamond':
        return GoogleFonts.ebGaramond();
      case 'robotomono':
      case 'roboto mono':
        return GoogleFonts.robotoMono();
      case 'sourcecodepro':
      case 'source code pro':
        return GoogleFonts.sourceCodePro();
      case 'jetbrainsmono':
      case 'jetbrains mono':
        return GoogleFonts.jetBrainsMono();
      case 'firamono':
      case 'fira mono':
        return GoogleFonts.firaMono();
      case 'spacemono':
      case 'space mono':
        return GoogleFonts.spaceMono();
      case 'bungee':
        return GoogleFonts.bungee();
      case 'fredoka':
        return GoogleFonts.fredoka();
      case 'pressstart2p':
      case 'press start 2p':
        return GoogleFonts.pressStart2p();
      case 'orbitron':
        return GoogleFonts.orbitron();
      case 'righteous':
        return GoogleFonts.righteous();
      case 'bangers':
        return GoogleFonts.bangers();
      case 'amiri':
        return GoogleFonts.amiri();
      case 'cairo':
        return GoogleFonts.cairo();
      case 'tajawal':
        return GoogleFonts.tajawal();
      case 'almarai':
        return GoogleFonts.almarai();
      case 'notosansarabic':
      case 'noto sans arabic':
        return GoogleFonts.notoSansArabic();
      default:
        try {
          return GoogleFonts.getFont(cleanFontName);
        } catch (e) {
          return GoogleFonts.roboto();
        }
    }
  }

  String _normalizeFontName(String fontName) {
    return fontName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-_]', multiLine: true), '');
  }

  FontWeight _getTextWeight(String? textStyle) {
    switch (textStyle?.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'light':
        return FontWeight.w300;
      case 'medium':
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  List<Shadow>? _buildTextShadows(String? shadow) {
    if (shadow == null || shadow.isEmpty) return null;
    return [
      Shadow(
        offset: const Offset(2.0, 2.0),
        blurRadius: 4.0,
        color: Colors.black.withOpacity(0.5),
      ),
    ];
  }

  // Helper method to get container height for move animations
  double _getContainerHeight() {
    String? type = widget.powerModel.effects?.power?.type?.toLowerCase();
    if (type == 'move_vertical' || type == 'move_horizontal') {
      return widget.height ?? 50.0;
    }
    return widget.height ?? double.infinity;
  }

  double _getBioContainerHeight() {
    String? type = widget.powerModel.effects?.bio?.type?.toLowerCase();
    if (type == 'move_vertical' || type == 'move_horizontal') {
      return widget.height ?? 30.0;
    }
    return widget.height ?? double.infinity;
  }

  Widget _buildAnimatedText(String text, TextStyle style) {
    String? type = widget.powerModel.effects?.power?.type?.toLowerCase();
    String displayText = type == 'remove_word' ? _currentText : text;

    bool showCursor = type == 'remove_word' && !_isDeleting;
    String textWithCursor = showCursor ? '$displayText|' : displayText;

    if (type == 'wave') {
      return _buildWaveAnimation(text, style);
    }

    Widget textWidget = Text(
      textWithCursor,
      style: style,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    Gradient? gradient = _buildGradient(
      widget.powerModel.effects?.power?.gradientColors,
      widget.powerModel.effects?.power?.gradientDirection,
    );
    if (gradient != null) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: textWidget,
      );
    }

    double baseOpacity =
        _parseOpacity(widget.powerModel.effects?.power?.opacity);

    if (type == 'remove_word') {
      return Opacity(opacity: baseOpacity, child: textWidget);
    }

    if (type == null || type == 'none') {
      return Opacity(opacity: baseOpacity, child: textWidget);
    }

    if (type == 'move_vertical' || type == 'move_horizontal') {
      return Container(
        height: type == 'move_vertical' ? _getContainerHeight() : null,
        width: type == 'move_horizontal' ? double.infinity : null,
        alignment: Alignment.center,
        child: ClipRect(
          child: _slideAnimation != null
              ? AnimatedBuilder(
                  animation: _slideAnimation!,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      _slideAnimation!.value.dx *
                          (type == 'move_horizontal'
                              ? MediaQuery.of(context).size.width
                              : 0),
                      _slideAnimation!.value.dy *
                          (type == 'move_vertical' ? _getContainerHeight() : 0),
                    ),
                    child: Opacity(opacity: baseOpacity, child: textWidget),
                  ),
                )
              : Opacity(opacity: baseOpacity, child: textWidget),
        ),
      );
    }

    switch (type) {
      case 'shake':
        return _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_slideAnimation!.value.dx * 5, 0),
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'bounce':
        return _scaleAnimation != null
            ? AnimatedBuilder(
                animation: _scaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'fade':
        return _fadeAnimation != null
            ? AnimatedBuilder(
                animation: _fadeAnimation!,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation!.value * baseOpacity,
                  child: textWidget,
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'pulse':
        return _scaleAnimation != null
            ? AnimatedBuilder(
                animation: _scaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'rotate':
        return _rotationAnimation != null
            ? AnimatedBuilder(
                animation: _rotationAnimation!,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationAnimation!.value * 3.14159,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'scale':
        return _scaleAnimation != null
            ? AnimatedBuilder(
                animation: _scaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'slide':
        return _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) => SlideTransition(
                  position: _slideAnimation!,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'flip':
        return _rotationAnimation != null
            ? AnimatedBuilder(
                animation: _rotationAnimation!,
                builder: (context, child) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_rotationAnimation!.value * 3.14159),
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'zoom':
        return _scaleAnimation != null
            ? AnimatedBuilder(
                animation: _scaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'swing':
        return _rotationAnimation != null
            ? AnimatedBuilder(
                animation: _rotationAnimation!,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationAnimation!.value * 0.5,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      default:
        return Opacity(opacity: baseOpacity, child: textWidget);
    }
  }

  Widget _buildWaveAnimation(String text, TextStyle style) {
    Gradient? gradient = _buildGradient(
      widget.powerModel.effects?.power?.gradientColors,
      widget.powerModel.effects?.power?.gradientDirection,
    );

    double baseOpacity =
        _parseOpacity(widget.powerModel.effects?.power?.opacity);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: baseOpacity,
          child: CustomPaint(
            painter: _WaveTextPainter(
              text: text,
              style: style,
              animationValue: _animationController.value,
              gradient: gradient,
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: _calculateTextWidth(text, style),
                minHeight: style.fontSize! * 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBioText() {
    Bio? bio = widget.powerModel.effects?.bio;
    if (bio?.text == null || bio!.text!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: _buildAnimatedBioText(bio.text!),
    );
  }

  Widget _buildAnimatedBioText(String text) {
    String? type = widget.powerModel.effects?.bio?.type?.toLowerCase();
    String displayText = type == 'remove_word' ? _bioCurrentText : text;

    if (type == 'wave') {
      return _buildBioWaveAnimation(text);
    }

    Widget textWidget = Text(
      displayText,
      style: _buildBioTextStyle(),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    Gradient? gradient = _buildGradient(
      widget.powerModel.effects?.bio?.gradientColors,
      widget.powerModel.effects?.bio?.gradientDirection,
    );
    if (gradient != null) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: textWidget,
      );
    }

    double baseOpacity = _parseOpacity(widget.powerModel.effects?.bio?.opacity);

    if (type == 'remove_word') {
      return Opacity(opacity: baseOpacity, child: textWidget);
    }

    if (type == null || type == 'none') {
      return Opacity(opacity: baseOpacity, child: textWidget);
    }

    // EXACT SAME CONTAINER LOGIC AS MAIN TEXT
    if (type == 'move_vertical' || type == 'move_horizontal') {
      return Container(
        height: type == 'move_vertical' ? _getBioContainerHeight() : null,
        width: type == 'move_horizontal' ? double.infinity : null,
        alignment: Alignment.center,
        child: ClipRect(
          child: _bioSlideAnimation != null
              ? AnimatedBuilder(
                  animation: _bioSlideAnimation!,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      _bioSlideAnimation!.value.dx *
                          (type == 'move_horizontal'
                              ? MediaQuery.of(context).size.width
                              : 0),
                      _bioSlideAnimation!.value.dy *
                          (type == 'move_vertical'
                              ? _getBioContainerHeight()
                              : 0),
                    ),
                    child: Opacity(opacity: baseOpacity, child: textWidget),
                  ),
                )
              : Opacity(opacity: baseOpacity, child: textWidget),
        ),
      );
    }

    // EXACT SAME ANIMATION SWITCH LOGIC AS MAIN TEXT
    switch (type) {
      case 'shake':
        return _bioSlideAnimation != null
            ? AnimatedBuilder(
                animation: _bioSlideAnimation!,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_bioSlideAnimation!.value.dx * 5, 0),
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'bounce':
        return _bioScaleAnimation != null
            ? AnimatedBuilder(
                animation: _bioScaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _bioScaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'fade':
        return _bioFadeAnimation != null
            ? AnimatedBuilder(
                animation: _bioFadeAnimation!,
                builder: (context, child) => Opacity(
                  opacity: _bioFadeAnimation!.value * baseOpacity,
                  child: textWidget,
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'pulse':
        return _bioScaleAnimation != null
            ? AnimatedBuilder(
                animation: _bioScaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _bioScaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'rotate':
        return _bioRotationAnimation != null
            ? AnimatedBuilder(
                animation: _bioRotationAnimation!,
                builder: (context, child) => Transform.rotate(
                  angle: _bioRotationAnimation!.value * 3.14159,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'scale':
        return _bioScaleAnimation != null
            ? AnimatedBuilder(
                animation: _bioScaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _bioScaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'slide':
        return _bioSlideAnimation != null
            ? AnimatedBuilder(
                animation: _bioSlideAnimation!,
                builder: (context, child) => SlideTransition(
                  position: _bioSlideAnimation!,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'flip':
        return _bioRotationAnimation != null
            ? AnimatedBuilder(
                animation: _bioRotationAnimation!,
                builder: (context, child) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_bioRotationAnimation!.value * 3.14159),
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'zoom':
        return _bioScaleAnimation != null
            ? AnimatedBuilder(
                animation: _bioScaleAnimation!,
                builder: (context, child) => Transform.scale(
                  scale: _bioScaleAnimation!.value,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      case 'swing':
        return _bioRotationAnimation != null
            ? AnimatedBuilder(
                animation: _bioRotationAnimation!,
                builder: (context, child) => Transform.rotate(
                  angle: _bioRotationAnimation!.value * 0.5,
                  child: Opacity(opacity: baseOpacity, child: textWidget),
                ),
              )
            : Opacity(opacity: baseOpacity, child: textWidget);
      default:
        return Opacity(opacity: baseOpacity, child: textWidget);
    }
  }

  Widget _buildBioWaveAnimation(String text) {
    TextStyle style = _buildBioTextStyle();
    Gradient? gradient = _buildGradient(
      widget.powerModel.effects?.bio?.gradientColors,
      widget.powerModel.effects?.bio?.gradientDirection,
    );

    double baseOpacity = _parseOpacity(widget.powerModel.effects?.bio?.opacity);

    return AnimatedBuilder(
      animation: _bioAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: baseOpacity,
          child: CustomPaint(
            painter: _WaveTextPainter(
              text: text,
              style: style,
              animationValue: _bioAnimationController.value,
              gradient: gradient,
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: _calculateTextWidth(text, style),
                minHeight: style.fontSize! * 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  Widget _buildGifImage(String? gifUrl, {bool isLeft = true}) {
    if (gifUrl == null || gifUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 30,
      height: 30,
      child: Image.network(
        // "https://ngoum.atonads.me/public/storage/$gifUrl",
        gifUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Power? power = widget.powerModel.effects?.power;
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildGifImage(power?.leftGif, isLeft: true),
              Flexible(
                fit: FlexFit.loose,
                child: _buildAnimatedText(
                  widget.displyText == null ? "" : widget.displyText!,
                  _buildTextStyle(),
                ),
              ),
              _buildGifImage(power?.rightGif, isLeft: false),
            ],
          ),
          _buildBioText(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientController.dispose();
    _bioAnimationController.dispose();
    _bioGradientController.dispose();
    _typingController?.dispose();
    _bioTypingController?.dispose();
    _typingTimer?.cancel();
    _bioTypingTimer?.cancel();
    super.dispose();
  }
}

// Custom painter for wave animation
class _WaveTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double animationValue;
  final Gradient? gradient;

  _WaveTextPainter({
    required this.text,
    required this.style,
    required this.animationValue,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double x = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      final waveOffset = sin(animationValue * 2 * pi + i * 0.5) * 8;

      final textPainter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      if (gradient != null) {
        canvas.save();
        canvas.translate(
            x, size.height / 2 - textPainter.height / 2 + waveOffset);

        final shader = gradient!.createShader(
          Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
        );

        // ignore: unused_local_variable
        final paint = Paint()..shader = shader;
        textPainter.paint(canvas, Offset.zero);

        canvas.restore();
      } else {
        textPainter.paint(
          canvas,
          Offset(x, size.height / 2 - textPainter.height / 2 + waveOffset),
        );
      }

      x += textPainter.width;
    }
  }

  @override
  bool shouldRepaint(covariant _WaveTextPainter oldDelegate) {
    return text != oldDelegate.text ||
        style != oldDelegate.style ||
        animationValue != oldDelegate.animationValue ||
        gradient != oldDelegate.gradient;
  }
}
