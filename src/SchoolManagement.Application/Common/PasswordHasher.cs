using System;
using System.Security.Cryptography;

namespace SchoolManagement.Application.Common
{
    public static class PasswordHasher
    {
        private const int IterationCount = 310000;

        public static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, IterationCount, HashAlgorithmName.SHA256))
            {
                byte[] subkey = pbkdf2.GetBytes(32);
                byte[] outputBytes = new byte[1 + 4 + 4 + 4 + 16 + 32];
                outputBytes[0] = 0x01; // Format V3

                // Write PRF (1 = HMAC-SHA256)
                WriteNetworkByteOrder(outputBytes, 1, 1);
                // Write iteration count.
                WriteNetworkByteOrder(outputBytes, 5, (uint)IterationCount);
                // Write salt size (16)
                WriteNetworkByteOrder(outputBytes, 9, 16);

                Buffer.BlockCopy(salt, 0, outputBytes, 13, 16);
                Buffer.BlockCopy(subkey, 0, outputBytes, 29, 32);

                return Convert.ToBase64String(outputBytes);
            }
        }

        public static bool VerifyHashedPassword(string hashedPassword, string password)
        {
            try
            {
                byte[] decodedHashedPassword = Convert.FromBase64String(hashedPassword);

                if (decodedHashedPassword.Length < 61)
                    return false;

                // Identity V3
                if (decodedHashedPassword[0] != 0x01)
                    return false;

                uint prf = ReadNetworkByteOrder(decodedHashedPassword, 1);
                uint iterationCount = ReadNetworkByteOrder(decodedHashedPassword, 5);
                uint saltLength = ReadNetworkByteOrder(decodedHashedPassword, 9);

                if (saltLength == 0 || saltLength > 128)
                    return false;

                int saltLen = (int)saltLength;

                byte[] salt = new byte[saltLen];
                Buffer.BlockCopy(decodedHashedPassword, 13, salt, 0, saltLen);

                int subkeyLength = decodedHashedPassword.Length - 13 - saltLen;

                byte[] expectedSubkey = new byte[subkeyLength];
                Buffer.BlockCopy(decodedHashedPassword,
                                 13 + saltLen,
                                 expectedSubkey,
                                 0,
                                 subkeyLength);

                HashAlgorithmName algorithm;

                switch (prf)
                {
                    case 0:
                        algorithm = HashAlgorithmName.SHA1;
                        break;

                    case 1:
                        algorithm = HashAlgorithmName.SHA256;
                        break;

                    case 2:
                        algorithm = HashAlgorithmName.SHA512;
                        break;

                    default:
                        return false;
                }

                using (var pbkdf2 = new Rfc2898DeriveBytes(
                    password,
                    salt,
                    (int)iterationCount,
                    algorithm))
                {
                    byte[] actualSubkey = pbkdf2.GetBytes(subkeyLength);

                    return CryptographicOperations.FixedTimeEquals(
                        actualSubkey,
                        expectedSubkey);
                }
            }
            catch
            {
                return false;
            }
        }

        private static void WriteNetworkByteOrder(byte[] buffer, int offset, uint value)
        {
            buffer[offset + 0] = (byte)(value >> 24);
            buffer[offset + 1] = (byte)(value >> 16);
            buffer[offset + 2] = (byte)(value >> 8);
            buffer[offset + 3] = (byte)(value >> 0);
        }

        private static uint ReadNetworkByteOrder(byte[] buffer, int offset)
        {
            return ((uint)(buffer[offset + 0]) << 24)
                | ((uint)(buffer[offset + 1]) << 16)
                | ((uint)(buffer[offset + 2]) << 8)
                | ((uint)(buffer[offset + 3]));
        }
    }
}
