-- Step 4: Constraints Script (Foreign Keys and Check Constraints)
USE SMS;
GO

-- ============================================================================
-- 1. FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- ClassSchedules Foreign Keys
ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Classes_ClassId 
    FOREIGN KEY (ClassId) REFERENCES ClassMaster(ClassId);

ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Divisions_DivisionId 
    FOREIGN KEY (DivisionId) REFERENCES DivisionMaster(DivisionId);

ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_FinancialYears_FinancialYearId 
    FOREIGN KEY (FinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- StudentInfo Foreign Keys
ALTER TABLE StudentInfo
    ADD CONSTRAINT FK_Students_FinancialYears_AdmissionFinancialYearId 
    FOREIGN KEY (AdmissionFinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- StudentMappings Foreign Keys
ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_Students_StudentId 
    FOREIGN KEY (StudentId) REFERENCES StudentInfo(StudentId);

ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_ClassSchedules_ClassScheduleId 
    FOREIGN KEY (ClassScheduleId) REFERENCES ClassSchedules(ClassScheduleId);

ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_FinancialYears_FinancialYearId 
    FOREIGN KEY (FinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- UserRoles Foreign Keys
ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_Users_UserId 
    FOREIGN KEY (UserId) REFERENCES Users(UserId);

ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_Roles_RoleId 
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId);

-- ClassSchedules -> StaffDetail
ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_StaffDetail_StaffId
    FOREIGN KEY (StaffId) REFERENCES StaffDetail(StaffID);

-- FeeDetail Foreign Keys
ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_FeeMaster_FeeId
    FOREIGN KEY (FeeID) REFERENCES FeeMaster(FeeID);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_ClassMaster_ClassId
    FOREIGN KEY (ClassID) REFERENCES ClassMaster(ClassId);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearID) REFERENCES FinancialYear(FinancialYearId);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_SemesterMaster_SemesterId
    FOREIGN KEY (SemesterID) REFERENCES SemesterMaster(SemesterID);

-- PaymentDetail Foreign Keys
ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_Students_StudentId
    FOREIGN KEY (StudentID) REFERENCES StudentInfo(StudentId);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearID) REFERENCES FinancialYear(FinancialYearId);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_FeeMaster_FeeId
    FOREIGN KEY (FeeID) REFERENCES FeeMaster(FeeID);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_SemesterMaster_SemesterId
    FOREIGN KEY (SemesterID) REFERENCES SemesterMaster(SemesterID);

-- StaffDetail -> StaffTypeMaster
ALTER TABLE StaffDetail
    ADD CONSTRAINT FK_StaffDetail_StaffTypeMaster_StaffType
    FOREIGN KEY (StaffType) REFERENCES StaffTypeMaster(StaffTypeID);


-- ============================================================================
-- 2. CHECK CONSTRAINTS
-- ============================================================================

-- FinancialYear StartDate & EndDate Check
ALTER TABLE FinancialYear
    ADD CONSTRAINT CK_FinancialYears_Dates 
    CHECK (StartDate < EndDate);

-- ClassSchedules MaxCapacity Check
ALTER TABLE ClassSchedules
    ADD CONSTRAINT CK_ClassSchedules_MaxCapacity 
    CHECK (MaxCapacity > 0);

-- StudentInfo Gender Check
ALTER TABLE StudentInfo
    ADD CONSTRAINT CK_Students_Gender 
    CHECK (Gender IN ('Male', 'Female', 'Other'));

-- AuditLogs OperationType Check
ALTER TABLE AuditLogs
    ADD CONSTRAINT CK_AuditLogs_OperationType 
    CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'));

-- FeeMaster Fee Check
ALTER TABLE FeeMaster
    ADD CONSTRAINT CK_FeeMaster_Fee
    CHECK (Fee >= 0);

-- PaymentDetail Checks
ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_FeePaid
    CHECK (FeePaid >= 0);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_TotalInstallment
    CHECK (TotalInstallment > 0);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_PaymentMode
    CHECK (PaymentMode IN ('Cash', 'Card', 'UPI', 'NetBanking', 'Cheque'));
GO

