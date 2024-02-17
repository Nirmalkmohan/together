import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({
    super.key,
  });

  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<dynamic> items = [];
  int currentPage = 1;
  int limit = 10;
  bool isLoading = false;
  bool reachedEnd = false;

  late ScrollController _scrollController; // ScrollController

  @override
  void initState() {
    super.initState();
//Call API function here
    _fetchData();

    _scrollController = ScrollController(); // Initialize ScrollController
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  /// Fetches data from an API endpoint and updates the state based on the response.
  Future<void> _fetchData() async {
    if (!isLoading && !reachedEnd) {
      setState(() {
        isLoading = true;
      });

      final Uri uri = Uri.parse(
          'https://api-stg.together.buzz/mocks/discovery?page=$currentPage&limit=$limit');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          List<dynamic> newItems = responseData['data'];
          if (newItems.isEmpty) {
            setState(() {
              reachedEnd = true;
            });
          } else {
            setState(() {
              items.addAll(newItems);
              currentPage++;
              isLoading = false;
            });
          }
        } else {
          // Handle unexpected response format
          print('Unexpected data format in response: ${responseData['data']}');
          _showErrorDialog('Unexpected data format');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Handle API error
        print('Error fetching data: ${response.statusCode}');
        _showErrorDialog('API Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Shows an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows an image dialog with the provided image URL.
  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog when tapped
            },
            child: SizedBox(
              width: double.infinity,
              child: Image.network(imageUrl),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Discovery Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              !reachedEnd &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchData();
          }
          return true;
        },
        child: ListView.builder(
          controller: _scrollController, // Assign ScrollController to ListView
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              final item = items[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    child: SizedBox(
                      height: 100,
                      child: ListTile(
                        title: Text(item['title']),
                        subtitle: Text(item['description'] ?? ''),
                        leading: item['image_url'] != null
                            ? GestureDetector(
                                onTap: () {
                                  _showImage(context, item['image_url']);
                                },
                                child: Image.network(
                                  item['image_url'],
                                  width: 60,
                                  height: 75,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            } else if (reachedEnd) {
              // Display "End of list" text when no more items to load
              return const Center(child: Text('End of list'));
            } else {
              // Show loading indicator while fetching more items
              return Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipOval(
            child: FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: Colors.deepPurple, // Set background color
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white, // Set icon color
              ),
            ),
          ),
          const SizedBox(height: 16), // Spacer between buttons
          ClipOval(
            child: FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: Colors.deepPurple, // Set background color
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.white, // Set icon color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
