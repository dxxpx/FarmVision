import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmvision/Screens/query_pages/query_detail_page.dart';
import 'package:farmvision/Screens/query_pages/new_query_page.dart';
import 'package:farmvision/Screens/query_pages/query_history.dart'; // Import the new history page
import 'package:intl/intl.dart'; // For formatting timestamps

class QueryListPage extends StatefulWidget {
  @override
  _QueryListPageState createState() => _QueryListPageState();
}

class _QueryListPageState extends State<QueryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime).inHours;
    return '$difference hours ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Queries'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search queries...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('comments').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var filteredQueries = snapshot.data!.docs.where((query) {
                  var queryText = query['text'].toLowerCase();
                  return queryText.contains(_searchText);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: filteredQueries.length,
                  itemBuilder: (context, index) {
                    var query = filteredQueries[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            query['author']?[0] ??
                                'U', // Display first letter of username
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          query['text'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (query['imageURL'] != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Image.network(query['imageURL']),
                                ),
                              SizedBox(height: 4),
                              Text(
                                'Posted ${_formatTimestamp(query['timestamp'] as Timestamp?)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Status: ${query['status']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QueryDetailPage(query.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QueryHistoryPage()),
              );
            },
            backgroundColor: Colors.teal,
            child: Icon(Icons.history),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewQueryPage()),
              );
            },
            backgroundColor: Colors.teal,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
