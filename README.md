# School Management System (SMS) - MVC

A secure, high-performance, and beautifully styled web-based **School Management System (SMS)** built with **ASP.NET Core MVC (.NET 7)**, **Entity Framework Core**, and **SQL Server**. It adheres strictly to **Clean Architecture** patterns, leveraging an SP-first (Stored Procedure first) mutation model with comprehensive view reporting.

---

## 1. Project Directory Structure

```text
├── database/                   # Database schemas, seeds, functions, views, SPs
│   ├── 01_create_database.sql  # Database creation
│   ├── 02_create_tables.sql    # Table schema definitions
│   ├── 03_create_constraints.sql # Foreign keys and check constraints
│   ├── 04_create_indexes.sql    # Custom filtered unique indexes
│   ├── 05_seed_data.sql        # Demo data (staff, fees, semesters, students, etc.)
│   ├── 06_functions.sql        # Utility functions (GrNo generator, etc.)
│   ├── 07_views.sql            # Analytical and details views (vw_StudentDetails, etc.)
│   ├── 08_create_stored_procedures.sql # Mutation/search procedures
│   ├── 09_staff_and_fees_procedures.sql # Staff, fee schedules, and payment SPs
│   └── schema_and_seed.sql     # Consolidated setup script for clean deployments
├── docs/                       # System design and architecture docs
├── src/                        # C# source code solution (.NET 7)
│   ├── SchoolManagement.Domain # Keyless query entities and data models
│   ├── SchoolManagement.Application # Service orchestration and business rules
│   ├── SchoolManagement.Infrastructure # EF Core context and SQL procedure call maps
│   └── SchoolManagement.Web    # Razor templates, controllers, and custom CSS theme
└── scratch/                    # Deployment helpers and utility patches
```

---

## 2. Quick-Start Database Setup Guide

To deploy the database to a clean local or remote SQL Server instance, choose **one** of the two methods below:

### Method A: Single Consolidated Script (Recommended)
1. Open your SQL Server Management Studio (SSMS) or command-line client.
2. Open and execute the consolidated file: **`database/schema_and_seed.sql`**.
   * *This single file automatically drops the database if it exists, initializes tables, establishes keys, hooks up views/procedures, and inserts ready-to-test seed records.*

### Method B: Ordered Batch Deployment
Alternatively, you can run the files in the `database/` folder sequentially:
1. `01_create_database.sql`
2. `02_create_tables.sql`
3. `03_create_constraints.sql`
4. `04_create_indexes.sql`
5. `05_seed_data.sql`
6. `06_functions.sql`
7. `07_views.sql`
8. `08_create_stored_procedures.sql`
9. `09_staff_and_fees_procedures.sql`

---

## 3. Running the Web Application

1. Open **`src/SchoolManagement.Web/appsettings.json`** and configure your connection string:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
2. Open a terminal in the solution source directory:
   ```bash
   cd src/SchoolManagement.Web
   ```
3. Run the development server:
   ```bash
   dotnet run --launch-profile "http"
   ```
4. Access the web app in your browser at: **`http://localhost:5076`**

---

## 4. Default Seed Credentials

Use the following credentials to access the system:

*   **Role**: System Administrator
*   **Username**: `admin`
*   **Password**: `Admin@123`

---

## 5. Phase 2 Features Implemented

*   **Manual GR Entries**: The auto-generated GR function was removed from `usp_Student_Save` in favor of user-inputted GR numbers with server-side validation to block duplicates.
*   **Fee Mapping**: Link specific semesters (e.g. Sem-1, Sem-2) and fee values to classes. Accessible directly in the sidebar.
*   **Dynamic Payments**: Redesigned collection slip with searchable student filters, live fee structure populator, and automatic balance calculations.
*   **Audit Trail**: Every modification (insert, edit, delete) writes to `AuditLogs` using native JSON tracking.
