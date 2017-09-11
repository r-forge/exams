

Question
========

Given two points $p = (3, 4)$ and
$q = (5, 2)$ in a Cartesian coordinate system:

Questionlist
------------
* What is the Manhattan distance $d_1(p, q)$?
* What is the Euclidean distance $d_2(p, q)$?
* What is the maximum distance $d_\infty(p, q)$?


Solution
========

The distances are visualized below in green ($d_1$), red ($d_2$),
and blue ($d_\infty$).

![](dist-1.svg)

Solutionlist
------------
* $d_1(p, q) = \sum_i |p_i - q_i| = |3 - 5| +
  |4 - 2| = 4$.
* $d_2(p, q) = \sqrt{\sum_i (p_i - q_i)^2} = \sqrt{(3 -
  5)^2 + (4 - 2)^2} = 2.828$.
* $d_\infty(p, q) = \max_i |p_i - q_i| = \max(|3 -
  5|, |4 - 2|) = 2$.


Meta-information
================
extype: cloze
exsolution: 4|2.828|2
exclozetype: num|num|num
exname: Distances
extol: 0.01
