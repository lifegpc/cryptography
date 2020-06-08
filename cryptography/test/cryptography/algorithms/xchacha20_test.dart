// Copyright 2019-2020 Gohilla Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('XChaCha20:', () {
    const algorithm = xchacha20;

    test('information', () {
      expect(algorithm.name, 'xchacha20');
      expect(algorithm.isAuthenticated, isFalse);
      expect(algorithm.secretKeyLength, 32);
      expect(algorithm.secretKeyValidLengths, unorderedEquals({32}));
      expect(algorithm.nonceLength, 24);
    });

    group('example', () {
      // -----------------------------------------------------------------------
      // The following constants are from:
      // https://tools.ietf.org/html/draft-arciszewski-xchacha-03
      // -----------------------------------------------------------------------
      final cleartext = hexToBytes('''
54 68 65 20 64 68 6f 6c 65 20 28 70 72 6f 6e 6f
75 6e 63 65 64 20 22 64 6f 6c 65 22 29 20 69 73
20 61 6c 73 6f 20 6b 6e 6f 77 6e 20 61 73 20 74
68 65 20 41 73 69 61 74 69 63 20 77 69 6c 64 20
64 6f 67 2c 20 72 65 64 20 64 6f 67 2c 20 61 6e
64 20 77 68 69 73 74 6c 69 6e 67 20 64 6f 67 2e
20 49 74 20 69 73 20 61 62 6f 75 74 20 74 68 65
20 73 69 7a 65 20 6f 66 20 61 20 47 65 72 6d 61
6e 20 73 68 65 70 68 65 72 64 20 62 75 74 20 6c
6f 6f 6b 73 20 6d 6f 72 65 20 6c 69 6b 65 20 61
20 6c 6f 6e 67 2d 6c 65 67 67 65 64 20 66 6f 78
2e 20 54 68 69 73 20 68 69 67 68 6c 79 20 65 6c
75 73 69 76 65 20 61 6e 64 20 73 6b 69 6c 6c 65
64 20 6a 75 6d 70 65 72 20 69 73 20 63 6c 61 73
73 69 66 69 65 64 20 77 69 74 68 20 77 6f 6c 76
65 73 2c 20 63 6f 79 6f 74 65 73 2c 20 6a 61 63
6b 61 6c 73 2c 20 61 6e 64 20 66 6f 78 65 73 20
69 6e 20 74 68 65 20 74 61 78 6f 6e 6f 6d 69 63
20 66 61 6d 69 6c 79 20 43 61 6e 69 64 61 65 2e
''');

      final secretKey = SecretKey(hexToBytes(
        '80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f 90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f',
      ));

      final nonce = Nonce(hexToBytes(
        '40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f 50 51 52 53 54 55 56 58',
      ));

      final initialKeyStreamIndex = 64;

      final expectedCipherText = hexToBytes('''
7d 0a 2e 6b 7f 7c 65 a2 36 54 26 30 29 4e 06 3b
7a b9 b5 55 a5 d5 14 9a a2 1e 4a e1 e4 fb ce 87
ec c8 e0 8a 8b 5e 35 0a be 62 2b 2f fa 61 7b 20
2c fa d7 20 32 a3 03 7e 76 ff dc dc 43 76 ee 05
3a 19 0d 7e 46 ca 1d e0 41 44 85 03 81 b9 cb 29
f0 51 91 53 86 b8 a7 10 b8 ac 4d 02 7b 8b 05 0f
7c ba 58 54 e0 28 d5 64 e4 53 b8 a9 68 82 41 73
fc 16 48 8b 89 70 ca c8 28 f1 1a e5 3c ab d2 01
12 f8 71 07 df 24 ee 61 83 d2 27 4f e4 c8 b1 48
55 34 ef 2c 5f bc 1e c2 4b fc 36 63 ef aa 08 bc
04 7d 29 d2 50 43 53 2d b8 39 1a 8a 3d 77 6b f4
37 2a 69 55 82 7c cb 0c dd 4a f4 03 a7 ce 4c 63
d5 95 c7 5a 43 e0 45 f0 cc e1 f2 9c 8b 93 bd 65
af c5 97 49 22 f2 14 a4 0b 7c 40 2c db 91 ae 73
c0 b6 36 15 cd ad 04 80 68 0f 16 51 5a 7a ce 9d
39 23 64 64 32 8a 37 74 3f fc 28 f4 dd b3 24 f4
d0 f5 bb dc 27 0c 65 b1 74 9a 6e ff f1 fb aa 09
53 61 75 cc d2 9f b9 e6 05 7b 30 73 20 d3 16 83
8a 9c 71 f7 0b 5b 59 07 a6 6f 7e a4 9a ad c4 09
''');

      // -----------------------------------------------------------------------
      // End of constants from RFC 7539
      // -----------------------------------------------------------------------

      test('encrypt', () async {
        expect(
          hexFromBytes(await xchacha20.encrypt(
            cleartext,
            secretKey: secretKey,
            nonce: nonce,
            keyStreamIndex: initialKeyStreamIndex,
          )),
          hexFromBytes(expectedCipherText),
        );
      });

      test('encryptSync', () {
        expect(
          hexFromBytes(xchacha20.encryptSync(
            cleartext,
            secretKey: secretKey,
            nonce: nonce,
            keyStreamIndex: initialKeyStreamIndex,
          )),
          hexFromBytes(expectedCipherText),
        );
      });

      test('decrypt', () async {
        expect(
          hexFromBytes(await xchacha20.decrypt(
            expectedCipherText,
            secretKey: secretKey,
            nonce: nonce,
            keyStreamIndex: initialKeyStreamIndex,
          )),
          hexFromBytes(cleartext),
        );
      });

      test('decryptSync', () {
        expect(
          hexFromBytes(xchacha20.decryptSync(
            expectedCipherText,
            secretKey: secretKey,
            nonce: nonce,
            keyStreamIndex: initialKeyStreamIndex,
          )),
          hexFromBytes(cleartext),
        );
      });
    });
  });
}
