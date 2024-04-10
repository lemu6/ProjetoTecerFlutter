import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logintest/ReadPostsPage.dart';
import 'package:logintest/edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> _userDataFuture;
  Map<String, dynamic>? currentUserData; // Variável para armazenar os dados atuais do usuário

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>? ?? {};
    }
    return {};
  }

      Future<int> _fetchUserGlobalRank(String userId) async {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .get();

        int rank = 1;
        for (var doc in snapshot.docs) {
          if (doc.id == userId) {
            return rank;
          }
          rank++;
        }

        return -1; // Retorne -1 caso o usuário não seja encontrado no ranking
      }

      Future<int> _fetchUserCityRank(String userId, String city) async {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('city', isEqualTo: city)
            .orderBy('points', descending: true)
            .get();

        int rank = 1;
        for (var doc in snapshot.docs) {
          if (doc.id == userId) {
            return rank;
          }
          rank++;
        }

        return -1; // Retorne -1 caso o usuário não seja encontrado no ranking
      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              if (currentUserData != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfilePage(userData: currentUserData!),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Não foi possível carregar os dados do usuário.'))
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              currentUserData = snapshot.data; // Armazenar os dados recebidos
              return _buildUserProfile(context, currentUserData!); // Passar currentUserData ao invés de snapshot.data!
            } else if (snapshot.hasError) {
              return Center(child: Text("Erro ao carregar os dados: ${snapshot.error}"));
            }
            return Text("Nenhum dado encontrado para o usuário.");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
Widget _buildUserProfile(BuildContext context, Map<String, dynamic> userData) {
  int points = userData['points'] ?? 0;
  List<String> badges = List<String>.from(userData['badges'] ?? []);

  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String city = userData['city'] ?? '';

  return SingleChildScrollView(
    child: Column(
      children: [
        ProfileDetails(userData),
        Divider(),
        _buildRankingSection(context, points, badges),
        // A seção ReadPosts foi removida da visualização direta
        _buildMenuSection(context, userId, city), // Passa os argumentos corretos aqui
        // Exibe o conteúdo baseado na seleção do menu
        // Adicione aqui outras seções conforme necessário
      ],
    ),
  );
}


  Widget _buildRankingSection(BuildContext context, int points, List<String> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text('Ranking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: Icon(Icons.stars, color: Colors.amber),
          title: Text('Pontos: $points', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            children: badges.map((badge) => Chip(
              avatar: Icon(Icons.check_circle, color: Colors.green),
              label: Text(badge),
            )).toList(),
          ),
        ),
      ],
    );
  }

Widget _buildMenuSection(BuildContext context, String userId, String city) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('Ranking Geral'),
          onPressed: () async {
            try {
              int rank = await _fetchUserGlobalRank(userId);
              _showRankDialog(context, 'Ranking Geral', rank);
            } catch (error) {
              // Handle errors, e.g., display an error message
              print('Error fetching global rank: $error'); 
            }
          },
        ),
        // ... Similar changes for other buttons

        ElevatedButton(
          child: Text('Posts Lidos'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReadPostsPage(),
              ),
            );
          },
        ),
      ],
    ),
  );
}


    void _showRankDialog(BuildContext context, String title, int rank) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: rank != -1
                ? Text('Sua posição é: $rank')
                : Text('Você ainda não está no ranking.'),
            actions: <Widget>[
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
}

void _navigateToReadPosts(BuildContext context, String userId) {
  // Navegar para a página de posts lidos
  // Você precisará implementar esta página e definir a rota
  Navigator.of(context).pushNamed('/readPostsPage', arguments: userId);
}


class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> userData;

  ProfileDetails(this.userData);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userData['photoUrl'] ?? 'https://via.placeholder.com/150'),
              ),
              SizedBox(height: 10),
              Text(
                userData['name'] ?? 'Nome',
                style: theme.textTheme.headline6?.copyWith(color: Colors.white),
              ),
              Text(
                userData['surname'] ?? 'Sobrenome',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        _buildInfoGrid(userData), // Chamada ao novo método que cria a GridView
      ],
    );
  }

  Widget _buildInfoGrid(Map<String, dynamic> userData) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: <Widget>[
        InfoTile(icon: Icons.location_city, title: "Cidade", value: userData['city'] ?? 'Cidade'),
        InfoTile(icon: Icons.person_3_rounded, title: "Nome da Mãe", value: userData['motherName'] ?? 'Nome da mãe'),
        InfoTile(icon: Icons.cake, title: "Idade", value: '${userData['age'] ?? 'Idade'} Anos'),
        InfoTile(icon: Icons.location_city, title: "Quilombo", value: userData['quilomboName'] ?? 'Quilombo'),
        InfoTile(icon: Icons.person, title: "Gênero", value: userData['gender'] ?? 'Gênero'),
      ],
    );
  }
}


class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoTile({Key? key, required this.icon, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
