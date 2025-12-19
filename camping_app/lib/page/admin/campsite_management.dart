import 'package:flutter/material.dart';
import '../../services/storage_services.dart'; // your provided storage helper
import '../../models/campsite.dart';
import '../../services/api_admin_services.dart';

class CampsiteManagementScreen extends StatefulWidget {
  final VoidCallback onBack;
  const CampsiteManagementScreen({Key? key, required this.onBack})
    : super(key: key);

  @override
  State<CampsiteManagementScreen> createState() =>
      _CampsiteManagementScreenState();
}

class _CampsiteManagementScreenState extends State<CampsiteManagementScreen> {
  // Form.. type shit
  final _formKey = GlobalKey<FormState>();
  int? editingCampsiteId;

  bool showAddForm = false;
  bool isEditing = false;
  int editedId = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController facilitiesController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  // Service Variable
  late Future<List<Campsite>> _campsitesFuture;
  List<Campsite> _campsites = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCampsites();
  }

  void _loadCampsites() {
    _campsitesFuture = _apiService.getCampsites();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    capacityController.dispose();
    priceController.dispose();
    facilitiesController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campsites = _getCampsites();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: const Color(0xFF2563EB),
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Campsite Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   '${_campsites.length} campsites',
                          //   style: const TextStyle(
                          //     color: Color(0xFFDBEAFE),
                          //     fontSize: 14,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // Add Button
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                        onPressed: () {
                          editingCampsiteId = null;
                          _clearForm();
                          setState(() => showAddForm = true);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Campsites List
              Expanded(
                child: FutureBuilder<List<Campsite>>(
                  future: _campsitesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    _campsites = snapshot.data!;

                    return ListView.builder(
                      itemCount: _campsites.length,
                      itemBuilder: (context, index) =>
                          _buildCampsiteCard(_campsites[index]),
                    );
                  },
                ),
              ),
            ],
          ),

          // Add Form Modal
          if (showAddForm) _buildAddFormModal(),
        ],
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    latitudeController.clear();
    longitudeController.clear();
    capacityController.clear();
    priceController.clear();
    facilitiesController.clear();
    imageUrlController.clear();
  }

  Widget _buildCampsiteCard(Campsite campsite) {
    final bool isActive = campsite.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: campsite.imageUrl != null
                  ? Image.network(
                      campsite.imageUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 96,
                      height: 96,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          campsite.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          campsite.locationName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating (static / optional)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      const Text('4.5', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      const Text(
                        '(120)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Capacity: ${campsite.capacity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        campsite.formattedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Color(0xFF2563EB),
                              ),
                              onPressed: () {
                                // isi controller dari campsite
                                nameController.text = campsite.name;
                                locationController.text = campsite.locationName;
                                priceController.text = campsite.pricePerNight
                                    .toString();
                                capacityController.text = campsite.capacity
                                    .toString();
                                descriptionController.text =
                                    campsite.description ?? '';
                                imageUrlController.text =
                                    campsite.imageUrl ?? '';

                                editedId = campsite.id;
                                showAddForm = true;
                                isEditing = true;
                                setState(() {});
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Color(0xFFDC2626),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Campsite'),
                                    content: const Text('Are you sure?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await apiService.deleteCampsite(campsite.id);
                                  _loadCampsites();
                                  setState(() {});
                                }
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFormModal() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Campsite',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF3F4F6),
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => showAddForm = false),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: 'Campsite Name',
                          hint: 'Enter campsite name',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: locationController,
                          label: 'Location',
                          hint: 'Enter location',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: latitudeController,
                                label: 'Latitude',
                                hint: '150000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: longitudeController,
                                label: 'Longitude',
                                hint: '50',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: priceController,
                                label: 'Price (per night)',
                                hint: '150000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: capacityController,
                                label: 'Capacity',
                                hint: '50',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: facilitiesController,
                        //   label: 'Description',
                        //   hint: 'Enter description',
                        //   maxLines: 4,
                        // ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: descriptionController,
                          label: 'Description',
                          hint: 'Enter description',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => showAddForm = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final campsiteData = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            'location_name': locationController.text,
                            'latitude':
                                double.tryParse(latitudeController.text) ?? 0.0,
                            'longitude':
                                double.tryParse(longitudeController.text) ??
                                0.0,
                            'capacity': int.parse(capacityController.text),
                            // 'price_per_night': priceController.text.isNotEmpty
                            //     ? double.parse(priceController.text)
                            //     : 0.0,
                            'price_per_night':
                                double.tryParse(priceController.text) ?? 0.0,
                            'facilities': facilitiesController.text,
                            'image_url': imageUrlController.text.isEmpty
                                ? null
                                : imageUrlController.text,
                          };

                          print("<=== FORM DATA CAMPSITE ===>");
                          print(campsiteData);
                          print("<=== FORM DATA CAMPSITE ===>");

                          try {
                            if (!isEditing) {
                              await apiService.createCampsite(campsiteData);
                            } else {
                              await apiService.updateCampsite(
                                editedId,
                                campsiteData,
                              );
                              editedId = 0;
                              isEditing = false;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campsite created successfully'),
                              ),
                            );

                            // OPTIONAL: refresh list here
                            // Navigator.pop(context); // close modal
                            _clearForm();
                            _loadCampsites();
                            setState(() => showAddForm = false);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                            print("<=== ERROR FORM ===>");
                            print(e.toString());
                            print("<=== ERROR FORM ===>");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? 'Edit Campsite' : 'Add Campsite',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  List<Map<String, dynamic>> _getCampsites() {
    return [
      {
        'id': 1,
        'name': 'Green Valley Camp',
        'location': 'Bandung, West Java',
        'price': 150000,
        'capacity': 50,
        'rating': 4.8,
        'reviews': 124,
        'status': 'active',
        'image':
            'https://images.unsplash.com/photo-1633803504744-1b8a284cd3cc?w=400',
        'facilities': ['Toilet', 'WiFi', 'BBQ Area'],
      },
      {
        'id': 2,
        'name': 'Mountain Peak Resort',
        'location': 'Bogor, West Java',
        'price': 200000,
        'capacity': 30,
        'rating': 4.9,
        'reviews': 89,
        'status': 'active',
        'image':
            'https://images.unsplash.com/photo-1471115853179-bb1d604434e0?w=400',
        'facilities': ['Toilet', 'Parking', 'Mountain View'],
      },
      {
        'id': 3,
        'name': 'Lakeside Paradise',
        'location': 'Cianjur, West Java',
        'price': 175000,
        'capacity': 40,
        'rating': 4.7,
        'reviews': 156,
        'status': 'active',
        'image':
            'https://images.unsplash.com/photo-1589051355082-e983d7e81181?w=400',
        'facilities': ['Toilet', 'Fishing', 'Lake Access'],
      },
      {
        'id': 4,
        'name': 'Sunset Beach Camp',
        'location': 'Pelabuhan Ratu, West Java',
        'price': 180000,
        'capacity': 35,
        'rating': 4.6,
        'reviews': 98,
        'status': 'inactive',
        'image':
            'https://images.unsplash.com/photo-1600403506000-62e42b6e3238?w=400',
        'facilities': ['Toilet', 'Beach Access', 'Sunset View'],
      },
    ];
  }
}
