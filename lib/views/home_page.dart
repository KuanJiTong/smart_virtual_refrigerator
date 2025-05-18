import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/login_viewmodel.dart';
import '../views/login_view.dart'; 
import '../../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signout = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await signout.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginView()),
              );
            },
            tooltip: 'Sign Out', 
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search recipe',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Recipes you can make',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Icon(Icons.tune),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Expiring soon',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://p3-pc-sign.douyinpic.com/tos-cn-i-0813/oEI5tAfqNcIAkc9BAxgeENFEYGA6AnxjDAAXCh~tplv-dy-aweme-images:q75.webp?biz_tag=aweme_images&from=327834062&lk3s=138a59ce&s=PackSourceEnum_SEARCH&sc=image&se=false&x-expires=1750053600&x-signature=lH4UpxReCL0OQMJMLP9eRWASGMI%3D',
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello! 👋',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Welcome back', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        )
      ],
    );
  }
}
