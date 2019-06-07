CREATE FUNCTION dbo.fnAgeYears (@dob datetime, @enddate datetime)
RETURNS int
AS BEGIN
	declare @Age int;
	select @age = 
		case	
			when	@dob > @enddate then 0  --sometimes an input date falls before a dob
			else	DATEDIFF(YY, @dob, @enddate) 
					-	
					CASE --This sub case statement enforces proper rounding
						WHEN RIGHT(CONVERT(VARCHAR(6), @enddate , 12), 4) 
							>= RIGHT(CONVERT(VARCHAR(6), @dob, 12), 4) 
						THEN 0 ELSE 1 
					END 
		end 
	return @age

end 
