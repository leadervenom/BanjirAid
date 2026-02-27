import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.list), text: 'All Tickets'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OverviewTab(),
          AllTicketsTab(),
          AnalyticsTab(),
          SettingsTab(),
        ],
      ),
    );
  }
}

// Overview Tab
class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  String _stringField(DocumentSnapshot doc, String key) {
    final data = doc.data() as Map<String, dynamic>?;
    return (data?[key] ?? '').toString().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data!.docs;
        final totalTickets = tickets.length;
        final newTickets =
            tickets.where((t) => _stringField(t, 'status') == 'new').length;
        final assignedTickets =
            tickets.where((t) => _stringField(t, 'status') == 'assigned').length;
        final enRouteTickets =
            tickets.where((t) => _stringField(t, 'status') == 'en_route').length;
        final resolvedTickets =
            tickets.where((t) => _stringField(t, 'status') == 'resolved').length;
        final p1Tickets =
            tickets.where((t) => _stringField(t, 'priority') == 'p1').length;
        final p2Tickets =
            tickets.where((t) => _stringField(t, 'priority') == 'p2').length;
        final p3Tickets =
            tickets.where((t) => _stringField(t, 'priority') == 'p3').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.deepPurple.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.dashboard, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'System Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverviewStat(
                            'Total Tickets',
                            totalTickets.toString(),
                            Icons.inbox,
                          ),
                          _buildOverviewStat(
                            'Active',
                            (newTickets + assignedTickets + enRouteTickets)
                                .toString(),
                            Icons.trending_up,
                          ),
                          _buildOverviewStat(
                            'Resolved',
                            resolvedTickets.toString(),
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status Breakdown
              const Text(
                'Status Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'New',
                      newTickets.toString(),
                      Icons.new_releases,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Assigned',
                      assignedTickets.toString(),
                      Icons.assignment,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'En Route',
                      enRouteTickets.toString(),
                      Icons.directions_car,
                      Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Resolved',
                      resolvedTickets.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority Breakdown
              const Text(
                'Priority Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'P1 - Critical',
                      p1Tickets.toString(),
                      Icons.priority_high,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'P2 - High',
                      p2Tickets.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'P3 - Medium',
                p3Tickets.toString(),
                Icons.info,
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// All Tickets Tab
class AllTicketsTab extends StatefulWidget {
  const AllTicketsTab({Key? key}) : super(key: key);

  @override
  State<AllTicketsTab> createState() => _AllTicketsTabState();
}

class _AllTicketsTabState extends State<AllTicketsTab> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _priorityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('tickets');

    if (_statusFilter != 'all') {
      query = query.where('status', isEqualTo: _statusFilter);
    }

    if (_priorityFilter != 'all') {
      query = query.where('priority', isEqualTo: _priorityFilter);
    }

    query = query.orderBy('created_at', descending: true);

    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search tickets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'new', child: Text('New')),
                        DropdownMenuItem(
                            value: 'assigned', child: Text('Assigned')),
                        DropdownMenuItem(
                            value: 'en_route', child: Text('En Route')),
                        DropdownMenuItem(
                            value: 'resolved', child: Text('Resolved')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priorityFilter,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'p1', child: Text('P1')),
                        DropdownMenuItem(value: 'p2', child: Text('P2')),
                        DropdownMenuItem(value: 'p3', child: Text('P3')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _priorityFilter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tickets List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var tickets = snapshot.data!.docs;

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                tickets = tickets.where((ticket) {
                  final data = ticket.data() as Map<String, dynamic>;
                  final message = (data['raw_message'] ?? '').toLowerCase();
                  final location =
                      (data['location_text'] ?? '').toLowerCase();
                  return message.contains(_searchQuery) ||
                      location.contains(_searchQuery) ||
                      ticket.id.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              if (tickets.isEmpty) {
                return const Center(child: Text('No tickets found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final data = ticket.data() as Map<String, dynamic>;
                  return _buildAdminTicketCard(ticket.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminTicketCard(String ticketId, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPriorityColor(data['priority']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIncidentIcon(data['incident_type']),
            color: _getPriorityColor(data['priority']),
          ),
        ),
        title: Text(
          '#${ticketId.substring(0, 8)} - ${(data['incident_type'] ?? 'Unknown').toString().toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${data['status']?.toString().toUpperCase() ?? 'NEW'} | ${_formatTimestamp(data['created_at'])}',
        ),
        trailing: data['priority'] != null
            ? Chip(
                label: Text(
                  data['priority'].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: _getPriorityColor(data['priority']),
                padding: EdgeInsets.zero,
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Message', data['raw_message'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow('Location', data['location_text'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'People', data['people_count']?.toString() ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Water Level', data['water_level']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateTicketStatus(ticketId, data),
                        icon: const Icon(Icons.edit),
                        label: const Text('Update Status'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteTicket(ticketId),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'p1':
        return Colors.red;
      case 'p2':
        return Colors.orange;
      case 'p3':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getIncidentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'rescue':
        return Icons.emergency;
      case 'medical':
        return Icons.local_hospital;
      case 'supplies':
        return Icons.inventory;
      case 'hazard':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, HH:mm').format(timestamp.toDate());
    }
    return 'N/A';
  }

  Future<void> _updateTicketStatus(
      String ticketId, Map<String, dynamic> data) async {
    final statuses = [
      'new',
      'triaged',
      'assigned',
      'en_route',
      'resolved',
      'closed'
    ];
    final currentStatus = data['status'] as String?;

    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select New Status'),
        children: statuses
            .map((status) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, status),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: status == currentStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ))
            .toList(),
      ),
    );

    if (newStatus != null) {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.toUpperCase()}')),
        );
      }
    }
  }

  Future<void> _deleteTicket(String ticketId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket deleted')),
        );
      }
    }
  }
}

// Analytics Tab
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Advanced analytics and reporting features coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Manage Teams'),
            subtitle: const Text('Add and edit rescue teams'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Manage Zones'),
            subtitle: const Text('Configure coverage zones'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.security),
            title: const Text('User Permissions'),
            subtitle: const Text('Manage roles and access'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit Logs'),
            subtitle: const Text('View system activity'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }
}

