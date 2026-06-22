using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class ClassSchedule : BaseEntity
    {
        public int ClassScheduleId { get; set; }
        public int ClassId { get; set; }
        public int DivisionId { get; set; }
        public int FinancialYearId { get; set; }
        public int MaxCapacity { get; set; }

        // Navigation properties
        public virtual ClassMaster? ClassMaster { get; set; }
        public virtual DivisionMaster? DivisionMaster { get; set; }
        public virtual FinancialYear? FinancialYear { get; set; }
    }
}
