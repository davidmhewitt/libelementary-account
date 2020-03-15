namespace ElementaryAccount {
    public class Utils {
        public static uint8[] generate_random_bytes (uint count) {
            var bytes = new uint8[count];
            var uint_size = sizeof(uint32);

            for (int i = 0; i < count; i += 4) {
                var random_int = Random.next_int ();
                for (int j = 0; j < uint_size; j++) {
                    if (i + j >= count) {
                        return bytes;
                    }

                    bytes[i+j] = (uint8)((random_int >> ((uint_size - 1 - j) * 8)) & 0xFF);
                }
            }

            return bytes;
        }

        public static string base64_url_encode (uint8[] bytes) {
            var encoded = GLib.Base64.encode (bytes);
            return encoded
                .replace ("=", "")
                .replace ("/", "_")
                .replace ("+", "-");
        }

        public static uint8[] sha256 (uint8[] data) {
            size_t digest_length = 32;
            var digest = new uint8[digest_length];

            var checksum = new GLib.Checksum (GLib.ChecksumType.SHA256);
            checksum.update (data, data.length);
            checksum.get_digest (digest, ref digest_length);

            return digest;
        }
    }
}
