{{#DCF}}---
title: "{{ExamResults}}: {{exam}}"
header-includes:{{#Babel}}
  - \usepackage[{{Babel}}]{babel}{{/Babel}}{{#Header}}
  - {{Header}}{{/Header}}
---

## {{PersonalData}}

| {{Name}} | {{RegistrationNumber}} |{{#has_mark}}{{Mark}}|{{/has_mark}} {{Points}} |
|:---------|:----------------------:|{{#has_mark}}:------:|{{/has_mark}}-----------:|
| {{name}} | {{registration}}       |{{#has_mark}}{{mark}}|{{/has_mark}} {{points}} |


## {{Evaluation}}

| {{Question}} | {{Point}} | {{GivenAnswer}} | {{CorrectAnswer}} |
|:------------:|:---------:|:---------------:|:-----------------:|{{#results}}
| {{question}} | {{points}} | `{{answer}}`    |  `{{solution}}`   |{{/results}}

{{/DCF}}


![]({{scan1}})

{{#scan2}}![]({{.}}){{/scan2}}
