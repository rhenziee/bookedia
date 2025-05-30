import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'terms_page.dart';
import 'package:file_picker/file_picker.dart';
import 'main.dart';

class RegistrationPage extends StatefulWidget {
  final String verifiedEmail;
  const RegistrationPage({super.key, required this.verifiedEmail});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middleinitialController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();

  String? _selectedProvince;
  String? _selectedMunicipality;
  String? _selectedBarangay;

  List<dynamic> _provinces = [];
  List<dynamic> _municipalities = [];
  List<dynamic> _barangays = [];

  List<List<dynamic>> _zipCodeData = [];

  @override
  void initState() {
    super.initState();
    _loadZipCodes();
    _fetchProvinces();

    _emailController.text = widget.verifiedEmail;
  }

  Future<void> _loadZipCodes() async {
    final rawData = await rootBundle.loadString('lib/assets/PHLZipCodes.csv');
    final List<List<dynamic>> csvData = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(rawData);

    setState(() {
      _zipCodeData = csvData.skip(1).toList(); // skip header row
    });
  }

  Future<void> _fetchProvinces() async {
    final response = await http.get(
      Uri.parse('https://psgc.gitlab.io/api/provinces/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _provinces = json.decode(response.body);
      });
    }
  }

  Future<void> _fetchMunicipalities(String provinceCode) async {
    final response = await http.get(
      Uri.parse(
        'https://psgc.gitlab.io/api/provinces/$provinceCode/cities-municipalities/',
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        _municipalities = json.decode(response.body);
      });
    }
  }

  Future<void> _fetchBarangays(String municipalityCode) async {
    final response = await http.get(
      Uri.parse(
        'https://psgc.gitlab.io/api/cities-municipalities/$municipalityCode/barangays/',
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        _barangays = json.decode(response.body);
      });
    }
  }

  String? _getMunicipalityNameByCode(String code) {
    try {
      final match = _municipalities.firstWhere(
        (municipality) => municipality['code'] == code,
      );
      return match['name'];
    } catch (e) {
      return null;
    }
  }

  void _updateZipCode() {
    if (_selectedMunicipality != null) {
      for (var row in _zipCodeData) {
        if (row.length >= 4 &&
            row[2].toString().toLowerCase() ==
                _getMunicipalityNameByCode(
                  _selectedMunicipality!,
                )?.toLowerCase()) {
          setState(() {
            _zipcodeController.text = row[3].toString();
          });
          return;
        }
      }
      _zipcodeController.text = 'N/A';
    }
  }

  String? _idUploadPath;
  String? _licenseUploadPath;
  String? _resumeUploadPath;

  Future<void> _pickFile(Function(String) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onFilePicked(result.files.single.path!);
    }
  }

  bool _agreedToTerms = false;
  String? _userType = 'Buyer';

  Future<void> _submitRegistration() async {
    final uri = Uri.parse('http:// 192.168.68.116:5000/submit_form');

    var request = http.MultipartRequest('POST', uri);
    request.fields['surname'] = _lastnameController.text;
    request.fields['firstname'] = _firstnameController.text;
    request.fields['middle_initial'] = _middleinitialController.text;
    request.fields['email'] = _emailController.text;
    request.fields['contact'] = _contactController.text;
    request.fields['province'] = _selectedProvince ?? '';
    request.fields['municipality'] = _selectedMunicipality ?? '';
    request.fields['barangay'] = _selectedBarangay ?? '';
    request.fields['zip_code'] = _zipcodeController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['userType'] = _userType ?? '';

    if (_idUploadPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('idUpload', _idUploadPath!),
      );
    }
    if (_userType == 'seller' && _licenseUploadPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'businessCertUpload',
          _licenseUploadPath!,
        ),
      );
    }
    if (_userType == 'courier') {
      if (_licenseUploadPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'driversLicense',
            _licenseUploadPath!,
          ),
        );
      }
      if (_resumeUploadPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('resumeUpload', _resumeUploadPath!),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return; // ✅ fix for async gap
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text(
                'Your account has been created successfully.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registration failed.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF432818),
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF432818),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E5),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('lib/assets/signup.png', height: 100),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextFormField(
                    controller: _middleinitialController,
                    decoration: const InputDecoration(
                      labelText: 'Middle Initial',
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Province'),
                    value: _selectedProvince,
                    items:
                        _provinces.map<DropdownMenuItem<String>>((province) {
                          return DropdownMenuItem<String>(
                            value: province['code'] as String,
                            child: Text(province['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvince = value;
                        _selectedMunicipality = null;
                        _selectedBarangay = null;
                        _municipalities = [];
                        _barangays = [];
                        _zipcodeController.clear();
                      });
                      _fetchMunicipalities(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Municipality/City',
                    ),
                    value: _selectedMunicipality,
                    items:
                        _municipalities.map<DropdownMenuItem<String>>((
                          municipality,
                        ) {
                          return DropdownMenuItem<String>(
                            value: municipality['code'] as String,
                            child: Text(municipality['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMunicipality = value;
                        _selectedBarangay = null;
                        _barangays = [];
                        _zipcodeController.clear();
                      });
                      _fetchBarangays(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Barangay'),
                    value: _selectedBarangay,
                    items:
                        _barangays.map<DropdownMenuItem<String>>((barangay) {
                          return DropdownMenuItem<String>(
                            value: barangay['name'],
                            child: Text(barangay['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBarangay = value;
                      });
                      _updateZipCode();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _zipcodeController,
                    decoration: const InputDecoration(labelText: 'ZIP Code'),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text('Buyer'),
                    value: 'Buyer',
                    groupValue: _userType,
                    onChanged: (value) {
                      setState(() {
                        _userType = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Courier'),
                    value: 'Courier',
                    groupValue: _userType,
                    onChanged: (value) {
                      setState(() {
                        _userType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_userType == 'Buyer' || _userType == 'Courier') ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upload Valid ID'),
                        ElevatedButton(
                          onPressed: () async {
                            await _pickFile((path) {
                              setState(() => _idUploadPath = path);
                            });
                          },
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                    if (_idUploadPath != null)
                      Text(
                        'Selected: $_idUploadPath',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],

                  if (_userType == 'Courier') ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upload Driver\'s License'),
                        ElevatedButton(
                          onPressed: () async {
                            await _pickFile((path) {
                              setState(() => _licenseUploadPath = path);
                            });
                          },
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                    if (_licenseUploadPath != null)
                      Text(
                        'Selected: $_licenseUploadPath',
                        style: const TextStyle(fontSize: 12),
                      ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upload Resume'),
                        ElevatedButton(
                          onPressed: () async {
                            await _pickFile((path) {
                              setState(() => _resumeUploadPath = path);
                            });
                          },
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                    if (_resumeUploadPath != null)
                      Text(
                        'Selected: $_resumeUploadPath',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsPage(),
                              ),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Agreements',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      if (!_agreedToTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You must agree to the Terms and Agreements',
                            ),
                          ),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        _submitRegistration(); // create this function below
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF884B25,
                      ), // Set background color here
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ), // Optional: for nicer spacing
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
