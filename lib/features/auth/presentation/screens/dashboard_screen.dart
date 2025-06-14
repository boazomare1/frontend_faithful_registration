import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salam/core/constants/app_colors.dart';
import 'package:salam/core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHouseholdMembers(BuildContext context, String householdName, List<dynamic> members) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Members of $householdName',
          style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: members.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${m['full_name']}',
                        style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Gender: ${m['gender']}',
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      Text(
                        'Date of Birth: ${m['date_of_birth']}',
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      Text(
                        'Occupation: ${m['occupation']}',
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      const Divider(),
                    ],
                  ),
                )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showHouseholdCounts(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final counts = await apiService.getHouseholdMemberCounts();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Household Member Counts',
          style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: counts.map((e) => ListTile(
                  title: Text(
                    '${e['household_name']} (${e['household']})',
                    style: const TextStyle(fontFamily: 'Amiri'),
                  ),
                  trailing: Text(
                    '${e['count']} member${e['count'] > 1 ? 's' : ''}',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
                  ),
                  onTap: () => _showHouseholdMembers(context, e['household_name'], e['members']),
                )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Faithful by ID (e.g., FTH-2025-0089)',
                    hintStyle: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.background.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppColors.accent),
                      onPressed: () async {
                        if (_searchController.text.isNotEmpty) {
                          final response = await apiService.searchFaithful(name: _searchController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['status'] == 'success'
                                    ? 'Found: ${response['full_name'] ?? _searchController.text}'
                                    : response['message'],
                                style: const TextStyle(fontFamily: 'Amiri'),
                              ),
                              backgroundColor: response['status'] == 'success'
                                  ? AppColors.accent
                                  : Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getMosqueCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'Mosques',
                            count: snapshot.data ?? 0,
                            icon: Icons.mosque,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getHouseholdCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'Households',
                            count: snapshot.data ?? 0,
                            icon: Icons.family_restroom,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getFemaleCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'Females',
                            count: snapshot.data ?? 0,
                            icon: Icons.female,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getMaleCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'Males',
                            count: snapshot.data ?? 0,
                            icon: Icons.male,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getWithHouseholdCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'With Household',
                            count: snapshot.data ?? 0,
                            icon: Icons.home,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: apiService.getWithoutHouseholdCount(),
                        builder: (context, snapshot) {
                          return DashboardCard(
                            title: 'Without Household',
                            count: snapshot.data ?? 0,
                            icon: Icons.person,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<int>(
                  future: apiService.getFaithfulCount(),
                  builder: (context, snapshot) {
                    return DashboardCard(
                      title: 'All Faithfuls',
                      count: snapshot.data ?? 0,
                      icon: Icons.people,
                      isFullWidth: true,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showHouseholdCounts(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'View Household Member Counts',
                      style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isFullWidth;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding for compactness
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.accent),
            const SizedBox(height: 8), // Spacing between icon and text
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16, // Slightly smaller for balance
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22, // Slightly smaller for balance
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
