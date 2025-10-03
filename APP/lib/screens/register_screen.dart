import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _nomeEmpresaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedFilial = 'matriz';

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeEmpresaController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatCnpj(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.length > 14) value = value.substring(0, 14);
    
    if (value.length > 12) {
      return '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5, 8)}/${value.substring(8, 12)}-${value.substring(12)}';
    } else if (value.length > 8) {
      return '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5, 8)}/${value.substring(8)}';
    } else if (value.length > 5) {
      return '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5)}';
    } else if (value.length > 2) {
      return '${value.substring(0, 2)}.${value.substring(2)}';
    }
    return value;
  }

  String _formatTelefone(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.length > 11) value = value.substring(0, 11);
    
    if (value.length > 10) {
      return '(${value.substring(0, 2)}) ${value.substring(2, 7)}-${value.substring(7)}';
    } else if (value.length > 6) {
      return '(${value.substring(0, 2)}) ${value.substring(2, 6)}-${value.substring(6)}';
    } else if (value.length > 2) {
      return '(${value.substring(0, 2)}) ${value.substring(2)}';
    }
    return value;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Remover formatação
    final cnpj = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final telefone = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    final success = await authProvider.signUp(
      cnpj: cnpj,
      nomeEmpresa: _nomeEmpresaController.text,
      email: _emailController.text,
      password: _passwordController.text,
      filialId: _selectedFilial,
      telefone: telefone.isNotEmpty ? telefone : null,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao criar conta'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/logo_dnotas.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Título
                Text(
                  'Cadastre sua empresa',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Campo CNPJ
                TextFormField(
                  controller: _cnpjController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CNPJ *',
                    hintText: '00.000.000/0000-00',
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: (value) {
                    final formatted = _formatCnpj(value);
                    if (formatted != value) {
                      _cnpjController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CNPJ';
                    }
                    final cnpj = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cnpj.length != 14) {
                      return 'CNPJ deve ter 14 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Nome da Empresa
                TextFormField(
                  controller: _nomeEmpresaController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Empresa *',
                    hintText: 'Digite o nome da empresa',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome da empresa';
                    }
                    if (value.length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'seu@email.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Telefone
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(00) 00000-0000',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  onChanged: (value) {
                    final formatted = _formatTelefone(value);
                    if (formatted != value) {
                      _telefoneController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Filial
                DropdownButtonFormField<String>(
                  value: _selectedFilial,
                  decoration: const InputDecoration(
                    labelText: 'Filial *',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'matriz', child: Text('Matriz')),
                    DropdownMenuItem(value: 'filial_1', child: Text('Filial 1')),
                    DropdownMenuItem(value: 'filial_2', child: Text('Filial 2')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilial = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha *',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha *',
                    hintText: 'Digite a senha novamente',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme a senha';
                    }
                    if (value != _passwordController.text) {
                      return 'Senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botão Cadastrar
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleRegister,
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              )
                            : const Text('Criar Conta'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Link para login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Já tem conta? Faça login',
                    style: TextStyle(color: Colors.white),
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