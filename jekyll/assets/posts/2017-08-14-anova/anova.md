

Question
========
A survey with 51 persons was conducted to analyze the
design of an advertising campaign. Each respondent was asked to
evaluate the overall impression of the advertisement on an
eleven-point scale from 0 (bad) to 10 (good). The evaluations are
summarized separately with respect to type of occupation of the
respondents in the following figure.

![](boxplots-1.svg)

To analyze the influence of occupation on the evaluation of the
advertisement an analysis of variance was performed:


```
  Res.Df    RSS Df Sum of Sq     F     Pr(>F)
1     50 53.549                              
2     47 34.018  3    19.531 8.995 8.1265e-05
```

Which of the following statements are correct?

Answerlist
----------
* It can be shown that the evaluation of the respondents depends on their occupation. (Significance level $5$%)
* The fraction of explained variance is larger than $60$%.
* A one-sided alternative was tested for the mean values.
* The fraction of explained variance is smaller than $45$%.
* The test statistic is larger than $7.5$.

Solution
========
In order to be able to answer the questions the fraction of
explained variance has to be determined. The residual sum of squares
when using only a single overall mean value ($\mathit{RSS}_0$) as
well as the residual sum of squares when allowing different mean
values given occupation ($\mathit{RSS}_1$) are required. Both are
given in the RSS column of the ANOVA table.  The
fraction of explained variance is given by
$1 - \mathit{RSS}_1/\mathit{RSS}_0 = 1 - 34.018/53.549 =
0.365$.
  
The statements above can now be evaluated as right or wrong.

Answerlist
----------
* True. The $p$ value is $8.13e-05$ and hence significant. It can  be shown that the evaluations differ with respect to the occupation of the respondents.
* False. The fraction of explained variance is $0.365$ and hence _not_ larger than 0.6.
* False. An ANOVA always tests the null hypothesis, that all mean values are equal against the alternative hypothesis that they are different.
* True. The fraction of explained variance is $0.365$ and hence  smaller than 0.45.
* True. The test statistic is $F = 8.995$ and hence  larger than $7.5$.

Meta-information
================
extype: mchoice
exsolution: 10011
exname: Analysis of variance
