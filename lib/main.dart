// // main.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'dart:convert';
// import 'dart:math';
//
// void main() {
//   runApp(CricketApp());
// }
//
// class CricketApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cricket Team Management',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomeScreen(),
//       routes: {
//         '/player': (context) => PlayerScreen(),
//         '/host': (context) => HostScreen(),
//         '/create_match': (context) => CreateMatchScreen(),
//         '/manage_teams': (context) => ManageTeamsScreen(),
//         '/scan_players': (context) => ScanPlayersScreen(),
//       },
//     );
//   }
// }
//
// // Data Models
// class PlayRequest {
//   final String playerId;
//   final String name;
//
//   PlayRequest({required this.playerId, required this.name});
//
//   Map<String, dynamic> toJson() => {
//     'playerId': playerId,
//     'name': name,
//   };
//
//   factory PlayRequest.fromJson(Map<String, dynamic> json) => PlayRequest(
//     playerId: json['playerId'],
//     name: json['name'],
//   );
// }
//
// class Match {
//   final String id;
//   final String name;
//   final List<String> team1;
//   final List<String> team2;
//
//   Match({
//     required this.id,
//     required this.name,
//     required this.team1,
//     required this.team2,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'team1': team1,
//     'team2': team2,
//   };
//
//   factory Match.fromJson(Map<String, dynamic> json) => Match(
//     id: json['id'],
//     name: json['name'],
//     team1: List<String>.from(json['team1']),
//     team2: List<String>.from(json['team2']),
//   );
// }
//
// // Local Storage Service
// class LocalStorage {
//   static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//
//   static Future<void> saveRequests(List<PlayRequest> requests) async {
//     final prefs = await _prefs;
//     await prefs.setStringList(
//         'requests', requests.map((r) => jsonEncode(r.toJson())).toList());
//   }
//
//   static Future<List<PlayRequest>> getRequests() async {
//     final prefs = await _prefs;
//     final requestStrings = prefs.getStringList('requests') ?? [];
//     return requestStrings
//         .map((s) => PlayRequest.fromJson(jsonDecode(s)))
//         .toList();
//   }
//
//   static Future<void> saveMatches(List<Match> matches) async {
//     final prefs = await _prefs;
//     await prefs.setStringList(
//         'matches', matches.map((m) => jsonEncode(m.toJson())).toList());
//   }
//
//   static Future<List<Match>> getMatches() async {
//     final prefs = await _prefs;
//     final matchStrings = prefs.getStringList('matches') ?? [];
//     return matchStrings.map((s) => Match.fromJson(jsonDecode(s))).toList();
//   }
// }
//
// // Home Screen (Player or Host Selection)
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Cricket Team Management')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/player'),
//               child: Text('Player Mode'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/host'),
//               child: Text('Host Mode'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Player Screen
// class PlayerScreen extends StatefulWidget {
//   @override
//   _PlayerScreenState createState() => _PlayerScreenState();
// }
//
// class _PlayerScreenState extends State<PlayerScreen> {
//   final _nameController = TextEditingController();
//   PlayRequest? _request;
//
//   Future<void> _raiseRequest() async {
//     if (_nameController.text.isNotEmpty) {
//       final request = PlayRequest(
//         playerId: Random().nextInt(1000000).toString(),
//         name: _nameController.text,
//       );
//       final requests = await LocalStorage.getRequests();
//       requests.add(request);
//       await LocalStorage.saveRequests(requests);
//       setState(() {
//         _request = request;
//       });
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Request raised!')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Please enter a name')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Player Dashboard')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Your Name'),
//             ),
//             ElevatedButton(
//               onPressed: _raiseRequest,
//               child: Text('Raise Play Request'),
//             ),
//             if (_request != null) ...[
//               SizedBox(height: 16),
//               Text('Your QR Code:'),
//               QrImageView(
//                 data: jsonEncode(_request!.toJson()),
//                 version: QrVersions.auto,
//                 size: 200.0,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Host Screen
// class HostScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Host Dashboard')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/create_match'),
//               child: Text('Create New Match'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/manage_teams'),
//               child: Text('Manage Teams'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Create Match Screen
// class CreateMatchScreen extends StatefulWidget {
//   @override
//   _CreateMatchScreenState createState() => _CreateMatchScreenState();
// }
//
// class _CreateMatchScreenState extends State<CreateMatchScreen> {
//   final _matchNameController = TextEditingController();
//
//   Future<void> _createMatch() async {
//     if (_matchNameController.text.isNotEmpty) {
//       final match = Match(
//         id: Random().nextInt(1000000).toString(),
//         name: _matchNameController.text,
//         team1: [],
//         team2: [],
//       );
//       final matches = await LocalStorage.getMatches();
//       matches.add(match);
//       await LocalStorage.saveMatches(matches);
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Create Match')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _matchNameController,
//               decoration: InputDecoration(labelText: 'Match Name'),
//             ),
//             ElevatedButton(onPressed: _createMatch, child: Text('Create')),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Manage Teams Screen
// class ManageTeamsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Manage Teams')),
//       body: FutureBuilder<List<Match>>(
//         future: LocalStorage.getMatches(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//           return ListView(
//             children: snapshot.data!.map((match) {
//               return ListTile(
//                 title: Text(match.name),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/scan_players',
//                       arguments: match.id);
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Scan Players Screen
// class ScanPlayersScreen extends StatefulWidget {
//   @override
//   _ScanPlayersScreenState createState() => _ScanPlayersScreenState();
// }
//
// class _ScanPlayersScreenState extends State<ScanPlayersScreen> {
//   MobileScannerController scannerController = MobileScannerController();
//
//   Future<void> _acceptPlayer(PlayRequest request, String matchId, String team) async {
//     final matches = await LocalStorage.getMatches();
//     final match = matches.firstWhere((m) => m.id == matchId);
//     final teamList = team == 'team1' ? match.team1 : match.team2;
//     if (teamList.length < 11) {
//       teamList.add(request.playerId);
//       final updatedMatch = Match(
//         id: match.id,
//         name: match.name,
//         team1: match.team1,
//         team2: match.team2,
//       );
//       matches[matches.indexWhere((m) => m.id == matchId)] = updatedMatch;
//       await LocalStorage.saveMatches(matches);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Player added to $team')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('$team is full')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String matchId = ModalRoute.of(context)!.settings.arguments as String;
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan Players')),
//       body: Column(
//         children: [
//           Expanded(
//             child: MobileScanner(
//               controller: scannerController,
//               onDetect: (barcodeCapture) {
//                 final List<Barcode> barcodes = barcodeCapture.barcodes;
//                 for (final barcode in barcodes) {
//                   if (barcode.rawValue != null) {
//                     try {
//                       final json = jsonDecode(barcode.rawValue!);
//                       final request = PlayRequest.fromJson(json);
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: Text('Add Player'),
//                           content: Text('Add ${request.name} to a team?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _acceptPlayer(request, matchId, 'team1');
//                               },
//                               child: Text('Team 1'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _acceptPlayer(request, matchId, 'team2');
//                               },
//                               child: Text('Team 2'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               child: Text('Cancel'),
//                             ),
//                           ],
//                         ),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Invalid QR code')));
//                     }
//                   }
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     scannerController.dispose();
//     super.dispose();
//   }
// }



// main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(CricketApp());
}

class CricketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Team Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {
        '/player': (context) => PlayerScreen(),
        '/host': (context) => HostScreen(),
        '/create_match': (context) => CreateMatchScreen(),
        '/manage_teams': (context) => ManageTeamsScreen(),
        '/match_details': (context) => MatchDetailsScreen(),
        '/scan_players': (context) => ScanPlayersScreen(),
        '/team_players': (context) => TeamPlayersScreen(),
      },
    );
  }
}

// Data Models
class PlayRequest {
  final String playerId;
  final String name;

  PlayRequest({required this.playerId, required this.name});

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'name': name,
  };

  factory PlayRequest.fromJson(Map<String, dynamic> json) => PlayRequest(
    playerId: json['playerId'],
    name: json['name'],
  );
}

class Match {
  final String id;
  final String name;
  final List<String> team1;
  final List<String> team2;

  Match({
    required this.id,
    required this.name,
    required this.team1,
    required this.team2,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'team1': team1,
    'team2': team2,
  };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json['id'],
    name: json['name'],
    team1: List<String>.from(json['team1']),
    team2: List<String>.from(json['team2']),
  );
}

// Local Storage Service
class LocalStorage {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveRequests(List<PlayRequest> requests) async {
    final prefs = await _prefs;
    await prefs.setStringList(
        'requests', requests.map((r) => jsonEncode(r.toJson())).toList());
  }

  static Future<List<PlayRequest>> getRequests() async {
    final prefs = await _prefs;
    final requestStrings = prefs.getStringList('requests') ?? [];
    return requestStrings
        .map((s) => PlayRequest.fromJson(jsonDecode(s)))
        .toList();
  }

  static Future<void> saveMatches(List<Match> matches) async {
    final prefs = await _prefs;
    await prefs.setStringList(
        'matches', matches.map((m) => jsonEncode(m.toJson())).toList());
  }

  static Future<List<Match>> getMatches() async {
    final prefs = await _prefs;
    final matchStrings = prefs.getStringList('matches') ?? [];
    return matchStrings.map((s) => Match.fromJson(jsonDecode(s))).toList();
  }
}

// Home Screen (Player or Host Selection)
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cricket Team Management')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/player'),
              child: Text('Player Mode'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/host'),
              child: Text('Host Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

// Player Screen
class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _nameController = TextEditingController();
  PlayRequest? _request;

  Future<void> _raiseRequest() async {
    if (_nameController.text.isNotEmpty) {
      final request = PlayRequest(
        playerId: Random().nextInt(1000000).toString(),
        name: _nameController.text,
      );
      final requests = await LocalStorage.getRequests();
      requests.add(request);
      await LocalStorage.saveRequests(requests);
      setState(() {
        _request = request;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Request raised!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a name')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Player Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            ElevatedButton(
              onPressed: _raiseRequest,
              child: Text('Raise Play Request'),
            ),
            if (_request != null) ...[
              SizedBox(height: 16),
              Text('Your QR Code:'),
              QrImageView(
                data: jsonEncode(_request!.toJson()),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Host Screen
class HostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create_match'),
              child: Text('Create New Match'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/manage_teams'),
              child: Text('Manage Teams'),
            ),
          ],
        ),
      ),
    );
  }
}

// Create Match Screen
class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _matchNameController = TextEditingController();

  Future<void> _createMatch() async {
    if (_matchNameController.text.isNotEmpty) {
      final match = Match(
        id: Random().nextInt(1000000).toString(),
        name: _matchNameController.text,
        team1: [],
        team2: [],
      );
      final matches = await LocalStorage.getMatches();
      matches.add(match);
      await LocalStorage.saveMatches(matches);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Match')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _matchNameController,
              decoration: InputDecoration(labelText: 'Match Name'),
            ),
            ElevatedButton(onPressed: _createMatch, child: Text('Create')),
          ],
        ),
      ),
    );
  }
}

// Manage Teams Screen
class ManageTeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Teams')),
      body: FutureBuilder<List<Match>>(
        future: LocalStorage.getMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.map((match) {
              return ListTile(
                title: Text(match.name),
                onTap: () {
                  Navigator.pushNamed(context, '/match_details',
                      arguments: match.id);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// Match Details Screen
class MatchDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String matchId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Match Details')),
      body: FutureBuilder<List<Match>>(
        future: LocalStorage.getMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final match = snapshot.data!.firstWhere((m) => m.id == matchId);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match: ${match.name}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/scan_players', arguments: matchId),
                  child: Text('Add Players'),
                ),
                SizedBox(height: 16),
                Text('Teams:', style: TextStyle(fontSize: 18)),
                ListTile(
                  title: Text('Team 1 (${match.team1.length}/11)'),
                  onTap: () {
                    Navigator.pushNamed(context, '/team_players',
                        arguments: {'matchId': matchId, 'team': 'team1'});
                  },
                ),
                ListTile(
                  title: Text('Team 2 (${match.team2.length}/11)'),
                  onTap: () {
                    Navigator.pushNamed(context, '/team_players',
                        arguments: {'matchId': matchId, 'team': 'team2'});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Team Players Screen
class TeamPlayersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String matchId = args['matchId'];
    String team = args['team'];

    return Scaffold(
      appBar: AppBar(title: Text('$team Players')),
      body: FutureBuilder<List<Match>>(
        future: LocalStorage.getMatches(),
        builder: (context, matchSnapshot) {
          if (!matchSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final match = matchSnapshot.data!.firstWhere((m) => m.id == matchId);
          final playerIds = team == 'team1' ? match.team1 : match.team2;

          return FutureBuilder<List<PlayRequest>>(
            future: LocalStorage.getRequests(),
            builder: (context, requestSnapshot) {
              if (!requestSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final players = requestSnapshot.data!
                  .where((r) => playerIds.contains(r.playerId))
                  .toList();

              return ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    title: Text(player.name),
                    subtitle: Text('Player ID: ${player.playerId}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Scan Players Screen
class ScanPlayersScreen extends StatefulWidget {
  @override
  _ScanPlayersScreenState createState() => _ScanPlayersScreenState();
}

class _ScanPlayersScreenState extends State<ScanPlayersScreen> {
  MobileScannerController scannerController = MobileScannerController();

  Future<void> _acceptPlayer(PlayRequest request, String matchId, String team) async {
    final matches = await LocalStorage.getMatches();
    final match = matches.firstWhere((m) => m.id == matchId);
    final teamList = team == 'team1' ? match.team1 : match.team2;
    if (teamList.length < 11) {
      teamList.add(request.playerId);
      final updatedMatch = Match(
        id: match.id,
        name: match.name,
        team1: match.team1,
        team2: match.team2,
      );
      matches[matches.indexWhere((m) => m.id == matchId)] = updatedMatch;
      await LocalStorage.saveMatches(matches);
      // Ensure the request is stored for later retrieval
      final requests = await LocalStorage.getRequests();
      if (!requests.any((r) => r.playerId == request.playerId)) {
        requests.add(request);
        await LocalStorage.saveRequests(requests);
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Player added to $team')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$team is full')));
    }
  }

  @override
  Widget build(BuildContext context) {
    String matchId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Scan Players')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: scannerController,
              onDetect: (barcodeCapture) {
                final List<Barcode> barcodes = barcodeCapture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    try {
                      final json = jsonDecode(barcode.rawValue!);
                      final request = PlayRequest.fromJson(json);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Add Player'),
                          content: Text('Add ${request.name} to a team?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _acceptPlayer(request, matchId, 'team1');
                              },
                              child: Text('Team 1'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _acceptPlayer(request, matchId, 'team2');
                              },
                              child: Text('Team 2'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid QR code')));
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}