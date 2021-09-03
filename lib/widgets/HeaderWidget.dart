import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String strTitle = "",
    disappearedBackButton = false}) {
  return AppBar(
    elevation: 0,
    iconTheme: IconThemeData(
      color: Theme.of(context).hintColor,
    ),
    automaticallyImplyLeading: disappearedBackButton ? false : true,
    title: Text(
      isAppTitle ? "SosyalMedya" : strTitle,
      style: TextStyle(
          color: Theme.of(context).hintColor,
          fontFamily: isAppTitle ? "Signatra" : "",
          fontSize: isAppTitle ? 45 : 22),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).backgroundColor,
  );
}
