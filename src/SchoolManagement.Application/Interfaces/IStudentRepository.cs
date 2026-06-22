using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IStudentRepository
    {
        Task<IEnumerable<StudentDetailsView>> GetAllAsync();
        Task<IEnumerable<StudentDetailsView>> GetByIdAsync(int id);
        Task<IEnumerable<StudentDetailsView>> SearchAsync(string searchText, int? classScheduleId, int? financialYearId, string gender);
        Task<DbOperationResult> SaveAsync(StudentInfo entity, int? classScheduleId, int? rollNo, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
    }
}
