using System;

namespace SchoolManagement.Domain.Entities
{
    public class ActiveClassScheduleView
    {
        public int ClassScheduleId { get; set; }
        public int ClassId { get; set; }
        public string ClassName { get; set; }
        public int DivisionId { get; set; }
        public string DivisionName { get; set; }
        public int FinancialYearId { get; set; }
        public string FinancialYear { get; set; } = string.Empty;
        public bool IsCurrentFinancialYear { get; set; }
        public int MaxCapacity { get; set; }
        public int? StaffId { get; set; }
        public string? StaffFullName { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public int CreatedBy { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? UpdatedBy { get; set; }
    }
}
