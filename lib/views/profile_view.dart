import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/profile_viewmode.dart';

class ManageProfilePage extends StatelessWidget {
  const ManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadUserData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage Profile')),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            final user = viewModel.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Take Photo"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    viewModel.pickAndUploadProfileImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text("Choose from Gallery"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    viewModel.pickAndUploadProfileImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : null,
                        child: user.imageUrl == null
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Profile Info',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: TextEditingController(text: user.email),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: viewModel.nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.updateName();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name updated')));
                    },
                    child: const Text('Save Name'),
                  ),

                  const Divider(height: 40),

                  const Text('Change Password',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: viewModel.oldPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Old Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: viewModel.newPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: viewModel.confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Confirm New Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      final result = await viewModel.changePassword();
                      final snackBar = SnackBar(
                        content:
                            Text(result ?? 'Password updated successfully'),
                        backgroundColor:
                            result == null ? Colors.green : Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text('Change Password'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

