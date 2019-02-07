import 'dart:math';

class MultipartHelper {
  static const int _BOUNDARY_LENGTH = 70;
  static final Random _random = new Random();

  /// Returns a randomly-generated multipart boundary string
  static String generateBoundaryString() {
    var prefix = 'dart-http-boundary-';
    var list = new List<int>.generate(
        _BOUNDARY_LENGTH - prefix.length,
        (index) =>
            _BOUNDARY_CHARACTERS[_random.nextInt(_BOUNDARY_CHARACTERS.length)],
        growable: false);
    return "$prefix${new String.fromCharCodes(list)}";
  }
}

const List<int> _BOUNDARY_CHARACTERS = const <int>[
  43,
  95,
  45,
  46,
  48,
  49,
  50,
  51,
  52,
  53,
  54,
  55,
  56,
  57,
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89,
  90,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104,
  105,
  106,
  107,
  108,
  109,
  110,
  111,
  112,
  113,
  114,
  115,
  116,
  117,
  118,
  119,
  120,
  121,
  122
];
