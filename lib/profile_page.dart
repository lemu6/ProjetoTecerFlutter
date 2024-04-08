import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navega para a página de configurações
            },
          ),
        ],
        backgroundColor: themeData.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            HeaderSection(),
            InfoSection(),
            ActionButtonSection(),
          ],
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeData.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          SizedBox(height: 10),
          Text(
            'Zeshan H.',
            style: themeData.textTheme.headline6?.copyWith(color: Colors.white) ??
                   TextStyle(color: Colors.white, fontSize: 24), // Fallback style
          ),
          Text(
            'ID Médico',
            style: themeData.textTheme.subtitle1?.copyWith(color: Colors.white70) ??
                   TextStyle(color: Colors.white70, fontSize: 16), // Fallback style
          ),
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Wrap(
        runSpacing: 20,
        spacing: 20,
        children: <Widget>[
          InfoCard('QUILÔMETROS', 'Piripiri', Icons.directions_run),
          InfoCard('IDADE', '23 Anos', Icons.cake),
          InfoCard('LEITURA', '15 Artigos', Icons.book),
          InfoCard('DATA DE NASC.', '07/1998', Icons.calendar_today),
          InfoCard('SEXO', 'Masculino', Icons.person),
          InfoCard('MAIS', '+', Icons.add_circle_outline),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  InfoCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: themeData.primaryColor),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: ElevatedButton(
        onPressed: () {
          // Implementar ação para ranking
        },
        child: Text('RANKING'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(vertical: 12),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
