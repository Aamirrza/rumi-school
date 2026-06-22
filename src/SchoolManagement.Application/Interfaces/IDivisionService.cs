using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IDivisionService
    {
        Task<IEnumerable<DivisionMaster>> GetAllAsync();
        Task<DivisionMaster> GetByIdAsync(int id);
        Task<DbOperationResult> SaveAsync(DivisionMaster entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
    }
}
