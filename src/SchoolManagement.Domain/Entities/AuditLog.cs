using System;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class AuditLog : BaseEntity
    {
        public int AuditLogId { get; set; }
        public string TableName { get; set; }
        public int RecordId { get; set; }
        public string OperationType { get; set; }
        public string OldValuesJson { get; set; }
        public string NewValuesJson { get; set; }
        public int PerformedBy { get; set; }
        public string IPAddress { get; set; }
    }
}
