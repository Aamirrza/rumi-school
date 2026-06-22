USE SMS;
GO

-- 1. Drop existing StudentPhotoPath / StudentPhoto columns to avoid conversion errors
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('StudentInfo') AND name = 'StudentPhotoPath')
BEGIN
    ALTER TABLE StudentInfo DROP COLUMN StudentPhotoPath;
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('StudentInfo') AND name = 'StudentPhoto')
BEGIN
    ALTER TABLE StudentInfo DROP COLUMN StudentPhoto;
END
GO

-- 2. Add StudentPhoto as VARBINARY(MAX)
ALTER TABLE StudentInfo ADD StudentPhoto VARBINARY(MAX) NULL;
GO

-- 3. Recreate VIEW vw_StudentDetails to reference StudentPhoto
CREATE OR ALTER VIEW vw_StudentDetails
AS
SELECT 
    s.StudentId,
    s.GrNo,
    s.AdmissionDate,
    s.FirstName,
    s.MiddleName,
    s.LastName,
    (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS FullName,
    s.DateOfBirth,
    s.Gender,
    s.StudentPhoto,
    s.PlaceOfBirth,
    s.Nationality,
    s.BloodGroup,
    s.Category,
    s.Religion,
    s.AadhaarNumber,
    s.AddressLine1,
    s.AddressLine2,
    s.City,
    s.State,
    s.Country,
    s.PinCode,
    s.FatherName,
    s.FatherOccupation,
    s.FatherMobileNumber,
    s.MotherName,
    s.MotherOccupation,
    s.MotherMobileNumber,
    s.GuardianName,
    s.GuardianMobileNumber,
    s.EmergencyContactNumber,
    s.PreviousSchoolName,
    s.AdmissionFinancialYearId,
    fy_adm.FinancialYear AS AdmissionFinancialYear,
    s.EmailAddress,
    
    -- Mapping fields
    sm.StudentMappingId,
    sm.ClassScheduleId,
    sm.RollNo,
    c.ClassName,
    d.DivisionName,
    fy.FinancialYear AS MappingFinancialYear,
    
    -- Global Audit fields
    s.CreatedDate,
    s.CreatedBy,
    s.UpdatedDate,
    s.UpdatedBy,
    s.IsActive,
    s.IsDeleted
FROM StudentInfo s
INNER JOIN FinancialYear fy_adm ON s.AdmissionFinancialYearId = fy_adm.FinancialYearId
LEFT JOIN StudentMappings sm ON s.StudentId = sm.StudentId AND sm.IsDeleted = 0
LEFT JOIN ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0
LEFT JOIN ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
LEFT JOIN DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
LEFT JOIN FinancialYear fy ON cs.FinancialYearId = fy.FinancialYearId AND fy.IsDeleted = 0
WHERE s.IsDeleted = 0;
GO

-- 4. Recreate usp_Student_Save to accept VARBINARY(MAX) for @StudentPhoto
CREATE OR ALTER PROCEDURE usp_Student_Save
    @StudentId INT,
    @AdmissionDate DATE,
    @FirstName VARCHAR(50),
    @MiddleName VARCHAR(50) = NULL,
    @LastName VARCHAR(50),
    @DateOfBirth DATE,
    @Gender VARCHAR(10),
    @StudentPhoto VARBINARY(MAX) = NULL,
    @PlaceOfBirth VARCHAR(100) = NULL,
    @Nationality VARCHAR(50) = 'Indian',
    @BloodGroup VARCHAR(5) = NULL,
    @Category VARCHAR(30) = NULL,
    @Religion VARCHAR(50) = NULL,
    @AadhaarNumber VARCHAR(12) = NULL,
    @AddressLine1 VARCHAR(150),
    @AddressLine2 VARCHAR(150) = NULL,
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Country VARCHAR(50) = 'India',
    @PinCode VARCHAR(10),
    @FatherName VARCHAR(100),
    @FatherOccupation VARCHAR(100) = NULL,
    @FatherMobileNumber VARCHAR(15),
    @MotherName VARCHAR(100),
    @MotherOccupation VARCHAR(100) = NULL,
    @MotherMobileNumber VARCHAR(15) = NULL,
    @GuardianName VARCHAR(100) = NULL,
    @GuardianMobileNumber VARCHAR(15) = NULL,
    @EmergencyContactNumber VARCHAR(15),
    @PreviousSchoolName VARCHAR(150) = NULL,
    @AdmissionFinancialYearId INT,
    @EmailAddress VARCHAR(100) = NULL,
    @ClassScheduleId INT = NULL,
    @RollNo INT = NULL,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OperationType VARCHAR(10) = 'UPDATE';
    DECLARE @OldValues NVARCHAR(MAX) = NULL;
    DECLARE @NewValues NVARCHAR(MAX) = NULL;
    DECLARE @GrNo VARCHAR(20) = NULL;
    DECLARE @MappingFinancialYearId INT = NULL;

    BEGIN TRY
        -- Fetch Financial Year Id for active mappings (based on ClassSchedule)
        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            SELECT @MappingFinancialYearId = FinancialYearId 
            FROM ClassSchedules 
            WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0 AND IsActive = 1;

            IF @MappingFinancialYearId IS NULL
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Selected Class Schedule is invalid or inactive.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END
        END

        BEGIN TRANSACTION;

        IF @StudentId IS NULL OR @StudentId = 0
        BEGIN
            SET @OperationType = 'INSERT';
            SET @GrNo = dbo.fn_GenerateGrNo(@AdmissionFinancialYearId);

            INSERT INTO StudentInfo (
                GrNo, AdmissionDate, FirstName, MiddleName, LastName, DateOfBirth, Gender, StudentPhoto,
                PlaceOfBirth, Nationality, BloodGroup, Category, Religion, AadhaarNumber,
                AddressLine1, AddressLine2, City, State, Country, PinCode,
                FatherName, FatherOccupation, FatherMobileNumber, MotherName, MotherOccupation, MotherMobileNumber,
                GuardianName, GuardianMobileNumber, EmergencyContactNumber,
                PreviousSchoolName, AdmissionFinancialYearId, EmailAddress, CreatedBy
            )
            VALUES (
                @GrNo, @AdmissionDate, @FirstName, @MiddleName, @LastName, @DateOfBirth, @Gender, @StudentPhoto,
                @PlaceOfBirth, @Nationality, @BloodGroup, @Category, @Religion, @AadhaarNumber,
                @AddressLine1, @AddressLine2, @City, @State, @Country, @PinCode,
                @FatherName, @FatherOccupation, @FatherMobileNumber, @MotherName, @MotherOccupation, @MotherMobileNumber,
                @GuardianName, @GuardianMobileNumber, @EmergencyContactNumber,
                @PreviousSchoolName, @AdmissionFinancialYearId, @EmailAddress, @PerformedBy
            );

            SET @StudentId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SELECT @GrNo = GrNo FROM StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0;
            IF @GrNo IS NULL
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Student not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE StudentInfo
            SET AdmissionDate = @AdmissionDate,
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                DateOfBirth = @DateOfBirth,
                Gender = @Gender,
                StudentPhoto = @StudentPhoto,
                PlaceOfBirth = @PlaceOfBirth,
                Nationality = @Nationality,
                BloodGroup = @BloodGroup,
                Category = @Category,
                Religion = @Religion,
                AddressLine1 = @AddressLine1,
                AddressLine2 = @AddressLine2,
                City = @City,
                State = @State,
                Country = @Country,
                PinCode = @PinCode,
                FatherName = @FatherName,
                FatherOccupation = @FatherOccupation,
                FatherMobileNumber = @FatherMobileNumber,
                MotherName = @MotherName,
                MotherOccupation = @MotherOccupation,
                MotherMobileNumber = @MotherMobileNumber,
                GuardianName = @GuardianName,
                GuardianMobileNumber = @GuardianMobileNumber,
                EmergencyContactNumber = @EmergencyContactNumber,
                PreviousSchoolName = @PreviousSchoolName,
                AdmissionFinancialYearId = @AdmissionFinancialYearId,
                EmailAddress = @EmailAddress,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE StudentId = @StudentId;
        END

        SET @NewValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StudentInfo', @StudentId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            DECLARE @MappingId INT = NULL;
            DECLARE @MapOldValues NVARCHAR(MAX) = NULL;
            DECLARE @MapNewValues NVARCHAR(MAX) = NULL;
            DECLARE @MapOpType VARCHAR(10) = 'UPDATE';

            SELECT @MappingId = StudentMappingId
            FROM StudentMappings
            WHERE StudentId = @StudentId AND FinancialYearId = @MappingFinancialYearId AND IsDeleted = 0;

            IF @MappingId IS NULL
            BEGIN
                SET @MapOpType = 'INSERT';
                INSERT INTO StudentMappings (StudentId, ClassScheduleId, FinancialYearId, RollNo, CreatedBy)
                VALUES (@StudentId, @ClassScheduleId, @MappingFinancialYearId, @RollNo, @PerformedBy);
                SET @MappingId = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SET @MapOldValues = (SELECT * FROM StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

                UPDATE StudentMappings
                SET ClassScheduleId = @ClassScheduleId,
                    RollNo = @RollNo,
                    UpdatedDate = SYSUTCDATETIME(),
                    UpdatedBy = @PerformedBy
                WHERE StudentMappingId = @MappingId;
            END

            SET @MapNewValues = (SELECT * FROM StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
            VALUES ('StudentMappings', @MappingId, @MapOpType, @MapOldValues, @MapNewValues, @PerformedBy, @IPAddress, @PerformedBy);
        END

        COMMIT TRANSACTION;

        SELECT @StatusCode AS StatusCode, @Message AS Message, @StudentId AS StudentId, @GrNo AS GrNo;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO
