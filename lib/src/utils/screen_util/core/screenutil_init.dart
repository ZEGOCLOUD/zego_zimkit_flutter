import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:zego_zimkit/src/utils/screen_util/core/_flutter_widgets.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/screenutil_mixin.dart';

typedef ZIMRebuildFactor = bool Function(
    MediaQueryData old, MediaQueryData data);

typedef ZIMScreenUtilInitBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

/// @nodoc
abstract class ZIMRebuildFactors {
  static bool size(MediaQueryData old, MediaQueryData data) {
    return old.size != data.size;
  }

  static bool orientation(MediaQueryData old, MediaQueryData data) {
    return old.orientation != data.orientation;
  }

  static bool sizeAndViewInsets(MediaQueryData old, MediaQueryData data) {
    return old.viewInsets != data.viewInsets;
  }

  static bool change(MediaQueryData old, MediaQueryData data) {
    return old != data;
  }

  static bool always(MediaQueryData _, MediaQueryData __) {
    return true;
  }

  static bool none(MediaQueryData _, MediaQueryData __) {
    return false;
  }
}

abstract class ZIMFontSizeResolvers {
  static double width(num fontSize, ZIMScreenUtil instance) {
    return instance.setWidth(fontSize);
  }

  static double height(num fontSize, ZIMScreenUtil instance) {
    return instance.setHeight(fontSize);
  }

  static double radius(num fontSize, ZIMScreenUtil instance) {
    return instance.radius(fontSize);
  }

  static double diameter(num fontSize, ZIMScreenUtil instance) {
    return instance.diameter(fontSize);
  }

  static double diagonal(num fontSize, ZIMScreenUtil instance) {
    return instance.diagonal(fontSize);
  }
}

/// @nodoc
class ZIMScreenUtilInit extends StatefulWidget {
  /// A helper widget that initializes [ZIMScreenUtil]
  const ZIMScreenUtilInit({
    Key? key,
    this.builder,
    this.child,
    this.rebuildFactor = ZIMRebuildFactors.size,
    this.designSize = const Size(750, 1334),
    this.splitScreenMode = false,
    this.minTextAdapt = false,
    this.useInheritedMediaQuery = false,
    this.ensureScreenSize,
    this.responsiveWidgets,
    this.fontSizeResolver = ZIMFontSizeResolvers.width,
  }) : super(key: key);

  final ZIMScreenUtilInitBuilder? builder;
  final Widget? child;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final bool? ensureScreenSize;
  final ZIMRebuildFactor rebuildFactor;
  final ZIMFontSizeResolver fontSizeResolver;

  /// The [Size] of the device in the design draft, in dp
  final Size designSize;
  final Iterable<String>? responsiveWidgets;

  @override
  State<ZIMScreenUtilInit> createState() => _ZIMScreenUtilInitState();
}

class _ZIMScreenUtilInitState extends State<ZIMScreenUtilInit>
    with WidgetsBindingObserver {
  final _canMarkedToBuild = HashSet<String>();
  MediaQueryData? _mediaQueryData;
  final _binding = WidgetsBinding.instance;
  final _screenSizeCompleter = Completer<void>();

  @override
  void initState() {
    if (widget.responsiveWidgets != null) {
      _canMarkedToBuild.addAll(widget.responsiveWidgets!);
    }
    _validateSize().then(_screenSizeCompleter.complete);

    super.initState();
    _binding.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _revalidate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revalidate();
  }

  MediaQueryData? _newData() {
    MediaQueryData? mq = MediaQuery.maybeOf(context);
    mq ??= MediaQueryData.fromView(View.of(context));

    return mq;
  }

  Future<void> _validateSize() async {
    if (widget.ensureScreenSize ?? false) {
      return ZIMScreenUtil.ensureScreenSize();
    }
  }

  void _markNeedsBuildIfAllowed(Element el) {
    final widgetName = el.widget.runtimeType.toString();
    final allowed = widget is ZIMSU ||
        _canMarkedToBuild.contains(widgetName) ||
        !(widgetName.startsWith('_') || zFlutterWidgets.contains(widgetName));

    if (allowed) el.markNeedsBuild();
  }

  void _updateTree(Element el) {
    _markNeedsBuildIfAllowed(el);
    el.visitChildren(_updateTree);
  }

  void _revalidate([void Function()? callback]) {
    final oldData = _mediaQueryData;
    final newData = _newData();

    if (newData == null) return;

    if (oldData == null || widget.rebuildFactor(oldData, newData)) {
      setState(() {
        _mediaQueryData = newData;
        _updateTree(context as Element);
        callback?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = _mediaQueryData;

    if (mq == null) return const SizedBox.shrink();

    return FutureBuilder<void>(
      future: _screenSizeCompleter.future,
      builder: (c, snapshot) {
        ZIMScreenUtil.configure(
          data: mq,
          designSize: widget.designSize,
          splitScreenMode: widget.splitScreenMode,
          minTextAdapt: widget.minTextAdapt,
          fontSizeResolver: widget.fontSizeResolver,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder?.call(context, widget.child) ?? widget.child!;
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _binding.removeObserver(this);
    super.dispose();
  }
}
