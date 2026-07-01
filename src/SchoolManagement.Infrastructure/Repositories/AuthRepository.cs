using System;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;
using SchoolManagement.Infrastructure.Data;

namespace SchoolManagement.Infrastructure.Repositories
{
    public class AuthRepository : IAuthRepository
    {
        private readonly SchoolDbContext _context;

        public AuthRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<User> LoginAsync(string username, string ipAddress)
        {
            User user = null;
            var connection = _context.Database.GetDbConnection();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "usp_Login";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@Username", username));
                    command.Parameters.Add(new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value));

                    if (connection.State != ConnectionState.Open)
                        await connection.OpenAsync();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            var statusCode = Convert.ToInt32(reader["StatusCode"]);
                            if (statusCode == 200)
                            {
                                user = new User
                                {
                                    UserId = Convert.ToInt32(reader["UserId"]),
                                    Username = reader["Username"].ToString(),
                                    PasswordHash = reader["PasswordHash"].ToString(),
                                    FullName = reader["FullName"].ToString(),
                                    EmailAddress = reader["EmailAddress"] == DBNull.Value ? null : reader["EmailAddress"].ToString(),
                                    LastLoginDate = reader["LastLoginDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["LastLoginDate"])
                                };
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

            return user;
        }

        public async Task<System.Collections.Generic.IEnumerable<string>> GetUserRolesAsync(int userId)
        {
            var roles = await _context.Roles
                .FromSqlRaw("SELECT r.* FROM SMS_Roles  r INNER JOIN SMS_UserRoles ur ON r.RoleId = ur.RoleId WHERE ur.UserId = @UserId AND ur.IsDeleted = 0 AND ur.IsActive = 1 AND r.IsDeleted = 0 AND r.IsActive = 1", new SqlParameter("@UserId", userId))
                .ToListAsync();

            var roleNames = new System.Collections.Generic.List<string>();
            foreach (var r in roles)
            {
                roleNames.Add(r.RoleName);
            }
            return roleNames;
        }

        public async Task<DbOperationResult> ChangePasswordAsync(int userId, string newPasswordHash, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_ChangePassword @UserId, @NewPasswordHash, @PerformedBy, @IPAddress",
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@NewPasswordHash", newPasswordHash ?? (object)DBNull.Value),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
