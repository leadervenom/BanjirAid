import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({Key? key}) : super(key: key);

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  final _authService = AuthService();
  String _selectedFilter = 'all';
  String _selectedPriority = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rescue Team Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
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
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: _buildStatsSection(),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    'All',
                    'all',
                    Icons.list,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'New',
                    'new',
                    Icons.new_releases,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Assigned',
                    'assigned',
                    Icons.assignment,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'En Route',
                    'en_route',
                    Icons.directions_car,
                  ),
                ),
              ],
            ),
          ),

          // Priority Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Priority: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildPriorityChip('All', 'all'),
                const SizedBox(width: 8),
                _buildPriorityChip('P1', 'p1'),
                const SizedBox(width: 8),
                _buildPriorityChip('P2', 'p2'),
                const SizedBox(width: 8),
                _buildPriorityChip('P3', 'p3'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tickets List
          Expanded(
            child: _buildTicketsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tickets = snapshot.data!.docs;
        final newCount =
            tickets.where((t) => t['status'] == 'new').length;
        final assignedCount =
            tickets.where((t) => t['status'] == 'assigned').length;
        final enRouteCount =
            tickets.where((t) => t['status'] == 'en_route').length;
        final p1Count =
            tickets.where((t) => t['priority'] == 'p1').length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'New',
                newCount.toString(),
                Icons.new_releases,
                Colors.blue.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Assigned',
                assignedCount.toString(),
                Icons.assignment,
                Colors.purple.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En Route',
                enRouteCount.toString(),
                Icons.directions_car,
                Colors.indigo.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'P1',
                p1Count.toString(),
                Icons.priority_high,
                Colors.red.shade300,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value) {
    final isSelected = _selectedPriority == value;
    Color color;
    switch (value) {
      case 'p1':
        color = Colors.red;
        break;
      case 'p2':
        color = Colors.orange;
        break;
      case 'p3':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    Query query = FirebaseFirestore.instance.collection('tickets');

    // Apply status filter
    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    // Apply priority filter
    if (_selectedPriority != 'all') {
      query = query.where('priority', isEqualTo: _selectedPriority);
    }

    // Order by priority and time
    query = query.orderBy('created_at', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data?.docs ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No tickets found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            final data = ticket.data() as Map<String, dynamic>;
            return _buildTicketCard(ticket.id, data);
          },
        );
      },
    );
  }

  Widget _buildTicketCard(String ticketId, Map<String, dynamic> data) {
    final priority = data['priority'] as String?;
    final status = data['status'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPriorityColor(priority).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showTicketDetails(ticketId, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (priority != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              priority.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            '#${ticketId.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (status ?? 'new').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Incident Type
              if (data['incident_type'] != null)
                Row(
                  children: [
                    Icon(
                      _getIncidentIcon(data['incident_type']),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (data['incident_type'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Message
              Text(
                data['raw_message'] ?? 'No message',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Location and Details
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data['location_text'] ?? 'No location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (data['people_count'] != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${data['people_count']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Timestamp
              Text(
                _formatTimestamp(data['created_at']),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'triaged':
        return Colors.orange;
      case 'assigned':
        return Colors.purple;
      case 'en_route':
        return Colors.indigo;
      case 'resolved':
        return Colors.green;
      case 'needs_review':
        return Colors.amber;
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
      case 'information':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMM dd, HH:mm').format(date);
    }
    return 'N/A';
  }

  void _showTicketDetails(String ticketId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketDetailsSheet(ticketId: ticketId, data: data),
    );
  }
}

// Ticket Details Bottom Sheet
class TicketDetailsSheet extends StatelessWidget {
  final String ticketId;
  final Map<String, dynamic> data;

  const TicketDetailsSheet({
    Key? key,
    required this.ticketId,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Actions
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ticket Details',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID: $ticketId',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Full ticket details would go here
                    // Similar to citizen's view but with action buttons

                    // Action Buttons
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final currentStatus = data['status'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentStatus == 'new' || currentStatus == 'triaged')
          ElevatedButton.icon(
            onPressed: () => _updateStatus(context, 'assigned'),
            icon: const Icon(Icons.assignment),
            label: const Text('Assign to Me'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.purple,
            ),
          ),
        if (currentStatus == 'assigned')
          ElevatedButton.icon(
            onPressed: () => _updateStatus(context, 'en_route'),
            icon: const Icon(Icons.directions_car),
            label: const Text('Mark En Route'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.indigo,
            ),
          ),
        if (currentStatus == 'en_route')
          ElevatedButton.icon(
            onPressed: () => _updateStatus(context, 'resolved'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark Resolved'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
            ),
          ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}



