using System.ComponentModel.DataAnnotations.Schema;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    [Table("SMS_SemesterMaster")]
    public class SemesterMaster : BaseEntity
    {
        public int SemesterID { get; set; }
        public string SemesterName { get; set; } = string.Empty;
    }
}
