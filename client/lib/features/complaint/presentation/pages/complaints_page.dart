import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/complaint_model.dart';
import '../bloc/complaint_bloc.dart';

/// Page for displaying list of complaints.
class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ComplaintBloc>().add(LoadComplaints());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keluhan Produk')),
      body: BlocBuilder<ComplaintBloc, ComplaintState>(
        builder: (context, state) {
          if (state is ComplaintLoading && state.complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ComplaintError && state.complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ComplaintBloc>().add(LoadComplaints()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.complaints.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text('Belum ada keluhan'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ComplaintBloc>().add(LoadComplaints());
            },
            child: ListView.separated(
              itemCount: state.complaints.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final complaint = state.complaints[index];
                return _ComplaintTile(complaint: complaint);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ComplaintTile extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintTile({required this.complaint});

  Color _statusColor() {
    switch (complaint.status) {
      case ComplaintStatus.open:
        return Colors.orange;
      case ComplaintStatus.inReview:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.rejected:
        return Colors.red;
    }
  }

  IconData _categoryIcon() {
    switch (complaint.category) {
      case ComplaintCategory.expired:
        return Icons.timer_off;
      case ComplaintCategory.damaged:
        return Icons.broken_image;
      case ComplaintCategory.qualityIssue:
        return Icons.warning;
      case ComplaintCategory.packaging:
        return Icons.inventory;
      case ComplaintCategory.other:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor().withOpacity(0.2),
        child: Icon(_categoryIcon(), color: _statusColor()),
      ),
      title: Text(complaint.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            complaint.category.displayName,
            style: TextStyle(color: _statusColor()),
          ),
          Text(
            '${complaint.shopName} • ${dateFormat.format(complaint.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          complaint.status.displayName,
          style: TextStyle(color: _statusColor(), fontSize: 12),
        ),
      ),
      onTap: () {
        context.push('/complaints/${complaint.id}');
      },
    );
  }
}
