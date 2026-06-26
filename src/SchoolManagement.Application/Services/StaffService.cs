using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class StaffService : IStaffService
    {
        private readonly IStaffRepository _repository;

        public StaffService(IStaffRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<StaffDetailsView>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<StaffDetailsView?> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<DbOperationResult> SaveAsync(StaffDetail entity, int performedBy, string ipAddress)
        {
            return await _repository.SaveAsync(entity, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            return await _repository.DeleteAsync(id, performedBy, ipAddress);
        }

        public async Task<IEnumerable<StaffTypeMaster>> GetStaffTypesAsync()
        {
            return await _repository.GetStaffTypesAsync();
        }

        public async Task<IEnumerable<StaffDetail>> GetStaffDropdownAsync(int? staffTypeId = null)
        {
            return await _repository.GetStaffDropdownAsync(staffTypeId);
        }
    }
}
