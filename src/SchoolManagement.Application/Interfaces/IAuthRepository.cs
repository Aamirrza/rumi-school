using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IAuthRepository
    {
        Task<User> LoginAsync(string username, string ipAddress);
        Task<IEnumerable<string>> GetUserRolesAsync(int userId);
        Task<DbOperationResult> ChangePasswordAsync(int userId, string newPasswordHash, int performedBy, string ipAddress);
    }
}
