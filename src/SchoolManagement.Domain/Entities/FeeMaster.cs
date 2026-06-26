using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class FeeMaster : BaseEntity
    {
        public int FeeID { get; set; }
        public decimal Fee { get; set; }
    }
}
