import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ParentDetailsForm extends StatefulWidget {
  const ParentDetailsForm({super.key});

  @override
  State<ParentDetailsForm> createState() => _ParentDetailsFormState();
}

class _ParentDetailsFormState extends State<ParentDetailsForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _selectedDOB;
  int? _calculatedAge;
  String? _gender;

  bool _isSaving = false;

  void _pickDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDOB = pickedDate;
        _calculatedAge = DateTime.now().year - pickedDate.year;
        if (DateTime.now().isBefore(
          DateTime(
            pickedDate.year + _calculatedAge!,
            pickedDate.month,
            pickedDate.day,
          ),
        )) {
          _calculatedAge = _calculatedAge! - 1;
        }
      });
    }
  }

  Future<void> _saveDetails() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty || _selectedDOB == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number must be exactly 10 digits")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'onboardingStep': 'profile-complete',
        'name': name,
        'phone': phone,
        'dob': _selectedDOB!.toIso8601String(),
        'age': _calculatedAge,
        'gender': _gender,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully")),
      );

      _nameController.clear();
      _phoneController.clear();
      setState(() {
        _selectedDOB = null;
        _calculatedAge = null;
        _gender = null;
      });

      Navigator.pushNamed(context, '/policy');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/icon/Final logo-01.png',
                height: 130,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parent Form',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123a5b),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField('Full Name', _nameController),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Phone Number',
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Date of Birth',
                        style: TextStyle(fontFamily: 'NexaBold', fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDOB != null
                                    ? DateFormat('yyyy-MM-dd').format(_selectedDOB!)
                                    : 'Select Date of Birth',
                                style: const TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                      if (_calculatedAge != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Age: $_calculatedAge',
                          style: const TextStyle(fontFamily: 'NexaBold', fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 30),
                      const Text(
                        'Gender',
                        style: TextStyle(fontFamily: 'NexaBold', fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildGenderOption('Male'),
                          const SizedBox(width: 16),
                          _buildGenderOption('Female'),
                          const SizedBox(width: 16),
                          _buildGenderOption('Prefer not to say'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0090FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Save Details',
                                  style: TextStyle(
                                    fontFamily: 'NexaBold',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'NexaBold', fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: label == 'Phone Number'
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(fontFamily: 'NexaBold'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value) {
    return Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _gender,
            onChanged: (val) {
              setState(() {
                _gender = val;
              });
            },
            activeColor: const Color(0xFF5F40FB),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'NexaBold', fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
