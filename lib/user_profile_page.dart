import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> _userDataFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildUserProfile(context, snapshot.data!);
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

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileDetails(userData),
          Divider(),
          _buildRankingSection(context, points, badges),
          _buildReadPostsSection(context),
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

  Widget _buildReadPostsSection(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Text('Você precisa estar logado para ver isso.');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('readPosts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Ocorreu um erro ao carregar os posts lidos.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Nenhum post lido ainda.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var readPostData = snapshot.data!.docs[index].data() as Map<String, dynamic>?;
            if (readPostData == null || !readPostData.containsKey('postId')) {
              return ListTile(
                title: Text('Detalhes do post não disponíveis.'),
              );
            }
            String? postId = readPostData['postId'] as String?;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
              builder: (context, postSnapshot) {
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Carregando...'));
                }

                if (postSnapshot.hasError || !postSnapshot.hasData) {
                  return ListTile(title: Text('Erro ao carregar dados do post.'));
                }

                var postData = postSnapshot.data!.data() as Map<String, dynamic>?;
                if (postData == null) {
                  return ListTile(title: Text('Post não encontrado.'));
                }
                String postTitle = postData['title'] as String? ?? 'Sem título';
                DateTime? readOnDate = (readPostData['readOn'] as Timestamp?)?.toDate();
                String formattedDate = readOnDate != null ? DateFormat('dd/MM/yyyy').format(readOnDate) : 'Data desconhecida';

                return ListTile(
                  title: Text(postTitle),
                  subtitle: Text('Lido em: $formattedDate'),
                );
              },
            );
          },
        );
      },
    );
  }


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
                userData['email'] ?? 'Email',
                style: theme.textTheme.subtitle1?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              InfoTile(icon: Icons.location_city, title: "Cidade", value: userData['city'] ?? 'Cidade'),
              InfoTile(icon: Icons.cake, title: "Idade", value: '${userData['age'] ?? 'Idade'} Anos'),
              InfoTile(icon: Icons.person, title: "Gênero", value: userData['gender'] ?? 'Gênero'),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
