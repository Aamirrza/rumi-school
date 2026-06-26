using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class StaffTypeMaster : BaseEntity
    {
        public int StaffTypeID { get; set; }
        public string StaffType { get; set; } = string.Empty;
    }
}
