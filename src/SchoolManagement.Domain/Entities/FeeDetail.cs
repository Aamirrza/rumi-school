using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class FeeDetail : BaseEntity
    {
        public int FeeDetailID { get; set; }
        public int FeeID { get; set; }
        public int ClassID { get; set; }
        public int FinancialYearID { get; set; }
        public int SemesterID { get; set; }

        public virtual FeeMaster? FeeMaster { get; set; }
        public virtual ClassMaster? ClassMaster { get; set; }
        public virtual FinancialYear? FinancialYear { get; set; }
        public virtual SemesterMaster? SemesterMaster { get; set; }
    }
}
