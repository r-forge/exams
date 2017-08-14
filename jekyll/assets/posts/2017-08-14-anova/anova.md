

Question
========
A survey with 49 persons was conducted to analyze the
design of an advertising campaign. Each respondent was asked to
evaluate the overall impression of the advertisement on an
eleven-point scale from 0 (bad) to 10 (good). The evaluations are
summarized separately with respect to type of occupation of the
respondents in the following figure.
\
![](boxplots-1.svg)

To analyze the influence of occupation on the evaluation of the
advertisement an analysis of variance was performed:


<pre><code>  Res.Df    RSS Df Sum of Sq     F  Pr(&gt;F)
1     48 24.789                           
2     45 24.642  3     0.147 0.089 0.96565
</code></pre>

Which of the following statements are correct?

Answerlist
----------
* A one-sided alternative was tested for the mean values.
* It can be shown that the evaluation of the respondents depends on their occupation. (Significance level $5$%)
* The fraction of explained variance is larger than $59$%.
* The fraction of explained variance is smaller than $56$%.
* The test statistic is smaller than $1.2$.

Solution
========
In order to be able to answer the questions the fraction of
explained variance has to be determined. The residual sum of squares
when using only a single overall mean value ($\mathit{RSS}_0$) as
well as the residual sum of squares when allowing different mean
values given occupation ($\mathit{RSS}_1$) are required. Both are
given in the RSS column of the ANOVA table.  The
fraction of explained variance is given by
$1 - \mathit{RSS}_1/\mathit{RSS}_0 = 1 - 24.642/24.789 =
0.006$.
  
The statements above can now be evaluated as right or wrong.

Answerlist
----------
* False. An ANOVA always tests the null hypothesis, that all mean values are equal against the alternative hypothesis that they are different.
* False. The $p$ value is $0.966$ and hence_not_ significant. It can _not_ be shown that the evaluations differ with respect to the occupation of the respondents.
* False. The fraction of explained variance is $0.006$ and hence _not_ larger than 0.59.
* True. The fraction of explained variance is $0.006$ and hence  smaller than 0.56.
* True. The test statistic is $F = 0.089$ and hence  smaller than $1.2$.

Meta-information
================
extype: mchoice
exsolution: 00011
exname: Analysis of variance
