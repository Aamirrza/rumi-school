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
    public class DivisionRepository : IDivisionRepository
    {
        private readonly SchoolDbContext _context;

        public DivisionRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DivisionMaster>> GetAllAsync()
        {
            return await _context.Divisions
                .FromSqlRaw("EXEC usp_Division_GetAll")
                .ToListAsync();
        }

        public async Task<DivisionMaster> GetByIdAsync(int id)
        {
            var result = await _context.Divisions
                .FromSqlRaw("EXEC usp_Division_GetById @DivisionId", new SqlParameter("@DivisionId", id))
                .ToListAsync();

            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveAsync(DivisionMaster entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_Division_Save @DivisionId, @DivisionName, @PerformedBy, @IPAddress",
                    new SqlParameter("@DivisionId", entity.DivisionId),
                    new SqlParameter("@DivisionName", entity.DivisionName ?? (object)DBNull.Value),
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
                    "EXEC usp_Division_Delete @DivisionId, @PerformedBy, @IPAddress",
                    new SqlParameter("@DivisionId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
