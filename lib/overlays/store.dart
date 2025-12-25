import 'package:flutter/material.dart';
import '../game/aqua_path_game.dart';

class Store extends StatefulWidget {
  final AquaPathGame game;

  const Store({super.key, required this.game});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  int _shells = 0;
  String? _toastMessage;
  bool _isSuccess = true;

  final List<Map<String, dynamic>> _storeItems = [
    {
      'name': 'Extra Life',
      'icon': Icons.favorite,
      'color': Colors.redAccent,
      'price': 50,
      'description': 'Start with an extra life!',
    },
    {
      'name': 'Speed Boost',
      'icon': Icons.flash_on,
      'color': Colors.amber,
      'price': 30,
      'description': 'Swim faster for 10 seconds.',
    },
    {
      'name': 'Shield',
      'icon': Icons.shield,
      'color': Colors.blueAccent,
      'price': 75,
      'description': 'Block one obstacle hit.',
    },
    {
      'name': 'Double Points',
      'icon': Icons.star,
      'color': Colors.purpleAccent,
      'price': 100,
      'description': '2x points for one game.',
    },
    {
      'name': 'Magnet',
      'icon': Icons.attractions,
      'color': Colors.teal,
      'price': 60,
      'description': 'Attract nearby food bubbles.',
    },
    {
      'name': 'Slow Motion',
      'icon': Icons.hourglass_bottom,
      'color': Colors.cyan,
      'price': 80,
      'description': 'Slow down obstacles briefly.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadShells();
  }

  Future<void> _loadShells() async {
    final shells = await widget.game.localStorage.getShells();
    setState(() {
      _shells = shells;
    });
  }

  void _showToast(String message, bool success) {
    setState(() {
      _toastMessage = message;
      _isSuccess = success;
    });
    // Auto-hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  Future<void> _purchaseItem(Map<String, dynamic> item) async {
    final price = item['price'] as int;

    if (_shells >= price) {
      // Deduct shells
      final newShells = _shells - price;
      await widget.game.localStorage.saveShells(newShells);
      setState(() {
        _shells = newShells;
      });
      _showToast('Purchased ${item['name']}!', true);
    } else {
      _showToast('Not enough shells!', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.game.playButtonSound();
                          widget.game.closeStore();
                        },
                        child: Image.asset(
                          'assets/images/btn_home.png',
                          width: 50,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'STORE',
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
                      const SizedBox(width: 50),
                    ],
                  ),
                ),

                // Shells Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/currency_shells.png',
                        width: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_shells',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Store Items Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.95,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _storeItems.length,
                      itemBuilder: (context, index) {
                        return _buildStoreItem(_storeItems[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Toast Message
            if (_toastMessage != null)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _toastMessage!,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItem(Map<String, dynamic> item) {
    final canAfford = _shells >= (item['price'] as int);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (item['color'] as Color).withValues(alpha: 0.8),
            (item['color'] as Color).withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canAfford ? Colors.white54 : Colors.grey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Item Icon
          Icon(
            item['icon'] as IconData,
            size: 36,
            color: canAfford ? Colors.white : Colors.grey,
          ),
          const SizedBox(height: 6),

          // Item Name
          Text(
            item['name'] as String,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              color: canAfford ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              item['description'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9,
                color: canAfford ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Buy Button
          GestureDetector(
            onTap: () => _purchaseItem(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: canAfford ? Colors.green.shade600 : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: canAfford ? Colors.greenAccent : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/currency_shells.png',
                    width: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item['price']}',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      color: canAfford ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

