import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/profile_viewmodel.dart';

import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';

class ManageProfilePage extends StatelessWidget {
  const ManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signout = Provider.of<LoginViewModel>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadUserData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Profile'),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12), // Adjust radius as needed
              ),
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await signout.signOut();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
                tooltip: 'Logout',
              )
            )
          ],
        ),
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

                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await viewModel.updateName();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name updated')));
                      },
                      child: const Text('Save Name'),
                    ),
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

                  Center(
                    child: ElevatedButton(
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    profileVM.loadUserData();
    final userName = profileVM.user?.name ?? 'Guest';
    final imageUrl = profileVM.user?.imageUrl;

    return Container(
      height: 100,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                imageUrl ?? 'https://p3-pc-sign.douyinpic.com/tos-cn-i-0813/oEI5tAfqNcIAkc9BAxgeENFEYGA6AnxjDAAXCh~tplv-dy-aweme-images:q75.webp?biz_tag=aweme_images&from=327834062&lk3s=138a59ce&s=PackSourceEnum_SEARCH&sc=image&se=false&x-expires=1750053600&x-signature=lH4UpxReCL0OQMJMLP9eRWASGMI%3D',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $userName 👋',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Welcome back, $userName' , style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

