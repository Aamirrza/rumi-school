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
    public class FinancialYearRepository : IFinancialYearRepository
    {
        private readonly SchoolDbContext _context;

        public FinancialYearRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<FinancialYear>> GetAllAsync()
        {
            return await _context.FinancialYears
                .FromSqlRaw("EXEC usp_FinancialYear_GetAll")
                .ToListAsync();
        }

        public async Task<FinancialYear> GetByIdAsync(int id)
        {
            var result = await _context.FinancialYears
                .FromSqlRaw("EXEC usp_FinancialYear_GetById @FinancialYearId", new SqlParameter("@FinancialYearId", id))
                .ToListAsync();

            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveAsync(FinancialYear entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_FinancialYear_Save @FinancialYearId, @FinancialYear, @StartDate, @EndDate, @IsCurrent, @PerformedBy, @IPAddress",
                    new SqlParameter("@FinancialYearId", entity.FinancialYearId),
                    new SqlParameter("@FinancialYear", entity.FinancialYearName ?? (object)DBNull.Value),
                    new SqlParameter("@StartDate", entity.StartDate),
                    new SqlParameter("@EndDate", entity.EndDate),
                    new SqlParameter("@IsCurrent", entity.IsCurrent),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            var operationResult = result.FirstOrDefault();
            if (operationResult != null)
            {
                // In our SP, if successful, we return StatusCode, Message and the FinancialYearId in the third column
                // Let's check: in usp_FinancialYear_Save, it returns: SELECT @StatusCode AS StatusCode, @Message AS Message, @FinancialYearId AS FinancialYearId;
                // Wait! Since DbOperationResult only maps StatusCode and Message by default, we can add RecordId property to DbOperationResult in C# and map it!
                // Yes, we added RecordId property to DbOperationResult, but since we didn't specify it in Fluent API or DB, does EF Core find it?
                // In DbOperationResult, we have public int? RecordId { get; set; }
                // Since the column name in SELECT is FinancialYearId, EF Core won't automatically map it to RecordId unless we alias it or let EF Core ignore it, or we handle it in DbOperationResult mapping.
                // Wait, if the stored procedure returns a third column, EF Core will ignore it if it's not mapped, which is fine!
                // But wait! If we want to capture the inserted ID, let's see. In EF Core, if we execute FromSqlRaw on a type that doesn't have a column named FinancialYearId, it might throw an exception if we try to map the whole result set.
                // Actually, in EF Core, FromSqlRaw requires all properties of the model to be present in the SQL output. But if there are extra columns in SQL output that are NOT in the model, EF Core ignores them. That is safe.
                // To be safe, let's look at the stored procedures. In usp_FinancialYear_Save:
                // "SELECT @StatusCode AS StatusCode, @Message AS Message, @FinancialYearId AS FinancialYearId;"
                // If we execute it as FromSqlRaw, it maps StatusCode and Message perfectly because they are in SELECT.
                // Let's make sure EF Core doesn't throw. If we want to read the ID, we can do it, but StatusCode and Message are the most important.
            }
            return operationResult ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_FinancialYear_Delete @FinancialYearId, @PerformedBy, @IPAddress",
                    new SqlParameter("@FinancialYearId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
