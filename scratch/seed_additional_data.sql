USE SMS;
GO

-- Disable triggers/constraints check temporarily if needed, but not necessary as IDs match
-- 1. Seed Staff Details (so we can assign them to Class Schedules)
INSERT INTO StaffDetail (
    StaffFirstName, StaffMiddleName, StaffLastName, StaffType, Mobileno, 
    EmergencyContact, Address, AadhaarNo, BankName, IFSCCode, AccountNo, 
    PanNo, DOB, IsActive, CreatedBy
)
VALUES 
    ('John', 'Robert', 'Doe', 1, '9876543210', '9876543211', '123 Teacher Lane, City', '123456789012', 'State Bank of India', 'SBIN0001234', '100020003000', 'ABCDE1234F', '1985-05-15', 1, 1),
    ('Mary', 'Alice', 'Smith', 1, '9876543220', '9876543221', '456 Faculty Road, City', '123456789023', 'HDFC Bank', 'HDFC0004567', '100020003001', 'FGHIJ5678K', '1990-08-22', 1, 1),
    ('David', 'James', 'Brown', 2, '9876543230', '9876543231', '789 Staff Street, City', '123456789034', 'ICICI Bank', 'ICIC0007890', '100020003002', 'LMNOP9012Q', '1988-12-10', 1, 1);
GO

-- 2. Seed Class Schedules (connecting Classes, Divisions, Financial Year, Staff)
-- Class 10 (ClassId=13), Division A (DivisionId=1), FinancialYear 2026-2027 (FYId=2), StaffId=1 (John Doe)
-- Class 12 (ClassId=15), Division B (DivisionId=2), FinancialYear 2026-2027 (FYId=2), StaffId=2 (Mary Smith)
INSERT INTO ClassSchedules (ClassId, DivisionId, FinancialYearId, MaxCapacity, StaffId, CreatedBy)
VALUES 
    (13, 1, 2, 40, 1, 1),
    (15, 2, 2, 35, 2, 1);
GO

-- 3. Seed Students
INSERT INTO StudentInfo (
    GrNo, AdmissionDate, FirstName, MiddleName, LastName, DateOfBirth, 
    Gender, Nationality, AddressLine1, City, State, PinCode, 
    FatherName, FatherMobileNumber, MotherName, EmergencyContactNumber, 
    AdmissionFinancialYearId, CreatedBy
)
VALUES 
    ('GR1001', '2026-06-01', 'Alice', 'Marie', 'Johnson', '2011-04-10', 'Female', 'Indian', '789 Student Way', 'City', 'State', '400001', 'Robert Johnson', '9898989801', 'Sarah Johnson', '9898989802', 2, 1),
    ('GR1002', '2026-06-02', 'Bob', 'Edward', 'Miller', '2009-09-15', 'Male', 'Indian', '456 Scholar Ave', 'City', 'State', '400002', 'William Miller', '9898989811', 'Linda Miller', '9898989812', 2, 1);
GO

-- 4. Seed Student Mappings (Alice mapped to Class 10 Div A, Bob to Class 12 Div B)
INSERT INTO StudentMappings (StudentId, ClassScheduleId, FinancialYearId, RollNo, CreatedBy)
VALUES 
    (1, 1, 2, 1, 1),
    (2, 2, 2, 1, 1);
GO

-- 5. Seed Fee Details (mapping fees to Classes, Semesters, Financial Years)
-- Class 10 (ClassId=13), Sem-1 (SemesterId=1) Fee=7000 (FeeId=3)
-- Class 10 (ClassId=13), Sem-2 (SemesterId=2) Fee=7000 (FeeId=3)
-- Class 12 (ClassId=15), Sem-1 (SemesterId=1) Fee=10000 (FeeId=4)
INSERT INTO FeeDetail (FeeID, ClassID, FinancialYearID, SemesterID, IsActive, CreatedBy)
VALUES 
    (3, 13, 2, 1, 1, 1),
    (3, 13, 2, 2, 1, 1),
    (4, 15, 2, 1, 1, 1);
GO

-- 6. Seed Student Payments (Alice pays for Class 10 Sem-1)
INSERT INTO PaymentDetail (StudentID, FinancialYearID, FeeID, SemesterID, PaymentMode, TransactionRef, IsFullyPaid, FeePaid, TotalInstallment, CreatedBy)
VALUES 
    (1, 2, 3, 1, 'Cash', 'CASH-0001', 1, 7000.00, 1, 1);
GO
