import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto/Screens/UserSide/Article/article_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Article/pdf_viewer_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:html' as html;
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class FullCarouselSliderScreen extends StatefulWidget {
  final List<String> imagesList;
  final int currentIndex;
  const FullCarouselSliderScreen({
    Key? key,
    required this.imagesList,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<FullCarouselSliderScreen> createState() =>
      _FullCarouselSliderScreenState();
}

class _FullCarouselSliderScreenState extends State<FullCarouselSliderScreen>
    with TickerProviderStateMixin {
  final CarouselController carouselController = CarouselController();
  late PageController pageController;
  late PhotoViewController photoViewController;

  late Animation<double> _fadeInOutAnimation;
  late AnimationController _animationController;
  var hideButton = false;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;

    pageController = PageController(
      viewportFraction: 0.5,
      initialPage: currentIndex,
    );
    photoViewController = PhotoViewController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInOutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.reverse();
    hideButton = false;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.grey.withOpacity(0.2),
        child: MouseRegion(
          onHover: (event) {
            _animationController.forward();

            setState(() {
              hideButton = true;
            });
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.grey.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      customPageView(),
                      if (hideButton == true &&
                          currentIndex < widget.imagesList.length)
                        nextPageButton(),
                      if (hideButton == true && currentIndex >= 1)
                        previousPageButton(),
                      customCrossButton(),
                      if (hideButton == true) pageViewsOptions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customPageView() {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: List.generate(widget.imagesList.length, (index) {
            return Container(
              width: width,
              height: width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: buildPage(index),
            );
          }),
        ),
      ),
    );
  }

  Widget previousPageButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: GestureDetector(
          onTap: () {
            if (currentIndex >= 1) {
              currentIndex--;
              sliderCurrentIndex = currentIndex;
              carouselController.previousPage();
              pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            setState(() {});
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.black, shape: BoxShape.circle),
            padding: const EdgeInsets.only(left: 5),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nextPageButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: GestureDetector(
          onTap: () {
            if (currentIndex < widget.imagesList.length - 1) {
              currentIndex++;
              sliderCurrentIndex = currentIndex;
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            setState(() {});
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.black, shape: BoxShape.circle),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget pageViewsOptions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: Container(
          width: 766,
          height: 50,
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.8, color: Colors.white),
                        shape: BoxShape.rectangle),
                    child: Center(
                      child: Text(
                        "${currentIndex + 1} ",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Text(
                    "\t / \t  ${widget.imagesList.length} ",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                width: 600,
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 1,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  ),
                  child: Slider(
                    value: currentIndex.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        sliderCurrentIndex = currentIndex;
                        currentIndex = value.toInt();
                      });
                    },
                    min: 0,
                    max: widget.imagesList.length.toDouble() - 1,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    thumbColor: Colors.white,
                    autofocus: false,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(right: 2),
                  child: Center(
                    child: Image.asset(
                      "assets/minus-button.png",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: Image.asset(
                      "assets/plus.png",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customCrossButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          exitFullScreen();
          Navigator.pop(context, currentIndex);
        },
        child: Container(
          width: 40,
          height: 50,
          margin: const EdgeInsets.only(top: 20, left: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildPage(int index) {
    final isSelected = index == currentIndex;
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Stack(
        children: [
          Center(
            child: Image.network(
              widget.imagesList[index],
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          if (!isSelected)
            Container(
              color: Colors.grey.withOpacity(0.5),
            )
        ],
      ),
    );
  }

  void exitFullScreen() {
    html.document.exitFullscreen();
  }
}

class FullPDFViewerScreen extends StatefulWidget {
  final int currentIndex;
  final String pdfUrl;
  final int pagesCounts;

  const FullPDFViewerScreen({
    super.key,
    required this.currentIndex,
    required this.pdfUrl,
    required this.pagesCounts,
  });

  @override
  State<FullPDFViewerScreen> createState() => _FullPDFViewerScreenState();
}

class _FullPDFViewerScreenState extends State<FullPDFViewerScreen>
    with TickerProviderStateMixin {
  late Animation<double> _fadeInOutAnimation;
  late AnimationController _animationController;
  var hideButton = false;
  late int currentIndex;
  var pagesCounts = 1;
  PdfController? pdfController;
  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    pagesCounts = widget.pagesCounts;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInOutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.reverse();
    hideButton = false;

    pdfController = pdfController;
    setState(() {});
    print('widget.currentIndex: $currentIndex');

    //setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) async {
      String url = widget.pdfUrl;
      final Uri parsedUri = Uri.parse(url);

      try {
        final Response res = await http.get(
          parsedUri,
        );
        //res.cookie('key', 'value', { sameSite: 'None', secure: true });
        var doc = PdfDocument.openData(res.bodyBytes);
        pdfController = PdfController(
            document: doc,
            viewportFraction: 0.5,
            initialPage: widget.currentIndex);
        setState(() {});
        if (res.statusCode == 200) {
          print(
              'PDF Content: ${String.fromCharCodes(res.bodyBytes.sublist(0, min(100, res.bodyBytes.length)))}');

          print('PDF Data Length: ${res.bodyBytes.length}');
        } else {
          print('Failed to fetch PDF. HTTP Status Code: ${res.statusCode}');
        }
      } catch (error) {
        print('Error during HTTP request: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.grey.withOpacity(0.2),
        child: MouseRegion(
          onHover: (event) {
            _animationController.forward();

            setState(() {
              hideButton = true;
            });
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.grey.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      customPageView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customPageView() {
    return SizedBox(
      width: width,
      height: height,
      child: pdfController != null
          ? PdfPageNumber(
              controller: pdfController!,
              builder: (context, state, page, pagesCount) {
                var pagesCounts = pagesCount ?? 1;
                return Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child: PdfView(
                          controller: pdfController!,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (page) {},
                          onDocumentLoaded: (document) {},
                          onDocumentError: (error) {
                            print("Error Occurred $error");
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Text(
                            '$page/${pagesCount ?? 0}',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      if (hideButton == true && currentIndex < pagesCounts)
                        nextPageButton(),
                      if (hideButton == true && currentIndex > 1)
                        previousPageButton(),
                      customCrossButton(),
                      if (hideButton == true) pageViewsOptions(),
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator()), // or some loading indicator
    );
  }

  Widget previousPageButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: GestureDetector(
          onTap: () {
            if (currentIndex > 1) {
              currentIndex--;
              sliderPDFCurrentIndex = currentIndex;

              pdfController!.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            setState(() {});
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.black, shape: BoxShape.circle),
            padding: const EdgeInsets.only(left: 5),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nextPageButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: GestureDetector(
          onTap: () {
            if (currentIndex < pagesCounts) {
              currentIndex++;
              sliderPDFCurrentIndex = currentIndex;
              pdfController!.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            setState(() {});
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.black, shape: BoxShape.circle),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget pageViewsOptions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: _fadeInOutAnimation,
        child: Container(
          width: 766,
          height: 50,
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.8, color: Colors.white),
                        shape: BoxShape.rectangle),
                    child: Center(
                      child: Text(
                        "$currentIndex ",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Text(
                    "\t / \t  $pagesCounts ",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                width: 600,
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 1,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  ),
                  child: Slider(
                    value: currentIndex.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        sliderPDFCurrentIndex = currentIndex;
                        currentIndex = value.toInt();
                      });
                    },
                    min: 1,
                    max: pagesCounts.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    thumbColor: Colors.white,
                    autofocus: false,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(right: 2),
                  child: Center(
                    child: Image.asset(
                      "assets/minus-button.png",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: Image.asset(
                      "assets/plus.png",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customCrossButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          exitFullScreen();
          Navigator.pop(context, currentIndex);
        },
        child: Container(
          width: 40,
          height: 50,
          margin: const EdgeInsets.only(top: 20, left: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void exitFullScreen() {
    html.document.exitFullscreen();
  }
}
