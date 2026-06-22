using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IAuthService
    {
        Task<User> AuthenticateAsync(string username, string password, string ipAddress);
        Task<IEnumerable<string>> GetUserRolesAsync(int userId);
        Task<DbOperationResult> ChangePasswordAsync(int userId, string newPassword, int performedBy, string ipAddress);
    }
}
