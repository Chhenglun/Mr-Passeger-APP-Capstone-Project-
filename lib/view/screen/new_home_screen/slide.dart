import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderHome extends StatefulWidget {
  @override
  _SliderHomeState createState() => _SliderHomeState();
}

class _SliderHomeState extends State<SliderHome> {
  int _current_slider = 0;
  List<String> images = [
  'https://www.blackandwhitecabs.com.au/wp-content/uploads/2020/05/Private-bookings-banner.jpg',
  'https://safedrivers.ae/wp-content/uploads/2021/05/image_2021_05_03T10_36_59_670Z.png',
  'https://www.allrideapps.com/wp-content/uploads/2023/06/Feature-image-3-opt.jpg',
  ];
  bool isSlideLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CarouselSlider(
        items: images
            .map((item) => Container(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(item, fit: BoxFit.cover, width: 1000),
                    ),
                  ),
                ))
            .toList(),
        options: CarouselOptions(
          height: 150,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 2.0,
          onPageChanged: (index, reason) {
            setState(() {
              _current_slider = index;
            });
          },
        ),
      ),
    );
  }
}
