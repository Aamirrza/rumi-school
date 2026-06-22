USE SMS;
GO

-- 1. Alter usp_FinancialYear_Delete
CREATE OR ALTER PROCEDURE usp_FinancialYear_Delete
    @FinancialYearId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        DECLARE @IsCurrent BIT;
        SELECT @IsCurrent = IsCurrent
        FROM FinancialYear
        WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0;

        IF @IsCurrent IS NULL
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Financial Year not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @IsCurrent = 1
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete the current active Financial Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in ClassSchedules
        IF EXISTS (SELECT 1 FROM ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in StudentInfo
        IF EXISTS (SELECT 1 FROM StudentInfo WHERE AdmissionFinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student admissions.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in StudentMappings
        IF EXISTS (SELECT 1 FROM StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student class mappings.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE FinancialYear
        SET IsDeleted = 1,
            IsCurrent = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE FinancialYearId = @FinancialYearId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FinancialYear', @FinancialYearId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

-- 2. Alter usp_Student_Delete
CREATE OR ALTER PROCEDURE usp_Student_Delete
    @StudentId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Student not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active mappings dependency
        IF EXISTS (SELECT 1 FROM StudentMappings WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Student as they have active class mappings. Remove class mappings first.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE StudentInfo
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StudentId = @StudentId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StudentInfo', @StudentId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
