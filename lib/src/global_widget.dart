
  import 'package:flutter/material.dart';

Widget item(String str, Function fun) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          onTap: () {
            fun();
          },
          child: SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
                  child: Text(
                    str,
                    style: const TextStyle(
                      color: Color(0xff000000),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }