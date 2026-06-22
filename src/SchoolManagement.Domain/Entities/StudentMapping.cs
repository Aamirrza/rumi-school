using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class StudentMapping : BaseEntity
    {
        public int StudentMappingId { get; set; }
        public int StudentId { get; set; }
        public int ClassScheduleId { get; set; }
        public int FinancialYearId { get; set; }
        public int RollNo { get; set; }

        // Navigation properties
        public virtual StudentInfo StudentInfo { get; set; }
        public virtual ClassSchedule ClassSchedule { get; set; }
        public virtual FinancialYear FinancialYear { get; set; }
    }
}
