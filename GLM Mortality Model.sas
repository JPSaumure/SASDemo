/* Approach 3: Poisson GLM for Mortality Rates (Corrected) */
/* Prepare data for Poisson modeling */
data policy_data_poisson;
    set policy_data;
    /* Create death indicator */
    Death_Count = (Status = 'Death');
    
    /* Create age bands for more flexible age effect */
    if Age < 30 then AgeBand = '20-29';
    else if Age < 40 then AgeBand = '30-39';
    else if Age < 50 then AgeBand = '40-49';
    else if Age < 60 then AgeBand = '50-59';
    else if Age < 70 then AgeBand = '60-69';
    else AgeBand = '70+';
    
    /* Create duration bands */
    Duration = 2023 - IssueYear;
    if Duration <= 2 then DurationBand = '0-2';
    else if Duration <= 5 then DurationBand = '3-5';
    else DurationBand = '6+';
    
    /* Log of exposure for offset - pre-calculated */
    Log_Exposure = log(ExposureYears);
run;

/* Fit Poisson GLM for mortality rates */
proc genmod data=policy_data_poisson plots=all;
    /* Define categorical variables */
    class Gender SmokingStatus MedicalRisk AgeBand DurationBand / param=glm;
    
    /* Model death count with log link and Poisson distribution */
    model Death_Count = Gender SmokingStatus MedicalRisk AgeBand DurationBand
                      / dist=poisson link=log offset=Log_Exposure
                        type3 scale=pearson;
    
    /* Remove the ESTIMATE statements that are causing errors */
    /* Instead we'll interpret the parameter estimates directly from the output */
    
    /* Output predictions */
    output out=poisson_pred pred=PredictedDeaths 
           stdreschi=StdResidual reschi=Residual;
    
    /* Add title */
    title 'Mortality Model: Poisson GLM Approach';
run;
title;

/* Calculate and display mortality rates */
data mortality_rates;
    set poisson_pred;
    /* Calculate actual mortality rate per 1000 person-years */
    Actual_Rate = (Death_Count / ExposureYears) * 1000;
    /* Calculate predicted mortality rate per 1000 person-years */
    Predicted_Rate = (PredictedDeaths / ExposureYears) * 1000;
    
    /* Keep only necessary variables */
    keep Gender SmokingStatus MedicalRisk AgeBand Death_Count 
         ExposureYears Actual_Rate Predicted_Rate;
run;

/* Display results by key segments */
proc tabulate data=mortality_rates format=8.2;
    class Gender SmokingStatus MedicalRisk AgeBand;
    var Actual_Rate Predicted_Rate ExposureYears;
    table (Gender SmokingStatus MedicalRisk AgeBand all),
          (ExposureYears*(sum) Actual_Rate*(mean) Predicted_Rate*(mean));
    title 'Mortality Rates per 1000 Person-Years';
run;
title;