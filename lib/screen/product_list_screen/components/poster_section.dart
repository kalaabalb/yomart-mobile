import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/story.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/story_viewer_screen.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterSection extends StatefulWidget {
  const PosterSection({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  State<PosterSection> createState() => _PosterSectionState();
}

class _PosterSectionState extends State<PosterSection> {
  late final PageController _pageController =
      PageController(viewportFraction: .96);
  int _activeIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final slides = dataProvider.posters
            .map(
              (poster) => _PromoPoster(
                title: poster.posterName?.trim().isNotEmpty == true
                    ? poster.posterName!.trim()
                    : context.l10n.discover_products,
                imageUrl: poster.imageUrl,
                subtitle: poster.subtitle,
              ),
            )
            .toList();
        final stories = dataProvider.stories;
        final totalCards = slides.length + stories.length;
        if (totalCards == 0) return const SizedBox.shrink();

        final availableWidth = MediaQuery.sizeOf(context).width - 32;
        final posterHeight = (availableWidth / 1.55).clamp(220.0, 300.0);
        return SizedBox(
          height: posterHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalCards,
            onPageChanged: (index) => setState(() => _activeIndex = index),
            itemBuilder: (context, index) {
              if (index >= slides.length) {
                final storyIndex = index - slides.length;
                final story = stories[storyIndex];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _storyCard(context, story, stories, storyIndex),
                );
              }
              final poster = slides[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _posterCard(
                  context,
                  poster,
                  slideCount: totalCards,
                  // The API has no poster destination field. The configured
                  // Browse products action therefore opens the catalog without
                  // turning promotional copy into a search query.
                  onTap: widget.onBrowse,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _storyCard(
    BuildContext context,
    Story story,
    List<Story> stories,
    int storyIndex,
  ) {
    final dark = MarketPalette.isDark(context);
    return Semantics(
      button: true,
      label: 'Watch story: ${story.title}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.4),
          boxShadow: const [
            BoxShadow(
                color: Color(0x8038BDF8), blurRadius: 13, spreadRadius: 1),
            BoxShadow(
                color: Color(0x704F46E5), blurRadius: 22, spreadRadius: 1),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => StoryViewerScreen(
                stories: stories,
                initialIndex: storyIndex,
                renewStory: (id) async {
                  final provider = context.read<DataProvider>();
                  await provider.getPublishedStories();
                  for (final item in provider.stories) {
                    if (item.id == id) return item;
                  }
                  return null;
                },
              ),
            )),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [
                          Color(0xFF08172B),
                          Color(0xFF142D52),
                          Color(0xFF31265E)
                        ]
                      : const [
                          Color(0xFF123B71),
                          Color(0xFF1459A8),
                          Color(0xFF383B91)
                        ],
                ),
              ),
              child: Stack(children: [
                Positioned(
                    right: 22,
                    top: 20,
                    child: Icon(Icons.auto_awesome,
                        color: Colors.white.withValues(alpha: .16), size: 62)),
                Positioned.fill(
                    child: Center(
                        child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .17),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54)),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 36),
                ))),
                Positioned(
                    left: 16,
                    right: 48,
                    top: 15,
                    child: Text(story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16))),
                if (story.subtitle.isNotEmpty)
                  Positioned(
                      left: 16,
                      right: 48,
                      top: 40,
                      child: Text(story.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11))),
                Positioned(
                    left: 16,
                    bottom: 13,
                    child: Row(children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 5),
                      Text('Watch story',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .9),
                              fontSize: 11,
                              fontWeight: FontWeight.w600))
                    ])),
                Positioned(
                  right: 12,
                  bottom: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      stories.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: storyIndex == index ? 13 : 5,
                        height: 5,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: storyIndex == index ? .95 : .5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _posterCard(BuildContext context, _PromoPoster poster,
      {required int slideCount, required VoidCallback onTap}) {
    final dark = MarketPalette.isDark(context);
    final textColor = dark ? Colors.white : MarketPalette.ink;
    return Semantics(
      button: true,
      label: poster.subtitle?.trim().isNotEmpty == true
          ? '${poster.title}. ${poster.subtitle}'
          : poster.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [
                        Color(0xFF0B1A31),
                        Color(0xFF192D53),
                        Color(0xFF513E83)
                      ]
                    : const [
                        Color(0xFFE5F2FF),
                        Color(0xFFBFD9F5),
                        Color(0xFFD8C9F2)
                      ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Center(
                    child: poster.imageUrl?.isNotEmpty == true
                        ? SizedBox.expand(
                            child: CustomNetworkImage(
                                imageUrl: poster.imageUrl!,
                                fit: BoxFit.contain,
                                placeholderColor: Colors.transparent))
                        : Icon(Icons.image_outlined,
                            size: 54,
                            color: dark ? Colors.white38 : MarketPalette.muted),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 11),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(poster.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            if (poster.subtitle?.trim().isNotEmpty == true)
                              Text(poster.subtitle!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: dark
                                          ? const Color(0xFFCBD8ED)
                                          : const Color(0xFF536A87),
                                      fontSize: 11)),
                          ])),
                      const SizedBox(width: 6),
                      MarketBrowseButton(
                          text: context.l10n.browse_products,
                          onPressed: onTap,
                          compact: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        slideCount,
                        (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: _activeIndex == index ? 13 : 5,
                              height: 5,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: (dark ? Colors.white : MarketPalette.ink)
                                    .withValues(
                                        alpha:
                                            _activeIndex == index ? .85 : .35),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            )),
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

class _PromoPoster {
  const _PromoPoster({required this.title, this.imageUrl, this.subtitle});

  final String title;
  final String? imageUrl;
  final String? subtitle;
}
