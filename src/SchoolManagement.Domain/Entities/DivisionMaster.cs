using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class DivisionMaster : BaseEntity
    {
        public int DivisionId { get; set; }
        public string DivisionName { get; set; }
    }
}
