import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(home: RankingPage()));
}

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rankings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Remove a sombra do AppBar
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false, // Impede que o botão de voltar seja exibido
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Ranking Global'),
            SizedBox(height: 10),
            Expanded(child: buildGlobalRanking()),
            SizedBox(height: 20),
            _buildSectionHeader('Ranking por Cidade'),
            SizedBox(height: 10),
            Expanded(child: buildCityRanking()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildGlobalRanking() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        List<DocumentSnapshot> rankedUsers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: rankedUsers.length,
          itemBuilder: (context, index) =>
              buildRankingTile(rankedUsers[index], index + 1),
        );
      },
    );
  }

  Widget buildCityRanking() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        Map<String, List<DocumentSnapshot>> usersByCity = {};
        for (var doc in snapshot.data!.docs) {
          String city = doc['city'] ?? 'Desconhecido';
          (usersByCity[city] ??= []).add(doc);
        }

        return ListView.builder(
          itemCount: usersByCity.entries.length,
          itemBuilder: (context, index) {
            var entry = usersByCity.entries.elementAt(index);
            return buildCityRankingCard(entry.key, entry.value);
          },
        );
      },
    );
  }

  Widget buildCityRankingCard(String cityName, List<DocumentSnapshot> users) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cityName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: users
                  .map((user) => buildCityUserTile(user))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCityUserTile(DocumentSnapshot user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Text(user['name'][0],
            style: TextStyle(color: Colors.white)),
      ),
      title: Text(user['name']),
      trailing: Chip(
        label: Text('${user['points']} pontos'),
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget buildRankingTile(DocumentSnapshot user, int rank) {
    Color rankColor = rank == 1
        ? Colors.orange
        : rank == 2
            ? Colors.grey
            : rank == 3
                ? Colors.brown
                : Colors.grey;
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(user['name']),
        subtitle: Text('Pontos: ${user['points']}'),
        trailing: Chip(
          label: Text('#$rank'),
          backgroundColor: rankColor,
        ),
      ),
    );
  }
}
