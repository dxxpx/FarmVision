import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryDetailPage extends StatefulWidget {
  final String commentId;

  QueryDetailPage(this.commentId);

  @override
  _QueryDetailPageState createState() => _QueryDetailPageState();
}

class _QueryDetailPageState extends State<QueryDetailPage> {
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String> _getUsername(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['email'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown';
    }
  }

  Future<void> _addResponse() async {
    if (currentUser != null) {
      // Check if the query is closed
      var commentDoc = await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .get();
      if (commentDoc.exists && commentDoc['status'] == 'closed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('This query is closed. You cannot add a response.')),
        );
        return;
      }

      String username = await _getUsername(currentUser!.uid);

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .collection('responses')
          .add({
        'text': _responseController.text,
        'author': username,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0, // Initialize likes count
        'dislikes': 0, // Initialize dislikes count
      });
      _responseController.clear();
    }
  }

  Future<void> _addReply(String responseId) async {
    if (currentUser != null) {
      var commentDoc = await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .get();
      if (commentDoc.exists && commentDoc['status'] == 'closed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This query is closed. You cannot reply.')),
        );
        return;
      }

      String username = await _getUsername(currentUser!.uid);

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .collection('responses')
          .doc(responseId)
          .collection('replies')
          .add({
        'text': _replyController.text,
        'author': username,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _replyController.clear();
    }
  }

  Future<void> _closeQuery() async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .update({'status': 'closed'});
    }
  }

  Future<void> _likeResponse(String responseId) async {
    if (currentUser != null) {
      var responseDoc = await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .collection('responses')
          .doc(responseId)
          .get();

      if (responseDoc.exists) {
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(widget.commentId)
            .collection('responses')
            .doc(responseId)
            .update({
          'likes': FieldValue.increment(1),
        });

        // Update user's points
        String authorId = responseDoc['authorId'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authorId)
            .update({
          'points': FieldValue.increment(100),
        });
      }
    }
  }

  Future<void> _dislikeResponse(String responseId) async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.commentId)
          .collection('responses')
          .doc(responseId)
          .update({
        'dislikes': FieldValue.increment(1),
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _getInitials(String username) {
    final words = username.split(' ');
    final initials = words.map((word) => word.isNotEmpty ? word[0] : '').join();
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Details'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .doc(widget.commentId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var comment = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comment['imageURL'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Image.network(comment['imageURL']),
                  ),
                Text(
                  comment['text'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(_getInitials(comment['author'] ?? '')),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Posted by ${comment['author']}',
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Timestamp: ${_formatTimestamp(comment['timestamp'] as Timestamp?)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .doc(widget.commentId)
                              .collection('responses')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> responseSnapshot) {
                            if (!responseSnapshot.hasData)
                              return Center(child: CircularProgressIndicator());
                            return ListView.builder(
                              itemCount: responseSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var response =
                                    responseSnapshot.data!.docs[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                child: Text(_getInitials(
                                                    response['author'] ?? '')),
                                                backgroundColor: Colors.teal,
                                                foregroundColor: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      response['author'] ?? '',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                        response['text'] ?? ''),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      'Timestamp: ${_formatTimestamp(response['timestamp'] as Timestamp?)}',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.thumb_up),
                                                          onPressed: () =>
                                                              _likeResponse(
                                                                  response.id),
                                                        ),
                                                        Text(
                                                            '${response['likes'] ?? 0}'),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.thumb_down),
                                                          onPressed: () =>
                                                              _dislikeResponse(
                                                                  response.id),
                                                        ),
                                                        Text(
                                                            '${response['dislikes'] ?? 0}'),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('comments')
                                                .doc(widget.commentId)
                                                .collection('responses')
                                                .doc(response.id)
                                                .collection('replies')
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    replySnapshot) {
                                              if (!replySnapshot.hasData)
                                                return Container();
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: replySnapshot
                                                    .data!.docs.length,
                                                itemBuilder:
                                                    (context, replyIndex) {
                                                  var reply = replySnapshot
                                                      .data!.docs[replyIndex];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Card(
                                                      elevation: 1,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CircleAvatar(
                                                                  child: Text(
                                                                      _getInitials(
                                                                          reply['author'] ??
                                                                              '')),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .teal,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        reply['author'] ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              4),
                                                                      Text(reply[
                                                                              'text'] ??
                                                                          ''),
                                                                      SizedBox(
                                                                          height:
                                                                              4),
                                                                      Text(
                                                                        'Timestamp: ${_formatTimestamp(reply['timestamp'] as Timestamp?)}',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          if (comment['status'] == 'open') ...[
                                            SizedBox(height: 10),
                                            TextField(
                                              controller: _replyController,
                                              decoration: InputDecoration(
                                                hintText: 'Add a reply...',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 2,
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _addReply(response.id),
                                              child: Text('Reply'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (comment['status'] == 'open') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: _responseController,
                            decoration: InputDecoration(
                              labelText: 'Add a Response',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _addResponse,
                          child: Text('Submit Response'),
                        ),
                        SizedBox(height: 20),
                        if (currentUser != null) ...[
                          ElevatedButton(
                            onPressed: _closeQuery,
                            child: Text('Close Query'),
                            style: ElevatedButton.styleFrom(
                                // Change button color if needed
                                ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
