using Microsoft.AspNetCore.Authentication.Cookies;
using SchoolManagement.Infrastructure;
using SchoolManagement.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Register Clean Architecture Layers
builder.Services.AddInfrastructure(builder.Configuration);

// Add Cookie Authentication
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Auth/Login";
        options.LogoutPath = "/Auth/Logout";
        options.AccessDeniedPath = "/Auth/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
        options.SlidingExpiration = true;
    });

var app = builder.Build();

// Verify Database Connection on Startup
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<SchoolDbContext>();
        if (context.Database.CanConnect())
        {
            Console.WriteLine(">>> SQL Server Database connection verified successfully. <<<");
        }
        else
        {
            Console.WriteLine(">>> SQL Server Database connection test failed (CanConnect returned false). <<<");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($">>> SQL Server Database connection test failed with exception: {ex.Message} <<<");
    }
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Dashboard}/{action=Index}/{id?}");

app.Run();
