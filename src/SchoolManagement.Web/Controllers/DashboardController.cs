using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SchoolManagement.Application.Interfaces;

namespace SchoolManagement.Web.Controllers
{
    [Authorize]
    public class DashboardController : Controller
    {
        private readonly IDashboardService _dashboardService;
        private readonly IFinancialYearService _financialYearService;

        public DashboardController(IDashboardService dashboardService, IFinancialYearService financialYearService)
        {
            _dashboardService = dashboardService;
            _financialYearService = financialYearService;
        }

        public async Task<IActionResult> Index(int? financialYearId = null)
        {
            var financialYears = await _financialYearService.GetAllAsync();
            
            // If no financial year is selected, default to the current one
            var currentFy = financialYears.FirstOrDefault(fy => fy.IsCurrent) ?? financialYears.FirstOrDefault();
            int selectedFyId = financialYearId ?? currentFy?.FinancialYearId ?? 0;

            var dashboardData = await _dashboardService.GetSummaryAsync(selectedFyId);
            dashboardData.SelectedFinancialYearId = selectedFyId;
            dashboardData.SelectedFinancialYear = financialYears.FirstOrDefault(fy => fy.FinancialYearId == selectedFyId)?.FinancialYearName ?? "N/A";

            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName", selectedFyId);

            return View(dashboardData);
        }
    }
}
