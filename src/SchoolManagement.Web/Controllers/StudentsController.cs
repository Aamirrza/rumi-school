using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;
using SchoolManagement.Web.Models;

namespace SchoolManagement.Web.Controllers
{
    [Authorize]
    public class StudentsController : Controller
    {
        private readonly IStudentService _studentService;
        private readonly IClassScheduleService _classScheduleService;
        private readonly IFinancialYearService _financialYearService;

        public StudentsController(
            IStudentService studentService,
            IClassScheduleService classScheduleService,
            IFinancialYearService financialYearService)
        {
            _studentService = studentService;
            _classScheduleService = classScheduleService;
            _financialYearService = financialYearService;
        }

        public async Task<IActionResult> Index(string? searchText, int? classScheduleId, int? financialYearId, string? gender)
        {
            var students = await _studentService.SearchAsync(searchText, classScheduleId, financialYearId, gender);

            var schedules = await _classScheduleService.GetAllAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", classScheduleId);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName", financialYearId);
            ViewBag.Genders = new SelectList(new[] { "Male", "Female", "Other" }, gender);

            ViewBag.SearchText = searchText;
            ViewBag.SelectedScheduleId = classScheduleId;
            ViewBag.SelectedFinancialYearId = financialYearId;
            ViewBag.SelectedGender = gender;

            return View(students);
        }

        public async Task<IActionResult> Details(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            // The list contains one row per mapping. The basic student info is identical across rows.
            var student = list.First();
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            return View(student);
        }

        public async Task<IActionResult> Create()
        {
            await PopulateDropdownsAsync();
            var model = new StudentInfo
            {
                AdmissionDate = DateTime.Today,
                DateOfBirth = DateTime.Today.AddYears(-5)
            };
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(StudentInfo model, int? classScheduleId, int? rollNo, IFormFile? studentPhoto)
        {
            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync(classScheduleId);
                return View(model);
            }

            int performedBy = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            if (studentPhoto != null && studentPhoto.Length > 0)
            {
                model.StudentPhoto = CompressImage(studentPhoto);
            }

            var result = await _studentService.SaveAsync(model, classScheduleId, rollNo, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student admitted successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(classScheduleId);
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            var viewItem = list.First();
            
            // Map view back to StudentInfo entity
            var model = new StudentInfo
            {
                StudentId = viewItem.StudentId,
                GrNo = viewItem.GrNo,
                AdmissionDate = viewItem.AdmissionDate,
                FirstName = viewItem.FirstName,
                MiddleName = viewItem.MiddleName,
                LastName = viewItem.LastName,
                DateOfBirth = viewItem.DateOfBirth,
                Gender = viewItem.Gender,
                StudentPhoto = viewItem.StudentPhoto,
                PlaceOfBirth = viewItem.PlaceOfBirth,
                Nationality = viewItem.Nationality,
                BloodGroup = viewItem.BloodGroup,
                Category = viewItem.Category,
                Religion = viewItem.Religion,
                AadhaarNumber = viewItem.AadhaarNumber,
                AddressLine1 = viewItem.AddressLine1,
                AddressLine2 = viewItem.AddressLine2,
                City = viewItem.City,
                State = viewItem.State,
                Country = viewItem.Country,
                PinCode = viewItem.PinCode,
                FatherName = viewItem.FatherName,
                FatherOccupation = viewItem.FatherOccupation,
                FatherMobileNumber = viewItem.FatherMobileNumber,
                MotherName = viewItem.MotherName,
                MotherOccupation = viewItem.MotherOccupation,
                MotherMobileNumber = viewItem.MotherMobileNumber,
                GuardianName = viewItem.GuardianName,
                GuardianMobileNumber = viewItem.GuardianMobileNumber,
                EmergencyContactNumber = viewItem.EmergencyContactNumber,
                PreviousSchoolName = viewItem.PreviousSchoolName,
                AdmissionFinancialYearId = viewItem.AdmissionFinancialYearId,
                EmailAddress = viewItem.EmailAddress
            };

            await PopulateDropdownsAsync();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, StudentInfo model, IFormFile? studentPhoto)
        {
            if (id != model.StudentId)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync();
                return View(model);
            }

            int performedBy = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            if (studentPhoto != null && studentPhoto.Length > 0)
            {
                model.StudentPhoto = CompressImage(studentPhoto);
            }
            else
            {
                var list = await _studentService.GetByIdAsync(id);
                if (list.Any())
                {
                    model.StudentPhoto = list.First().StudentPhoto;
                }
            }

            // When editing basic student details, we pass null classScheduleId and rollNo because they are updated independently or mapped elsewhere
            var result = await _studentService.SaveAsync(model, null, null, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student details updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync();
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> Allocate(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            var student = list.First();
            ViewBag.StudentName = $"{student.FirstName} {student.LastName} ({student.GrNo})";
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            var schedules = await _classScheduleService.GetAllAsync();
            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName");

            return View(new StudentAllocationModel { StudentId = id });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Allocate(StudentAllocationModel model)
        {
            var list = await _studentService.GetByIdAsync(model.StudentId);
            if (!list.Any())
            {
                return NotFound();
            }

            var viewItem = list.First();
            ViewBag.StudentName = $"{viewItem.FirstName} {viewItem.LastName} ({viewItem.GrNo})";
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            if (!ModelState.IsValid)
            {
                var schedules = await _classScheduleService.GetAllAsync();
                ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", model.ClassScheduleId);
                return View(model);
            }

            // Reconstruct StudentInfo for SaveAsync
            var studentInfo = new StudentInfo
            {
                StudentId = viewItem.StudentId,
                GrNo = viewItem.GrNo,
                AdmissionDate = viewItem.AdmissionDate,
                FirstName = viewItem.FirstName,
                MiddleName = viewItem.MiddleName,
                LastName = viewItem.LastName,
                DateOfBirth = viewItem.DateOfBirth,
                Gender = viewItem.Gender,
                StudentPhoto = viewItem.StudentPhoto,
                PlaceOfBirth = viewItem.PlaceOfBirth,
                Nationality = viewItem.Nationality,
                BloodGroup = viewItem.BloodGroup,
                Category = viewItem.Category,
                Religion = viewItem.Religion,
                AadhaarNumber = viewItem.AadhaarNumber,
                AddressLine1 = viewItem.AddressLine1,
                AddressLine2 = viewItem.AddressLine2,
                City = viewItem.City,
                State = viewItem.State,
                Country = viewItem.Country,
                PinCode = viewItem.PinCode,
                FatherName = viewItem.FatherName,
                FatherOccupation = viewItem.FatherOccupation,
                FatherMobileNumber = viewItem.FatherMobileNumber,
                MotherName = viewItem.MotherName,
                MotherOccupation = viewItem.MotherOccupation,
                MotherMobileNumber = viewItem.MotherMobileNumber,
                GuardianName = viewItem.GuardianName,
                GuardianMobileNumber = viewItem.GuardianMobileNumber,
                EmergencyContactNumber = viewItem.EmergencyContactNumber,
                PreviousSchoolName = viewItem.PreviousSchoolName,
                AdmissionFinancialYearId = viewItem.AdmissionFinancialYearId,
                EmailAddress = viewItem.EmailAddress
            };

            int performedBy = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _studentService.SaveAsync(studentInfo, model.ClassScheduleId, model.RollNo, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student allocated successfully.";
                return RedirectToAction(nameof(Details), new { id = model.StudentId });
            }

            ModelState.AddModelError(string.Empty, result.Message);
            var schedulesList = await _classScheduleService.GetAllAsync();
            ViewBag.ClassSchedules = new SelectList(schedulesList, "ClassScheduleId", "ClassName", model.ClassScheduleId);
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }
            return View(list.First());
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            int performedBy = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _studentService.DeleteAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student deleted successfully.";
                return RedirectToAction(nameof(Index));
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Index));
        }

        private async Task PopulateDropdownsAsync(int? selectedScheduleId = null)
        {
            var schedules = await _classScheduleService.GetAllAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", selectedScheduleId);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName");
            ViewBag.Genders = new SelectList(new[] { "Male", "Female", "Other" });
            ViewBag.BloodGroups = new SelectList(new[] { "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-" });
            ViewBag.Categories = new SelectList(new[] { "General", "OBC", "SC", "ST", "EWS" });
        }

        private byte[] CompressImage(IFormFile file)
        {
            using (var memoryStream = new MemoryStream())
            {
                file.CopyTo(memoryStream);
                memoryStream.Position = 0;
                
                using (var originalImage = Image.FromStream(memoryStream))
                {
                    // Calculate new dimensions (max width/height of 1000px to maintain clarity and small file size)
                    int maxWidth = 1000;
                    int maxHeight = 1000;
                    int newWidth = originalImage.Width;
                    int newHeight = originalImage.Height;
                    
                    if (newWidth > maxWidth || newHeight > maxHeight)
                    {
                        double ratioX = (double)maxWidth / originalImage.Width;
                        double ratioY = (double)maxHeight / originalImage.Height;
                        double ratio = Math.Min(ratioX, ratioY);
                        
                        newWidth = (int)(originalImage.Width * ratio);
                        newHeight = (int)(originalImage.Height * ratio);
                    }
                    
                    using (var resizedImage = new Bitmap(newWidth, newHeight))
                    {
                        using (var graphics = Graphics.FromImage(resizedImage))
                        {
                            graphics.CompositingQuality = CompositingQuality.HighQuality;
                            graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                            graphics.SmoothingMode = SmoothingMode.HighQuality;
                            graphics.DrawImage(originalImage, 0, 0, newWidth, newHeight);
                        }
                        
                        using (var outputStream = new MemoryStream())
                        {
                            // Compress to JPEG with 75% quality for excellent clarity but small footprint (< 150 KB)
                            var jpegEncoder = GetEncoder(ImageFormat.Jpeg);
                            var encoderParameters = new EncoderParameters(1);
                            encoderParameters.Param[0] = new EncoderParameter(Encoder.Quality, 75L);
                            
                            if (jpegEncoder != null)
                            {
                                resizedImage.Save(outputStream, jpegEncoder, encoderParameters);
                            }
                            else
                            {
                                resizedImage.Save(outputStream, ImageFormat.Jpeg);
                            }
                            
                            return outputStream.ToArray();
                        }
                    }
                }
            }
        }

        private ImageCodecInfo? GetEncoder(ImageFormat format)
        {
            ImageCodecInfo[] codecs = ImageCodecInfo.GetImageEncoders();
            foreach (ImageCodecInfo codec in codecs)
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }
            return null;
        }
    }
}
