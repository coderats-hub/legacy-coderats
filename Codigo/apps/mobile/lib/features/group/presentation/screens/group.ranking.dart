import 'package:flutter/material.dart';

class GroupRankingScreen extends StatelessWidget {
  final List<UserRanking>? rankings;
  GroupRankingScreen({super.key, this.rankings});

  @override
  Widget build(BuildContext context) {
    final rankingList = rankings ?? sampleRanking;
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ranking do Grupo',
          style: TextStyle(
            color: Color(0xFFD9D9D9),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: rankingList.length,
          separatorBuilder: (context, i) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final user = rankingList[i];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF444444), width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF9A24DD),
                    child: Text(
                      user.position.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.points} pontos',
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ícone de troféu para top 3
                  if (user.position == 1)
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28)
                  else if (user.position == 2)
                    const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28)
                  else if (user.position == 3)
                    const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserRanking {
  final int position;
  final String name;
  final double points;
  UserRanking({required this.position, required this.name, required this.points});
}

final List<UserRanking> sampleRanking = [
  UserRanking(position: 1, name: 'Alice', points: 49.5),
  UserRanking(position: 2, name: 'Felipe', points: 45.5),
  UserRanking(position: 3, name: 'Gustavo', points: 45.5),
  UserRanking(position: 4, name: 'Bruna', points: 40.0),
  UserRanking(position: 5, name: 'Lucas', points: 38.0),
  UserRanking(position: 6, name: 'Marina', points: 35.0),
  UserRanking(position: 7, name: 'João', points: 30.0),
  UserRanking(position: 8, name: 'Paula', points: 28.0),
  UserRanking(position: 9, name: 'Rafael', points: 25.0),
  UserRanking(position: 10, name: 'Carla', points: 20.0),
];
