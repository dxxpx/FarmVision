import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryHistoryPage extends StatelessWidget {
  Future<void> _closeQuery(String queryId) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(queryId)
        .update({
      'status': 'closed',
      'canReply': false, // Prevent further replies after closing the query
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Query History'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        // Filter the queries by the current user's ID
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('authorId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var queries = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: queries.length,
            itemBuilder: (context, index) {
              var query = queries[index];
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Posted by ${query['author']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Status: ${query['status']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  // Close option only appears if the query is still open
                  trailing: query['status'] == 'open'
                      ? IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            await _closeQuery(query.id);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
