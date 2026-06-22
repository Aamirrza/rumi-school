using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class Role : BaseEntity
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
    }
}
