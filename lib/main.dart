import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyAppSJCHSuqWgomnq_2H5xtyvW3_CPKEpM",
              appId: "1:100063994790:android:0f22c515131e4c09d42567",
              messagingSenderId: "100063994790",
              projectId: "mobileapi-2f80e"))
      : await Firebase.initializeApp();

  runApp(MyApp());
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // After signing in, navigate to the main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      print('Error signing in: $e');
      // Handle sign-in error as needed
      // You might want to show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    try {
      // Register with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // After registering, navigate to the main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print('Error registering: $e');
      // Handle registration error as needed
      // You might want to show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainApp();
  }

  Future<void> _navigateToMainApp() async {
    // Simulate any initialization tasks if needed

    // Wait for 2 seconds (or however long you want your splash screen to appear)
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to the main app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  List<String> _appBarTitles = ['Home', 'Search', 'CRUD', 'Account'];
  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http
        .get(Uri.parse('https://kitsu.io/api/edge/trending/anime'), headers: {
      'Accept': 'application/vnd.api+json',
    });

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      // Sorting anime based on rating
      data.sort((a, b) => b['attributes']['averageRating']
          .compareTo(a['attributes']['averageRating']));

      return data.take(10).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> fetchGenres(String animeId) async {
    final response = await http
        .get(Uri.parse('https://kitsu.io/api/edge/anime/$animeId/genres'));

    if (response.statusCode == 200) {
      List<String> genres = List<String>.from(json
          .decode(response.body)['data']
          .map((genre) => genre['attributes']['name'] as String));
      return genres;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  void _showDetailsScreen(Map<String, dynamic> anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailsScreen(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchFragment()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Page 0 (Home)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final anime = snapshot.data![index];
                    final imageUrl =
                        anime['attributes']['posterImage']['medium'];
                    final title = anime['attributes']['canonicalTitle'];
                    final rating = anime['attributes']['averageRating'];

                    return FutureBuilder<List<String>>(
                      future: fetchGenres(anime['id']),
                      builder: (context, genresSnapshot) {
                        if (genresSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: $rating'),
                                const Text('Genres: Loading...'),
                              ],
                            ),
                            leading: imageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                  )
                                : const Icon(Icons.image),
                          );
                        } else if (genresSnapshot.hasError) {
                          return ListTile(
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: $rating'),
                                const Text('Genres: Error'),
                              ],
                            ),
                            leading: imageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                  )
                                : const Icon(Icons.image),
                          );
                        } else {
                          List<String> genres = genresSnapshot.data ?? [];
                          return ListTile(
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: $rating'),
                                Text(
                                    'Genres: ${genres.isNotEmpty ? genres.join(', ') : 'N/A'}'),
                              ],
                            ),
                            leading: imageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                  )
                                : const Icon(Icons.image),
                            onTap: () => _showDetailsScreen(anime),
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          ),

          // Page 1 (Search)
          const SearchFragment(),

          // Page 2 (CRUD)
          CrudPage(),

          // Page 3 (Account)
          AccountInfoScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,
        selectedItemColor: Colors.blue[200],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'CRUD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }
}

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchFragmentState createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implementasi logika pencarian di sini
                    fetchSearchResults(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final anime = searchResults[index];
                final imageUrl = anime['attributes']['posterImage']['medium'];
                final title = anime['attributes']['canonicalTitle'];
                final rating = anime['attributes']['averageRating'];

                return ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating: $rating'),
                    ],
                  ),
                  leading: imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        )
                      : const Icon(Icons.image),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimeDetailsScreen(anime: anime),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSearchResults(String query) async {
    try {
      final List<Map<String, dynamic>> results =
          await fetchSearchResultsFromApi(query);
      print('Search results: $results');
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error fetching search results: $e');
      // Handle errors as needed
    }
  }

  Future<List<Map<String, dynamic>>> fetchSearchResultsFromApi(
      String query) async {
    final response = await http.get(
      Uri.parse('https://kitsu.io/api/edge/anime?filter[text]=$query'),
      headers: {
        'Accept': 'application/vnd.api+json',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      // Sorting anime based on rating

      return data;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}

class AnimeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> anime;

  AnimeDetailsScreen({required this.anime});

  @override
  Widget build(BuildContext context) {
    final imageUrl = anime['attributes']['posterImage']['original'];
    final title = anime['attributes']['canonicalTitle'];
    final rating = anime['attributes']['averageRating'];
    final description = anime['attributes']['description'];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl != null
                ? Image.network(imageUrl,
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            Text('Rating: $rating'),
            const SizedBox(height: 8),
            Text('Description: $description'),
          ],
        ),
      ),
    );
  }
}

class AccountInfoScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${_user?.email ?? 'N/A'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Sign out the user
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class CrudPage extends StatefulWidget {
  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _dataController = TextEditingController();
  late CollectionReference _crudCollection;
  List<Map<String, dynamic>> readResults = [];
  @override
  void initState() {
    super.initState();
    _crudCollection = _firestore.collection('crud_data');
  }

  Future<void> _addData() async {
    try {
      await _crudCollection.add({'data': _dataController.text});
      _dataController.clear();
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> _readData() async {
    try {
      QuerySnapshot querySnapshot = await _crudCollection.get();
      List<Map<String, dynamic>> results = [];
      querySnapshot.docs.forEach((doc) {
        results.add({'id': doc.id, 'data': doc['data']});
      });

      setState(() {
        readResults = results; // Update the read results list
      });
    } catch (e) {
      print('Error reading data: $e');
    }
  }

  Future<void> _updateData(String documentId, String newdata) async {
    try {
      await _crudCollection.doc(documentId).update({'data': newdata});
      _dataController.clear();
      _readData(); // Refresh the read results list
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  Future<void> _deleteData(String documentId) async {
    try {
      await _crudCollection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> _showEditDialog(String documentId, String currentData) async {
    String editedData = currentData; // Initialize with current data

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: TextField(
            onChanged: (value) {
              editedData = value; // Update edited data as the user types
            },
            controller: TextEditingController(text: currentData),
            decoration: InputDecoration(labelText: 'New Data'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _updateData(documentId,
                    editedData); // Call update method with edited data
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addData,
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: _readData,
                  child: const Text('Read'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            // Display read results
            Expanded(
              child: ListView.builder(
                itemCount: readResults.length,
                itemBuilder: (context, index) {
                  final data = readResults[index];
                  final documentId = data['id'];
                  final content = data['data'];

                  return ListTile(
                    title: Text('ID: $documentId, Data: $content'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(documentId, content),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteData(documentId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
