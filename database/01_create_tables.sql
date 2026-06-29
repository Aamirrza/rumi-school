-- Consolidated table and schema setup
-- Database Creation Script
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SMS')
BEGIN
    CREATE DATABASE SMS;
END
GO
USE SMS;
GO

-- Table Creation Script
-- Note: Contains only table definitions and primary keys if they don't already exist.

-- 1. SMS_FinancialYear Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_FinancialYear]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_FinancialYear (
        FinancialYearId INT IDENTITY(1,1) PRIMARY KEY,
        SMS_FinancialYear VARCHAR(20) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,
        IsCurrent BIT NOT NULL DEFAULT 0,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 2. SMS_DivisionMaster Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_DivisionMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_DivisionMaster (
        DivisionId INT IDENTITY(1,1) PRIMARY KEY,
        DivisionName VARCHAR(50) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 3. SMS_ClassMaster Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_ClassMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_ClassMaster (
        ClassId INT IDENTITY(1,1) PRIMARY KEY,
        ClassName VARCHAR(50) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 4. SMS_ClassSchedules Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_ClassSchedules (
        ClassScheduleId INT IDENTITY(1,1) PRIMARY KEY,
        ClassId INT NOT NULL,
        DivisionId INT NOT NULL,
        FinancialYearId INT NOT NULL,
        MaxCapacity INT NOT NULL,
        StaffId INT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 5. SMS_StudentInfo Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_StudentInfo (
        StudentId INT IDENTITY(1,1) PRIMARY KEY,
        GrNo VARCHAR(20) NULL,
        AdmissionDate DATE NOT NULL,
        FirstName VARCHAR(50) NOT NULL,
        MiddleName VARCHAR(50) NULL,
        LastName VARCHAR(50) NOT NULL,
        DateOfBirth DATE NOT NULL,
        Gender VARCHAR(10) NOT NULL,
        StudentPhoto VARBINARY(MAX) NULL,
        PlaceOfBirth VARCHAR(100) NULL,
        Nationality VARCHAR(50) NULL,
        BloodGroup VARCHAR(5) NULL,
        Category VARCHAR(30) NULL,
        Religion VARCHAR(50) NULL,
        AadhaarNumber VARCHAR(15) NULL,
        AddressLine1 VARCHAR(150) NOT NULL,
        AddressLine2 VARCHAR(150) NULL,
        City VARCHAR(50) NOT NULL,
        State VARCHAR(50) NULL,
        Country VARCHAR(50) NULL,
        PinCode VARCHAR(10) NOT NULL,
        FatherName VARCHAR(100) NOT NULL,
        FatherOccupation VARCHAR(100) NULL,
        FatherMobileNumber VARCHAR(15) NOT NULL,
        MotherName VARCHAR(100) NOT NULL,
        MotherOccupation VARCHAR(100) NULL,
        MotherMobileNumber VARCHAR(15) NULL,
        GuardianName VARCHAR(100) NULL,
        GuardianMobileNumber VARCHAR(15) NULL,
        Guardian2Name VARCHAR(100) NULL,
        Guardian2MobileNumber VARCHAR(15) NULL,
        EmergencyContactNumber VARCHAR(15) NOT NULL,
        PreviousSchoolName VARCHAR(150) NULL,
        AdmissionFinancialYearId INT NOT NULL,
        EmailAddress VARCHAR(100) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 6. SMS_StudentMappings Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_StudentMappings (
        StudentMappingId INT IDENTITY(1,1) PRIMARY KEY,
        StudentId INT NOT NULL,
        ClassScheduleId INT NOT NULL,
        FinancialYearId INT NOT NULL,
        RollNo INT NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 7. SMS_Users Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        Username VARCHAR(50) NOT NULL,
        PasswordHash VARCHAR(255) NOT NULL,
        FullName VARCHAR(100) NOT NULL,
        EmailAddress VARCHAR(100) NULL,
        LastLoginDate DATETIME2 NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 8. SMS_Roles Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_Roles]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_Roles (
        RoleId INT IDENTITY(1,1) PRIMARY KEY,
        RoleName VARCHAR(50) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 9. SMS_UserRoles Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_UserRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_UserRoles (
        UserRoleId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        RoleId INT NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 10. SMS_AuditLogs Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_AuditLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_AuditLogs (
        AuditLogId INT IDENTITY(1,1) PRIMARY KEY,
        TableName VARCHAR(100) NOT NULL,
        RecordId INT NOT NULL,
        OperationType VARCHAR(10) NOT NULL,
        OldValuesJson NVARCHAR(MAX) NULL,
        NewValuesJson NVARCHAR(MAX) NULL,
        PerformedBy INT NOT NULL,
        IPAddress VARCHAR(50) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 11. SMS_SemesterMaster Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_SemesterMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_SemesterMaster (
        SemesterID INT IDENTITY(1,1) PRIMARY KEY,
        SemesterName NVARCHAR(30) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 12. SMS_FeeMaster Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_FeeMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_FeeMaster (
        FeeID INT IDENTITY(1,1) PRIMARY KEY,
        Fee DECIMAL(18,2) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 13. SMS_FeeDetail Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_FeeDetail]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_FeeDetail (
        FeeDetailID INT IDENTITY(1,1) PRIMARY KEY,
        FeeID INT NOT NULL,
        ClassID INT NOT NULL,
        FinancialYearID INT NOT NULL,
        SemesterID INT NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 14. SMS_PaymentDetail Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_PaymentDetail (
        PaymentDetailID INT IDENTITY(1,1) PRIMARY KEY,
        StudentID INT NOT NULL,
        FinancialYearID INT NOT NULL,
        FeeID INT NOT NULL,
        PaymentMode VARCHAR(12) NOT NULL,
        TransactionRef NVARCHAR(50) NULL,
        Transactionphoto NVARCHAR(MAX) NULL,
        IsFullyPaid BIT NOT NULL DEFAULT 0,
        SemesterID INT NOT NULL,
        FeePaid DECIMAL(18,2) NOT NULL,
        TotalInstallment INT NOT NULL,
        Remarks NVARCHAR(250) NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 15. SMS_StaffTypeMaster Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_StaffTypeMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_StaffTypeMaster (
        StaffTypeID INT IDENTITY(1,1) PRIMARY KEY,
        StaffType NVARCHAR(50) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 16. SMS_StaffDetail Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_StaffDetail]') AND type in (N'U'))
BEGIN
    CREATE TABLE SMS_StaffDetail (
        StaffID INT IDENTITY(1,1) PRIMARY KEY,
        StaffFirstName NVARCHAR(50) NOT NULL,
        StaffMiddleName NVARCHAR(50) NULL,
        StaffLastName NVARCHAR(50) NOT NULL,
        StaffType INT NOT NULL,
        Mobileno VARCHAR(15) NOT NULL,
        EmergencyContact VARCHAR(15) NOT NULL,
        AddressLine1 NVARCHAR(150) NOT NULL,
        AddressLine2 NVARCHAR(150) NULL,
        AadhaarNo VARCHAR(15) NULL,
        BankName NVARCHAR(50) NULL,
        IFSCCode NVARCHAR(20) NULL,
        AccountNo NVARCHAR(20) NULL,
        PanNo NVARCHAR(20) NULL,
        StaffPic NVARCHAR(MAX) NULL,
        DOB DATE NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CreatedBy INT NOT NULL,
        UpdatedDate DATETIME2 NULL,
        UpdatedBy INT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO


-- Constraints Script (Foreign Keys and Check Constraints)
USE SMS;
GO

-- 1. FOREIGN KEY CONSTRAINTS

-- SMS_ClassSchedules Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ClassSchedules_Classes_ClassId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    ALTER TABLE SMS_ClassSchedules
        ADD CONSTRAINT FK_ClassSchedules_Classes_ClassId 
        FOREIGN KEY (ClassId) REFERENCES SMS_ClassMaster(ClassId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ClassSchedules_Divisions_DivisionId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    ALTER TABLE SMS_ClassSchedules
        ADD CONSTRAINT FK_ClassSchedules_Divisions_DivisionId 
        FOREIGN KEY (DivisionId) REFERENCES SMS_DivisionMaster(DivisionId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ClassSchedules_FinancialYears_FinancialYearId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    ALTER TABLE SMS_ClassSchedules
        ADD CONSTRAINT FK_ClassSchedules_FinancialYears_FinancialYearId 
        FOREIGN KEY (FinancialYearId) REFERENCES SMS_FinancialYear(FinancialYearId);
END

-- SMS_StudentInfo Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Students_FinancialYears_AdmissionFinancialYearId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    ALTER TABLE SMS_StudentInfo
        ADD CONSTRAINT FK_Students_FinancialYears_AdmissionFinancialYearId 
        FOREIGN KEY (AdmissionFinancialYearId) REFERENCES SMS_FinancialYear(FinancialYearId);
END

-- SMS_StudentMappings Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_StudentMappings_Students_StudentId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    ALTER TABLE SMS_StudentMappings
        ADD CONSTRAINT FK_StudentMappings_Students_StudentId 
        FOREIGN KEY (StudentId) REFERENCES SMS_StudentInfo(StudentId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_StudentMappings_ClassSchedules_ClassScheduleId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    ALTER TABLE SMS_StudentMappings
        ADD CONSTRAINT FK_StudentMappings_ClassSchedules_ClassScheduleId 
        FOREIGN KEY (ClassScheduleId) REFERENCES SMS_ClassSchedules(ClassScheduleId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_StudentMappings_FinancialYears_FinancialYearId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    ALTER TABLE SMS_StudentMappings
        ADD CONSTRAINT FK_StudentMappings_FinancialYears_FinancialYearId 
        FOREIGN KEY (FinancialYearId) REFERENCES SMS_FinancialYear(FinancialYearId);
END

-- SMS_UserRoles Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserRoles_Users_UserId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_UserRoles]'))
BEGIN
    ALTER TABLE SMS_UserRoles
        ADD CONSTRAINT FK_UserRoles_Users_UserId 
        FOREIGN KEY (UserId) REFERENCES SMS_Users(UserId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserRoles_Roles_RoleId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_UserRoles]'))
BEGIN
    ALTER TABLE SMS_UserRoles
        ADD CONSTRAINT FK_UserRoles_Roles_RoleId 
        FOREIGN KEY (RoleId) REFERENCES SMS_Roles(RoleId);
END

-- SMS_ClassSchedules -> SMS_StaffDetail
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ClassSchedules_StaffDetail_StaffId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    ALTER TABLE SMS_ClassSchedules
        ADD CONSTRAINT FK_ClassSchedules_StaffDetail_StaffId
        FOREIGN KEY (StaffId) REFERENCES SMS_StaffDetail(StaffID);
END

-- SMS_FeeDetail Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FeeDetail_FeeMaster_FeeId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FeeDetail]'))
BEGIN
    ALTER TABLE SMS_FeeDetail
        ADD CONSTRAINT FK_FeeDetail_FeeMaster_FeeId
        FOREIGN KEY (FeeID) REFERENCES SMS_FeeMaster(FeeID);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FeeDetail_ClassMaster_ClassId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FeeDetail]'))
BEGIN
    ALTER TABLE SMS_FeeDetail
        ADD CONSTRAINT FK_FeeDetail_ClassMaster_ClassId
        FOREIGN KEY (ClassID) REFERENCES SMS_ClassMaster(ClassId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FeeDetail_FinancialYears_FinancialYearId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FeeDetail]'))
BEGIN
    ALTER TABLE SMS_FeeDetail
        ADD CONSTRAINT FK_FeeDetail_FinancialYears_FinancialYearId
        FOREIGN KEY (FinancialYearID) REFERENCES SMS_FinancialYear(FinancialYearId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FeeDetail_SemesterMaster_SemesterId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FeeDetail]'))
BEGIN
    ALTER TABLE SMS_FeeDetail
        ADD CONSTRAINT FK_FeeDetail_SemesterMaster_SemesterId
        FOREIGN KEY (SemesterID) REFERENCES SMS_SemesterMaster(SemesterID);
END

-- SMS_PaymentDetail Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PaymentDetail_Students_StudentId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT FK_PaymentDetail_Students_StudentId
        FOREIGN KEY (StudentID) REFERENCES SMS_StudentInfo(StudentId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PaymentDetail_FinancialYears_FinancialYearId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT FK_PaymentDetail_FinancialYears_FinancialYearId
        FOREIGN KEY (FinancialYearID) REFERENCES SMS_FinancialYear(FinancialYearId);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PaymentDetail_FeeMaster_FeeId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT FK_PaymentDetail_FeeMaster_FeeId
        FOREIGN KEY (FeeID) REFERENCES SMS_FeeMaster(FeeID);
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PaymentDetail_SemesterMaster_SemesterId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT FK_PaymentDetail_SemesterMaster_SemesterId
        FOREIGN KEY (SemesterID) REFERENCES SMS_SemesterMaster(SemesterID);
END

-- SMS_StaffDetail -> SMS_StaffTypeMaster
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_StaffDetail_StaffTypeMaster_StaffType]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StaffDetail]'))
BEGIN
    ALTER TABLE SMS_StaffDetail
        ADD CONSTRAINT FK_StaffDetail_StaffTypeMaster_StaffType
        FOREIGN KEY (StaffType) REFERENCES SMS_StaffTypeMaster(StaffTypeID);
END


-- 2. CHECK CONSTRAINTS

-- SMS_FinancialYear StartDate & EndDate Check
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_FinancialYears_Dates]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FinancialYear]'))
BEGIN
    ALTER TABLE SMS_FinancialYear
        ADD CONSTRAINT CK_FinancialYears_Dates 
        CHECK (StartDate < EndDate);
END

-- SMS_ClassSchedules MaxCapacity Check
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_ClassSchedules_MaxCapacity]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    ALTER TABLE SMS_ClassSchedules
        ADD CONSTRAINT CK_ClassSchedules_MaxCapacity 
        CHECK (MaxCapacity > 0);
END

-- SMS_StudentInfo Gender Check
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_Students_Gender]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    ALTER TABLE SMS_StudentInfo
        ADD CONSTRAINT CK_Students_Gender 
        CHECK (Gender IN ('Male', 'Female', 'Other'));
END

-- SMS_AuditLogs OperationType Check
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_AuditLogs_OperationType]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_AuditLogs]'))
BEGIN
    ALTER TABLE SMS_AuditLogs
        ADD CONSTRAINT CK_AuditLogs_OperationType 
        CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'));
END

-- SMS_FeeMaster Fee Check
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_FeeMaster_Fee]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_FeeMaster]'))
BEGIN
    ALTER TABLE SMS_FeeMaster
        ADD CONSTRAINT CK_FeeMaster_Fee
        CHECK (Fee >= 0);
END

-- SMS_PaymentDetail Checks
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_PaymentDetail_FeePaid]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT CK_PaymentDetail_FeePaid
        CHECK (FeePaid >= 0);
END

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_PaymentDetail_TotalInstallment]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT CK_PaymentDetail_TotalInstallment
        CHECK (TotalInstallment > 0);
END

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_PaymentDetail_PaymentMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[SMS_PaymentDetail]'))
BEGIN
    ALTER TABLE SMS_PaymentDetail
        ADD CONSTRAINT CK_PaymentDetail_PaymentMode
        CHECK (PaymentMode IN ('Cash', 'Card', 'UPI', 'NetBanking', 'Cheque'));
END
GO


-- Indexes Script
USE SMS;
GO

-- 1. UNIQUE FILTERED INDEXES

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_FinancialYears_IsCurrent' AND object_id = OBJECT_ID(N'[dbo].[SMS_FinancialYear]'))
BEGIN
    CREATE UNIQUE INDEX UX_FinancialYears_IsCurrent 
    ON SMS_FinancialYear(IsCurrent) 
    WHERE IsCurrent = 1 AND IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_FinancialYears_FinancialYear' AND object_id = OBJECT_ID(N'[dbo].[SMS_FinancialYear]'))
BEGIN
    CREATE UNIQUE INDEX UX_FinancialYears_FinancialYear 
    ON SMS_FinancialYear(SMS_FinancialYear) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_Divisions_DivisionName' AND object_id = OBJECT_ID(N'[dbo].[SMS_DivisionMaster]'))
BEGIN
    CREATE UNIQUE INDEX UX_Divisions_DivisionName 
    ON SMS_DivisionMaster(DivisionName) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_Classes_ClassName' AND object_id = OBJECT_ID(N'[dbo].[SMS_ClassMaster]'))
BEGIN
    CREATE UNIQUE INDEX UX_Classes_ClassName 
    ON SMS_ClassMaster(ClassName) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_ClassSchedules_Year_Class_Div' AND object_id = OBJECT_ID(N'[dbo].[SMS_ClassSchedules]'))
BEGIN
    CREATE UNIQUE INDEX UX_ClassSchedules_Year_Class_Div 
    ON SMS_ClassSchedules(FinancialYearId, ClassId, DivisionId) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_Students_GrNo' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    CREATE UNIQUE INDEX UX_Students_GrNo 
    ON SMS_StudentInfo(GrNo) 
    WHERE IsDeleted = 0 AND GrNo IS NOT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_StudentMappings_Year_Student' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    CREATE UNIQUE INDEX UX_StudentMappings_Year_Student 
    ON SMS_StudentMappings(FinancialYearId, StudentId) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_StudentMappings_Schedule_RollNo' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    CREATE UNIQUE INDEX UX_StudentMappings_Schedule_RollNo 
    ON SMS_StudentMappings(ClassScheduleId, RollNo) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_Users_Username' AND object_id = OBJECT_ID(N'[dbo].[SMS_Users]'))
BEGIN
    CREATE UNIQUE INDEX UX_Users_Username 
    ON SMS_Users(Username) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_Roles_RoleName' AND object_id = OBJECT_ID(N'[dbo].[SMS_Roles]'))
BEGIN
    CREATE UNIQUE INDEX UX_Roles_RoleName 
    ON SMS_Roles(RoleName) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'UX_UserRoles_User_Role' AND object_id = OBJECT_ID(N'[dbo].[SMS_UserRoles]'))
BEGIN
    CREATE UNIQUE INDEX UX_UserRoles_User_Role 
    ON SMS_UserRoles(UserId, RoleId) 
    WHERE IsDeleted = 0;
END


-- 2. NON-CLUSTERED INDEXES

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Students_Name' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Students_Name 
    ON SMS_StudentInfo(LastName, FirstName, MiddleName) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Students_FatherMobileNumber' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Students_FatherMobileNumber 
    ON SMS_StudentInfo(FatherMobileNumber) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Students_EmailAddress' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentInfo]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Students_EmailAddress 
    ON SMS_StudentInfo(EmailAddress) 
    WHERE IsDeleted = 0 AND EmailAddress IS NOT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_StudentMappings_ClassScheduleId' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_StudentMappings_ClassScheduleId 
    ON SMS_StudentMappings(ClassScheduleId) 
    INCLUDE (StudentId, RollNo) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_StudentMappings_FinancialYearId' AND object_id = OBJECT_ID(N'[dbo].[SMS_StudentMappings]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_StudentMappings_FinancialYearId 
    ON SMS_StudentMappings(FinancialYearId) 
    INCLUDE (StudentId) 
    WHERE IsDeleted = 0;
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_AuditLogs_TableName_RecordId' AND object_id = OBJECT_ID(N'[dbo].[SMS_AuditLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_AuditLogs_TableName_RecordId 
    ON SMS_AuditLogs(TableName, RecordId);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_AuditLogs_CreatedDate' AND object_id = OBJECT_ID(N'[dbo].[SMS_AuditLogs]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_AuditLogs_CreatedDate 
    ON SMS_AuditLogs(CreatedDate);
END
GO
