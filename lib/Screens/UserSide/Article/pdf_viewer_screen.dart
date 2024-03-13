import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:html' as html;
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:proyecto/Screens/UserSide/Article/article_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/see_Images_screen.dart';

final GlobalKey<_PDFViewerScreenState> pdfViewerKey = GlobalKey();

class PDFViewerScreen extends StatefulWidget {
  final String pdfURl;
  const PDFViewerScreen({super.key, required this.pdfURl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInOutAnimation;
  PdfController? pdfController;
  var hideButton = true;
  var isMobile = false;
  var currentIndex = 1;
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInOutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.reverse();
    initializePDFController();
  }

  void initializePDFController() async {
    String url = widget.pdfURl;
    final Uri parsedUri = Uri.parse(url);

    try {
      final Response res = await http.get(
        parsedUri,
      );
      //res.cookie('key', 'value', { sameSite: 'None', secure: true });
      var doc = PdfDocument.openData(res.bodyBytes);
      pdfController = PdfController(document: doc, initialPage: currentIndex);
      setState(() {});
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return showPDFViewer();
  }

  Widget showPDFViewer() {
    return MouseRegion(
      onEnter: (event) {
        _animationController.forward();

        // setState(() {
        //   hideButton = true;
        // });
      },
      onExit: (event) {
        // _animationController.reverse();

        // setState(() {});
      },
      child: Container(
        width: isMobile ? 360 : 400,
        height: isMobile ? 460 : 470,
        color: Colors.grey.withOpacity(0.2),
        child: SizedBox(
          width: 400,
          height: 500,
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
                              padding:
                                  const EdgeInsets.only(top: 10, right: 10),
                              child: Text(
                                '$page/${pagesCount ?? 0}',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          if (hideButton == true && currentIndex < pagesCounts)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: GestureDetector(
                                  onTap: () {
                                    if (currentIndex < pagesCounts) {
                                      //  carouselController.nextPage();
                                      pdfController!.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                    setState(() {
                                      currentIndex++;
                                      sliderPDFCurrentIndex = currentIndex;
                                    });
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (hideButton == true && currentIndex > 1)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: GestureDetector(
                                  onTap: () {
                                    if (currentIndex > 1) {
                                      pdfController!.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut);

                                      //carouselController.previousPage();
                                      setState(() {
                                        currentIndex--;
                                        sliderPDFCurrentIndex = currentIndex;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                    margin: const EdgeInsets.only(left: 10),
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
                            ),
                          if (hideButton == true)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: Container(
                                  height: 40,
                                  color: Colors.black.withOpacity(0.6),
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${currentIndex}/ $pagesCounts",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 1,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 8.0),
                                        ),
                                        child: Slider(
                                          value: currentIndex.toDouble(),
                                          secondaryTrackValue:
                                              currentIndex.toDouble(),
                                          onChanged: (value) {
                                            setState(() {
                                              currentIndex = value.toInt();
                                              pdfController!.animateToPage(
                                                  currentIndex,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.bounceInOut);
                                            });
                                          },
                                          min: 1,
                                          max: pagesCounts.toDouble(),
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.grey,
                                          thumbColor: Colors.white,
                                          autofocus: true,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          html.document.documentElement!
                                              .requestFullscreen();
                                          navigateToFullCarouselSliderScreen(
                                              pagesCounts);
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 20,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Image.asset(
                                            "assets/fullscreen.png",
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child:
                      CircularProgressIndicator()), // or some loading indicator
        ),
      ),
    );
  }

  void navigateToFullCarouselSliderScreen(int pagesCounts) async {
    int? returnedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullPDFViewerScreen(
          key: pdfViewerKey,
          pagesCounts: pagesCounts,
          currentIndex: currentIndex,
          pdfUrl: widget.pdfURl,

          // Pass the current index
        ),
      ),
    );

    // Handle returnedIndex when it returns
    if (returnedIndex != null) {
      print("returnedIndex $returnedIndex");
      currentIndex = returnedIndex;
      print(currentIndex);
      setState(() {});
      pdfController!.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
