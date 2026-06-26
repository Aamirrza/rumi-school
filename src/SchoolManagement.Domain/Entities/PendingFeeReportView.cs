using System;

namespace SchoolManagement.Domain.Entities
{
    public class PendingFeeReportView
    {
        public int StudentId { get; set; }
        public string StudentFullName { get; set; } = string.Empty;
        public string GrNo { get; set; } = string.Empty;
        public int ClassId { get; set; }
        public string ClassName { get; set; } = string.Empty;
        public string DivisionName { get; set; } = string.Empty;
        public int RollNo { get; set; }
        public string StaffName { get; set; } = string.Empty;
        public int FinancialYearId { get; set; }
        public string FinancialYear { get; set; } = string.Empty;
        public int FeeId { get; set; }
        public int SemesterId { get; set; }
        public string SemesterName { get; set; } = string.Empty;
        public decimal TotalFeeAmount { get; set; }
        public decimal AmountPaid { get; set; }
        public decimal RemainingBalance { get; set; }
    }
}
