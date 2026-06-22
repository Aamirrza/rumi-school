using System;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class FinancialYear : BaseEntity
    {
        public int FinancialYearId { get; set; }
        public string FinancialYearName { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsCurrent { get; set; }
    }
}
