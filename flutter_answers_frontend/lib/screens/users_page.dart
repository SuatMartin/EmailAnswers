import 'package:flutter/material.dart';
import '../services/fetch_users_service.dart';
import '../services/update_role_service.dart'; // Import the update role service
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admin_check_service.dart';


class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<List<User>> futureUsers;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    AdminCheckService.checkAdmin(context);
  }

  // Load the current user ID from SharedPreferences
  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('user_id'); // Retrieve user_id
    });
    futureUsers = fetchUsers();
  }

  Future<void> _showDeleteDialog(int userId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete User #$userId?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await deleteUser(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User #$userId deleted successfully')),
        );

        // Refresh the user list after deletion
        setState(() {
          futureUsers = fetchUsers();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }

  // Function to update the role of a user
  Future<void> _updateUserRole(int userId, String currentRole) async {
    String newRole = currentRole == 'user' ? 'admin' : 'user'; // Toggle role

    try {
      await updateUserRole(userId, newRole);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User #$userId role updated to $newRole')),
      );

      // Refresh the user list after role update
      setState(() {
        futureUsers = fetchUsers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<User> users = snapshot.data!;

            // Exclude the currently logged-in user
            users = users.where((user) => user.userId != currentUserId).toList();

            return ListView.separated(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: Colors.white,
                  title: Text('User #${index + 1}: ${users[index].username}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email: ${users[index].email}',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Role: ${users[index].role}', // Display the role here
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(users[index].userId);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.person_add_alt_1,
                          color: users[index].role == 'admin' ? Colors.blue : Colors.green,
                        ),
                        onPressed: () {
                          _updateUserRole(users[index].userId, users[index].role);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            );
          } else {
            return Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}