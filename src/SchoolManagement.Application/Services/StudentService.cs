using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class StudentService : IStudentService
    {
        private readonly IStudentRepository _repository;

        public StudentService(IStudentRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<StudentDetailsView>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<IEnumerable<StudentDetailsView>> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<StudentDetailsView>> SearchAsync(string searchText, int? classScheduleId, int? financialYearId, string gender)
        {
            return await _repository.SearchAsync(searchText, classScheduleId, financialYearId, gender);
        }

        public async Task<DbOperationResult> SaveAsync(StudentInfo entity, int? classScheduleId, int? rollNo, int performedBy, string ipAddress)
        {
            return await _repository.SaveAsync(entity, classScheduleId, rollNo, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            return await _repository.DeleteAsync(id, performedBy, ipAddress);
        }
    }
}
