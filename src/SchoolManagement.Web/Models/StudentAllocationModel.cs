using System.ComponentModel.DataAnnotations;

namespace SchoolManagement.Web.Models
{
    public class StudentAllocationModel
    {
        [Required]
        public int StudentId { get; set; }

        [Required(ErrorMessage = "Class Schedule is required.")]
        [Display(Name = "Class Schedule")]
        public int ClassScheduleId { get; set; }

        [Required(ErrorMessage = "Roll Number is required.")]
        [Range(1, 1000, ErrorMessage = "Roll Number must be between 1 and 1000.")]
        [Display(Name = "Roll Number")]
        public int RollNo { get; set; }
    }
}
