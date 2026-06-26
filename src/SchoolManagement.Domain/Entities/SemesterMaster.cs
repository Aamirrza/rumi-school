using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class SemesterMaster : BaseEntity
    {
        public int SemesterID { get; set; }
        public string SemesterName { get; set; } = string.Empty;
    }
}
