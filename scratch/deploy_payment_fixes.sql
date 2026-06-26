-- ====================================================================
-- Deployment Script: Payment CRUD + GrNo + Fee Dropdown Fixes
-- Run this script in SSMS on the SMS database after re-seeding.
-- It deploys ONLY the CHANGED stored procedures.
-- ====================================================================
USE SMS;
GO

-- ====================================================================
-- 1. Fix usp_Dropdown_GetAvailableFeesForClass 
--    (returns all columns expected by FeeDetailsView C# entity)
-- ====================================================================
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

-- ====================================================================
-- 2. New: usp_PaymentDetail_GetAll (all payment records for index page)
-- ====================================================================
IF OBJECT_ID('usp_PaymentDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_GetAll;
GO
CREATE PROCEDURE usp_PaymentDetail_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StudentPayments ORDER BY CreatedDate DESC;
END;
GO

-- ====================================================================
-- 3. New: usp_PaymentDetail_Delete (soft-delete a payment record)
-- ====================================================================
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

PRINT '=== All payment procedures deployed successfully ===';
GO
