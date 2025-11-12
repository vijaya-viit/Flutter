import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(SlidingPuzzleApp());

class SlidingPuzzleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '15 Puzzle',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SlidingPuzzlePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SlidingPuzzlePage extends StatefulWidget {
  @override
  _SlidingPuzzlePageState createState() => _SlidingPuzzlePageState();
}

class _SlidingPuzzlePageState extends State<SlidingPuzzlePage> {
 
  List<int> tiles = List<int>.generate(16, (i) => i); 

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
   
    tiles = List<int>.from(List<int>.generate(15, (i) => i + 1))..add(0);
    _shuffleSolvable();
  }

  void _shuffleSolvable() {
    final rng = Random();
    
    do {
      tiles.shuffle(rng);
    } while (!_isSolvable(tiles) || _isSolvedList(tiles));
    setState(() {}); 
  }

  
  bool _isSolvable(List<int> list) {
    int inversions = 0;
    List<int> arr = list.where((v) => v != 0).toList();
    for (int i = 0; i < arr.length; i++) {
      for (int j = i + 1; j < arr.length; j++) {
        if (arr[i] > arr[j]) inversions++;
      }
    }
    
    int blankIndex = list.indexOf(0);
    int blankRowFromBottom = 4 - (blankIndex ~/ 4); 
    
    return ((inversions + blankRowFromBottom) % 2) == 0;
  }

  bool _isSolvedList(List<int> list) {
    for (int i = 0; i < 15; i++) {
      if (list[i] != i + 1) return false;
    }
    return list[15] == 0;
  }

  void _onTileTap(int idx) {
    final emptyIdx = tiles.indexOf(0);
    if (_canMove(idx, emptyIdx)) {
      setState(() {
        tiles[emptyIdx] = tiles[idx];
        tiles[idx] = 0;
      });

      if (_isSolvedList(tiles)) {
        Future.delayed(Duration(milliseconds: 200), () => _showSolvedDialog());
      }
    }
  }

  bool _canMove(int idx, int emptyIdx) {
    int r1 = idx ~/ 4;
    int c1 = idx % 4;
    int r2 = emptyIdx ~/ 4;
    int c2 = emptyIdx % 4;
    return (r1 == r2 && (c1 - c2).abs() == 1) || (c1 == c2 && (r1 - r2).abs() == 1);
  }

  void _showSolvedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Solved! 🎉'),
        content: Text('You solved the puzzle. Play again?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _newGame();
            },
            child: Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tileSize = 78.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('15 Puzzle'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _newGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: tileSize * 4 + 16,
              height: tileSize * 4 + 16,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final val = tiles[index];
                  if (val == 0) {
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => _onTileTap(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(2, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          val.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _shuffleSolvable,
              icon: Icon(Icons.shuffle),
              label: Text('Shuffle (Solvable)'),
            ),
            SizedBox(height: 8),
            Text(
              'Tap tiles adjacent to the empty space to move.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
