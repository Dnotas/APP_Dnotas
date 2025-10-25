import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class FilialSelector extends StatelessWidget {
  const FilialSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        // Se não tem filiais, não mostra o seletor
        if (user?.filiais == null || user!.filiais!.isEmpty) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  authProvider.selectedFilial != null 
                    ? Icons.store 
                    : Icons.business,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  authProvider.selectedFilial != null ? 'Filial' : 'Matriz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
          tooltip: 'Trocar entre Matriz e Filiais',
          offset: const Offset(0, 40),
          onSelected: (value) {
            if (value == 'matriz') {
              authProvider.selectFilial(null);
            } else {
              // Encontrar a filial pelo CNPJ
              final filial = user.filiais!.firstWhere(
                (f) => f['cnpj'] == value,
              );
              authProvider.selectFilial(filial);
            }
            
            // Mostrar feedback visual
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value == 'matriz' 
                    ? 'Trocado para Matriz' 
                    : 'Trocado para ${user.filiais!.firstWhere((f) => f['cnpj'] == value)['nome']}',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          },
          itemBuilder: (context) => [
            // Opção Matriz
            PopupMenuItem(
              value: 'matriz',
              child: Container(
                decoration: BoxDecoration(
                  color: authProvider.selectedFilial == null 
                    ? Colors.blue.withOpacity(0.1) 
                    : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: authProvider.selectedFilial == null 
                        ? Colors.blue 
                        : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Matriz',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: authProvider.selectedFilial == null 
                                ? Colors.blue 
                                : Colors.black87,
                            ),
                          ),
                          Text(
                            user.nomeEmpresa,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (authProvider.selectedFilial == null)
                      const Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
            
            // Divisor
            const PopupMenuDivider(),
            
            // Opções de Filiais
            ...user.filiais!.map<PopupMenuEntry<String>>((filial) {
              final isSelected = authProvider.selectedFilial != null && 
                                authProvider.selectedFilial!['cnpj'] == filial['cnpj'];
              
              return PopupMenuItem<String>(
                value: filial['cnpj'],
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Colors.blue.withOpacity(0.1) 
                      : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: isSelected 
                          ? Colors.blue 
                          : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filial['nome'] ?? 'Filial',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                  ? Colors.blue 
                                  : Colors.black87,
                              ),
                            ),
                            Text(
                              _formatCnpj(filial['cnpj'] ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String _formatCnpj(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
}