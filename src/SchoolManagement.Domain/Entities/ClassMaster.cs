using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class ClassMaster : BaseEntity
    {
        public int ClassId { get; set; }
        public string ClassName { get; set; }
    }
}
