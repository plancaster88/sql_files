Select respondentid, PSR_PT, CI_PT, PSR_PS, CI_PS, PSR_0_5, CI_0_5
from LA_Temp.dbo.BH_Provider_SurveyResponse 
where respondentid = '10380308136' 


Select 
	r.RespondentID
	, r.Respond_Num
	, PT
	, PS
	, Age_0_5 
	, Cat --Category
from LA_Temp.dbo.BH_Provider_SurveyResponse r
cross apply
(
  values
    (PSR_PT, PSR_PS, PSR_0_5, 'PSR'),
    (CI_PT, CI_PS, CI_0_5, 'CI')
) c (PT, PS, Age_0_5, Cat)
where r.respondentid = '10380308136' 

