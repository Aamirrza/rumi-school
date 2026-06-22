using System.Threading.Tasks;
using SchoolManagement.Application.Common;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _authRepository;

        public AuthService(IAuthRepository authRepository)
        {
            _authRepository = authRepository;
        }

        public async Task<User> AuthenticateAsync(string username, string password, string ipAddress)
        {
            var user = await _authRepository.LoginAsync(username, ipAddress);
            if (user == null) return null;

            bool isValid = PasswordHasher.VerifyHashedPassword(user.PasswordHash, password);
            return isValid ? user : null;
        }

        public async Task<System.Collections.Generic.IEnumerable<string>> GetUserRolesAsync(int userId)
        {
            return await _authRepository.GetUserRolesAsync(userId);
        }

        public async Task<DbOperationResult> ChangePasswordAsync(int userId, string newPassword, int performedBy, string ipAddress)
        {
            string newPasswordHash = PasswordHasher.HashPassword(newPassword);
            return await _authRepository.ChangePasswordAsync(userId, newPasswordHash, performedBy, ipAddress);
        }
    }
}
