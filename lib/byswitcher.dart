library byswitcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _extension = 7.0;

const Color _activeTrackColor = Color(0xFFF12E49);
const Color _busyTrackColor = Color(0xFFE6E9E6);
const Color _inactiveTrackColor = Color(0xFFF9FCF8);
const Color _thumbColor = Color(0xFFF9FCF8);

const int _progressDuration = 1200;

const Duration _reactionDuration = Duration(milliseconds: 300);
const Duration _toggleDuration = Duration(milliseconds: 200);

const Color _borderColor = Color(0x1A000000);

const List<BoxShadow> _thumbBoxShadows = <BoxShadow>[
  BoxShadow(
    color: Color(0x26000000),
    offset: Offset(0, 3),
    blurRadius: 8.0,
  ),
  BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 3),
    blurRadius: 1.0,
  ),
];

enum SwitchState {
  /// 打开态
  ACTIVE,

  /// 加载态
  LOADING,

  /// 关闭态
  INACTIVE,
}

class SwitcherStyle {
  static const double width = 67;
  static const double height = 32;
  static const double gap = 1.6;
}

class BySwitcher extends StatefulWidget {
  final double width;

  final double height;

  /// 状态
  final SwitchState state;

  /// 是否需要中间加载态（如果有中间态，暂不实现拖拽开关功能）
  final bool hasLoadingState;

  /// 点击事件
  final VoidCallback onTap;

  /// 打开态背景色
  final Color activeTrackColor;

  /// 加载态背景色
  final Color busyTrackColor;

  /// 关闭态背景色
  final Color inactiveTrackColor;

  /// 滑块颜色
  final Color thumbColor;

  /// 滑块视图
  final Widget thumb;

  /// 打开态显示标志
  final Widget activeFlag;

  /// 关闭态显示标志
  final Widget inactiveFlag;

  /// 切换开关时触发
  final ValueChanged<SwitchState> onChanged;

  /// 切换加载态时触发
  final ValueChanged<SwitchState> onLoading;

  /// 是否描边
  final bool withBorder;

  /// 样式：描边颜色
  final Color borderColor;

  /// 进度条颜色
  final Color progressColor;

  /// 进度条静态图
  final Widget progressImg;

  /// 自定义完整进度条
  final Widget progress;

  const BySwitcher({
    Key key,
    @required this.onChanged,
    this.onLoading,
    this.state = SwitchState.INACTIVE,
    this.hasLoadingState = false,
    this.onTap,
    this.width = SwitcherStyle.width,
    this.height = SwitcherStyle.height,
    this.activeTrackColor = _activeTrackColor,
    this.inactiveTrackColor = _inactiveTrackColor,
    this.busyTrackColor = _busyTrackColor,
    this.thumbColor = _thumbColor,
    this.thumb,
    this.activeFlag,
    this.inactiveFlag,
    this.withBorder = true,
    this.borderColor = _borderColor,
    this.progressColor,
    this.progressImg,
    this.progress,
  })  : assert(!hasLoadingState || (hasLoadingState && onLoading != null)),
        super(key: key);

  const BySwitcher.loading({
    Key key,
    @required this.onChanged,
    this.onLoading,
    this.state = SwitchState.INACTIVE,
    this.hasLoadingState = true,
    this.onTap,
    this.width = SwitcherStyle.width,
    this.height = SwitcherStyle.height,
    this.activeTrackColor = _activeTrackColor,
    this.inactiveTrackColor = _inactiveTrackColor,
    this.busyTrackColor = _busyTrackColor,
    this.thumbColor = _thumbColor,
    this.thumb,
    this.activeFlag,
    this.inactiveFlag,
    this.withBorder = true,
    this.borderColor = _borderColor,
    this.progressColor,
    this.progressImg,
    this.progress,
  })  : assert(!hasLoadingState || (hasLoadingState && onLoading != null)),
        super(key: key);

  @override
  _BySwitcherState createState() => _BySwitcherState();
}

class _BySwitcherState extends State<BySwitcher> with TickerProviderStateMixin {
  double _trackRadius;
  double _trackInnerStart;
  double _trackInnerEnd;
  double _trackInnerLength;
  double _thumbSize;

  bool get _enabled => widget.onChanged != null;

  bool _isDragging = false;
  bool _needsMoveAnimation = false;

  double _toggleOpacity;
  double _reactionOpacity = 0.0;

  AnimationController _progressCtrl;

  bool toActive() => widget.state == SwitchState.ACTIVE;

  bool toInactive() => widget.state == SwitchState.INACTIVE;

  bool inLoading() => widget.state == SwitchState.LOADING;

  @override
  void initState() {
    super.initState();

    _trackRadius = widget.height / 2.0;
    _trackInnerStart = widget.height / 2.0;
    _trackInnerEnd = widget.width - _trackInnerStart;
    _trackInnerLength = _trackInnerEnd - _trackInnerStart;

    _thumbSize = widget.height - SwitcherStyle.gap * 2;

    _toggleOpacity = toActive() ? 1.0 : 0.0;

    _progressCtrl = !widget.hasLoadingState || widget.progressImg == null
        ? null
        : AnimationController(
            duration: const Duration(milliseconds: _progressDuration),
            vsync: this,
          );
  }

  _doReaction(bool forward) {
    setState(() {
      _reactionOpacity = forward ? 1.0 : 0.0;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (inLoading()) {
      return;
    }

    if (_enabled) {
      _doReaction(true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (inLoading()) {
      return;
    }

    if (_enabled) {
      _doReaction(false);
    }
  }

  void _handleTap() {
    if (_enabled) {
      _toggleState();
    }
  }

  void _handleTapCancel() {
    if (_enabled) {
      _doReaction(false);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (inLoading()) {
      return;
    }

    if (_enabled) {
      _needsMoveAnimation = false;
      _isDragging = true;
      _doReaction(true);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (inLoading()) {
      return;
    }

    if (_enabled) {
      setState(() {
        _toggleOpacity =
            (_toggleOpacity + details.primaryDelta / _trackInnerLength)
                .clamp(0.0, 1.0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (inLoading()) {
      return;
    }

    _isDragging = false;
    _needsMoveAnimation = true;
    _doReaction(false);

    // Call onChanged when the user's intent to change value is clear.
    if (_toggleOpacity >= 0.5 != toActive()) {
      _toggleState();
    } else {
      setState(() {
        _toggleOpacity = toActive() ? 1.0 : 0.0;
      });
    }
  }

  void _toggleState() {
    if (inLoading()) {
      return;
    }

    SwitchState target = toActive() ? SwitchState.INACTIVE : SwitchState.ACTIVE;
    if (widget.hasLoadingState) {
      widget.onChanged(SwitchState.LOADING);
      widget.onLoading(target);
    } else {
      widget.onChanged(target);
    }
  }

  @override
  void didUpdateWidget(BySwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == widget.state) {
      return;
    }

    if (inLoading()) {
      _progressCtrl?.repeat();
    } else {
      _toggleOpacity = toActive() ? 1.0 : 0.0;
      _progressCtrl?.stop();
    }
  }

  @override
  void dispose() {
    _progressCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _enabled ? 1.0 : 0.5,
      child: _buildLayout(),
    );
  }

  Widget _buildLayout() => GestureDetector(
        onHorizontalDragStart: widget.hasLoadingState ? null : _handleDragStart,
        onHorizontalDragUpdate:
            widget.hasLoadingState ? null : _handleDragUpdate,
        onHorizontalDragEnd: widget.hasLoadingState ? null : _handleDragEnd,
        onTapDown: _handleTapDown,
        onTap: _handleTap,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: widget.width,
          height: widget.height,
          child: _buildContent(),
        ),
      );

  Widget _buildContent() {
    List<Widget> children = <Widget>[];
    children.add(_trackView());

    Widget flags = _flagView();
    if (flags != null) {
      children.add(flags);
    }

    children.add(_thumbView());

    return Stack(
      alignment: Alignment.centerLeft,
      children: children,
    );
  }

  _trackView() => AnimatedContainer(
        curve: Curves.linear,
        duration: _toggleDuration,
        decoration: BoxDecoration(
          color: inLoading()
              ? _busyTrackColor
              : Color.lerp(widget.inactiveTrackColor, widget.activeTrackColor,
                  _toggleOpacity),
          borderRadius: BorderRadius.all(Radius.circular(_trackRadius)),
          border: widget.withBorder
              ? Border.all(color: _borderColor, width: 0.5)
              : null,
        ),
      );

  _flagView() {
    double offset = widget.height / 8;
    bool isActive = toActive();
    Widget flag = isActive ? widget.activeFlag : widget.inactiveFlag;
    if (flag == null) {
      return null;
    }

    return Positioned(
      left: isActive ? offset : null,
      right: isActive ? null : offset,
      child: flag,
    );
  }

  _thumbView() => AnimatedContainer(
        curve: Curves.linear,
        duration: _toggleDuration,
        margin: EdgeInsets.fromLTRB(
            SwitcherStyle.gap + _toggleOpacity * _trackInnerLength,
            SwitcherStyle.gap,
            SwitcherStyle.gap,
            SwitcherStyle.gap),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              curve: Curves.ease,
              duration: _reactionDuration,
              child: _thumbObj(),
            ),
            inLoading() ? _loadingProgress() : SizedBox(),
          ],
        ),
      );

  _thumbObj() => Container(
        width: _thumbSize + _reactionOpacity * _extension,
        height: _thumbSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.thumbColor,
          borderRadius: BorderRadius.all(Radius.circular(_thumbSize / 2.0)),
          boxShadow: _thumbBoxShadows,
          border: widget.withBorder
              ? Border.all(color: _borderColor, width: 0.5)
              : null,
        ),
        child: inLoading() ? null : widget.thumb,
      );

  _loadingProgress() => _progressCtrl == null
      ? CupertinoActivityIndicator(
          radius: _thumbSize / 3,
        )
      : RotationTransition(
          alignment: Alignment.center,
          turns: _progressCtrl,
          child: widget.progressImg,
        );
}
