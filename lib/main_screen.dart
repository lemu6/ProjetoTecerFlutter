import 'package:flutter/material.dart';
import 'package:logintest/ranking_page.dart';
import 'home_page.dart';
import 'user_profile_page.dart';
// Importe sua terceira página de Ranking aqui

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    UserProfilePage(),
    HomePage(),
    RankingPage(),
    
    // Sua terceira página de Ranking aqui
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(1); // Ação do botão do perfil
        },
        child: Icon(Icons.home, color: Colors.white), // Ícone de adição branco
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 15.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Botão Home
            IconButton(
              icon: Icon(Icons.person_2_sharp, color: _currentIndex == 0 ? Colors.purple : Colors.grey),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            // Espaço reservado para o botão do perfil
            SizedBox(width: 48), // Garantir o alinhamento correto
            // Botão Ranking
            IconButton(
              icon: Icon(Icons.leaderboard, color: _currentIndex == 2 ? Colors.purple : Colors.grey),
              onPressed: () {
                _onItemTapped(2);
              },
            ),
          ],
        ),
        color: Colors.white,
      ),
    );
  }
}
