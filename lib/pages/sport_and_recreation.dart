import 'dart:math';

import 'package:flutter/material.dart';

import '../database_config/tour_data_service.dart';
import '../helper/accessibility_theme.dart';
import '../helper/images_loader_helper.dart';
import '../helper/remote_data_builder.dart';
import '../helper/responsive_layout.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/custom_app_bar.dart';
import '../navigation/navigation_helper.dart';
import 'parks/park_details.dart';
import 'sports/sport_details.dart';

class SportsAndRecreation extends StatelessWidget {
  const SportsAndRecreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).sportRecreation,
        const Color.fromRGBO(65, 89, 45, 1),
        onRefresh: () {
          TourDataService.instance.refresh(TourCollection.parks);
          TourDataService.instance.refresh(TourCollection.sports);
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: Color.fromRGBO(65, 89, 45, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgroundAndCoverImages/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(photoTextScrim, BlendMode.srcOver),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _RecreationSection(
                    title: localization(context).parks,
                    collection: TourCollection.parks,
                    languageCode: languageCode,
                  ),
                  const SizedBox(height: 20),
                  _RecreationSection(
                    title: localization(context).sportFields,
                    collection: TourCollection.sports,
                    languageCode: languageCode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecreationSection extends StatelessWidget {
  const _RecreationSection({
    required this.title,
    required this.collection,
    required this.languageCode,
  });

  final String title;
  final TourCollection collection;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        RemoteDataBuilder<List<Map<String, dynamic>>>(
          queryKey: languageCode,
          load: () => TourDataService.instance.list(collection, languageCode),
          refreshSignal: TourDataService.instance.refreshSignal(collection),
          onRetry: () => TourDataService.instance.refresh(collection),
          onData: (data) => _RecreationCarousel(
            data: data,
            isPark: collection == TourCollection.parks,
          ),
        ),
      ],
    );
  }
}

class _RecreationCarousel extends StatelessWidget {
  const _RecreationCarousel({required this.data, required this.isPark});

  final List<Map<String, dynamic>> data;
  final bool isPark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fraction = constraints.maxWidth < 600 ? 1.0 : 0.5;
        final pageWidth = constraints.maxWidth * fraction;
        final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ) ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w300);
        final titleHeight = data
            .map((item) => measureTextHeight(
                  context,
                  item['title'] as String,
                  titleStyle,
                  max(1, pageWidth - 40),
                ))
            .fold<double>(0, max);
        final imageHeight = (pageWidth * 0.55).clamp(150.0, 260.0);
        return SizedBox(
          height: imageHeight + titleHeight + 96,
          child: _PagedRecreationCards(
            key: ValueKey(fraction),
            data: data,
            isPark: isPark,
            fraction: fraction,
            cacheWidth: max(
                1, (pageWidth * MediaQuery.devicePixelRatioOf(context)).ceil()),
          ),
        );
      },
    );
  }
}

class _PagedRecreationCards extends StatefulWidget {
  const _PagedRecreationCards({
    Key? key,
    required this.data,
    required this.isPark,
    required this.fraction,
    required this.cacheWidth,
  }) : super(key: key);

  final List<Map<String, dynamic>> data;
  final bool isPark;
  final double fraction;
  final int cacheWidth;

  @override
  State<_PagedRecreationCards> createState() => _PagedRecreationCardsState();
}

class _PagedRecreationCardsState extends State<_PagedRecreationCards> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.fraction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = (1 / widget.fraction).floor();
    final lastPage = max(0, widget.data.length - visiblePages);

    void moveTo(int page) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.jumpToPage(page);
      } else {
        _controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.data.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final item = widget.data[index];
              final title = item['title'] as String;
              final image =
                  item[widget.isPark ? 'park_image_path' : 'sport_image_path']
                      as String;
              return Semantics(
                button: true,
                label: title,
                onTapHint: widget.isPark
                    ? localization(context).tapToViewPark
                    : localization(context).tapToViewSport,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: InkWell(
                    onTap: () => showDetailsPage(
                      context,
                      widget.isPark
                          ? ParkDetailsPage(parkId: item['id'] as String)
                          : SportDetailsPage(sportId: item['id'] as String),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TourImage(
                            image: image,
                            cacheWidth: widget.cacheWidth,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            semanticLabel: localization(context).image(title),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Center(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: localization(context).previousItem,
                  onPressed:
                      _currentPage > 0 ? () => moveTo(_currentPage - 1) : null,
                  icon: Icon(Icons.chevron_left,
                      semanticLabel: localization(context).previousItem),
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(localization(context)
                      .positionInList(_currentPage + 1, widget.data.length)),
                ),
                IconButton(
                  tooltip: localization(context).nextItem,
                  onPressed: _currentPage < lastPage
                      ? () => moveTo(_currentPage + 1)
                      : null,
                  icon: Icon(Icons.chevron_right,
                      semanticLabel: localization(context).nextItem),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
