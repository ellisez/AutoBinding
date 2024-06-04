import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_binding/core/dependent_manager.dart';
import 'package:auto_binding/core/data_inject.dart';

class BindingTextField<P extends ShouldNotifyDependents, T>
    extends StatefulWidget {
  final Binding<P, T> binding;
  final String Function(T)? valueToString;
  final T Function(String)? stringToValue;

  BindingTextField(
    this.binding, {
    this.valueToString,
    this.stringToValue,
    super.key,
    this.focusNode,
    this.undoController,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    this.toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  });

  final TextMagnifierConfiguration? magnifierConfiguration;

  final FocusNode? focusNode;

  final InputDecoration? decoration;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle? style;

  final StrutStyle? strutStyle;

  final TextAlign textAlign;

  final TextAlignVertical? textAlignVertical;

  final TextDirection? textDirection;

  final bool autofocus;

  final String obscuringCharacter;

  final bool obscureText;

  final bool autocorrect;

  final SmartDashesType? smartDashesType;

  final SmartQuotesType? smartQuotesType;

  final bool enableSuggestions;

  final int? maxLines;

  final int? minLines;

  final bool expands;

  final bool readOnly;

  @Deprecated(
    'Use `contextMenuBuilder` instead. '
    'This feature was deprecated after v3.3.0-0.5.pre.',
  )
  final ToolbarOptions? toolbarOptions;

  final bool? showCursor;

  final int? maxLength;

  final MaxLengthEnforcement? maxLengthEnforcement;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onEditingComplete;

  final ValueChanged<String>? onSubmitted;

  final AppPrivateCommandCallback? onAppPrivateCommand;

  final List<TextInputFormatter>? inputFormatters;

  final bool? enabled;

  final double cursorWidth;

  final double? cursorHeight;

  final Radius? cursorRadius;

  final bool? cursorOpacityAnimates;

  final Color? cursorColor;

  final ui.BoxHeightStyle selectionHeightStyle;

  final ui.BoxWidthStyle selectionWidthStyle;

  final Brightness? keyboardAppearance;

  final EdgeInsets scrollPadding;

  final bool? enableInteractiveSelection;

  final TextSelectionControls? selectionControls;

  final DragStartBehavior dragStartBehavior;

  final GestureTapCallback? onTap;

  final TapRegionCallback? onTapOutside;

  final MouseCursor? mouseCursor;

  final InputCounterWidgetBuilder? buildCounter;

  final ScrollPhysics? scrollPhysics;

  final ScrollController? scrollController;

  final Iterable<String>? autofillHints;

  final Clip clipBehavior;

  final String? restorationId;

  final bool scribbleEnabled;

  final bool enableIMEPersonalizedLearning;

  final ContentInsertionConfiguration? contentInsertionConfiguration;

  final EditableTextContextMenuBuilder? contextMenuBuilder;

  final bool canRequestFocus;

  final UndoHistoryController? undoController;

  final SpellCheckConfiguration? spellCheckConfiguration;

  @override
  State<StatefulWidget> createState() => _BindingTextFieldState<T>();
}

class _BindingTextFieldState<T> extends State<BindingTextField> {
  late TextEditingController _controller;

  late String Function(T) valueToString;
  late Function(String) stringToValue;
  late ValueSetter<String> onChanged;

  void _changeWidget() {
    valueToString = widget.valueToString ?? (T t) => t as String;
    stringToValue = widget.stringToValue ?? (String text) => text as T;
    onChanged = (String text) {
      widget.binding.value = stringToValue(text);
      if (widget.onChanged != null) {
        widget.onChanged!(text);
      }
    };
  }

  void _bindController() {
    widget.binding.bindValueNotifier<TextEditingValue>(
      _controller,
      covertToValue: (t) {
        var text = valueToString(t);
        return _controller.text == text
            ? _controller.value
            : _controller.value.copyWith(
                text: text,
              );
      },
      valueCovertTo: (v) => stringToValue(v.text) as T,
    );
  }

  void _unbindController(BindingTextField oldWidget) {
    oldWidget.binding.unbindNotifier(_controller);
  }

  @override
  void didUpdateWidget(BindingTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unbindController(oldWidget);
    _changeWidget();
    _bindController();
  }

  @override
  void initState() {
    _changeWidget();
    _controller =
        TextEditingController(text: valueToString(widget.binding.raw));
    _bindController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      undoController: widget.undoController,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      contextMenuBuilder: widget.contextMenuBuilder,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      scribbleEnabled: widget.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      canRequestFocus: widget.canRequestFocus,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
