import 'package:flutter/material.dart';

import '../utils/viewport_pagination.dart';

class ViewportPagedContent extends StatefulWidget {
  const ViewportPagedContent({
    super.key,
    required this.pages,
    required this.backgroundColor,
    this.header,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
    this.onSlideChanged,
    this.onRequestNext,
    this.onRequestPrevious,
    this.controller,
    this.rtlSwipe = true,
  });

  final List<List<ViewportSegment>> pages;
  final Color backgroundColor;
  final Widget? header;
  final EdgeInsets padding;
  final ValueChanged<int>? onSlideChanged;
  final VoidCallback? onRequestNext;
  final VoidCallback? onRequestPrevious;
  final PageController? controller;
  final bool rtlSwipe;

  @override
  State<ViewportPagedContent> createState() => ViewportPagedContentState();
}

class ViewportPagedContentState extends State<ViewportPagedContent> {
  late PageController _controller;
  late int _slideIndex;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PageController();
    _slideIndex = _controller.initialPage;
  }

  @override
  void didUpdateWidget(ViewportPagedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pages.length != widget.pages.length) {
      _slideIndex = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void jumpToSlide(int index) {
    if (index < 0 || index >= widget.pages.length) return;
    _controller.jumpToPage(index);
    setState(() => _slideIndex = index);
  }

  bool _shouldGoNext(OverscrollNotification notification) {
    if (_slideIndex != widget.pages.length - 1) return false;
    return widget.rtlSwipe ? notification.overscroll < 0 : notification.overscroll > 0;
  }

  bool _shouldGoPrevious(OverscrollNotification notification) {
    if (_slideIndex != 0) return false;
    return widget.rtlSwipe ? notification.overscroll > 0 : notification.overscroll < 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return ColoredBox(color: widget.backgroundColor);
    }

    final pageView = PageView.builder(
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.pages.length,
      onPageChanged: (index) {
        setState(() => _slideIndex = index);
        widget.onSlideChanged?.call(index);
      },
      itemBuilder: (context, index) {
        final segments = widget.pages[index];
        return Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (index == 0 && widget.header != null) ...[
                widget.header!,
                const SizedBox(height: 8),
              ],
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < segments.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        segments[i].builder(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return ColoredBox(
      color: widget.backgroundColor,
      child: NotificationListener<OverscrollNotification>(
        onNotification: (notification) {
          if (_shouldGoNext(notification)) {
            widget.onRequestNext?.call();
            return true;
          }
          if (_shouldGoPrevious(notification)) {
            widget.onRequestPrevious?.call();
            return true;
          }
          return false;
        },
        child: widget.rtlSwipe
            ? Directionality(
                textDirection: TextDirection.rtl,
                child: pageView,
              )
            : pageView,
      ),
    );
  }
}
