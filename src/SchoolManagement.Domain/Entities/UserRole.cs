using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class UserRole : BaseEntity
    {
        public int UserRoleId { get; set; }
        public int UserId { get; set; }
        public int RoleId { get; set; }

        // Navigation properties
        public virtual User User { get; set; }
        public virtual Role Role { get; set; }
    }
}
