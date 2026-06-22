using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly IDashboardRepository _repository;

        public DashboardService(IDashboardRepository repository)
        {
            _repository = repository;
        }

        public async Task<DashboardData> GetSummaryAsync(int? financialYearId)
        {
            return await _repository.GetSummaryAsync(financialYearId);
        }
    }
}
