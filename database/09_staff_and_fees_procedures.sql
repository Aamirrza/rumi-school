-- Step 9: Staff and Fees Stored Procedures & Views Script
USE SMS;
GO

-- ============================================================================
-- 1. VIEWS FOR STAFF AND FEES
-- ============================================================================

-- View to retrieve active staff details along with staff type name
IF OBJECT_ID('vw_StaffDetails', 'V') IS NOT NULL DROP VIEW vw_StaffDetails;
GO
CREATE VIEW vw_StaffDetails
AS
SELECT 
    s.StaffID,
    s.StaffFirstName,
    s.StaffMiddleName,
    s.StaffLastName,
    (s.StaffFirstName + ' ' + ISNULL(s.StaffMiddleName + ' ', '') + s.StaffLastName) AS StaffFullName,
    s.StaffType AS StaffTypeID,
    st.StaffType AS StaffTypeName,
    s.Mobileno,
    s.EmergencyContact,
    s.Address,
    s.AadhaarNo,
    s.BankName,
    s.IFSCCode,
    s.AccountNo,
    s.PanNo,
    s.StaffPic,
    s.DOB,
    s.IsActive,
    s.CreatedDate,
    s.CreatedBy
FROM StaffDetail s
INNER JOIN StaffTypeMaster st ON s.StaffType = st.StaffTypeID AND st.IsDeleted = 0
WHERE s.IsDeleted = 0;
GO

-- View to retrieve fee details mapped with Class, Semester, and Financial Year names
IF OBJECT_ID('vw_FeeDetails', 'V') IS NOT NULL DROP VIEW vw_FeeDetails;
GO
CREATE VIEW vw_FeeDetails
AS
SELECT 
    fd.FeeDetailID,
    fd.FeeID,
    fm.Fee AS FeeAmount,
    fd.ClassID,
    c.ClassName,
    fd.FinancialYearID,
    fy.FinancialYear,
    fy.IsCurrent AS IsCurrentFinancialYear,
    fd.SemesterID,
    sem.SemesterName,
    fd.IsActive,
    fd.CreatedDate,
    fd.CreatedBy
FROM FeeDetail fd
INNER JOIN FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
INNER JOIN ClassMaster c ON fd.ClassID = c.ClassId AND c.IsDeleted = 0
INNER JOIN FinancialYear fy ON fd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
INNER JOIN SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
WHERE fd.IsDeleted = 0;
GO

-- View to retrieve student payments mapped with student, class, semester and financial year
IF OBJECT_ID('vw_StudentPayments', 'V') IS NOT NULL DROP VIEW vw_StudentPayments;
GO
CREATE VIEW vw_StudentPayments
AS
SELECT 
    pd.PaymentDetailID,
    pd.StudentID,
    (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS StudentFullName,
    s.GrNo,
    pd.FinancialYearID,
    fy.FinancialYear,
    pd.FeeID,
    fm.Fee AS TotalFeeAmount,
    pd.SemesterID,
    sem.SemesterName,
    pd.PaymentMode,
    pd.TransactionRef,
    pd.Transactionphoto,
    pd.IsFullyPaid,
    pd.FeePaid,
    pd.TotalInstallment,
    pd.CreatedDate,
    pd.CreatedBy,
    (fm.Fee - ISNULL((
        SELECT SUM(pd2.FeePaid)
        FROM PaymentDetail pd2
        WHERE pd2.StudentID = pd.StudentID
          AND pd2.FinancialYearID = pd.FinancialYearID
          AND pd2.SemesterID = pd.SemesterID
          AND pd2.IsDeleted = 0
    ), 0)) AS FeeRemaining
FROM PaymentDetail pd
INNER JOIN StudentInfo s ON pd.StudentID = s.StudentId AND s.IsDeleted = 0
INNER JOIN FinancialYear fy ON pd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
INNER JOIN FeeMaster fm ON pd.FeeID = fm.FeeID AND fm.IsDeleted = 0
INNER JOIN SemesterMaster sem ON pd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
WHERE pd.IsDeleted = 0;
GO


-- ============================================================================
-- 2. DROPDOWN SP's (For UI Dropdown selection inputs)
-- ============================================================================

-- Dropdown list for Classes
IF OBJECT_ID('usp_Dropdown_GetClasses', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetClasses;
GO
CREATE PROCEDURE usp_Dropdown_GetClasses
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClassId, ClassName 
    FROM ClassMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY ClassName;
END;
GO

-- Dropdown list for Semesters
IF OBJECT_ID('usp_Dropdown_GetSemesters', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetSemesters;
GO
CREATE PROCEDURE usp_Dropdown_GetSemesters
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SemesterID, SemesterName, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM SemesterMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY SemesterName;
END;
GO

-- Dropdown list for Staff Types
IF OBJECT_ID('usp_Dropdown_GetStaffTypes', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetStaffTypes;
GO
CREATE PROCEDURE usp_Dropdown_GetStaffTypes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StaffTypeID, StaffType, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM StaffTypeMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY StaffType;
END;
GO

-- Dropdown list for Fees (Distinct Fee Amounts available)
IF OBJECT_ID('usp_Dropdown_GetFees', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetFees;
GO
CREATE PROCEDURE usp_Dropdown_GetFees
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FeeID, Fee AS FeeAmount
    FROM FeeMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY Fee;
END;
GO

-- Dropdown list for Staff (with optional type filtering, e.g., to assign teaching staff to classes)
IF OBJECT_ID('usp_Dropdown_GetStaff', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetStaff;
GO
CREATE PROCEDURE usp_Dropdown_GetStaff
    @StaffTypeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        *
    FROM vw_StaffDetails
    WHERE IsActive = 1
      AND (@StaffTypeId IS NULL OR StaffTypeID = @StaffTypeId)
    ORDER BY StaffTypeID, StaffFirstName, StaffLastName;
END;
GO

-- Dropdown list for mapped fees of a selected class for student payment screen
IF OBJECT_ID('usp_Dropdown_GetAvailableFeesForClass', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetAvailableFeesForClass;
GO
CREATE PROCEDURE usp_Dropdown_GetAvailableFeesForClass
    @ClassId INT,
    @FinancialYearId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        fd.FeeDetailID,
        fd.FeeID,
        fm.Fee AS FeeAmount,
        fd.ClassID,
        c.ClassName,
        fd.FinancialYearID,
        fy.FinancialYear,
        fy.IsCurrent AS IsCurrentFinancialYear,
        fd.SemesterID,
        sem.SemesterName,
        fd.IsActive
    FROM FeeDetail fd
    INNER JOIN FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
    INNER JOIN ClassMaster c ON fd.ClassID = c.ClassId AND c.IsDeleted = 0
    INNER JOIN FinancialYear fy ON fd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
    INNER JOIN SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
    WHERE fd.ClassID = @ClassId 
      AND fd.FinancialYearID = @FinancialYearId
      AND fd.IsDeleted = 0 AND fd.IsActive = 1
    ORDER BY sem.SemesterName;
END;
GO


-- ============================================================================
-- 3. CRUD PROCEDURES - STAFF DETAIL
-- ============================================================================

-- GetAll Staff
IF OBJECT_ID('usp_StaffDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_GetAll;
GO
CREATE PROCEDURE usp_StaffDetail_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StaffDetails ORDER BY StaffFirstName, StaffLastName;
END;
GO

-- GetById Staff
IF OBJECT_ID('usp_StaffDetail_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_GetById;
GO
CREATE PROCEDURE usp_StaffDetail_GetById
    @StaffId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StaffDetails WHERE StaffID = @StaffId;
END;
GO

-- Insert/Update Staff Detail (Upsert)
IF OBJECT_ID('usp_StaffDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_Save;
GO
CREATE PROCEDURE usp_StaffDetail_Save
    @StaffId INT,
    @StaffFirstName NVARCHAR(50),
    @StaffMiddleName NVARCHAR(50) = NULL,
    @StaffLastName NVARCHAR(50),
    @StaffType INT,
    @Mobileno VARCHAR(15),
    @EmergencyContact VARCHAR(15),
    @Address NVARCHAR(255),
    @AadhaarNo VARCHAR(12),
    @BankName NVARCHAR(50),
    @IFSCCode NVARCHAR(20),
    @AccountNo NVARCHAR(20),
    @PanNo NVARCHAR(20),
    @StaffPic NVARCHAR(MAX) = NULL,
    @DOB DATE,
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Validate Aadhaar Number length
        IF LEN(ISNULL(@AadhaarNo, '')) <> 12
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Aadhaar Number must be exactly 12 digits.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Validate Aadhaar uniqueness
        IF EXISTS (SELECT 1 FROM StaffDetail WHERE AadhaarNo = @AadhaarNo AND StaffID <> @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'A staff member with this Aadhaar Number already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check if Staff Type exists
        IF NOT EXISTS (SELECT 1 FROM StaffTypeMaster WHERE StaffTypeID = @StaffType AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Invalid Staff Type selected.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @StaffId = 0 OR @StaffId IS NULL
        BEGIN
            -- INSERT
            SET @OpType = 'INSERT';
            INSERT INTO StaffDetail (
                StaffFirstName, StaffMiddleName, StaffLastName, StaffType, Mobileno,
                EmergencyContact, Address, AadhaarNo, BankName, IFSCCode, AccountNo,
                PanNo, StaffPic, DOB, IsActive, CreatedBy
            )
            VALUES (
                @StaffFirstName, @StaffMiddleName, @StaffLastName, @StaffType, @Mobileno,
                @EmergencyContact, @Address, @AadhaarNo, @BankName, @IFSCCode, @AccountNo,
                @PanNo, @StaffPic, @DOB, @IsActive, @PerformedBy
            );
            
            SET @StaffId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- UPDATE
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM StaffDetail WHERE StaffID = @StaffId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Staff member not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            -- Get Old values for Audit Log
            SET @OldValues = (SELECT * FROM StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE StaffDetail
            SET StaffFirstName = @StaffFirstName,
                StaffMiddleName = @StaffMiddleName,
                StaffLastName = @StaffLastName,
                StaffType = @StaffType,
                Mobileno = @Mobileno,
                EmergencyContact = @EmergencyContact,
                Address = @Address,
                AadhaarNo = @AadhaarNo,
                BankName = @BankName,
                IFSCCode = @IFSCCode,
                AccountNo = @AccountNo,
                PanNo = @PanNo,
                StaffPic = ISNULL(@StaffPic, StaffPic), -- Retain old picture if not uploaded new
                DOB = @DOB,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE StaffID = @StaffId;
        END

        -- Capture new values and write Audit Log
        SET @NewValues = (SELECT * FROM StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StaffDetail', @StaffId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @StaffId AS StaffId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Delete Staff
IF OBJECT_ID('usp_StaffDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_Delete;
GO
CREATE PROCEDURE usp_StaffDetail_Delete
    @StaffId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM StaffDetail WHERE StaffID = @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Staff member not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent deletion if assigned to class schedules
        IF EXISTS (SELECT 1 FROM ClassSchedules WHERE StaffId = @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete staff member as they are actively assigned to a class schedule.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE StaffDetail
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StaffID = @StaffId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StaffDetail', @StaffId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


-- ============================================================================
-- 4. CRUD PROCEDURES - FEE MASTER
-- ============================================================================

-- GetAll FeeMaster
IF OBJECT_ID('usp_FeeMaster_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_FeeMaster_GetAll;
GO
CREATE PROCEDURE usp_FeeMaster_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FeeID, Fee, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM FeeMaster 
    WHERE IsDeleted = 0 
    ORDER BY Fee;
END;
GO

-- Save (Upsert) FeeMaster
IF OBJECT_ID('usp_FeeMaster_Save', 'P') IS NOT NULL DROP PROCEDURE usp_FeeMaster_Save;
GO
CREATE PROCEDURE usp_FeeMaster_Save
    @FeeId INT,
    @Fee DECIMAL(18,2),
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        IF @Fee < 0
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee amount cannot be negative.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check unique fee value
        IF EXISTS (SELECT 1 FROM FeeMaster WHERE Fee = @Fee AND FeeID <> @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'This fee amount already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @FeeId = 0 OR @FeeId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO FeeMaster (Fee, IsActive, CreatedBy)
            VALUES (@Fee, @IsActive, @PerformedBy);
            SET @FeeId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Fee not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM FeeMaster WHERE FeeID = @FeeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE FeeMaster
            SET Fee = @Fee,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FeeID = @FeeId;
        END

        SET @NewValues = (SELECT * FROM FeeMaster WHERE FeeID = @FeeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FeeMaster', @FeeId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @FeeId AS FeeId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


-- ============================================================================
-- 5. CRUD PROCEDURES - FEE DETAIL (CLASS FEE SCHEDULING)
-- ============================================================================

-- GetAll mapped FeeDetail
IF OBJECT_ID('usp_FeeDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_GetAll;
GO
CREATE PROCEDURE usp_FeeDetail_GetAll
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM vw_FeeDetails
    WHERE (@FinancialYearId IS NULL OR FinancialYearID = @FinancialYearId)
    ORDER BY ClassName, SemesterName;
END;
GO

-- GetById FeeDetail
IF OBJECT_ID('usp_FeeDetail_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_GetById;
GO
CREATE PROCEDURE usp_FeeDetail_GetById
    @FeeDetailId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_FeeDetails WHERE FeeDetailID = @FeeDetailId;
END;
GO

-- Save mapped FeeDetail
IF OBJECT_ID('usp_FeeDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_Save;
GO
CREATE PROCEDURE usp_FeeDetail_Save
    @FeeDetailId INT,
    @FeeId INT,
    @ClassId INT,
    @FinancialYearId INT,
    @SemesterId INT,
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Verify FKs
        IF NOT EXISTS (SELECT 1 FROM FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Fee amount is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Class is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SemesterMaster WHERE SemesterID = @SemesterId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Semester is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Financial Year is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent duplicate fee mappings for the same Class, Semester, and Financial Year
        IF EXISTS (
            SELECT 1 FROM FeeDetail 
            WHERE ClassID = @ClassId 
              AND SemesterID = @SemesterId 
              AND FinancialYearID = @FinancialYearId 
              AND FeeDetailID <> @FeeDetailId
              AND IsDeleted = 0
        )
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'A fee mapping already exists for this Class, Semester, and Financial Year combination.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @FeeDetailId = 0 OR @FeeDetailId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO FeeDetail (FeeID, ClassID, FinancialYearID, SemesterID, IsActive, CreatedBy)
            VALUES (@FeeId, @ClassId, @FinancialYearId, @SemesterId, @IsActive, @PerformedBy);
            SET @FeeDetailId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM FeeDetail WHERE FeeDetailID = @FeeDetailId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Fee mapping record not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE FeeDetail
            SET FeeID = @FeeId,
                ClassID = @ClassId,
                FinancialYearID = @FinancialYearId,
                SemesterID = @SemesterId,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FeeDetailID = @FeeDetailId;
        END

        SET @NewValues = (SELECT * FROM FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FeeDetail', @FeeDetailId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @FeeDetailId AS FeeDetailId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Delete FeeDetail mapping
IF OBJECT_ID('usp_FeeDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_Delete;
GO
CREATE PROCEDURE usp_FeeDetail_Delete
    @FeeDetailId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM FeeDetail WHERE FeeDetailID = @FeeDetailId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Fee mapping record not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent delete if payments exist for this combination
        DECLARE @FeeId INT, @ClassId INT, @SemesterId INT, @FinancialYearId INT;
        SELECT @FeeId = FeeID, @ClassId = ClassID, @SemesterId = SemesterID, @FinancialYearId = FinancialYearID 
        FROM FeeDetail 
        WHERE FeeDetailID = @FeeDetailId;

        IF EXISTS (
            SELECT 1 FROM PaymentDetail pd
            INNER JOIN StudentMappings sm ON pd.StudentID = sm.StudentId AND sm.IsDeleted = 0
            INNER JOIN ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0
            WHERE pd.FeeID = @FeeId 
              AND pd.SemesterID = @SemesterId 
              AND pd.FinancialYearID = @FinancialYearId
              AND cs.ClassId = @ClassId
              AND pd.IsDeleted = 0
        )
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete fee mapping because payments have already been collected for this fee config.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE FeeDetail
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE FeeDetailID = @FeeDetailId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FeeDetail', @FeeDetailId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


-- ============================================================================
-- 6. PROCEDURES - STUDENT PAYMENT DETAIL
-- ============================================================================

-- Get all payments history for a student
IF OBJECT_ID('usp_PaymentDetail_GetByStudent', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_GetByStudent;
GO
CREATE PROCEDURE usp_PaymentDetail_GetByStudent
    @StudentId INT,
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If no financial year passed, use current
    IF @FinancialYearId IS NULL OR @FinancialYearId = 0
    BEGIN
        SELECT @FinancialYearId = FinancialYearId 
        FROM FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    -- List what the student has paid so far
    SELECT * 
    FROM vw_StudentPayments
    WHERE StudentID = @StudentId 
      AND FinancialYearID = @FinancialYearId
    ORDER BY CreatedDate DESC;
END;
GO

-- Save Student Payment Record
IF OBJECT_ID('usp_PaymentDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_Save;
GO
CREATE PROCEDURE usp_PaymentDetail_Save
    @PaymentDetailId INT,
    @StudentId INT,
    @FinancialYearId INT,
    @FeeId INT,
    @PaymentMode VARCHAR(12),
    @TransactionRef NVARCHAR(50) = NULL,
    @Transactionphoto NVARCHAR(MAX) = NULL,
    @IsFullyPaid BIT = 0,
    @SemesterId INT,
    @FeePaid DECIMAL(18,2),
    @TotalInstallment INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Validation checks
        IF NOT EXISTS (SELECT 1 FROM StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Student not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Financial Year not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee configuration not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SemesterMaster WHERE SemesterID = @SemesterId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Semester not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @FeePaid < 0
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee paid amount cannot be negative.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- If online mode, Reference Number is mandatory
        IF @PaymentMode IN ('Card', 'UPI', 'NetBanking') AND ISNULL(@TransactionRef, '') = ''
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Transaction reference number is required for online/card payments.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @PaymentDetailId = 0 OR @PaymentDetailId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO PaymentDetail (
                StudentID, FinancialYearID, FeeID, PaymentMode, TransactionRef,
                Transactionphoto, IsFullyPaid, SemesterID, FeePaid, TotalInstallment, CreatedBy
            )
            VALUES (
                @StudentId, @FinancialYearId, @FeeId, @PaymentMode, @TransactionRef,
                @Transactionphoto, @IsFullyPaid, @SemesterId, @FeePaid, @TotalInstallment, @PerformedBy
            );
            SET @PaymentDetailId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM PaymentDetail WHERE PaymentDetailID = @PaymentDetailId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Payment record not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE PaymentDetail
            SET StudentID = @StudentId,
                FinancialYearID = @FinancialYearId,
                FeeID = @FeeId,
                PaymentMode = @PaymentMode,
                TransactionRef = @TransactionRef,
                Transactionphoto = ISNULL(@Transactionphoto, Transactionphoto), -- Retain old receipt photo if not updated
                IsFullyPaid = @IsFullyPaid,
                SemesterID = @SemesterId,
                FeePaid = @FeePaid,
                TotalInstallment = @TotalInstallment,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE PaymentDetailID = @PaymentDetailId;
        END

        SET @NewValues = (SELECT * FROM PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('PaymentDetail', @PaymentDetailId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @PaymentDetailId AS PaymentDetailId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- GetAll Payments (standalone Payments list page)
IF OBJECT_ID('usp_PaymentDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_GetAll;
GO
CREATE PROCEDURE usp_PaymentDetail_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StudentPayments ORDER BY CreatedDate DESC;
END;
GO

-- Soft-Delete a Payment
IF OBJECT_ID('usp_PaymentDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_Delete;
GO
CREATE PROCEDURE usp_PaymentDetail_Delete
    @PaymentDetailId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PaymentDetail WHERE PaymentDetailID = @PaymentDetailId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Payment record not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE PaymentDetail
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE PaymentDetailID = @PaymentDetailId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('PaymentDetail', @PaymentDetailId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Retrieve students with pending fees
IF OBJECT_ID('usp_Report_GetPendingFees', 'P') IS NOT NULL DROP PROCEDURE usp_Report_GetPendingFees;
GO
CREATE PROCEDURE usp_Report_GetPendingFees
    @ClassId INT = NULL,
    @SemesterId INT = NULL,
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- If financial year is not provided, use the active one
    IF @FinancialYearId IS NULL
    BEGIN
        SELECT TOP 1 @FinancialYearId = FinancialYearId 
        FROM FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    SELECT 
        s.StudentId,
        (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS StudentFullName,
        s.GrNo,
        c.ClassId,
        c.ClassName,
        d.DivisionName,
        sm.RollNo,
        (st.StaffFirstName + ' ' + ISNULL(st.StaffMiddleName + ' ', '') + st.StaffLastName) AS StaffName,
        sm.FinancialYearId,
        fy.FinancialYear,
        fd.FeeID AS FeeId,
        fd.SemesterID AS SemesterId,
        sem.SemesterName,
        fm.Fee AS TotalFeeAmount,
        ISNULL(paid.TotalPaid, 0) AS AmountPaid,
        (fm.Fee - ISNULL(paid.TotalPaid, 0)) AS RemainingBalance
    FROM StudentMappings sm
    INNER JOIN StudentInfo s ON sm.StudentId = s.StudentId AND s.IsDeleted = 0
    INNER JOIN ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0
    INNER JOIN ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
    INNER JOIN DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
    INNER JOIN FinancialYear fy ON sm.FinancialYearId = fy.FinancialYearId AND fy.IsDeleted = 0
    INNER JOIN FeeDetail fd ON cs.ClassId = fd.ClassID AND fd.FinancialYearID = sm.FinancialYearId AND fd.IsDeleted = 0 AND fd.IsActive = 1
    INNER JOIN FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
    INNER JOIN SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
    LEFT JOIN StaffDetail st ON cs.StaffId = st.StaffID AND st.IsDeleted = 0
    LEFT JOIN (
        SELECT StudentID, FinancialYearID, FeeID, SemesterID, SUM(FeePaid) AS TotalPaid
        FROM PaymentDetail
        WHERE IsDeleted = 0
        GROUP BY StudentID, FinancialYearID, FeeID, SemesterID
    ) paid ON sm.StudentId = paid.StudentID 
          AND sm.FinancialYearId = paid.FinancialYearID 
          AND fd.FeeID = paid.FeeID 
          AND fd.SemesterID = paid.SemesterID
    WHERE sm.IsDeleted = 0 AND sm.IsActive = 1
      AND sm.FinancialYearId = @FinancialYearId
      AND (@ClassId IS NULL OR cs.ClassId = @ClassId)
      AND (@SemesterId IS NULL OR fd.SemesterID = @SemesterId)
      AND (fm.Fee - ISNULL(paid.TotalPaid, 0)) > 0
    ORDER BY c.ClassName, s.FirstName, sem.SemesterName;
END;
GO
