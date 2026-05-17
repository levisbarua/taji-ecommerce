import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../services/managers.dart';

class AdminPanel extends StatefulWidget {
  final VoidCallback? onProductDeleted;
  const AdminPanel({super.key, this.onProductDeleted});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _promoTitleController = TextEditingController();
  final TextEditingController _promoDiscountController = TextEditingController();
  final TextEditingController _subheadingController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Merchant';
  List<String> _categories = ['Merchant', 'Design', 'Brands', 'Projects'];
  XFile? _promoPoster;
  bool _isPromoActive = true;
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isBannerActive = false;
  final TextEditingController _bannerTextController = TextEditingController();
  bool _isPremiumActive = false;
  final TextEditingController _notifTitleController = TextEditingController();
  final TextEditingController _notifMessageController = TextEditingController();
  List<Map<String, String>> _customNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadPromoData();
    _loadGlobalSettings();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryManager.getCategories();
    setState(() {
      _categories = cats;
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : '';
      }
    });
  }

  Future<void> _loadGlobalSettings() async {
    final bannerActive = await GlobalSettingsManager.isBannerActive();
    final bannerText = await GlobalSettingsManager.getBannerText();
    final premiumActive = await GlobalSettingsManager.isPremium();
    final notifications = await GlobalSettingsManager.getNotifications();
    setState(() {
      _isBannerActive = bannerActive;
      _bannerTextController.text = bannerText;
      _isPremiumActive = premiumActive;
      _customNotifications = notifications;
    });
  }

  Future<void> _loadPromoData() async {
    final data = await DiscountManager.getPromoData();
    setState(() {
      _promoTitleController.text = data['title']!;
      _promoDiscountController.text = data['discount']!;
      if (data['poster']!.isNotEmpty) {
        _promoPoster = XFile(data['poster']!);
      }
      _isPromoActive = data['active'] ?? true;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (selected != null) {
        setState(() {
          _imageFile = selected;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e"), backgroundColor: tajiError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            "Admin Console",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: pureYellow,
            labelColor: pureYellow,
            unselectedLabelColor: tajiTextMutedDark,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.add_photo_alternate), text: "Upload"),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "Products"),
              Tab(icon: Icon(Icons.campaign), text: "Promos"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
              Tab(icon: Icon(Icons.message), text: "Requests"),
              Tab(icon: Icon(Icons.settings), text: "Global"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUploadSection(),
            _buildProductsListSection(),
            _buildPromosSection(),
            _buildOrdersSection(),
            _buildRequestsSection(),
            _buildGlobalSettingsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _showReplyDialog(String userName, int index) async {
    final TextEditingController replyController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Reply to $userName", style: const TextStyle(color: pureWhite)),
        content: TextField(
          controller: replyController,
          maxLines: 4,
          style: const TextStyle(color: pureWhite),
          decoration: InputDecoration(
            hintText: "Type your response...",
            hintStyle: TextStyle(color: pureWhite.withValues(alpha: 0.3)),
            filled: true,
            fillColor: tajiTextLight.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reply sent to $userName"), backgroundColor: tajiSuccess),
                );
              }
            }, 
            child: const Text("Send", style: TextStyle(color: pureYellow)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminSectionTitle("Update Portfolio / Products"),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 50, color: pureYellow.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text("Tap to select image", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Category", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedCategory = newValue);
                },
                isExpanded: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Subheading / Type", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _subheadingController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g., Premium Store Display",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Price", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: r"e.g., $299.00",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Description", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Enter item description...",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_subheadingController.text.isEmpty || _priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in subheading and price"), backgroundColor: tajiError),
                  );
                  return;
                }
                
                await ProductManager.saveProduct({
                  'name': _subheadingController.text,
                  'type': _selectedCategory,
                  'price': _priceController.text,
                  'description': _descController.text,
                  'category': _selectedCategory,
                  'image': _imageFile?.path ?? '',
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Content successfully updated!"), backgroundColor: tajiSuccess),
                );
                
                _subheadingController.clear();
                _priceController.clear();
                _descController.clear();
                setState(() => _imageFile = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pureYellow,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Deploy Update", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromosSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAdminSectionTitle("Update Selection Promotion"),
              Switch(
                value: _isPromoActive,
                activeThumbColor: pureYellow,
                onChanged: (val) {
                  setState(() => _isPromoActive = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Promotion Poster", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickPromoPoster,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: _promoPoster == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: pureYellow.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text("Select Banner Poster", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_promoPoster!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Collection Title", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _promoTitleController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g. Summer Collection",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
          ),
          const SizedBox(height: 24),
          Text("Discount Description", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _promoDiscountController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "e.g. Discount up to 70%",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _updatePromoData,
              style: ElevatedButton.styleFrom(
                backgroundColor: pureYellow,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Save Promotion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPromoPoster() async {
    try {
      final XFile? selected = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (selected != null) setState(() => _promoPoster = selected);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking poster: $e"), backgroundColor: tajiError));
    }
  }

  Future<void> _updatePromoData() async {
    await DiscountManager.savePromoData(
      _promoTitleController.text,
      _promoDiscountController.text,
      _promoPoster?.path ?? '',
      _isPromoActive,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promotion updated! Restart app or go home to see changes."), backgroundColor: tajiSuccess),
      );
    }
  }

  Widget _buildOrdersSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: OrderManager.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text("No orders found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: pureYellow.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag, color: pureYellow),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order["id"]!, style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
                        Text(order["user"] ?? "Unkown User", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(order["items_count"]?.toString() ?? "0 Items", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) async {
                      await OrderManager.updateOrderStatus(order["id"], val);
                      setState(() {});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "Pending", child: Text("Pending")),
                      const PopupMenuItem(value: "Processing", child: Text("Processing")),
                      const PopupMenuItem(value: "Shipped", child: Text("Shipped")),
                      const PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                      const PopupMenuItem(value: "Cancelled", child: Text("Cancelled")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (order["status"] == "Cancelled" ? tajiError : tajiAmber).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(order["status"]!, style: TextStyle(color: order["status"] == "Cancelled" ? tajiError : tajiAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: RequestManager.getRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(child: Text("No requests found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(request["user"] ?? "Unkown", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(request["date"] ?? "Just now", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request["msg"] ?? "", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showReplyDialog(request["user"] ?? "User", index);
                        }, 
                        child: const Text("Reply", style: TextStyle(color: pureYellow)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              title: const Text("Archive Request?", style: TextStyle(color: pureWhite)),
                              content: Text("This will remove the request from the list.", style: TextStyle(color: tajiTextLight.withValues(alpha: 0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true), 
                                  child: const Text("Archive", style: TextStyle(color: tajiError)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await RequestManager.deleteRequest(index);
                            setState(() {});
                          }
                        }, 
                        child: Text("Archive", style: TextStyle(color: tajiTextLight.withValues(alpha: 0.38))),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlobalSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminSectionTitle("App-Wide Settings"),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Announcement Banner", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                    Switch(
                      value: _isBannerActive,
                      activeThumbColor: pureYellow,
                      onChanged: (val) async {
                        setState(() => _isBannerActive = val);
                        await GlobalSettingsManager.setBanner(val, _bannerTextController.text);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banner state updated")));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bannerTextController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Enter banner text...",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) async {
                    await GlobalSettingsManager.setBanner(_isBannerActive, val);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banner text updated")));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Premium Member Status", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Toggle your mock PRO badge", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                  ],
                ),
                Switch(
                  value: _isPremiumActive,
                  activeThumbColor: pureYellow,
                  onChanged: (val) async {
                    setState(() => _isPremiumActive = val);
                    await GlobalSettingsManager.setPremium(val);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Premium status toggled")));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Push Custom Notification", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                TextField(
                  controller: _notifTitleController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Notification Title",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notifMessageController,
                  maxLines: 2,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Notification Message",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_notifTitleController.text.isEmpty || _notifMessageController.text.isEmpty) return;
                      await GlobalSettingsManager.addNotification(
                        _notifTitleController.text, 
                        _notifMessageController.text,
                        "yellow", "campaign"
                      );
                      setState(() {
                        _notifTitleController.clear();
                        _notifMessageController.clear();
                      });
                      _loadGlobalSettings();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification pushed!", style: TextStyle(color: pureBlack)), backgroundColor: pureYellow));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pureYellow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Push Notification", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_customNotifications.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Divider(color: tajiTextLight.withValues(alpha: 0.1)),
                  const SizedBox(height: 24),
                  Text("Active Notifications", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _customNotifications.length,
                    itemBuilder: (context, index) {
                      final notif = _customNotifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tajiTextLight.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: GlobalSettingsManager.getColor(notif["color"]).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                GlobalSettingsManager.getIcon(notif["icon"]),
                                color: GlobalSettingsManager.getColor(notif["color"]),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif["title"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                  Text(notif["message"] ?? "", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                                  if (notif["time"] != null)
                                    Text(notif["time"]!, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: tajiError, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    title: const Text("Delete Notification?"),
                                    content: const Text("This notification will be removed for all users."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: tajiError)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await GlobalSettingsManager.deleteNotification(index);
                                  _loadGlobalSettings();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsListSection() {
    return FutureBuilder<List<Map<String, String>>>(
      future: ProductManager.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: pureYellow));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Text("No custom products found", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: pureYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: (product['image'] != null && product['image']!.startsWith('http'))
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(product['image']!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.inventory_2_outlined, color: pureYellow, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? "Unnamed Item",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          product['category'] ?? "General",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product['price'] ?? r"$0.00",
                    style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: tajiError),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).cardColor,
                          title: const Text("Delete Product?"),
                          content: const Text("This will permanently remove the product from the store."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: tajiError)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ProductManager.deleteProduct(product['name']!);
                        widget.onProductDeleted?.call();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }
}
