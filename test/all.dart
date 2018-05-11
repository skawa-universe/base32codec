import "package:base32codec/base32codec.dart";
import "package:test/test.dart";

// ASCII string => base32 pairs
const Map<String, String> pairs = const {
  "GE======": "1",
  "GEZA====": "12",
  "GEZDG===": "123",
  "GEZDGNA=": "1234",
  "GEZDGNBV": "12345",
  "MZXW6YTBOI======": "foobar",
  "JZXXOIDJOMQHI2DFEB3WS3TUMVZCA33GEBXXK4RAMRUXGY3PNZ2GK3TUBJGWCZDFEBTWY33SN"
      "FXXK4ZAON2W23LFOIQGE6JAORUGS4ZAON2W4IDPMYQFS33SNM======":
      "Now is the winter of our discontent\nMade glorious summer by this sun"
      " of York",
};

const Map<String, List<int>> binaryPairs = const {
  "TKT5DQIR4JHX6BMLYA7SVDNQSY======": const [154, 167, 209, 193, 17, 226, 79, 127, 5, 139, 192, 63, 42, 141, 176, 150],
  "LU6AIQXDVF75LDDUO65XE===": const [93, 60, 4, 66, 227, 169, 127, 213, 140, 116, 119, 187, 114],
  "FEA7GT5M": const [41, 1, 243, 79, 172],
  "CPJ44HZMCQ323XKF3A======": const [19, 211, 206, 31, 44, 20, 55, 173, 221, 69, 216],
  "Q4PDCMY=": const [135, 30, 49, 51],
  "OHEFWWI3N2W4KUESJI======": const [113, 200, 91, 89, 27, 110, 173, 197, 80, 146, 74],
  "XCL3NTAJQDUQ====": const [184, 151, 182, 204, 9, 128, 233],
  "2AB3MH7UQM======": const [208, 3, 182, 31, 244, 131],
  "YZ2X7NIKNCI42===": const [198, 117, 127, 181, 10, 104, 145, 205],
};

final Map<String, List<int>> allPairs = new Map.unmodifiable(
  new Map.from(binaryPairs)
    ..addAll(new Map.fromIterable(
      pairs.keys,
      value: (k) => pairs[k].runes.toList(),
    )),
);

void main() {
  test("encoding", () {
    allPairs.forEach((String encoded, List<int> binary) {
      expect(base32.encode(binary), encoded);
    });
  });
  test("decoding", () {
    allPairs.forEach((String encoded, List<int> binary) {
      expect(base32.decode(encoded), binary);
    });
  });
}
