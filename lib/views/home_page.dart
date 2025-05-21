import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/login_viewmodel.dart';
import '../views/login_view.dart';
import 'fridge_page.dart'; // Make sure this path is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeBody(),
    const Center(child: Text('Favorites')),
    const FridgePage(),
    const Center(child: Text('Cart')),
    const Center(child: Text('Settings')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final signout = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await signout.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''), // FridgePage
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        children: [
          Row(
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
          ),
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
            children: const [
              Text('Expiring soon',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Spacer(),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}