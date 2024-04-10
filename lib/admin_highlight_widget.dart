import 'package:flutter/material.dart';
import 'admin_user_model.dart';
import 'admin_details_page.dart'; // Importe a página de detalhes do administrador.

class AdminHighlightWidget extends StatelessWidget {
  final AdminUserModel adminUser;

  AdminHighlightWidget({required this.adminUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adiciona espaço entre os ícones
      child: GestureDetector(
        onTap: () {
          // Implemente a navegação para a página de detalhes do administrador aqui
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminDetailsPage(admin: adminUser),
            ),
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2), // Espaço entre a borda e o avatar
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple, // Cor da borda
                      width: 2, // Espessura da borda
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Posição da sombra
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(adminUser.photoUrl),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    Icons.verified_user, // Ícone de verificação
                    color: Colors.blue, // Cor do ícone de verificação
                    size: 20, // Tamanho do ícone de verificação
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(adminUser.name, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
