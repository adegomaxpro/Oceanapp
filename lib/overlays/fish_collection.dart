import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';

class FishCollection extends StatefulWidget {
  final AquaPathGame game;

  const FishCollection({super.key, required this.game});

  @override
  State<FishCollection> createState() => _FishCollectionState();
}

class _FishCollectionState extends State<FishCollection> {
  int _fishCount = 0;

  final List<Map<String, dynamic>> _fishTypes = [
    {
      'name': 'Clownfish',
      'image': 'assets/images/fish_clownfish.png',
      'description': 'A friendly orange fish with white stripes.',
      'unlocked': true,
    },
    {
      'name': 'Teal Fish',
      'image': 'assets/images/fish_teal.png',
      'description': 'A beautiful teal-colored tropical fish.',
      'unlocked': true,
    },
    {
      'name': 'Blue Tang',
      'image': 'assets/images/fish_blue_tang.png',
      'description': 'The majestic blue tang, king of the reef!',
      'unlocked': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFishCount();
  }

  Future<void> _loadFishCount() async {
    final count = await widget.game.localStorage.getFishCount();
    setState(() {
      _fishCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.game.playButtonSound();
                      widget.game.closeFishCollection();
                    },
                    child: Image.asset(
                      'assets/images/btn_home.png',
                      width: 50,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'FISH COLLECTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 50), // Balance the back button
                ],
              ),
            ),

            // Fish Saved Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/fish_clownfish.png',
                    width: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Fish Saved: $_fishCount',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Fish Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _fishTypes.length,
                  itemBuilder: (context, index) {
                    return _buildFishCard(_fishTypes[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishCard(Map<String, dynamic> fish) {
    final bool unlocked = fish['unlocked'] as bool;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unlocked
              ? [Colors.teal.shade700, Colors.teal.shade900]
              : [Colors.grey.shade700, Colors.grey.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? Colors.tealAccent : Colors.grey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fish Image
          Image.asset(
            fish['image'] as String,
            width: 80,
            height: 80,
            color: unlocked ? null : Colors.black54,
            colorBlendMode: unlocked ? null : BlendMode.saturation,
          ),
          const SizedBox(height: 12),

          // Fish Name
          Text(
            fish['name'] as String,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              color: unlocked ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              fish['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11,
                color: unlocked ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ),

          if (!unlocked) ...[
            const SizedBox(height: 8),
            const Icon(Icons.lock, color: Colors.grey, size: 20),
          ],
        ],
      ),
    );
  }
}

