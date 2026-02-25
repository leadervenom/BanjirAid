import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'submit_request_screen.dart';
import 'my_requests_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({Key? key}) : super(key: key);

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  final _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CitizenDashboard(),
    SubmitRequestScreen(),
    MyRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ReliefRouter - Citizen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Submit Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Requests',
          ),
        ],
      ),
    );
  }
}

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.blue.shade700,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  user?.email?.split('@')[0] ?? 'Citizen',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'In case of life-threatening emergency, call 999 immediately',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Request Button
              _buildActionButton(
                context: context,
                title: 'Submit Help Request',
                subtitle: 'Report flood emergency',
                icon: Icons.emergency,
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubmitRequestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // View My Requests
              _buildActionButton(
                context: context,
                title: 'My Requests',
                subtitle: 'Track your submissions',
                icon: Icons.list_alt,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyRequestsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Safety Tips
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Safety Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSafetyTip(
                        '• Move to higher ground immediately',
                      ),
                      _buildSafetyTip(
                        '• Do not walk or drive through floodwater',
                      ),
                      _buildSafetyTip(
                        '• Keep emergency supplies ready',
                      ),
                      _buildSafetyTip(
                        '• Stay informed via official channels',
                      ),
                      _buildSafetyTip(
                        '• Help vulnerable neighbors if safe to do so',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Contacts
              Card(
                elevation: 4,
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.phone_in_talk,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEmergencyContact('Emergency Services', '999'),
                      _buildEmergencyContact('NADMA Hotline', '1-800-88-3023'),
                      _buildEmergencyContact(
                          'Civil Defense', '991'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        tip,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildEmergencyContact(String label, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

