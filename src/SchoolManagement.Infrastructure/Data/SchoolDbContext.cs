using Microsoft.EntityFrameworkCore;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Infrastructure.Data
{
    public class SchoolDbContext : DbContext
    {
        public SchoolDbContext(DbContextOptions<SchoolDbContext> options) : base(options)
        {
        }

        // Tables
        public DbSet<FinancialYear> FinancialYears { get; set; }
        public DbSet<DivisionMaster> Divisions { get; set; }
        public DbSet<ClassMaster> Classes { get; set; }
        public DbSet<ClassSchedule> ClassSchedules { get; set; }
        public DbSet<StudentInfo> Students { get; set; }
        public DbSet<StudentMapping> StudentMappings { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }
        public DbSet<SemesterMaster> Semesters { get; set; }
        public DbSet<FeeMaster> Fees { get; set; }
        public DbSet<FeeDetail> FeeDetails { get; set; }
        public DbSet<PaymentDetail> PaymentDetails { get; set; }
        public DbSet<StaffTypeMaster> StaffTypes { get; set; }
        public DbSet<StaffDetail> StaffDetails { get; set; }

        // Views and Keyless Query Types
        public DbSet<ActiveClassScheduleView> ActiveClassSchedulesView { get; set; }
        public DbSet<StudentDetailsView> StudentDetailsView { get; set; }
        public DbSet<StaffDetailsView> StaffDetailsView { get; set; }
        public DbSet<FeeDetailsView> FeeDetailsView { get; set; }
        public DbSet<StudentPaymentsView> StudentPaymentsView { get; set; }
        public DbSet<DbOperationResult> DbOperationResults { get; set; }
        public DbSet<DashboardSummaryMetrics> DashboardSummaryMetrics { get; set; }
        public DbSet<GenderDistribution> GenderDistributions { get; set; }
        public DbSet<ClassStudentCount> ClassStudentCounts { get; set; }
        public DbSet<DivisionStudentCount> DivisionStudentCounts { get; set; }
        public DbSet<StaffRoleCount> StaffRoleCounts { get; set; }
        public DbSet<PendingFeeReportView> PendingFeeReportView { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Table mappings and keys
            modelBuilder.Entity<FinancialYear>().ToTable("FinancialYear");
            modelBuilder.Entity<FinancialYear>().HasKey(e => e.FinancialYearId);
            modelBuilder.Entity<FinancialYear>().Property(e => e.FinancialYearName).HasColumnName("FinancialYear");

            modelBuilder.Entity<DivisionMaster>().ToTable("DivisionMaster");
            modelBuilder.Entity<DivisionMaster>().HasKey(e => e.DivisionId);

            modelBuilder.Entity<ClassMaster>().ToTable("ClassMaster");
            modelBuilder.Entity<ClassMaster>().HasKey(e => e.ClassId);

            modelBuilder.Entity<ClassSchedule>().ToTable("ClassSchedules");
            modelBuilder.Entity<ClassSchedule>().HasKey(e => e.ClassScheduleId);

            modelBuilder.Entity<StudentInfo>().ToTable("StudentInfo");
            modelBuilder.Entity<StudentInfo>().HasKey(e => e.StudentId);

            modelBuilder.Entity<StudentMapping>().ToTable("StudentMappings");
            modelBuilder.Entity<StudentMapping>().HasKey(e => e.StudentMappingId);

            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<User>().HasKey(e => e.UserId);

            modelBuilder.Entity<Role>().ToTable("Roles");
            modelBuilder.Entity<Role>().HasKey(e => e.RoleId);

            modelBuilder.Entity<UserRole>().ToTable("UserRoles");
            modelBuilder.Entity<UserRole>().HasKey(e => e.UserRoleId);

            modelBuilder.Entity<AuditLog>().ToTable("AuditLogs");
            modelBuilder.Entity<AuditLog>().HasKey(e => e.AuditLogId);

            modelBuilder.Entity<SemesterMaster>().ToTable("SemesterMaster");
            modelBuilder.Entity<SemesterMaster>().HasKey(e => e.SemesterID);

            modelBuilder.Entity<FeeMaster>().ToTable("FeeMaster");
            modelBuilder.Entity<FeeMaster>().HasKey(e => e.FeeID);

            modelBuilder.Entity<FeeDetail>().ToTable("FeeDetail");
            modelBuilder.Entity<FeeDetail>().HasKey(e => e.FeeDetailID);

            modelBuilder.Entity<PaymentDetail>().ToTable("PaymentDetail");
            modelBuilder.Entity<PaymentDetail>().HasKey(e => e.PaymentDetailID);

            modelBuilder.Entity<StaffTypeMaster>().ToTable("StaffTypeMaster");
            modelBuilder.Entity<StaffTypeMaster>().HasKey(e => e.StaffTypeID);

            modelBuilder.Entity<StaffDetail>().ToTable("StaffDetail");
            modelBuilder.Entity<StaffDetail>().HasKey(e => e.StaffID);

            // Keyless Entity Types
            modelBuilder.Entity<ActiveClassScheduleView>().HasNoKey().ToView("vw_ActiveClassSchedules");
            modelBuilder.Entity<StudentDetailsView>().HasNoKey().ToView("vw_StudentDetails");
            modelBuilder.Entity<StaffDetailsView>().HasNoKey().ToView("vw_StaffDetails");
            modelBuilder.Entity<FeeDetailsView>().HasNoKey().ToView("vw_FeeDetails");
            modelBuilder.Entity<StudentPaymentsView>().HasNoKey().ToView("vw_StudentPayments");
            
            modelBuilder.Entity<DbOperationResult>().HasNoKey().Ignore(e => e.RecordId);
            modelBuilder.Entity<DashboardSummaryMetrics>().HasNoKey();
            modelBuilder.Entity<GenderDistribution>().HasNoKey();
            modelBuilder.Entity<ClassStudentCount>().HasNoKey();
            modelBuilder.Entity<DivisionStudentCount>().HasNoKey();
            modelBuilder.Entity<StaffRoleCount>().HasNoKey();
            modelBuilder.Entity<PendingFeeReportView>().HasNoKey();
        }
    }
}
