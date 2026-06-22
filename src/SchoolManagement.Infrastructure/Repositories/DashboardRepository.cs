using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Models;
using SchoolManagement.Infrastructure.Data;

namespace SchoolManagement.Infrastructure.Repositories
{
    public class DashboardRepository : IDashboardRepository
    {
        private readonly SchoolDbContext _context;

        public DashboardRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardData> GetSummaryAsync(int? financialYearId)
        {
            var data = new DashboardData();
            var connection = _context.Database.GetDbConnection();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "usp_Dashboard_GetSummary";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@FinancialYearId", financialYearId ?? (object)DBNull.Value));

                    if (connection.State != ConnectionState.Open)
                        await connection.OpenAsync();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // 1. Result Set 1: Summary Metrics
                        if (await reader.ReadAsync())
                        {
                            data.Metrics = new DashboardSummaryMetrics
                            {
                                TotalMappedStudents = Convert.ToInt32(reader["TotalMappedStudents"]),
                                TotalActiveClasses = Convert.ToInt32(reader["TotalActiveClasses"]),
                                TotalCapacity = Convert.ToInt32(reader["TotalCapacity"]),
                                TotalAdmittedStudents = Convert.ToInt32(reader["TotalAdmittedStudents"])
                            };
                        }

                        // 2. Result Set 2: Gender Distribution
                        if (await reader.NextResultAsync())
                        {
                            data.GenderDistribution = new List<GenderDistribution>();
                            while (await reader.ReadAsync())
                            {
                                data.GenderDistribution.Add(new GenderDistribution
                                {
                                    Gender = reader["Gender"].ToString(),
                                    StudentCount = Convert.ToInt32(reader["StudentCount"])
                                });
                            }
                        }

                        // 3. Result Set 3: Class Distribution
                        if (await reader.NextResultAsync())
                        {
                            data.ClassDistribution = new List<ClassStudentCount>();
                            while (await reader.ReadAsync())
                            {
                                data.ClassDistribution.Add(new ClassStudentCount
                                {
                                    ClassName = reader["ClassName"].ToString(),
                                    StudentCount = Convert.ToInt32(reader["StudentCount"]),
                                    MaxCapacity = Convert.ToInt32(reader["MaxCapacity"])
                                });
                            }
                        }

                        // 4. Result Set 4: Division Distribution
                        if (await reader.NextResultAsync())
                        {
                            data.DivisionDistribution = new List<DivisionStudentCount>();
                            while (await reader.ReadAsync())
                            {
                                data.DivisionDistribution.Add(new DivisionStudentCount
                                {
                                    DivisionName = reader["DivisionName"].ToString(),
                                    StudentCount = Convert.ToInt32(reader["StudentCount"])
                                });
                            }
                        }
                    }
                }
            }
            finally
            {
                if (connection.State == ConnectionState.Open)
                    await connection.CloseAsync();
            }

            return data;
        }
    }
}
