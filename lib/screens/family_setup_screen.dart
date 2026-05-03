import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../widgets/glass_card.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  Map<String, dynamic>? _family;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    final db = DatabaseHelper.instance;
    final family = await db.getFamily();
    final members = await db.getMembers();

    setState(() {
      _family = family;
      _members = members;
      _isLoading = false;
    });
  }

  void _showAddMemberDialog() {
    String name = "";
    String role = "Member";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Family Member", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Member Name"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: role,
              dropdownColor: SashTheme.backgroundDark,
              onChanged: (val) => role = val!,
              items: ["Admin", "Member", "Child", "Partner"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty && _family != null) {
                    await DatabaseHelper.instance.insertMember({
                      'family_id': _family!['id'],
                      'name': name,
                      'role': role,
                    });
                    Navigator.pop(context);
                    _loadFamilyData();
                  }
                },
                child: const Text("Add Member"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFamilyDialog() {
    String name = _family?['name'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rename Family", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: name),
              onChanged: (val) => name = val,
              decoration: const InputDecoration(labelText: "Family Name"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await DatabaseHelper.instance.updateFamilyName(name);
                    Navigator.pop(context);
                    _loadFamilyData();
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: SashTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Family Setup", style: TextStyle(fontFamily: 'Outfit')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFamilyHeader(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                TextButton.icon(
                  onPressed: _showAddMemberDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Member"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._members.map((member) => _buildMemberCard(member)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyHeader() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SashTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.family_restroom, color: SashTheme.primary, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_family?['name'] ?? "Sash Family", 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                const Text("Main Household", style: TextStyle(color: Colors.white60, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditFamilyDialog,
            icon: const Icon(Icons.edit_outlined, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: SashTheme.primary.withOpacity(0.1),
              child: Text(member['name'][0].toUpperCase(), 
                style: const TextStyle(color: SashTheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(member['role'], style: const TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
            ),
            if (member['role'] != 'Admin')
              IconButton(
                onPressed: () async {
                  await DatabaseHelper.instance.deleteMember(member['id']);
                  _loadFamilyData();
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white10, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
