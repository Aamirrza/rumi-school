using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Application.Services;
using SchoolManagement.Infrastructure.Data;
using SchoolManagement.Infrastructure.Repositories;

namespace SchoolManagement.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
        {
            // Register DbContext
            services.AddDbContext<SchoolDbContext>(options =>
                options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

            // Register Repositories
            services.AddScoped<IAuthRepository, AuthRepository>();
            services.AddScoped<IFinancialYearRepository, FinancialYearRepository>();
            services.AddScoped<IDivisionRepository, DivisionRepository>();
            services.AddScoped<IClassRepository, ClassRepository>();
            services.AddScoped<IClassScheduleRepository, ClassScheduleRepository>();
            services.AddScoped<IStudentRepository, StudentRepository>();
            services.AddScoped<IDashboardRepository, DashboardRepository>();
            services.AddScoped<IStaffRepository, StaffRepository>();
            services.AddScoped<IFeeRepository, FeeRepository>();
            services.AddScoped<IPaymentRepository, PaymentRepository>();

            // Register Services
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IFinancialYearService, FinancialYearService>();
            services.AddScoped<IDivisionService, DivisionService>();
            services.AddScoped<IClassService, ClassService>();
            services.AddScoped<IClassScheduleService, ClassScheduleService>();
            services.AddScoped<IStudentService, StudentService>();
            services.AddScoped<IDashboardService, DashboardService>();
            services.AddScoped<IStaffService, StaffService>();
            services.AddScoped<IFeeService, FeeService>();
            services.AddScoped<IPaymentService, PaymentService>();

            return services;
        }
    }
}
