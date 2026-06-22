using System;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class User : BaseEntity
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string FullName { get; set; }
        public string EmailAddress { get; set; }
        public DateTime? LastLoginDate { get; set; }
    }
}
