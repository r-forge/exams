---
layout: page
#
# Content
#
subheadline: "Installation"
title: "R/exams Installation Tutorial for Ubuntu users"
teaser: "Before you can start using our delightful software package, you
will need to install some other software. This tutorial will show step-by-step how to get started.
"
categories:
  - tutorials
tags:
  - first steps
  - installation
  - R
  - delete
  - dummy
author: keller, krimm

#
# Style
#
image:
  # shown on top of blog post
  title: unsplash_markus-spiske-109588.970.jpg
  # preview in list of posts
  thumb: unsplash_markus-spiske-109588.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "Photo from unsplash."
  caption_url: "https://unsplash.com/"
---

This is the first tutorial. It is part of the [first step][series]
series, which tries to make beginner's live easier.

[series]: /blog/by-tag/first-steps

To use R/exams you need to install:

- [LaTeX](https://wiki.ubuntuusers.de/LaTeX/#Installation)
- [R](https://cran.r-project.org)

Click on the upper links to gather information about the installation.

Afterwards you can download the whole package [exams_2.2-1.tar.gz](https://cran.r-project.org/src/contrib/exams_2.2-1.tar.gz) with the software and given templates.

After saving the folder you have to start R in your Terminal. Just write R and press Enter. Now type in the following code:

```
R> library("exams")
R> tstat_sol <- exams ("tstat.Rnw")
R> tstat_sol
```

If your installation was succesfull a PDF file will open.





Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas
venenatis feugiat nulla ac venenatis. Donec commodo lectus massa, et
cursus risus convallis posuere. Aliquam luctus massa ut volutpat rutrum.
Ut tincidunt fermentum dui. Nulla finibus, neque ac euismod cursus,
felis dolor maximus lectus, nec dignissim est ante vitae orci. Nulla
vulputate ipsum id consequat hendrerit. Maecenas felis erat, cursus
pretium sem pretium, consectetur aliquet turpis. Nulla tristique dictum
accumsan. Phasellus neque est, tristique sit amet mauris et, aliquet
bibendum lacus. Nulla eu aliquet tellus, in tincidunt mauris.
Pellentesque nec leo non enim suscipit ultrices at quis diam.

![People at work.](/images/unsplash_helloquence-61189.970.jpg)

Morbi in eleifend dui. Proin quis velit laoreet, congue dolor nec,
suscipit nibh. Donec accumsan egestas erat sit amet sagittis.
Pellentesque posuere mauris felis, eget posuere est bibendum a. Praesent
posuere malesuada sagittis. In gravida at massa eu tristique. Praesent
congue velit vitae diam gravida, id varius tortor semper.

Duis porta libero nec magna dictum euismod. In placerat egestas ipsum
sed tempus. Aenean sodales varius sodales. Vestibulum ante ipsum primis
in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus nisl
lorem, laoreet a pretium et, suscipit vitae sem. In auctor eros urna, in
pretium lectus varius eget. Ut sit amet tincidunt est. Integer commodo
lectus purus, lobortis euismod dui malesuada quis. Pellentesque vitae
risus non orci vestibulum efficitur. Aliquam ornare aliquet massa, eget
aliquet purus scelerisque a.

Pellentesque aliquet rhoncus nibh, in interdum dolor bibendum quis.
Vestibulum tempor condimentum libero, vel sodales enim egestas vel.
Suspendisse aliquam justo eget ante ornare, a molestie neque gravida.
Suspendisse ornare, dui non mollis semper, enim augue luctus felis, et
facilisis mauris massa et ligula. Aenean ullamcorper nunc ut ligula
molestie, id sagittis diam fermentum. Maecenas laoreet scelerisque eros
eu elementum. Phasellus ullamcorper, turpis vel maximus euismod, arcu
tortor aliquet elit, id dapibus dui massa nec magna. Ut eget volutpat
ligula, vel pharetra lorem. Ut ultricies dolor et justo porta
consectetur.

Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus
fermentum nisi quis risus pulvinar feugiat non at justo. Nam nec libero
libero. Quisque vel ornare ante. Vestibulum vehicula, dolor vel sagittis
tempus, risus diam accumsan urna, in fringilla risus nulla sit amet
turpis. Nunc dictum enim odio, non luctus ante commodo nec. Duis sit
amet sodales enim, non finibus leo. Maecenas vitae risus ut risus
ullamcorper finibus. Nulla a lectus eu lectus eleifend pulvinar ac
convallis sapien.
