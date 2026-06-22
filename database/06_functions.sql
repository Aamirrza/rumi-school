-- Step 7: Functions Script
USE SMS;
GO

CREATE FUNCTION fn_GenerateGrNo (
    @AdmissionFinancialYearId INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @FinancialYear VARCHAR(20);
    DECLARE @Prefix VARCHAR(10);
    DECLARE @NextSequence INT = 1;
    DECLARE @NextGrNo VARCHAR(20);

    -- 1. Fetch the Financial Year Name (using the new column and table name)
    SELECT @FinancialYear = FinancialYear 
    FROM FinancialYear 
    WHERE FinancialYearId = @AdmissionFinancialYearId;

    -- If the financial year is not found, return NULL
    IF @FinancialYear IS NULL
        RETURN NULL;

    -- 2. Extract prefix: GR-{StartYearLastTwoDigits}{EndYearLastTwoDigits}-
    -- Example: '2026-2027' -> 'GR-2627-'
    -- Format: 'yyyy-yyyy' -> Length = 9. StartYear starts at index 1, EndYear starts at index 6.
    SET @Prefix = 'GR-' 
                  + SUBSTRING(@FinancialYear, 3, 2) 
                  + SUBSTRING(@FinancialYear, 8, 2) 
                  + '-';

    -- 3. Determine the next sequence number by searching the StudentInfo table
    SELECT @NextSequence = ISNULL(MAX(CAST(SUBSTRING(GrNo, 9, 4) AS INT)), 0) + 1
    FROM StudentInfo
    WHERE GrNo LIKE @Prefix + '%';

    -- 4. Format: Prefix + 4-digit zero-padded sequence (e.g., GR-2627-0001)
    SET @NextGrNo = @Prefix + RIGHT('0000' + CAST(@NextSequence AS VARCHAR), 4);

    RETURN @NextGrNo;
END;
GO

