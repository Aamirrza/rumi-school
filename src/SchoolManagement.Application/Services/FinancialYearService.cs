using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class FinancialYearService : IFinancialYearService
    {
        private readonly IFinancialYearRepository _repository;

        public FinancialYearService(IFinancialYearRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<FinancialYear>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<FinancialYear> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<DbOperationResult> SaveAsync(FinancialYear entity, int performedBy, string ipAddress)
        {
            return await _repository.SaveAsync(entity, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            return await _repository.DeleteAsync(id, performedBy, ipAddress);
        }
    }
}
