using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IClassRepository
    {
        Task<IEnumerable<ClassMaster>> GetAllAsync();
        Task<ClassMaster> GetByIdAsync(int id);
        Task<DbOperationResult> SaveAsync(ClassMaster entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
    }
}
