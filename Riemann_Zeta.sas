/* Simplified Program to Chart the Riemann Zeta Function in SAS */
%macro RiemannZetaSimple(sigma_min=0, sigma_max=2, sigma_step=0.1, 
                       t_min=0, t_max=30, t_step=0.5,
                       terms=100);  /* Reduced default terms */

/* Create reduced grid with larger step sizes */
data grid;
    do sigma = &sigma_min to &sigma_max by &sigma_step;
        do t = &t_min to &t_max by &t_step;
            output;
        end;
    end;
run;

/* Calculate Riemann Zeta function with fewer terms */
data zeta;
    set grid;
    z_real = sigma;
    z_imag = t;
    
    /* Initialize zeta function components */
    zeta_real = 0;
    zeta_imag = 0;
    
    /* Use fewer terms in approximation */
    do n = 1 to &terms;
        /* For large values of t and small sigma, many terms are negligible
           Skip calculation when term is likely to be very small */
        if n > 20 and t > 10 and n**(-sigma) < 0.01 then continue;
        
        n_pow_minus_sigma = n**(-sigma);
        arg = -t * log(n);
        
        term_real = n_pow_minus_sigma * cos(arg);
        term_imag = n_pow_minus_sigma * sin(arg);
        
        zeta_real + term_real;
        zeta_imag + term_imag;
    end;
    
    /* Calculate absolute value of zeta(z) */
    zeta_abs = sqrt(zeta_real**2 + zeta_imag**2);
run;

/* Create simple heatmap visualization - fastest option */
title "Riemann Zeta Function |ζ(σ + it)| - Simplified";
title2 "σ range: &sigma_min to &sigma_max, t range: &t_min to &t_max";

proc sgplot data=zeta;
    heatmapparm x=z_real y=z_imag colorresponse=zeta_abs / 
                colormodel=threecolor name="heat";
    gradlegend "heat" / title="|ζ(σ + it)|";
    xaxis label="Real part (σ)";
    yaxis label="Imaginary part (t)";
run;

%mend RiemannZetaSimple;

/* For quick visualization along a specific line */
%macro RiemannZetaLineSimple(sigma_fixed=0.5, 
                           t_min=0, t_max=50, t_step=0.5,
                           terms=100);

data zeta_line;
    sigma = &sigma_fixed;
    
    /* Use larger step size for faster computation */
    do t = &t_min to &t_max by &t_step;
        /* Initialize zeta function components */
        zeta_real = 0;
        zeta_imag = 0;
        
        /* For sigma > 1, we can use a faster approximation */
        if sigma > 1 then do;
            /* Simplified calculation for sigma > 1 */
            sum_terms = 0;
            do n = 1 to &terms;
                sum_terms = sum_terms + 1/(n**sigma);
            end;
            zeta_real = sum_terms;
            zeta_imag = 0;
        end;
        else do;
            /* For sigma <= 1, we need to calculate term by term */
            do n = 1 to &terms;
                /* Skip calculation when term is likely to be very small */
                if n > 20 and n**(-sigma) < 0.01 then continue;
                
                n_pow_minus_sigma = n**(-sigma);
                arg = -t * log(n);
                
                term_real = n_pow_minus_sigma * cos(arg);
                term_imag = n_pow_minus_sigma * sin(arg);
                
                zeta_real + term_real;
                zeta_imag + term_imag;
            end;
        end;
        
        zeta_abs = sqrt(zeta_real**2 + zeta_imag**2);
        output;
    end;
run;

title "Riemann Zeta Function |ζ(&sigma_fixed + it)| - Simplified";
title2 "Fixed σ = &sigma_fixed, t range: &t_min to &t_max";

proc sgplot data=zeta_line;
    series x=t y=zeta_abs / lineattrs=(thickness=2 color=blue);
    xaxis label="Imaginary part (t)";
    yaxis label="|ζ(&sigma_fixed + it)|";
run;

%mend RiemannZetaLineSimple;

/* Example usage with parameters optimized for speed */
%RiemannZetaSimple(sigma_min=0, sigma_max=2, sigma_step=0.1,
                  t_min=0, t_max=30, t_step=1,
                  terms=50);

/* Example for critical line - faster version */
%RiemannZetaLineSimple(sigma_fixed=0.5, 
                      t_min=0, t_max=30, t_step=0.2,
                      terms=50);