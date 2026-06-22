using System.Threading.Tasks;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IDashboardRepository
    {
        Task<DashboardData> GetSummaryAsync(int? financialYearId);
    }
}
