import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Hardcoded values mimicking user state or mock data
  String userName = 'Luiz Silva';
  String userEmail = 'luiz.silva@koavy.com';
  String userAge = '28';
  String userWeight = '78';
  String userHeight = '182';
  String userBlood = 'AB+';
  String emergencyContact = 'Maria Silva (Mãe) - (11) 98888-7777';

  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController bloodController;
  late TextEditingController contactController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: userName);
    emailController = TextEditingController(text: userEmail);
    ageController = TextEditingController(text: userAge);
    weightController = TextEditingController(text: userWeight);
    heightController = TextEditingController(text: userHeight);
    bloodController = TextEditingController(text: userBlood);
    contactController = TextEditingController(text: emergencyContact);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    bloodController.dispose();
    contactController.dispose();
    super.dispose();
  }

  void saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userName = nameController.text;
        userEmail = emailController.text;
        userAge = ageController.text;
        userWeight = weightController.text;
        userHeight = heightController.text;
        userBlood = bloodController.text;
        emergencyContact = contactController.text;
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil atualizado com sucesso!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xff00d4aa),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PERFIL DO USUÁRIO',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: const Color(0xff00f2ff)),
            onPressed: () {
              if (isEditing) {
                saveProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar with glow
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xff00f2ff), Color(0xff00d4aa)],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xff111418),
                        child: Icon(Icons.person, size: 60, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Fields List
              _buildSectionTitle('Dados Pessoais'),
              const SizedBox(height: 12),
              _buildTextField('Nome Completo', nameController, Icons.person_outline, isEditing),
              const SizedBox(height: 16),
              _buildTextField('E-mail', emailController, Icons.email_outlined, isEditing, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Idade (anos)', ageController, Icons.calendar_today, isEditing, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Tipo Sanguíneo', bloodController, Icons.bloodtype_outlined, isEditing)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Peso (kg)', weightController, Icons.scale_outlined, isEditing, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Altura (cm)', heightController, Icons.height, isEditing, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 30),

              _buildSectionTitle('Segurança e Contato'),
              const SizedBox(height: 12),
              _buildTextField('Contato de Emergência', contactController, Icons.contact_emergency_outlined, isEditing),
              const SizedBox(height: 40),

              if (isEditing)
                ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shadowColor: const Color(0xff00f2ff).withValues(alpha: 0.3),
                    elevation: 10,
                  ),
                  child: const Text('SALVAR ALTERAÇÕES'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xff00f2ff),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData prefixIcon,
    bool enabled, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(prefixIcon, color: const Color(0xff00d4aa)),
        filled: true,
        fillColor: enabled ? const Color(0xff161a22) : const Color(0xff111418),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff00f2ff)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}
