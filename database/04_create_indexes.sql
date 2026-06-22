-- Step 5: Indexes Script
USE SMS;
GO

-- ============================================================================
-- 1. UNIQUE FILTERED INDEXES (For Soft-Delete Uniqueness & Logic Enforcements)
-- ============================================================================

-- Enforce only ONE current financial year among active (non-deleted) records
CREATE UNIQUE INDEX UX_FinancialYears_IsCurrent 
ON FinancialYear(IsCurrent) 
WHERE IsCurrent = 1 AND IsDeleted = 0;

-- Enforce unique FinancialYear name among active records
CREATE UNIQUE INDEX UX_FinancialYears_FinancialYear 
ON FinancialYear(FinancialYear) 
WHERE IsDeleted = 0;

-- Enforce unique DivisionName among active records
CREATE UNIQUE INDEX UX_Divisions_DivisionName 
ON DivisionMaster(DivisionName) 
WHERE IsDeleted = 0;

-- Enforce unique ClassName among active records
CREATE UNIQUE INDEX UX_Classes_ClassName 
ON ClassMaster(ClassName) 
WHERE IsDeleted = 0;

-- Enforce unique ClassSchedules (FinancialYearId + ClassId + DivisionId) among active records
CREATE UNIQUE INDEX UX_ClassSchedules_Year_Class_Div 
ON ClassSchedules(FinancialYearId, ClassId, DivisionId) 
WHERE IsDeleted = 0;

-- Enforce unique GrNo (General Register Number) for students among active records
CREATE UNIQUE INDEX UX_Students_GrNo 
ON StudentInfo(GrNo) 
WHERE IsDeleted = 0;

-- Enforce one student can belong to only one class schedule per financial year among active records
CREATE UNIQUE INDEX UX_StudentMappings_Year_Student 
ON StudentMappings(FinancialYearId, StudentId) 
WHERE IsDeleted = 0;

-- Enforce unique RollNo within a ClassSchedule among active records
CREATE UNIQUE INDEX UX_StudentMappings_Schedule_RollNo 
ON StudentMappings(ClassScheduleId, RollNo) 
WHERE IsDeleted = 0;

-- Enforce unique Username among active records
CREATE UNIQUE INDEX UX_Users_Username 
ON Users(Username) 
WHERE IsDeleted = 0;

-- Enforce unique RoleName among active records
CREATE UNIQUE INDEX UX_Roles_RoleName 
ON Roles(RoleName) 
WHERE IsDeleted = 0;

-- Enforce unique mapping between User and Role among active records
CREATE UNIQUE INDEX UX_UserRoles_User_Role 
ON UserRoles(UserId, RoleId) 
WHERE IsDeleted = 0;


-- ============================================================================
-- 2. NON-CLUSTERED INDEXES (For Performance Optimization)
-- ============================================================================

-- Optimize Student Search by Name
CREATE NONCLUSTERED INDEX IX_Students_Name 
ON StudentInfo(LastName, FirstName, MiddleName) 
WHERE IsDeleted = 0;

-- Optimize Student Search by Mobile Number
CREATE NONCLUSTERED INDEX IX_Students_FatherMobileNumber 
ON StudentInfo(FatherMobileNumber) 
WHERE IsDeleted = 0;

-- Optimize Student Search by Email
CREATE NONCLUSTERED INDEX IX_Students_EmailAddress 
ON StudentInfo(EmailAddress) 
WHERE IsDeleted = 0 AND EmailAddress IS NOT NULL;

-- Optimize Dashboard Queries: Student Mappings queries
CREATE NONCLUSTERED INDEX IX_StudentMappings_ClassScheduleId 
ON StudentMappings(ClassScheduleId) 
INCLUDE (StudentId, RollNo) 
WHERE IsDeleted = 0;

-- Optimize Dashboard Queries: Student count by Financial Year
CREATE NONCLUSTERED INDEX IX_StudentMappings_FinancialYearId 
ON StudentMappings(FinancialYearId) 
INCLUDE (StudentId) 
WHERE IsDeleted = 0;

-- Optimize Audit Log Retrieval by Table Name
CREATE NONCLUSTERED INDEX IX_AuditLogs_TableName_RecordId 
ON AuditLogs(TableName, RecordId);

-- Optimize Audit Log Retrieval by Date
CREATE NONCLUSTERED INDEX IX_AuditLogs_CreatedDate 
ON AuditLogs(CreatedDate);
GO

