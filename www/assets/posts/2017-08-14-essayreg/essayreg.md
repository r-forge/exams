

Question
========
Consider the following regression results:


<pre><code>
Call:
lm(formula = log(y) ~ log(x), data = d)

Residuals:
    Min      1Q  Median      3Q     Max 
-6.6119 -1.4477  0.1735  1.5365  4.8160 

Coefficients:
            Estimate Std. Error t value Pr(&gt;|t|)
(Intercept)   0.1264     0.2520   0.501    0.618
log(x)        0.2870     0.2279   1.259    0.212

Residual standard error: 2.251 on 79 degrees of freedom
Multiple R-squared:  0.01967,	Adjusted R-squared:  0.007263 
F-statistic: 1.585 on 1 and 79 DF,  p-value: 0.2117
</code></pre>

Describe how the response `y` depends on the regressor `x`.


Solution
========
The presented results describe a log-log regression.

The mean of the response `y` increases with increasing `x`.

If `x` increases by 1 percent then a change of `y` by about 0.29 percent can be expected.

However, the effect of `x` is _not_ significant at the 5 percent level.


Meta-information
================
extype: string
exsolution: nil
exname: regression essay
exextra[essay,logical]: TRUE
exextra[essay_format,character]: editor
exextra[essay_required,logical]: FALSE
exextra[essay_fieldlines,numeric]: 5
exextra[essay_attachments,numeric]: 1
exextra[essay_attachmentsrequired,logical]: FALSE
