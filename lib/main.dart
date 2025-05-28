import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(DroneControlApp());
  });
}

class DroneControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DroneControlScreen(),
    );
  }
}

class DroneControlScreen extends StatefulWidget {
  @override
  _DroneControlScreenState createState() => _DroneControlScreenState();
}

class _DroneControlScreenState extends State<DroneControlScreen> {
  double _batteryLevel = 85.0;
  String _droneStatus = "Connected";
  double _altitude = 12.5;
  bool _isRecording = false;
  double _rotation = 0.0;
  Offset _rightStickPosition = Offset.zero;

  final String _upIcon = """
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 4L4 16H20L12 4Z" fill="white"/>
    </svg>
  """;

  final String _rightIcon = """
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M4 12L16 4V20L4 12Z" fill="white"/>
    </svg>
  """;

  final String _downIcon = """
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 20L20 8H4L12 20Z" fill="white"/>
    </svg>
  """;

  final String _leftIcon = """
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M20 12L8 20V4L20 12Z" fill="white"/>
    </svg>
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage('https://example.com/drone-feed.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _buildStatusPanel(),
            ),
          ),

          Positioned(
            left: 30,
            bottom: 30,
            child: _buildDPad(),
          ),

          Positioned(
            right: 30,
            bottom: 30,
            child: _buildAnalogStick(),
          ),

          Positioned(
            right: 30,
            top: 30,
            child: _buildRecordingButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusItem(Icons.battery_std, '${_batteryLevel.toStringAsFixed(0)}%',
              _batteryLevel > 20 ? Colors.green : Colors.red),
          SizedBox(width: 25),
          _buildStatusItem(Icons.height, '${_altitude.toStringAsFixed(1)}m', Colors.blue),
          SizedBox(width: 25),
          _buildStatusItem(
              _droneStatus == "Connected" ? Icons.link : Icons.link_off,
              _droneStatus,
              _droneStatus == "Connected" ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildDPad() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),

          Positioned(
            top: 0,
            child: _buildDirectionButton(_upIcon, () {
              setState(() => _altitude += 0.5);
            }),
          ),

          Positioned(
            right: 0,
            child: _buildDirectionButton(_rightIcon, () {}),
          ),

          Positioned(
            bottom: 0,
            child: _buildDirectionButton(_downIcon, () {
              setState(() => _altitude -= 0.5);
            }),
          ),

          Positioned(
            left: 0,
            child: _buildDirectionButton(_leftIcon, () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(String svg, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      onTapCancel: () => setState(() {}),
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: SvgPicture.string(
            svg,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalogStick() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _rightStickPosition = details.localPosition - Offset(75, 75);
          _rightStickPosition = Offset(
            _rightStickPosition.dx.clamp(-60.0, 60.0),
            _rightStickPosition.dy.clamp(-60.0, 60.0),
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _rightStickPosition = details.localPosition - Offset(75, 75);
          _rightStickPosition = Offset(
            _rightStickPosition.dx.clamp(-60.0, 60.0),
            _rightStickPosition.dy.clamp(-60.0, 60.0),
          );

          if (_rightStickPosition.dx.abs() > 10) {
            _rotation = _rightStickPosition.dx / 60.0;
          }
        });
      },
      onPanEnd: (_) => setState(() {
        _rightStickPosition = Offset.zero;
        _rotation = 0.0;
      }),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 100,
                height: 2,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Center(
              child: Container(
                width: 2,
                height: 100,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
            ),
            Positioned(
              left: 75 + _rightStickPosition.dx - 25,
              top: 75 + _rightStickPosition.dy - 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: () => setState(() => _isRecording = !_isRecording),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red.withOpacity(0.7) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isRecording ? Colors.red : Colors.white,
            width: 3,
          ),
          boxShadow: _isRecording
              ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ]
              : null,
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.fiber_manual_record,
          color: _isRecording ? Colors.white : Colors.red,
          size: 36,
        ),
      ),
    );
  }
}