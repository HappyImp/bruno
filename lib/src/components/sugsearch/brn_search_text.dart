import 'package:bruno/src/constants/brn_asset_constants.dart';
import 'package:bruno/src/constants/brn_strings_constants.dart';
import 'package:bruno/src/theme/brn_theme_configurator.dart';
import 'package:bruno/src/utils/brn_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 搜索框内容变化回调
typedef BrnOnSearchTextChange = void Function(String content);

/// 提交搜索框内容时的回调
typedef BrnOnCommit = void Function(String content);

/// 右侧清除按钮 X 被点击的回调
typedef BrnOnTextClear = bool Function();

/// 基本IOS风格搜索框, 提供输入回调
class BrnSearchText extends StatefulWidget {
  /// 提示语
  final String hintText;

  /// 提示语样式
  final TextStyle hintStyle;

  /// 输入框样式
  final TextStyle textStyle;

  /// 用于设置搜索框前端的 Icon
  final Widget prefixIcon;

  /// 包裹搜索框的容器背景色
  final Color outSideColor;

  /// 搜索框内部的颜色
  final Color innerColor;

  /// 最大展示行数
  final int maxLines;

  /// 最大输入长度
  final int maxLength;

  /// 输入框最大高度，默认 60
  final double maxHeight;

  ///内部搜索框之外的 Padding。设置该字段会导致显示区域变小。
  final EdgeInsets innerPadding;

  ///普通状态的 border
  final BoxBorder normalBorder;

  /// 激活状态的 Border， 默认和 border 一致
  final BoxBorder activeBorder;

  /// 输入框圆角
  final BorderRadius borderRadius;

  /// 右侧操作 widget
  final Widget action;

  /// 是否自动获取焦点
  final bool autoFocus;

  /// 用于控制键盘动作
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final FocusNode focusNode;

  /// 文本变化的回调
  final BrnOnSearchTextChange onTextChange;

  /// 提交文本时的回调
  final BrnOnCommit onTextCommit;

  /// 右侧 action 区域点击的回调
  final VoidCallback onActionTap;

  /// 清除按钮的回调 如果用户设置了该属性
  /// 如果返回值为true，表明用户想要拦截，则不会走默认的清除行为
  /// 如果返回值为false，表明用户不想要拦截，在执行了用户的行为之后，还会走默认的行为
  final BrnOnTextClear onTextClear;

  /// 用于控制清除 Icon 和右侧 Action 的显示与隐藏。等其他复杂的操作。
  final BrnSearchTextController searchController;

  const BrnSearchText(
      {Key key,
      this.searchController,
      this.controller,
      this.maxLines = 1,
      this.maxLength,
      this.hintText,
      this.hintStyle,
      this.textStyle,
      this.prefixIcon,
      this.onTextChange,
      this.onTextCommit,
      this.onTextClear,
      this.onActionTap,
      this.action,
      this.maxHeight = 60,
      this.innerPadding = const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      this.outSideColor = Colors.white,
      this.innerColor = const Color(0xfff8f8f8),
      this.normalBorder,
      this.activeBorder,
      this.borderRadius = const BorderRadius.all(const Radius.circular(6.0)),
      this.focusNode,
      this.autoFocus = false,
      this.textInputAction,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchTextState();
  }
}

class _SearchTextState extends State<BrnSearchText> {
  FocusNode focusNode;
  TextEditingController textEditingController;
  BoxBorder border;
  BrnSearchTextController searchTextController;

  BrnSearchTextController tmpController;

  @override
  void initState() {
    super.initState();

    if (widget.searchController == null) {
      tmpController = BrnSearchTextController();
    }
    searchTextController = widget.searchController ?? tmpController;
    searchTextController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    focusNode = widget.focusNode ?? FocusNode();
    textEditingController = widget.controller ?? TextEditingController();
    border = widget.normalBorder ??
        Border.all(
          width: 1.0,
          color: widget.innerColor,
        );

    focusNode.addListener(_handleFocusNodeChangeListenerTick);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tmpController?.dispose();
    focusNode.removeListener(_handleFocusNodeChangeListenerTick);
  }

  /// 焦点状态回到，用于刷新当前 UI
  void _handleFocusNodeChangeListenerTick() {
    if (focusNode.hasFocus) {
      border = widget.activeBorder ?? border;
    } else {
      border = widget.normalBorder ?? border;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
      ),
      child: Container(
        padding: widget.innerPadding,
        color: widget.outSideColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.innerColor,
                  border: border,
                  // 边界半径（`borderRadius`）属性，对此容器框的角进行舍入。
                  borderRadius: widget.borderRadius,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    widget.prefixIcon ??
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Center(
                            child: Container(
                                child: Image.asset(
                              'assets/${BrnAsset.ICON_SEARCH}',
                              package: BrnStrings.flutterPackageName,
                              height: 16,
                              width: 16,
                            )),
                          ),
                        ),
                    Expanded(
                      child: TextField(
                          maxLength: widget.maxLength,
                          autofocus: widget.autoFocus,
                          textInputAction: this.widget.textInputAction,
                          focusNode: focusNode,
                          // 控制器属性，控制正在编辑的文本。
                          controller: textEditingController,
                          // 光标颜色属性，绘制光标时使用的颜色。
                          cursorColor:
                              BrnThemeConfigurator.instance.getConfig().commonConfig.brandPrimary,
                          // 光标宽度属性，光标的厚度，默认是2.0。
                          cursorWidth: 2.0,
                          // 样式属性，用于正在编辑的文本的样式。
                          style: widget.textStyle ??
                              TextStyle(
                                  textBaseline: TextBaseline.alphabetic,
                                  color: BrnThemeConfigurator.instance
                                      .getConfig()
                                      .commonConfig
                                      .colorTextBase,
                                  fontSize: 16),
                          // 装饰（`decoration`）属性，在文本字段周围显示的装饰。
                          decoration: InputDecoration(
                            // 边框属性，装饰的容器周围绘制的形状。
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 8, right: 6),
                            // 填充颜色属性，填充装饰容器的颜色。
                            fillColor: widget.innerColor,
                            // 是密集属性，输入子项是否是密集形式的一部分（即使用较少的垂直空间）。
                            isDense: true,
                            // 填充属性，如果为`true`，则装饰的容器将填充fillColor颜色。
                            filled: true,
                            // 提示样式属性，用于提示文本（`hintText`）的样式。
                            hintStyle: widget.hintStyle ??
                                TextStyle(
                                  fontSize: 16,
                                  height: 1,
                                  textBaseline: TextBaseline.alphabetic,
                                  color: Color(0xff999999),
                                ),
                            // 提示文本属性，提示字段接受哪种输入的文本。
                            hintText: widget.hintText ?? "请输入搜索内容",
                            // 不显示计数面板
                            counterText: '',
                          ),
                          // 在改变属性，当正在编辑的文本发生更改时调用。
                          onChanged: (content) {
                            if (widget.onTextChange != null) {
                              widget.onTextChange(content);
                            }
                            setState(() {});
                          },
                          onSubmitted: (content) {
                            if (widget.onTextCommit != null) {
                              widget.onTextCommit(content);
                            }
                          }),
                    ),
                    Visibility(
                      visible: searchTextController.isClearShow,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onTextClear != null) {
                            bool isIntercept = widget.onTextClear() ?? false;
                            if (isIntercept) return;
                          }
                          textEditingController.clear();
                          if (this.widget.onTextChange != null) {
                            this.widget.onTextChange(textEditingController.value.text);
                          }
                          setState(() {});
                        },
                        child: Visibility(
                          visible: textEditingController.text.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: BrunoTools.getAssetImage(
                              BrnAsset.ICON_DELETE_TEXT,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: searchTextController.isActionShow,
              child: widget.action ??
                  GestureDetector(
                    onTap: () {
                      if (widget.onActionTap != null) {
                        widget.onActionTap();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text(
                        '取消',
                        style: TextStyle(
                            color: BrnThemeConfigurator.instance
                                .getConfig()
                                .commonConfig
                                .colorTextBase,
                            fontSize: 16,
                            height: 1),
                      ),
                    ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}

/// 搜索框控制类，用于控制 清除 icon（x）、取消按钮的展示 隐藏
class BrnSearchTextController extends ChangeNotifier {
  bool _isClearShow = true;
  bool _isActionShow = false;

  bool get isClearShow => _isClearShow;

  bool get isActionShow => _isActionShow;

  /// 设置清除 icon 的展示隐藏
  set isClearShow(bool value) {
    _isClearShow = value;
    notifyListeners();
  }

  /// 设置取消按钮的展示隐藏
  set isActionShow(bool value) {
    _isActionShow = value;
    notifyListeners();
  }
}
