using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IFinancialYearService
    {
        Task<IEnumerable<FinancialYear>> GetAllAsync();
        Task<FinancialYear> GetByIdAsync(int id);
        Task<DbOperationResult> SaveAsync(FinancialYear entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress);
    }
}
