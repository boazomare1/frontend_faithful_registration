import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salam/core/constants/app_colors.dart';
import 'package:salam/core/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _mosques = [];
  List<Map<String, dynamic>> _filteredMosques = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMosques();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMosques() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final mosques = await apiService.getAllMosques();
      if (mounted) {
        setState(() {
          _mosques = mosques;
          _filteredMosques = mosques;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading mosques: $e',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredMosques = query.isEmpty
          ? _mosques
          : _mosques.where((mosque) {
              final name = mosque['mosque_name']?.toString().toLowerCase() ?? '';
              return name.contains(query);
            }).toList();
    });
  }

  Widget _buildImageWidget(String? imageUrl, BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final fullUrl = imageUrl != null ? '${ApiService.imageBaseUrl}$imageUrl' : null;
    return fullUrl != null
        ? CachedNetworkImage(
            imageUrl: fullUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            httpHeaders: {'Cookie': 'sid=${apiService.sid ?? ''}'},
            placeholder: (context, url) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.mosque, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.mosque, color: Colors.grey),
            ),
          )
        : Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.mosque, color: Colors.grey),
          );
  }

  void _showMosqueDetails(BuildContext context, Map<String, dynamic> mosque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildImageWidget(mosque['front_image'], context),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mosque['mosque_name'] ?? 'N/A',
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
              Text('ID: ${mosque['name'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Location: ${mosque['location'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
              Text('Date Established: ${mosque['date_established'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Head Imam: ${mosque['head_imam_name'] ?? mosque['head_imam'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Total Capacity: ${mosque['total_capacity'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Contact Email: ${mosque['contact_email'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              Text('Contact Phone: ${mosque['contact_phone'] ?? 'N/A'}',
                  style: const TextStyle(fontFamily: 'Amiri')),
              const SizedBox(height: 8),
              const Text('Images:', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (mosque['front_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['front_image'], context),
                        const Text('Front', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['back_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['back_image'], context),
                        const Text('Back', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['madrasa_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['madrasa_image'], context),
                        const Text('Madrasa', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['inside_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['inside_image'], context),
                        const Text('Inside', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['ceiling_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['ceiling_image'], context),
                        const Text('Ceiling', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['minbar_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['minbar_image'], context),
                        const Text('Minbar', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                  if (mosque['head_imam_image'] != null)
                    Column(
                      children: [
                        _buildImageWidget(mosque['head_imam_image'], context),
                        const Text('Head Imam', style: TextStyle(fontFamily: 'Amiri')),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Imams:', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              ...?mosque['imams']?.asMap().entries.map<Widget>((entry) {
                final imam = entry.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${imam['imam_name'] ?? 'N/A'}',
                          style: const TextStyle(fontFamily: 'Amiri')),
                      Text('Role: ${imam['role_in_mosque'] ?? 'N/A'}',
                          style: const TextStyle(fontFamily: 'Amiri')),
                      Text('ID: ${imam['name'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Amiri')),
                      if (entry.key < mosque['imams'].length - 1) const Divider(),
                    ],
                  ),
                );
              }).toList(),
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

  void _showMosqueForm(BuildContext context, {Map<String, dynamic>? mosque}) {
    final isEdit = mosque != null;
    final nameController = TextEditingController(text: mosque?['name']);
    final mosqueNameController = TextEditingController(text: mosque?['mosque_name']);
    final locationController = TextEditingController(text: mosque?['location']);
    final dateEstablishedController = TextEditingController(text: mosque?['date_established']);
    final totalCapacityController = TextEditingController(text: mosque?['total_capacity']?.toString());
    final contactEmailController = TextEditingController(text: mosque?['contact_email']);
    final contactPhoneController = TextEditingController(text: mosque?['contact_phone']);
    final formKey = GlobalKey<FormState>();
    String? selectedImam;
    String? frontImageBase64;
    String? backImageBase64;
    String? madrasaImageBase64;
    String? insideImageBase64;
    String? ceilingImageBase64;
    String? minbarImageBase64;
    List<Map<String, dynamic>> imams = [];

    Future<void> loadImams() async {
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        imams = await apiService.getAllImams();
        if (mounted) {
          setState(() {
            selectedImam = isEdit ? mosque!['head_imam'] : imams.isNotEmpty ? imams[0]['name'] : null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading imams: $e',
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }

    Future<void> pickImage(String field) async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          if (mounted) {
            setState(() {
              switch (field) {
                case 'front_image':
                  frontImageBase64 = base64String;
                  break;
                case 'back_image':
                  backImageBase64 = base64String;
                  break;
                case 'madrasa_image':
                  madrasaImageBase64 = base64String;
                  break;
                case 'inside_image':
                  insideImageBase64 = base64String;
                  break;
                case 'ceiling_image':
                  ceilingImageBase64 = base64String;
                  break;
                case 'minbar_image':
                  minbarImageBase64 = base64String;
                  break;
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error picking image: $e',
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }

    loadImams(); // Load imams when form opens

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? 'Update Mosque' : 'Add Mosque',
          style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdit)
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Mosque ID',
                      labelStyle: TextStyle(fontFamily: 'Amiri'),
                    ),
                    enabled: false,
                  ),
                TextFormField(
                  controller: mosqueNameController,
                  decoration: const InputDecoration(
                    labelText: 'Mosque Name',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Mosque name is required' : null,
                ),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Location is required' : null,
                ),
                TextFormField(
                  controller: dateEstablishedController,
                  decoration: const InputDecoration(
                    labelText: 'Date Established (YYYY-MM-DD)',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Date is required';
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Use YYYY-MM-DD format';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedImam,
                  decoration: const InputDecoration(
                    labelText: 'Head Imam',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  items: imams.map((imam) {
                    return DropdownMenuItem<String>(
                      value: imam['name'],
                      child: Text(
                        imam['imam_name'] ?? 'N/A',
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        selectedImam = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Head Imam is required' : null,
                ),
                TextFormField(
                  controller: totalCapacityController,
                  decoration: const InputDecoration(
                    labelText: 'Total Capacity',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Capacity is required';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Email is required' : null,
                ),
                TextFormField(
                  controller: contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Phone is required' : null,
                ),
                const SizedBox(height: 8),
                const Text('Images (Optional):', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => pickImage('front_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    frontImageBase64 == null ? 'Upload Front Image' : 'Front Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pickImage('back_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    backImageBase64 == null ? 'Upload Back Image' : 'Back Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pickImage('madrasa_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    madrasaImageBase64 == null ? 'Upload Madrasa Image' : 'Madrasa Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pickImage('inside_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    insideImageBase64 == null ? 'Upload Inside Image' : 'Inside Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pickImage('ceiling_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    ceilingImageBase64 == null ? 'Upload Ceiling Image' : 'Ceiling Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pickImage('minbar_image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: Text(
                    minbarImageBase64 == null ? 'Upload Minbar Image' : 'Minbar Image Selected',
                    style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() && selectedImam != null) {
                final apiService = Provider.of<ApiService>(context, listen: false);
                try {
                  Map<String, dynamic> response;
                  if (isEdit) {
                    response = await apiService.updateMosque(
                      name: nameController.text,
                      mosqueName: mosqueNameController.text,
                      location: locationController.text,
                      dateEstablished: dateEstablishedController.text,
                      headImam: selectedImam!,
                      totalCapacity: int.parse(totalCapacityController.text),
                      contactEmail: contactEmailController.text,
                      contactPhone: contactPhoneController.text,
                      frontImage: frontImageBase64,
                      backImage: backImageBase64,
                      madrasaImage: madrasaImageBase64,
                      insideImage: insideImageBase64,
                      ceilingImage: ceilingImageBase64,
                      minbarImage: minbarImageBase64,
                    );
                  } else {
                    response = await apiService.registerMosque(
                      mosqueName: mosqueNameController.text,
                      location: locationController.text,
                      dateEstablished: dateEstablishedController.text,
                      headImam: selectedImam!,
                      totalCapacity: int.parse(totalCapacityController.text),
                      contactEmail: contactEmailController.text,
                      contactPhone: contactPhoneController.text,
                      frontImage: frontImageBase64,
                      backImage: backImageBase64,
                      madrasaImage: madrasaImageBase64,
                      insideImage: insideImageBase64,
                      ceilingImage: ceilingImageBase64,
                      minbarImage: minbarImageBase64,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response['status'] == 'success'
                              ? isEdit
                                  ? 'Mosque updated'
                                  : 'Mosque added'
                              : response['message'] ?? 'Operation failed',
                          style: const TextStyle(fontFamily: 'Amiri'),
                        ),
                        backgroundColor: response['status'] == 'success'
                            ? AppColors.accent
                            : Colors.redAccent,
                      ),
                    );
                    if (response['status'] == 'success') {
                      await _loadMosques();
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: Text(
              isEdit ? 'Update' : 'Add',
              style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMosque(BuildContext context, String name, String mosqueName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete $mosqueName',
          style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
        ),
        content: const Text(
          'Are you sure you want to delete this mosque?',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiService = Provider.of<ApiService>(context, listen: false);
              try {
                final response = await apiService.deleteMosque(name: name);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response['status'] == 'success'
                            ? 'Mosque deleted'
                            : response['message'] ?? 'Deletion failed',
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      backgroundColor: response['status'] == 'success'
                          ? AppColors.accent
                          : Colors.redAccent,
                    ),
                  );
                  if (response['status'] == 'success') {
                    await _loadMosques();
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkUploadMosques(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await apiService.bulkRegisterMosques(file: file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['status'] == 'success'
                    ? 'Bulk upload successful'
                    : response['message'] ?? 'Bulk upload failed',
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              backgroundColor: response['status'] == 'success'
                  ? AppColors.accent
                  : Colors.redAccent,
            ),
          );
          if (response['status'] == 'success') {
            await _loadMosques();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error uploading file: $e',
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

    return Scaffold(
      body: Container(
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
                      hintText: 'Search Mosques by Name (e.g., Twaiba Mosque)',
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
                                _onSearchChanged();
                              },
                            )
                          : const Icon(Icons.search, color: AppColors.accent),
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
                              title: 'Total Mosques',
                              count: snapshot.data ?? 0,
                              icon: Icons.mosque,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder<int>(
                          future: Future.value(
                            _mosques.fold<int>(0, (sum, m) => sum + (m['total_capacity'] as int? ?? 0)),
                          ),
                          builder: (context, snapshot) {
                            return DashboardCard(
                              title: 'Total Capacity',
                              count: snapshot.data ?? 0,
                              icon: Icons.group,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filteredMosques.isNotEmpty) ...[
                    const Text(
                      'Mosques',
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
                      itemCount: _filteredMosques.length,
                      itemBuilder: (context, index) {
                        final mosque = _filteredMosques[index];
                        return Card(
                          color: AppColors.background.withOpacity(0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _buildImageWidget(mosque['front_image'], context),
                            title: Text(
                              mosque['mosque_name'] ?? 'N/A',
                              style: const TextStyle(fontFamily: 'Amiri', color: Colors.white),
                            ),
                            subtitle: Text(
                              'ID: ${mosque['name'] ?? 'N/A'}\nLocation: ${mosque['location'] ?? 'N/A'}\nCapacity: ${mosque['total_capacity'] ?? 'N/A'}',
                              style: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteMosque(context, mosque['name'], mosque['mosque_name']),
                            ),
                            onTap: () async {
                              try {
                                final response = await apiService.getMosque(name: mosque['name']);
                                if (mounted) {
                                  if (response['status'] == 'success') {
                                    _showMosqueDetails(context, response['data']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Found: ${response['data']['mosque_name'] ?? mosque['name']}',
                                          style: const TextStyle(fontFamily: 'Amiri'),
                                        ),
                                        backgroundColor: AppColors.accent,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ?? 'Failed to load mosque details',
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
                            onLongPress: () => _showMosqueForm(context, mosque: mosque),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    const Text(
                      'No mosques found',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: AppColors.accent),
                  title: const Text(
                    'Add Mosque',
                    style: TextStyle(fontFamily: 'Amiri'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showMosqueForm(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file, color: AppColors.accent),
                  title: const Text(
                    'Bulk Upload',
                    style: TextStyle(fontFamily: 'Amiri'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _bulkUploadMosques(context);
                  },
                ),
              ],
            ),
          );
        },
        label: const Text(
          'Actions',
          style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
        ),
        icon: const Icon(Icons.add, color: AppColors.primary),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
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