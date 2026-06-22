using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IClassScheduleService
    {
        Task<IEnumerable<ActiveClassScheduleView>> GetAllAsync();
        Task<ActiveClassScheduleView> GetByIdAsync(int id);
        Task<DbOperationResult> SaveAsync(ClassSchedule entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
    }
}
