USE SMS;
GO

CREATE OR ALTER PROCEDURE usp_Student_GetById
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        StudentId,
        GrNo,
        AdmissionDate,
        FirstName,
        MiddleName,
        LastName,
        FullName,
        DateOfBirth,
        Gender,
        StudentPhoto,
        PlaceOfBirth,
        Nationality,
        BloodGroup,
        Category,
        Religion,
        AadhaarNumber,
        AddressLine1,
        AddressLine2,
        City,
        State,
        Country,
        PinCode,
        FatherName,
        FatherOccupation,
        FatherMobileNumber,
        MotherName,
        MotherOccupation,
        MotherMobileNumber,
        GuardianName,
        GuardianMobileNumber,
        EmergencyContactNumber,
        PreviousSchoolName,
        AdmissionFinancialYearId,
        AdmissionFinancialYear,
        EmailAddress,
        IsStudentActive,
        StudentMappingId,
        RollNo,
        ClassScheduleId,
        ClassId,
        ClassName,
        DivisionId,
        DivisionName,
        MappingFinancialYearId,
        MappingFinancialYear,
        IsCurrentMappingYear
    FROM vw_StudentDetails
    WHERE StudentId = @StudentId;
END;
GO
