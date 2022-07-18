import 'package:flutter/material.dart';
import 'package:sconnect_v1/widgets/search_functions.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List recents = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: UsersSearch(hintText: "Search Users"),
              );
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.withOpacity(0.3),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.search,
                      color: Colors.black87,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Search Users",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
            preferredSize: const Size.fromHeight(4),
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
