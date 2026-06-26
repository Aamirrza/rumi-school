namespace SchoolManagement.Domain.Entities
{
    public class FeeDetailsView
    {
        public int FeeDetailID { get; set; }
        public int FeeID { get; set; }
        public decimal FeeAmount { get; set; }
        public int ClassID { get; set; }
        public string ClassName { get; set; } = string.Empty;
        public int FinancialYearID { get; set; }
        public string FinancialYear { get; set; } = string.Empty;
        public bool IsCurrentFinancialYear { get; set; }
        public int SemesterID { get; set; }
        public string SemesterName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }
}
