import 'package:flutter/material.dart';

RouteObserver<PageRoute> _routeObserver;

void setRouteObserver(RouteObserver<PageRoute> routeObserver) {
  _routeObserver = routeObserver;
}

RouteObserver<PageRoute> getRouteObserver() {
  if (_routeObserver == null) {
    _routeObserver = RouteObserver<PageRoute>();
  }
  return _routeObserver;
}

class RouteAwareWidget extends StatefulWidget {
  final String name;
  final Widget child;

  RouteAwareWidget(this.name, {@required this.child});

  @override
  State<RouteAwareWidget> createState() => _RouteAwareWidgetState();
}

class _RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getRouteObserver().subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    getRouteObserver().unsubscribe(this);
    super.dispose();
  }

  @override
  // Called when the current route has been pushed.
  void didPush() {}

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {}

  @override
  Widget build(BuildContext context) => widget.child;
}
