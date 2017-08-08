# Generate randomized exam in Portugese for Photos
library('exams')
exams2nops(sample(c("tstat2","deriv2","dist3","hessian","Rlogo","swisscapital",
                    "ttest","switzerland","scatterplot","relfreq","gaussmarkov",
                    "cholesky","boxplots","anova"),
                  37,
                  replace=TRUE),
           language="pt",
           dir='nops-pt-demo',
           blank=0)
