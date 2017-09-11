

Question
========

The waiting time (in minutes) at the cashier of two supermarket
chains with different cashier systems is compared. The following
statistical test was performed:


<pre><code>
	Two Sample t-test

data:  Waiting by Supermarket
t = 3.8575, df = 132, p-value = 0.9999
alternative hypothesis: true difference in means is less than 0
95 percent confidence interval:
     -Inf 3.552905
sample estimates:
 mean in group Sparag mean in group Consumo 
             5.859404              3.373846 
</code></pre>

Which of the following statements are correct? (Significance level 5%)

Answerlist
----------
* The absolute value of the test statistic is larger than 1.96.
* A one-sided alternative was tested.
* The p-value is larger than 0.05.
* The test shows that the waiting time is longer at Sparag  than at Consumo.
* The test shows that the waiting time is shorter at Sparag than at Consumo.

Solution
========

Answerlist
----------
* True. The absolute value of the test statistic is equal to 3.857.
* True. The test aims at showing that the difference of means is  smaller than 0.
* True. The p-value is equal to 1.
* False. The test aims at showing that the alternative that the waiting time is shorter at Sparag than at Consumo. The test result is not significant ($p \ge 0.05$).
* False.  The test result ist not significant ($p \ge 0.05$).

Meta-information
================
extype: mchoice
exsolution: 11100
exname: 2-sample t-test
