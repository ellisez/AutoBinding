part of binding;

abstract class ViewModel<T extends ViewBinder> {
  @protected
  final $widgetList = <Widget>[];
  @protected
  final $binderMap = <Widget, T>{};

  T createViewBinder();

  T getBinder(State state) {
    var binder = $binderMap[state.widget];
    if (binder == null) {
      binder = createViewBinder();
      $binderMap[state.widget] = binder;
      $widgetList.add(state.widget);
    } else {
      binder.dispose();
      binder = createViewBinder();
      $binderMap[state.widget] = binder;
    }
    return binder;
  }

  void didUpdateWidget(Widget oldWidget, Widget newWidget) {
    for (var i = 0; i < $widgetList.length; i++) {
      var widget = $widgetList[i];
      if (widget == oldWidget) {
        $widgetList[i] = newWidget;
        $binderMap.remove(oldWidget);
        $binderMap[newWidget] = createViewBinder();
        break;
      }
    }
  }

  void dispose(State state) {
    var widget = state.widget;
    if ($widgetList.remove(widget)) {
      $binderMap.remove(widget)?.dispose();
    }
  }

  void reset(State state) {
    var widget = state.widget;
    $binderMap[widget]?.dispose();
    $binderMap[widget] = createViewBinder();
  }
}

abstract class ViewBinder {
  void dispose();
}
