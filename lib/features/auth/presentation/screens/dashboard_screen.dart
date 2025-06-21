import 'package:cached_network_image/cached_network_image.dart';
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
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final results = await apiService.searchFaithful(name: query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error searching: $e',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _searchResults = [];
        });
      }
    }
  }

  Widget _buildImageWidget(String? imageUrl, BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return imageUrl != null
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            httpHeaders: {'Cookie': 'sid=${apiService.sid ?? ''}'},
            placeholder: (context, url) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          )
        : Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey),
          );
  }

  void _showFaithfulDetails(BuildContext context, Map<String, dynamic> faithful) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildImageWidget(faithful['profile_image'], context),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                faithful['full_name'] ?? 'N/A',
                style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${faithful['name'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Email: ${faithful['email'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Phone: ${faithful['phone'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Gender: ${faithful['gender'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Mosque: ${faithful['mosque_name'] ?? faithful['mosque'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Household: ${faithful['household_name'] ?? faithful['household'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Occupation: ${faithful['occupation'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Education Level: ${faithful['education_level'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Marital Status: ${faithful['marital_status'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Monthly Income: ${faithful['monthly_household_income'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Joined Community: ${faithful['date_joined_community'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              if (faithful['national_id_document'] != null) ...[
                const SizedBox(height: 8),
                const Text('National ID Document:', style: TextStyle(fontFamily: 'Amiri')),
                _buildImageWidget(faithful['national_id_document'], context),
              ],
              if (faithful['special_needs_proof'] != null) ...[
                const SizedBox(height: 8),
                const Text('Special Needs Proof:', style: TextStyle(fontFamily: 'Amiri')),
                _buildImageWidget(faithful['special_needs_proof'], context),
              ],
            ],
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
            children: members.asMap().entries.expand<Widget>((entry) {
              final index = entry.key;
              final m = entry.value as Map<String, dynamic>;
              final memberWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${m['name'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          Text(
                            'Name: ${m['full_name'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Phone: ${m['phone'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          Text(
                            'National ID: ${m['national_id_number'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          Text(
                            'Mosque: ${m['mosque_name'] ?? m['mosque'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          Text(
                            'Marital Status: ${m['marital_status'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                        ],
                      ),
                    ),
                    _buildImageWidget(m['profile_image'], context),
                  ],
                ),
              );
              if (index < members.length - 1) {
                return [
                  memberWidget,
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Divider(),
                  ),
                ];
              }
              return [memberWidget];
            }).toList(),
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
    try {
      final counts = await apiService.getHouseholdMemberCounts();
      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error fetching household counts: $e',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
                    hintText: 'Search Faithful by Name (e.g., Pinkie Ponkie)',
                    hintStyle: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.background.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.accent),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : const Icon(Icons.search, color: AppColors.accent),
                  ),
                  style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                ),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final faithful = _searchResults[index];
                      return Card(
                        color: AppColors.background.withOpacity(0.9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: _buildImageWidget(faithful['profile_image'], context),
                          title: Text(
                            faithful['full_name'] ?? 'N/A',
                            style: const TextStyle(fontFamily: 'Amiri', color: Colors.white),
                          ),
                          subtitle: Text(
                            'ID: ${faithful['name'] ?? 'N/A'}\nMosque: ${faithful['mosque_name'] ?? faithful['mosque'] ?? 'N/A'}\nHousehold: ${faithful['household_name'] ?? faithful['household'] ?? 'N/A'}',
                            style: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                          ),
                          onTap: () async {
                            try {
                              final response = await apiService.searchFaithfulById(name: faithful['name']);
                              if (mounted) {
                                if (response['status'] == 'success') {
                                  _showFaithfulDetails(context, response);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Found: ${response['full_name'] ?? faithful['name']}',
                                        style: const TextStyle(fontFamily: 'Amiri'),
                                      ),
                                      backgroundColor: AppColors.accent,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['message'] ?? 'Failed to load faithful details',
                                        style: const TextStyle(fontFamily: 'Amiri'),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: $e',
                                      style: const TextStyle(fontFamily: 'Amiri'),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.accent),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
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