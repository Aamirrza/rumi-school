namespace SchoolManagement.Domain.Models
{
    public class DbOperationResult
    {
        public int StatusCode { get; set; }
        public string Message { get; set; }
        public int? RecordId { get; set; } // Optional helper if we return an ID
    }
}
