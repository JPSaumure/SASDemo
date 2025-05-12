/* Program to Chart the Riemann Zeta Function in SAS */
%macro RiemannZeta(sigma_min=0, sigma_max=2, sigma_step=0.05, 
                  t_min=0, t_max=30, t_step=0.5,
                  terms=1000);

/* Create dataset with grid points for sigma and t */
data grid;
    do sigma = &sigma_min to &sigma_max by &sigma_step;
        do t = &t_min to &t_max by &t_step;
            output;
        end;
    end;
run;

/* Calculate Riemann Zeta function */
data zeta;
    set grid;
    z_real = sigma;
    z_imag = t;
    
    /* Initialize zeta function components */
    zeta_real = 0;
    zeta_imag = 0;
    
    /* Sum the first n terms of the series */
    do n = 1 to &terms;
        /* Calculate n^(-z) = n^(-sigma) * e^(-it*ln(n)) */
        /* n^(-z) = n^(-sigma) * (cos(-t*ln(n)) + i*sin(-t*ln(n))) */
        
        n_pow_minus_sigma = n**(-sigma);
        arg = -t * log(n);
        
        term_real = n_pow_minus_sigma * cos(arg);
        term_imag = n_pow_minus_sigma * sin(arg);
        
        zeta_real + term_real;
        zeta_imag + term_imag;
    end;
    
    /* Calculate absolute value of zeta(z) */
    zeta_abs = sqrt(zeta_real**2 + zeta_imag**2);
    
    /* Calculate argument (phase) of zeta(z) in radians */
    zeta_arg = atan2(zeta_imag, zeta_real);
    
    /* Convert argument to degrees */
    zeta_arg_deg = zeta_arg * 180 / constant('pi');
run;

/* Create visualizations */
title "Riemann Zeta Function |ζ(σ + it)|";
title2 "σ range: &sigma_min to &sigma_max, t range: &t_min to &t_max";

/* Create a contour plot of |ζ(σ + it)| */
proc sgrender data=zeta template=ContourPlotParm;
    dynamic _title="Absolute Value of Riemann Zeta Function |ζ(σ + it)|"
            _x="z_real" _y="z_imag" _z="zeta_abs";
run;

/* Create a 3D surface plot of |ζ(σ + it)| */
proc g3d data=zeta;
    scatter z_real*z_imag=zeta_abs / rotate=20;
    label z_real = "Real part (σ)"
          z_imag = "Imaginary part (t)"
          zeta_abs = "|ζ(σ + it)|";
run;

/* Create a heatmap of |ζ(σ + it)| */
proc sgplot data=zeta;
    heatmap x=z_real y=z_imag / colorresponse=zeta_abs colormodel=threecolor
            name="heat";
    gradlegend "heat" / title="|ζ(σ + it)|";
    xaxis label="Real part (σ)";
    yaxis label="Imaginary part (t)";
run;

/* Create a contour plot of the argument of ζ(σ + it) */
proc sgplot data=zeta;
    contour x=z_real y=z_imag / response=zeta_arg_deg contourtype=fill
            name="contour";
    gradlegend "contour" / title="Arg(ζ(σ + it)) in degrees";
    xaxis label="Real part (σ)";
    yaxis label="Imaginary part (t)";
run;

%mend RiemannZeta;

/* Example usage - customize parameter values as needed */
%RiemannZeta(sigma_min=0.5, sigma_max=2, sigma_step=0.05,
             t_min=0, t_max=30, t_step=0.5,
             terms=1000);

/* For 3D visualization along a specific line */
%macro RiemannZetaLine(sigma_fixed=0.5, 
                      t_min=0, t_max=50, t_step=0.1,
                      terms=1000);

data zeta_line;
    sigma = &sigma_fixed;
    do t = &t_min to &t_max by &t_step;
        /* Initialize zeta function components */
        zeta_real = 0;
        zeta_imag = 0;
        
        /* Sum the first n terms of the series */
        do n = 1 to &terms;
            n_pow_minus_sigma = n**(-sigma);
            arg = -t * log(n);
            
            term_real = n_pow_minus_sigma * cos(arg);
            term_imag = n_pow_minus_sigma * sin(arg);
            
            zeta_real + term_real;
            zeta_imag + term_imag;
        end;
        
        zeta_abs = sqrt(zeta_real**2 + zeta_imag**2);
        output;
    end;
run;

title "Riemann Zeta Function |ζ(&sigma_fixed + it)|";
title2 "Fixed σ = &sigma_fixed, t range: &t_min to &t_max";

proc sgplot data=zeta_line;
    series x=t y=zeta_abs / lineattrs=(thickness=2 color=blue);
    xaxis label="Imaginary part (t)";
    yaxis label="|ζ(&sigma_fixed + it)|";
run;

proc sgplot data=zeta_line;
    series x=zeta_real y=zeta_imag / lineattrs=(thickness=2 color=red);
    xaxis label="Re(ζ(&sigma_fixed + it))";
    yaxis label="Im(ζ(&sigma_fixed + it))";
run;

%mend RiemannZetaLine;

/* Example usage for a line chart with fixed sigma */
%RiemannZetaLine(sigma_fixed=0.5, 
                t_min=0, t_max=50, t_step=0.1,
                terms=1000);