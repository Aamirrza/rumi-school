using System.Collections.Generic;

namespace SchoolManagement.Domain.Models
{
    public class DashboardSummaryMetrics
    {
        public int TotalMappedStudents { get; set; }
        public int TotalActiveClasses { get; set; }
        public int TotalCapacity { get; set; }
        public int TotalAdmittedStudents { get; set; }
    }

    public class GenderDistribution
    {
        public string Gender { get; set; }
        public int StudentCount { get; set; }
    }

    public class ClassStudentCount
    {
        public string ClassName { get; set; }
        public int StudentCount { get; set; }
        public int MaxCapacity { get; set; }
    }

    public class DivisionStudentCount
    {
        public string DivisionName { get; set; }
        public int StudentCount { get; set; }
    }

    public class DashboardData
    {
        public DashboardSummaryMetrics Metrics { get; set; } = new DashboardSummaryMetrics();
        public List<GenderDistribution> GenderDistribution { get; set; } = new List<GenderDistribution>();
        public List<ClassStudentCount> ClassDistribution { get; set; } = new List<ClassStudentCount>();
        public List<DivisionStudentCount> DivisionDistribution { get; set; } = new List<DivisionStudentCount>();
        public int SelectedFinancialYearId { get; set; }
        public string SelectedFinancialYear { get; set; } = string.Empty;
    }
}
