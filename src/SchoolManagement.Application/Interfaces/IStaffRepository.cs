using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IStaffRepository
    {
        Task<IEnumerable<StaffDetailsView>> GetAllAsync();
        Task<StaffDetailsView?> GetByIdAsync(int id);
        Task<DbOperationResult> SaveAsync(StaffDetail entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
        
        // Dropdown data
        Task<IEnumerable<StaffTypeMaster>> GetStaffTypesAsync();
        Task<IEnumerable<StaffDetail>> GetStaffDropdownAsync(int? staffTypeId = null);
    }
}
