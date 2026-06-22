using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;
using SchoolManagement.Infrastructure.Data;

namespace SchoolManagement.Infrastructure.Repositories
{
    public class ClassScheduleRepository : IClassScheduleRepository
    {
        private readonly SchoolDbContext _context;

        public ClassScheduleRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ActiveClassScheduleView>> GetAllAsync()
        {
            return await _context.ActiveClassSchedulesView
                .FromSqlRaw("EXEC usp_ClassSchedule_GetAll")
                .ToListAsync();
        }

        public async Task<ActiveClassScheduleView> GetByIdAsync(int id)
        {
            var result = await _context.ActiveClassSchedulesView
                .FromSqlRaw("EXEC usp_ClassSchedule_GetById @ClassScheduleId", new SqlParameter("@ClassScheduleId", id))
                .ToListAsync();

            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveAsync(ClassSchedule entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_ClassSchedule_Save @ClassScheduleId, @ClassId, @DivisionId, @FinancialYearId, @MaxCapacity, @PerformedBy, @IPAddress",
                    new SqlParameter("@ClassScheduleId", entity.ClassScheduleId),
                    new SqlParameter("@ClassId", entity.ClassId),
                    new SqlParameter("@DivisionId", entity.DivisionId),
                    new SqlParameter("@FinancialYearId", entity.FinancialYearId),
                    new SqlParameter("@MaxCapacity", entity.MaxCapacity),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_ClassSchedule_Delete @ClassScheduleId, @PerformedBy, @IPAddress",
                    new SqlParameter("@ClassScheduleId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
