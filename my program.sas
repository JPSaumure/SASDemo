/* this is a test*/

cas mysession ;

caslib _all_ assign;

data environment_info;
    length info_type $50 info_value $500;
    
    /* SAS Version Information */
    info_type = 'SAS Version';
    info_value = "&sysvlong";
    output;
    
    info_type = 'SAS Site Number';
    info_value = "&syssite";
    output;
    
    /* Operating System Information */
    info_type = 'Operating System';
    info_value = "&sysscp";
    output;
    
    info_type = 'OS Version';
    info_value = "&sysscpl";
    output;
    
    /* User and Session Information */
    info_type = 'User ID';
    info_value = "&sysuserid";
    output;
    
    info_type = 'Job ID';
    info_value = "&sysjobid";
    output;
    
    info_type = 'Process ID';
    info_value = "&syspid";
    output;
    
    /* Date and Time Information */
    info_type = 'Current Date';
    info_value = put(today(), date9.);
    output;
    
    info_type = 'Current Time';
    info_value = put(time(), time8.);
    output;
    
    info_type = 'Current DateTime';
    info_value = put(datetime(), datetime20.);
    output;
    
    /* System Configuration */
    info_type = 'SAS Installation Path';
    info_value = "&sysroot";
    output;
    
    info_type = 'Working Directory';
    info_value = "&sysprocessname";
    output;
    
    info_type = 'Encoding';
    info_value = "&sysencoding";
    output;
    
    info_type = 'Character Set';
    info_value = "&syscharwidth";
    output;
    
    /* Engine Information */
    info_type = 'Default Engine';
    info_value = getoption('engine');
    output;
run;

/* Display the environment information */
proc print data=environment_info noobs;
    title 'SAS Environment Information';
    var info_type info_value;
run;