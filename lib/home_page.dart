import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_post_page.dart';
import 'all_posts_page.dart';
import 'auth_service.dart';
import 'admin_user_model.dart';
import 'admin_highlight_widget.dart';
import 'PostCardWidget.dart'; // Importe o widget do card aqui
import 'post_model.dart'; // Modelo para os posts

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  List<AdminUserModel> _adminUsers = [];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _fetchAdminUsers();
  }

  void _checkAdminStatus() async {
    bool isAdmin = await _authService.isUserAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  void _fetchAdminUsers() async {
    var adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .get();
    var admins = adminSnapshot.docs
        .map((doc) => AdminUserModel.fromSnapshot(doc))
        .toList();
    setState(() {
      _adminUsers = admins;
    });
  }

  Widget _buildAdminHighlights() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _adminUsers.length,
        itemBuilder: (context, index) {
          return AdminHighlightWidget(adminUser: _adminUsers[index]);
        },
      ),
    );
  }

Widget _buildHorizontalPostCards() {
  double cardHeight = MediaQuery.of(context).size.height * 0.25;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          "Últimas publicações",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      Container(
        height: cardHeight,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts')
              .orderBy('dateCreated', descending: true)
              .limit(3)  // Limita a busca aos três últimos posts
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar os posts'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Ainda sem posts'));
            }
            var documents = snapshot.data!.docs;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: documents.length + 1,  // Adiciona mais um para o botão de 'Ver todos'
              itemBuilder: (context, index) {
                if (index == documents.length) {
                  // Se for o último item, retorna o card de 'Ver todos'
                  return _buildViewAllCard(context);
                } else {
                  // Caso contrário, retorna o card do post
                  BlogPost post = BlogPost.fromJson(documents[index].data() as Map<String, dynamic>);
                  return PostCardWidget(post: post);
                }
              },
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildViewAllCard(BuildContext context) {
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllPostsPage())),
    child: Container(
      width: 150, // Defina uma largura fixa que se encaixe bem no layout
      height: 150, // Altura para fazer o card quadrado, ajuste conforme necessário
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(15), // Raio da borda para arredondar os cantos
        boxShadow: [ // Sombra para dar um efeito elevado
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Ver todos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem vindo ao TECER'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())),
            ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllPostsPage())),
          ),
        ],
      ),
      body: Column(
            children: [
              _buildAdminHighlights(),
              SizedBox(height: 16), // Espaço opcional entre os destaques e os cards de post
              _buildHorizontalPostCards(), // Não mais envolvido por um Expanded
              // Conteúdo adicional que virá no meio da página
            ],
      ),
    );
  }
}
