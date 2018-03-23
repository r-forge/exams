

Question
========
Using the data provided in [regression.csv](regression.csv) estimate a linear regression of
`y` on `x` and answer the following questions.

Answerlist
----------
* `x` and `y` are not significantly correlated
* `y` increases significantly with `x`
* `y` decreases significantly with `x`
* Estimated slope with respect to `x`:

Solution
========
\
![](scatterplot-1.svg)

To replicate the analysis in R:
```
## data
d <- read.csv("regression.csv")
## regression
m <- lm(y ~ x, data = d)
summary(m)
## visualization
plot(y ~ x, data = d)
abline(m)
```

Meta-information
================
exname: Linear regression
extype: cloze
exsolution: 001|-0.674
exclozetype: schoice|num
extol: 0.01
