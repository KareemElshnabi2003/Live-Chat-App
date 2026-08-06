import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

Widget autoSliderImage({
  List<Widget>? images,
}) {
  return CarouselSlider(
    items: images,
    options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        aspectRatio: 35 / 9,
        autoPlayAnimationDuration: const Duration(milliseconds: 1200),
        onPageChanged: null),
  );
}
