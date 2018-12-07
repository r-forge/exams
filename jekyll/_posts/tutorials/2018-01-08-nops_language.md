---
layout: page
#
# Content
#
title: "Written R/exams around the World"
teaser: "How to internationalize exams2nops() by adding support for new natural languages in written R/exams (that can be automatically scanned and evaluated)."
categories:
  - tutorials
tags:
  - internationalization
  - exams2nops
  - written
  - PDF
  - scan
  - evaluation
  - R
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: nops.title.jpg
  # preview in list of posts
  thumb: nops.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC-BY)."
---

## Idea

In addition to completely customizable PDF output, R/exams provides a standardized format called
"NOPS" for [written exams]({{ site.url }}/intro/written/) with multiple-choice
(and/or single-choice) exercises that can be
[automatically generated, scanned, and evaluated]({{ site.url }}/tutorials/exams2nops/).
In order to assure that the automatic scanning works the title page has a fixed layout
that cannot be modified by R/exams users. However, to internationalize the format there
is a possibility for customizing the natural language support. A number of languages
is already available but it is not difficult to add further languages or to tweak
existing languages if desired.

## Example

To illustrate how the language support works, once it has been fully incorporated into the
`exams` package, we set up a short exam with three exercises:
[deriv2]({{ site.url }}/templates/deriv2/), [tstat2]({{ site.url }}/templates/tstat2/),
[swisscapital]({{ site.url }}/templates/swisscapital/). All of these are readily available
in the package (and are actually in English).


<pre><code class="prettyprint ">library(&quot;exams&quot;)
myexam &lt;- c(&quot;deriv2.Rnw&quot;, &quot;tstat2.Rnw&quot;, &quot;swisscapital.Rnw&quot;)</code></pre>

Then we set up PDF output in English (en), German (de), and Spanish (es).
By setting `language` most text on the title page is modified, only the name of the
`institution` and the `title` of the exam have to be set separately. For the English
example we produce `n = 1` PDF output file in the output directory `nops_pdf` (created
automatically).


<pre><code class="prettyprint ">set.seed(403)
exams2nops(myexam, n = 1, language = &quot;en&quot;,
  institution = &quot;R University&quot;, title = &quot;Exam&quot;,
  dir = &quot;nops_pdf&quot;, name = &quot;en&quot;, date = &quot;2018-01-08&quot;)</code></pre>

Then we do the same for the other two languages.


<pre><code class="prettyprint ">set.seed(403)
exams2nops(myexam, n = 1, language = &quot;de&quot;,
  institution = &quot;R Universit\\\&quot;at&quot;, title = &quot;Klausur&quot;,
  dir = &quot;nops_pdf&quot;, name = &quot;de&quot;, date = &quot;2018-01-08&quot;)
set.seed(403)
exams2nops(myexam, n = 1, language = &quot;es&quot;,
  institution = &quot;R Universidad&quot;, title = &quot;Examen&quot;,
  dir = &quot;nops_pdf&quot;, name = &quot;es&quot;, date = &quot;2018-01-08&quot;)</code></pre>

The title pages of the resulting PDF files then have the desired languages.

[![en1.pdf]({{ site.url }}/assets/posts/2018-01-08-nops_language/en1.png)]({{ site.url }}/assets/posts/2018-01-08-nops_language//en1.pdf)
[![de1.pdf]({{ site.url }}/assets/posts/2018-01-08-nops_language/de1.png)]({{ site.url }}/assets/posts/2018-01-08-nops_language//de1.pdf)
[![es1.pdf]({{ site.url }}/assets/posts/2018-01-08-nops_language/es1.png)]({{ site.url }}/assets/posts/2018-01-08-nops_language//es1.pdf)


## Language specification

To add a new language, essentially just a single text file (say `lang.dcf`) is needed containing
suitable translations of all the phrases on the title page as well as a few additional phrases,
e.g., occuring in the HTML evaluation reports etc.
As an example, the first few phrases in English (`en.dcf`) are:

<pre>
PersonalData: Personal Data
Name: Name
FamilyName: Family Name
GivenName: Given Name
Signature: Signature
RegistrationNumber: Registration Number
Checked: checked
NoChanges: In this section \textbf{no} changes or modifications must be made!
...
</pre>

And the corresponding translations to German (`de.dcf`) are:

<pre>
PersonalData: Pers{\"o}nliche Daten
Name: Name
FamilyName: Nachname
GivenName: Vorname
Signature: Unterschrift
RegistrationNumber: Matrikelnummer
Checked: gepr{\"u}ft
NoChanges: In diesem Feld d{\"u}rfen \textbf{keine} Ver{\"a}nderungen der Daten vorgenommen werden!
...
</pre>

Note that here LaTeX markup is used for the German umlaute and for bold highlighting. Alternatively,
special characters can be added in a suitable encoding (typically UTF-8) but then the encoding has
to be declared when calling `exams2nops()` (e.g., `encoding = "UTF-8"`).

Most of the phrases required in the `.dcf` are very straightforward and only some are a bit technical.
There are also a couple of coordinates (`MarkExample*`) necessary for aligning some text lines.
If you have set up your own `lang.dcf` you can easily pass it to `exams2nops()` by setting
`language = "/path/to/lang.dcf"`. The same has to be done for `nops_eval()` when evaluating the exam.


## Currently available languages

Due to the kind support from friends and various dedicated R/exams users, there is already support
for many important Western languages as well as a few other languages/countries. All of these
are directly available in the R package (note that `"tr"` requires the current
[development version from R-Forge](http://R-Forge.R-project.org/R/?group_id=1337), though). But for convenience
and manual inspection the `.dcf` files are also linked here.

File                                                                    | Language     | Contributor                                                                                                        |
:-----------------------------------------------------------------------|:-------------|:-------------------------------------------------------------------------------------------------------------------|
[da.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/da.dcf)   | Danish       | [Tue Vissing Jensen](http://orcid.org/0000-0002-6594-5094) & [Jakob Messner](http://orcid.org/0000-0002-1027-3673) |
[de.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/de.dcf)   | German       | [Achim Zeileis](https://eeecon.uibk.ac.at/~zeileis/)                                                               |
[en.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/en.dcf)   | English      | [Achim Zeileis](https://eeecon.uibk.ac.at/~zeileis/)                                                               |
[es.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/es.dcf)   | Spanish      | [Maria Kogelnik](http://www.broomcenter.ucsb.edu/people/maria-kogelnik)                                            |
[fi.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/fi.dcf)   | Finnish      | [Klaus Nordhausen](http://klausnordhausen.com/)                                                                    |
[fr.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/fr.dcf)   | French       | [Arthur Allignol](https://github.com/aallignol)                                                                    |
[gsw.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/gsw.dcf) | Swiss German | [Reto Stauffer](http://retostauffer.org)                                                                           |
[hr.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/hr.dcf)   | Croatian     | [Krunoslav Juraić](http://www.irb.hr/eng/People/Krunoslav-Juraic) & [Tatjana Kecojevic](https://tanjakec.github.io/) |
[hu.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/hu.dcf)   | Hungarian    | [Gergely Daróczi](https://twitter.com/daroczig) & Dénes Tóth                                                    |
[it.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/it.dcf)   | Italian      | [Domenico Zambella](https://domenicozambella.altervista.org/)                                                      |
[nl.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/nl.dcf)   | Dutch        | [Niels Smits](https://www.uva.nl/en/profile/s/m/n.smits/n.smits.html)                                              |
[pt.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/pt.dcf) <br/> ([pt-BR.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/pt-BR.dcf), [pt-PT.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/pt-PT.dcf)) | Portugese | [Mauricio Calvão](http://www.if.ufrj.br/~orca/) & Fabian Petutschnig & <br/> [Thomas Dellinger](http://www3.uma.pt/thd/) |
[ro.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/ro.dcf)   | Romanian     | [Cristian Gatu](https://profs.info.uaic.ro/~cgatu/)                                                                |
[sr.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/sr.dcf)   | Serbian      | [Tatjana Kecojevic](https://tanjakec.github.io/)                                                                   |
[sk.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/sk.dcf)   | Slovak       | Peter Fabsic                                                                                                       |
[tr.dcf]({{ site.url }}/assets/posts/2018-01-08-nops_language/tr.dcf)   | Turkish      | [Emrah Er](http://eremrah.com/)                                                                                    |


## Contributing new languages

If you want to contribute a new language, simply set up a `.dcf` file starting out from one of the examples
above and send the file or a link to
_<&#x69;&#x6e;&#x66;&#x6f;&#x20;&#x61;&#x74;&#x20;&#x52;&#x2d;&#x65;&#x78;&#x61;&#x6d;&#x73;&#x2e;&#x6f;&#x72;&#x67;>_.
Do not worry if not everything is 100% perfect, yet, we can still sort this out together!
For Western languages (e.g., `sv`, `no` are still missing) it is probably the most robust solution to
code special characters in LaTeX. For languages requiring other alphabets (e.g., `ru` would be nice or Asian languages...)
it is probably easiest to use UTF-8 encoding. Get in touch through e-mail, the 
[support forum](http://R-Forge.R-project.org/forum/?group_id=1337)
or on Twitter ([@AchimZeileis](https://twitter.com/AchimZeileis)) if you want to know more or need further details.
