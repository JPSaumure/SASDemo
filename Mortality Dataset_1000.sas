/* Generate expanded policy dataset with 1000 records */
data policy_data;
    /* Set variable lengths to prevent truncation */
    length PolicyID $7 Gender $1 SmokingStatus $10 MedicalRisk $6 Status $6;
    
    /* Set random seed for reproducibility */
    call streaminit(12345);
    
    /* Generate 1000 policies */
    do i = 1 to 1000;
        /* Create policy ID */
        PolicyID = 'P' || put(100000 + i, z6.);
        
        /* Assign gender (slightly more males than females in typical portfolio) */
        if rand('uniform') < 0.55 then Gender = 'M';
        else Gender = 'F';
        
        /* Age distribution centered around 45 with standard deviation 15 */
        Age = round(rand('normal', 45, 15));
        /* Constrain ages to reasonable range */
        Age = max(20, min(80, Age));
        
        /* Issue year between 2010 and 2022 */
        IssueYear = 2010 + round(rand('uniform') * 12);
        
        /* Policy amount - correlated with age (younger = higher coverage typically) */
        base_amount = 200000 - (Age - 45) * 2000;
        random_factor = rand('uniform') * 0.5 + 0.75; /* 0.75 to 1.25 multiplier */
        PolicyAmount = round(base_amount * random_factor, 10000);
        /* Ensure reasonable bounds */
        PolicyAmount = max(50000, min(500000, PolicyAmount));
        
        /* Smoking status - probability decreases with age (survivor effect) */
        smoking_prob = max(0.05, min(0.3, 0.25 - (Age - 45)*0.005));
        if rand('uniform') < smoking_prob then SmokingStatus = 'Smoker';
        else SmokingStatus = 'Non-Smoker';
        
        /* Medical risk - increases with age */
        risk_rand = rand('uniform');
        if Age < 40 then do;
            if risk_rand < 0.8 then MedicalRisk = 'Low';
            else if risk_rand < 0.95 then MedicalRisk = 'Medium';
            else MedicalRisk = 'High';
        end;
        else if Age < 60 then do;
            if risk_rand < 0.6 then MedicalRisk = 'Low';
            else if risk_rand < 0.85 then MedicalRisk = 'Medium';
            else MedicalRisk = 'High';
        end;
        else do;
            if risk_rand < 0.3 then MedicalRisk = 'Low';
            else if risk_rand < 0.7 then MedicalRisk = 'Medium';
            else MedicalRisk = 'High';
        end;
        
        /* Determine mortality based on risk factors */
        base_mortality = 0.005 * exp(0.06 * (Age - 45));  /* Gompertz-like baseline */
        
        /* Apply risk factor adjustments */
        if Gender = 'M' then base_mortality = base_mortality * 1.5;
        if SmokingStatus = 'Smoker' then base_mortality = base_mortality * 2.2;
        if MedicalRisk = 'Medium' then base_mortality = base_mortality * 1.3;
        if MedicalRisk = 'High' then base_mortality = base_mortality * 2.0;
        
        /* Apply duration effect (mortality higher in early policy years - selection wears off) */
        years_since_issue = 2023 - IssueYear;
        duration_factor = 1.0 - 0.3 * exp(-0.2 * years_since_issue);
        annual_mortality = base_mortality * duration_factor;
        
        /* Determine if death occurred within observation period */
        death_occurred = 0;
        death_year = .;
        
        /* Simulate mortality for each year from issue to 2023 */
        do year = IssueYear to 2022;
            current_age = Age + (year - IssueYear);
            
            /* Recalculate mortality probability for current age */
            current_mortality = 0.005 * exp(0.06 * (current_age - 45));
            if Gender = 'M' then current_mortality = current_mortality * 1.5;
            if SmokingStatus = 'Smoker' then current_mortality = current_mortality * 2.2;
            if MedicalRisk = 'Medium' then current_mortality = current_mortality * 1.3;
            if MedicalRisk = 'High' then current_mortality = current_mortality * 2.0;
            
            /* Apply duration effect */
            years_duration = year - IssueYear;
            dur_factor = 1.0 - 0.3 * exp(-0.2 * years_duration);
            year_mortality = current_mortality * dur_factor;
            
            /* Check if death occurs this year */
            if rand('uniform') < year_mortality then do;
                death_occurred = 1;
                death_year = year;
                leave; /* Exit the year loop once death occurs */
            end;
        end;
        
        /* Assign death year if death occurred */
        if death_occurred = 1 then DeathYear = death_year;
        else DeathYear = .;
        
        /* Calculate exposure and status */
        if DeathYear = . then do;
            Status = 'Active';
            ExposureYears = 2023 - IssueYear;
        end;
        else do;
            Status = 'Death';
            ExposureYears = DeathYear - IssueYear;
        end;
        
        /* Drop working variables */
        drop i base_amount random_factor smoking_prob risk_rand base_mortality
             years_since_issue duration_factor annual_mortality death_occurred
             death_year year current_age current_mortality years_duration
             dur_factor year_mortality;
             
        output;
    end;
run;

/* View summary statistics for verification */
proc freq data=policy_data;
    tables Gender SmokingStatus MedicalRisk Status;
    title 'Summary of Categorical Variables in 1000-Record Dataset';
run;

proc means data=policy_data n mean std min max;
    var Age PolicyAmount ExposureYears;
    class Status;
    title 'Summary Statistics by Policy Status';
run;

/* Create crosstabs to examine risk profiles */
proc freq data=policy_data;
    tables Gender*Status SmokingStatus*Status MedicalRisk*Status / chisq;
    title 'Mortality Rates by Risk Factors';
run;