import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
      case 'closed':
        return Colors.grey;
      case 'needs_review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('reporter_email', isEqualTo: user?.email)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
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
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submit a help request to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final data = ticket.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    _showTicketDetails(context, ticket.id, data);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Request #${ticket.id.substring(0, 8)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                        data['status'] ?? 'new')
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (data['status'] ?? 'new').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(
                                      data['status'] ?? 'new'),
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
                                (data['incident_type'] as String)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),

                        // Message Preview
                        Text(
                          data['raw_message'] ?? 'No message',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Priority and Timestamp
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (data['priority'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(data['priority'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data['priority'].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _getPriorityColor(data['priority']),
                                  ),
                                ),
                              ),
                            Text(
                              _formatTimestamp(data['created_at']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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
    );
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

  void _showTicketDetails(
      BuildContext context, String ticketId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Request Details',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ID: $ticketId',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Status
              _buildDetailRow(
                'Status',
                (data['status'] ?? 'new').toUpperCase(),
                icon: Icons.flag,
              ),
              const Divider(height: 32),

              // Priority
              if (data['priority'] != null) ...[
                _buildDetailRow(
                  'Priority',
                  data['priority'].toUpperCase(),
                  icon: Icons.priority_high,
                ),
                const Divider(height: 32),
              ],

              // Incident Type
              if (data['incident_type'] != null) ...[
                _buildDetailRow(
                  'Type',
                  (data['incident_type'] as String).toUpperCase(),
                  icon: Icons.category,
                ),
                const Divider(height: 32),
              ],

              // Message
              _buildDetailSection(
                'Your Message',
                data['raw_message'] ?? 'No message provided',
                icon: Icons.message,
              ),
              const Divider(height: 32),

              // Location
              _buildDetailSection(
                'Location',
                data['location_text'] ?? 'No location provided',
                icon: Icons.location_on,
              ),
              const Divider(height: 32),

              // Details
              if (data['people_count'] != null)
                _buildDetailRow(
                  'People Affected',
                  '${data['people_count']}',
                  icon: Icons.people,
                ),
              if (data['water_level'] != null)
                _buildDetailRow(
                  'Water Level',
                  (data['water_level'] as String).toUpperCase(),
                  icon: Icons.water,
                ),
              if (data['injuries'] != null)
                _buildDetailRow(
                  'Injuries',
                  data['injuries'] == 'yes' ? 'Yes' : 'No',
                  icon: Icons.local_hospital,
                ),
              if (data['vulnerable_people'] != null)
                _buildDetailRow(
                  'Vulnerable People',
                  data['vulnerable_people'] ? 'Yes' : 'No',
                  icon: Icons.elderly,
                ),
              const Divider(height: 32),

              // Timestamps
              _buildDetailRow(
                'Submitted',
                _formatTimestamp(data['created_at']),
                icon: Icons.access_time,
              ),
              _buildDetailRow(
                'Last Updated',
                _formatTimestamp(data['updated_at']),
                icon: Icons.update,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
