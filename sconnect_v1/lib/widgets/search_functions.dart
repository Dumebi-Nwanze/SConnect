import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sconnect_v1/helpers/search_api.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';

class UsersSearch extends SearchDelegate {
  UsersSearch({
    required String hintText,
  });
  static List<UserModel> recentSearches = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query == "") {
            Navigator.of(context).pop();
          } else {
            query = "";
          }
        },
        icon: const Icon(
          Icons.clear,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
        future: SearchApi.getUsers(query),
        builder: (context, snapshot) {
          if (query.isEmpty) {
            return recentSearches.isEmpty
                ? Container()
                : StatefulBuilder(builder: (context, StateSetter setState) {
                    return ListView.builder(
                        itemCount: recentSearches.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    profileId: recentSearches[index].uid,
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              recentSearches[index].name,
                            ),
                            subtitle: Text(
                              recentSearches[index].username,
                            ),
                            leading: recentSearches[index].photoUrl == ""
                                ? const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: AssetImage(
                                      'assets/default_profilepic.jpg',
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(
                                      recentSearches[index].photoUrl,
                                    ),
                                  ),
                            trailing: TextButton(
                              child: const Text(
                                "Clear",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                if (recentSearches
                                    .contains(recentSearches[index])) {
                                  recentSearches.remove(
                                    recentSearches[index],
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        });
                  });
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.black,
                ),
              );
            } else if (snapshot.hasError || snapshot.data!.isEmpty) {
              return Container();
            } else {
              final List<UserModel> suggestions =
                  snapshot.data as List<UserModel>;
              return StatefulBuilder(builder: (context, StateSetter setState) {
                return ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        if (!recentSearches.contains(suggestions[index])) {
                          recentSearches.add(suggestions[index]);
                          setState(() {});
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              profileId: suggestions[index].uid,
                            ),
                          ),
                        );
                      },
                      title: Text(
                        suggestions[index].name,
                      ),
                      subtitle: Text(
                        suggestions[index].username,
                      ),
                      leading: suggestions[index].photoUrl == ""
                          ? const CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: AssetImage(
                                'assets/default_profilepic.jpg',
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                suggestions[index].photoUrl,
                              ),
                            ),
                    );
                  },
                );
              });
            }
          }
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: usersRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            );
          } else if (snapshot.data!.docs
              .where((user) => user['username']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList()
              .isEmpty) {
            return Center(
              child: Text(
                "Sorry, there are no results for '${query}'",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            );
          } else {
            List<UserModel> users = snapshot.data!.docs
                .where((user) => user['username']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList()
                .map((user) => UserModel.fromSnap(user))
                .toList();

            return StatefulBuilder(builder: (context, StateSetter setState) {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      if (!recentSearches.contains(users[index])) {
                        recentSearches.add(users[index]);
                        setState(() {});
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            profileId: users[index].uid.toString(),
                          ),
                        ),
                      );
                    },
                    title: Text(
                      users[index].name,
                    ),
                    subtitle: Text(users[index].username),
                    leading: users[index].photoUrl == ""
                        ? const CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: AssetImage(
                              'assets/default_profilepic.jpg',
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                NetworkImage(users[index].photoUrl),
                          ),
                  );
                },
              );
            });
          }
        });
  }
}
