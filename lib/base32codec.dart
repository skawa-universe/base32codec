import "dart:convert";
import "dart:typed_data";

const String _base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

class Base32Encoder extends Converter<List<int>, String> {
  const Base32Encoder();

  /// Takes in a [input] and outputs a Base32 [String] representation.
  @override
  String convert(List<int> input) {
    Uint8List bytes = input is Uint8List ? input : new Uint8List.fromList(input);
    int i = 0, index = 0, digit = 0;
    int currByte, nextByte;
    StringBuffer base32 = new StringBuffer();

    while (i < bytes.length) {
      currByte = bytes[i];

      if (index > 3) {
        if ((i + 1) < bytes.length) {
          nextByte = bytes[i + 1];
        } else {
          nextByte = 0;
        }

        digit = currByte & (0xFF >> index);
        index = (index + 5) & 7;
        digit <<= index;
        digit |= nextByte >> (8 - index);
        i++;
      } else {
        digit = (currByte >> (8 - (index + 5)) & 0x1F);
        index = (index + 5) & 7;
        if (index == 0) {
          i++;
        }
      }
      base32.write(_base32Chars[digit]);
    }
    final int padding = -base32.length & 7;
    for (int i = 0; i < padding; ++i) base32.write("=");
    return base32.toString();
  }
}

const List<int> _base32Lookup = const [
  0xFF, 0xFF, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E,
  0x1F, // '0', '1', '2', '3', '4', '5', '6', '7'
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, // '8', '9', ':', ';', '<', '=', '>', '?'
  0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
  0x06, // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
  0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D,
  0x0E, // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
  0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
  0x16, // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
  0x17, 0x18, 0x19, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
  0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
  0x06, // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
  0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D,
  0x0E, // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
  0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
  0x16, // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
  0x17, 0x18, 0x19 // 'x', 'y', 'z'
  // and we don't care about the rest
];

class Base32Decoder extends Converter<String, List<int>> {
  const Base32Decoder();

  @override
  List<int> convert(String input) {
    int paddingStart = input.indexOf("=");
    if (paddingStart < 0) paddingStart = input.length;
    final int length = paddingStart;
    int index = 0, lookup, offset = 0, digit;
    Uint8List bytes = new Uint8List(length * 5 >> 3);
    // bytes is already initialized to zeros

    for (int i = 0; i < length; i++) {
      lookup = input.codeUnitAt(i) - 48;
      if (lookup < 0 || lookup >= _base32Lookup.length) continue;

      digit = _base32Lookup[lookup];
      if (digit == 0xFF) continue;

      if (index <= 3) {
        index = (index + 5) & 7;
        if (index == 0) {
          bytes[offset] |= digit;
          offset++;
          if (offset >= bytes.length) break;
        } else {
          bytes[offset] |= digit << (8 - index);
        }
      } else {
        index = (index + 5) & 7;
        bytes[offset] |= (digit >> index);
        offset++;

        if (offset >= bytes.length) break;

        bytes[offset] |= digit << (8 - index);
      }
    }
    return bytes;
  }
}

const Base32Codec base32 = const Base32Codec();

class Base32Codec extends Codec<List<int>, String> {
  const Base32Codec();

  @override
  Converter<String, List<int>> get decoder => const Base32Decoder(); // will return the same (const) instance

  @override
  Converter<List<int>, String> get encoder => const Base32Encoder(); // will return the same (const) instance
}
