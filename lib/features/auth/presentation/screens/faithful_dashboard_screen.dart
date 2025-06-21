import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import 'faithful_registration_screen.dart';
import 'faithful_update_screen.dart';

class FaithfulDashboardScreen extends StatefulWidget {
  const FaithfulDashboardScreen({super.key});

  @override
  State<FaithfulDashboardScreen> createState() => _FaithfulDashboardScreenState();
}

class _FaithfulDashboardScreenState extends State<FaithfulDashboardScreen> {
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

  Future<void> _bulkUploadFaithfuls(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv','xlsx', 'xls'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final response = await apiService.bulkUploadFaithfuls(file: file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'],
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: response['status'] == 'success' ? AppColors.accent : Colors.redAccent,
          ),
        );
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
              Text('Date of Birth: ${faithful['date_of_birth'] ?? 'N/A'}',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push('/register-faithful'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Register Faithful',
                        style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _bulkUploadFaithfuls(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Bulk Upload',
                        style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'All Faithfuls',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: apiService.getAllFaithfuls(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text(
                        'Error loading faithfuls',
                        style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                      );
                    }
                    final faithfuls = snapshot.data!;
                    if (faithfuls.isEmpty) {
                      return const Text(
                        'No faithfuls found',
                        style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: faithfuls.length,
                      itemBuilder: (context, index) {
                        final faithful = faithfuls[index];
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.accent),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FaithfulUpdateScreen(name:faithful['name'] ?? ''),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Confirm Deletion',
                                          style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete ${faithful['full_name'] ?? 'this faithful'}?',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(fontFamily: 'Amiri', color: Colors.redAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final response = await apiService.deleteFaithful(name: faithful['name']);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              response['message'],
                                              style: const TextStyle(fontFamily: 'Amiri'),
                                            ),
                                            backgroundColor: response['status'] == 'success'
                                                ? AppColors.accent
                                                : Colors.redAccent,
                                          ),
                                        );
                                        setState(() {}); // Refresh list
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
