
#source("C:/BA-Stat/R-Bsps/functions.R")
#source("~/BA-Stat/R-Bsps/functions.R")
# exams("ch11-1.Rnw")

##
## functions for chapter 11 and chapter 12
##

##  usage:
##  1/ start R interactively
##  2/ library(exams)
##  3/ rm(list=ls())
##  4/ source("functions.R")
##  5/ exams("bsp")

##  after final compilation of all exams/examples copy file 
##  functions.R between << ... >> and @ (R-part) 
##  into ALL exam files

############# H, LT, GT +/- Saison #######################
##
## f_lt0,  f_lt,  f_h,  f_gt0, f_gt, f_seas
##

f_lt0 <- function(nobs=100, a=1, b=1) {
## generates a linear trend given nobs:  lt = a + b*time + u
## 
##   plot-scaling delivers always graphs with same slope
  maxtrials <- 100;
  time      <- c(1:nobs);
  r2        <- c(0*1:maxtrials);
  r2h <- 0;
  for (i3 in 1:maxtrials) {
    sscale <- runif(1, min=2,max=10);
    su     <- nobs*b/sscale;
##    u      <- rnorm(nobs, mean=0, sd=1);
    u  <- f_rbeta_n(nobs,mean=0,sd=1);
    lt    <- a + b*time + su*u;
    modt <- lm(lt ~ time);
    r2h  <- summary(modt)$r.squared;
    r2[i3] <- r2h; 
    if (r2h > 0.3) break;
    }
  lt <- lt; 
  }

f_lt <- function(nobs=100, a=1, b=1, resid=resid) {
## generates a linear trend given nobs:  lt = a + b*time + u
##   plot-scaling delivers always graphs with same slope
##  u  wird zu (0,1) transformiert
  time   <- c(1:nobs);
  u      <- resid
  u      <- (u - mean(u))/sd(u)
  sscale <- runif(1, min=2,max=10);
  su     <- nobs*b/sscale;
  lt     <- a + b*time + su*u;
  lt
  }

f_h0 <- function(nobs=100,const=TRUE,sd=TRUE,ar=TRUE) {
## horizontales Muster, AR(1), WN given nobs
## std(h) = su*sqrt(1/(1-rho1^2))
  maxtrials <- 100;
  r2 <- c(0*1:maxtrials);
  maxrho1 = 0.6
  u <- c(0*1:nobs)
  if (const) { a <- runif(1, min=-.5, max=20) }
        else { a <- 0 };
  if (sd)    { su <- runif(1, min=0.2, max=5) }
        else { su <- 1 };
  if (ar)    {  
##  rho1 <- runif(1, min=-maxrho1, max=maxrho1)
               rho1 <- rbeta(1, 0.6, 0.5) - 0.5  
#               rho1 <- rho1*(maxrho1/0.5)
              }
        else { rho1 = 0 };
#
#  eps=0.001; if ( abs(rho1) < eps ) {rho1 = eps};       
# (1 - a1 L)yt=ut  (1,0,0)-arima.sim NICHT fuer WN !!  
for (i2 in 1:maxtrials) {
#  ts.u  <- arima.sim(list(order = c(1,0,0),ar=rho1),n=nobs)
#  u <- as.real(ts.u)
   ucv = 1/(1-rho1^2);  ucs <- sqrt(ucv);   
   u[1] <- f_rbeta_n(1,0,ucs)
   v    <- f_rbeta_n(nobs,0,1)
   for (j in 2:nobs) { u[j] = rho1*u[j-1] + v[j] }
   acf_u <- acf(u, plot=FALSE)
   rho1h = acf_u$acf[2,1,1]
   r2[i2] <- rho1h
   if ( abs(rho1h) < maxrho1 ) break
    }
   h <- su*u + a; h
  }


f_h <- function(nobs=100,const=TRUE,sd=TRUE,ar=TRUE,seas=seas) {
## horizontales Muster, AR(1), WN given nobs
  maxtrials <- 100;
  r2 <- c(0*1:maxtrials);
  maxrho1 = 0.6
  u <- c(0*1:nobs)
  if (const) { a <- runif(1, min=-.5, max=20) }
        else { a <- 0 };
  if (sd)    { su <- runif(1, min=0.2, max=5) }
        else { su <- 1 };
  if (ar)    {  
##  rho1 <- runif(1, min=-maxrho1, max=maxrho1)
               rho1 <- rbeta(1, 0.7, 0.5) - 0.5  
               rho1 <- rho1*(maxrho1/0.5) }
        else { rho1 = 0 };
#
#  eps=0.001; if ( abs(rho1) < eps ) {rho1 = eps};       
# (1 - a1 L)yt=ut  (1,0,0)-arima.sim NICHT fuer WN !!  
for (i2 in 1:maxtrials) {
#  ts.u  <- arima.sim(list(order = c(1,0,0),ar=rho1),n=nobs)
#  u <- as.real(ts.u)
   ucv = 1/(1-rho1^2);  ucs <- sqrt(ucv);   
   u[1] <- f_rbeta_n(1,0,ucs)
   v    <- f_rbeta_n(nobs,0,1)
   for (j in 2:nobs) { u[j] = rho1*u[j-1] + v[j] }
   acf_u <- acf(u, plot=FALSE)
   rho1h = acf_u$acf[2,1,1]
   r2[i2] <- rho1h
   if ( abs(rho1h) < maxrho1 ) break
    }
   u   <- su*(u -mean(u))
   sdu <- sd(u)
   sds <- sd(seas)
   hs  <- u + a + 2.75*sdu/sds*seas
  }

f_hg <- function(nobs=100,const=TRUE,sd=TRUE,ar=TRUE,seas=seas,scal=scal) {
## horizontales Muster, AR(1), WN given nobs
  maxtrials <- 100;
  r2 <- c(0*1:maxtrials);
  maxrho1 = 0.6
  u <- c(0*1:nobs)
  if (const) { a <- runif(1, min=-.5, max=20) }
        else { a <- 0 };
  if (sd)    { su <- runif(1, min=0.2, max=5) }
        else { su <- 1 };
  if (ar)    {  
##  rho1 <- runif(1, min=-maxrho1, max=maxrho1)
               rho1 <- rbeta(1, 0.7, 0.5) - 0.5  
               rho1 <- rho1*(maxrho1/0.5) }
        else { rho1 = 0 };
#
#  eps=0.001; if ( abs(rho1) < eps ) {rho1 = eps};       
# (1 - a1 L)yt=ut  (1,0,0)-arima.sim NICHT fuer WN !!  
for (i2 in 1:maxtrials) {
#  ts.u  <- arima.sim(list(order = c(1,0,0),ar=rho1),n=nobs)
#  u <- as.real(ts.u)
   ucv = 1/(1-rho1^2);  ucs <- sqrt(ucv);   
   u[1] <- f_rbeta_n(1,0,ucs)
   v    <- f_rbeta_n(nobs,0,1)
   for (j in 2:nobs) { u[j] = rho1*u[j-1] + v[j] }
   acf_u <- acf(u, plot=FALSE)
   rho1h = acf_u$acf[2,1,1]
   r2[i2] <- rho1h
   if ( abs(rho1h) < maxrho1 ) break
    }
   u   <- su*(u -mean(u))
   sdu <- sd(u)
   sds <- sd(seas)
   hs  <- u + a + scal*sdu/sds*seas
  }


f_gt0 <- function(nobs=100) {
## generate geometric trend given nobs, b > 0 (!!)
# gtslope... bestimmt die Kruemmung (beta) im Graphen zB in (1, 2) 
#   gt_slope = 1/(nobs/2) * gtslope
# gtmax  ... bestimmt die Skala der y-Achse (Kosmetik)
maxtrials <- 100
r2  <- c(0*1:maxtrials)
r2h <- 0
gtslope <- runif(1,min=1,max=2)
gtmax   <- runif(1,min=5,max=1000)
  a <- 1   # no flat/steep linear trends visible in plots
  b <- 1
time  <- c(1:nobs)
time2 <- time - nobs/2
sscale = runif(1, min=30,max=40)
su  <- nobs*b/sscale

for (i1 in 1:maxtrials) {
##  u <- rnorm(nobs, mean=0, sd=1)
  u  <- f_rbeta_n(nobs, mean=0, sd=1)
  t <- a + b*time2 + su*u

# dmt in (-1,+1), slope = (1-0)/(nobs/2)
  dmt <- 2*t /( max(t) - min(t) ) 
  dmt <- dmt*gtslope      # gt-slope = slope*gtslope
  gt  <- exp( dmt )
  gt  <- gtmax*gt / max(abs(gt))

  modgt   <- lm(gt ~ time2)
  gt_res  <- modgt$residuals
  gt_res_acf  <-  acf(gt_res, plot = FALSE)
  r2h1    <- gt_res_acf$acf[2,1,1]
  r2[i1]  <- r2h1 
  if (r2h1 > 0.8) break
  }
  gt
  }


f_gt <- function(nobs=100, resid=resid) {
## generate geometric trend given nobs, b > 0 (!!)
# gtslope... bestimmt die Kruemmung (beta) im Graphen zB in (1, 2) 
#   gt_slope = 1/(nobs/2) * gtslope
# gtmax  ... bestimmt die Skala der y-Achse (Kosmetik)

u <- resid
## u wird standardisiert
u <- 2.75*( u - mean(u) ) / sd(u)

gtslope <- runif(1,min=1,max=2)
gtmax   <- runif(1,min=5,max=1000)
  a <- 1   # no flat/steep linear trends visible in plots
  b <- 1
time  <- c(1:nobs)
time2 <- time - nobs/2
sscale = runif(1, min=30,max=40)
su  <- nobs*b/sscale

##  u <- rnorm(nobs, mean=0, sd=1)
##  u  <- f_rbeta_n(nobs, mean=0, sd=1)
  t <- a + b*time2 + su*u

# dmt in (-1,+1), slope = (1-0)/(nobs/2)
  dmt <- 2*t /( max(t) - min(t) ) 
  dmt <- dmt*gtslope      # gt-slope = slope*gtslope
  gt  <- exp( dmt )
  gt  <- gtmax*gt / max(abs(gt))
  gt
  }


## Saison :  mod(nobs,12) = 0 !!!
f_seas <- function(nobs,freq) {
  eps <- 0.001
#
if (freq == 4) {
  seas4      <- c(0*1:12)
  dim(seas4) <- c(4,3)
  seas0      <- c(0*1:4) 
  stype <- ceiling( runif(1,min=1-1+eps,max=3-eps) )
#  stype=1

# Nächtigungen ausl Gäste 2006, aggr
  seas4[,1] <- c(4.62, 1.98, 3.77, 1.72)
# Gastronomie SCS, aggr
  seas4[,2] <- c(3.28, 2.89, 2.62, 3.18)
# elec MWH, aggr
  seas4[,3] <- c( 2.09, 3.29, 4.14, 2.49)

  seas0 <- seas4[,stype]/3 - 1
  }

if (freq == 12) {
  seas12      <- c(0*1:72)
  dim(seas12) <- c(12,6)
  seas0       <- c(0*1:12)
  stype <- ceiling( runif(1,min=1-1+eps,max=6-eps) )

# EP Pos 661 (03-06) Schnittlauch OK
  seas12[,1] <- c(1.16, 1.06, 1.03, 1.12, 1.03, 0.94,
                  0.83, 0.88, 0.90, 0.95, 0.95, 1.15)
# Nächtigungen ausl Gäste 2006 ???
  seas12[,2] <-  c(1.50, 1.65, 1.47, 0.70, 0.50, 0.78, 
                 1.35, 1.50, 0.92, 0.55, 0.25, 0.92)
# Gastronomie SCS ok
  seas12[,3] <- c(1.06, 1.16, 1.06, 1.06, 0.94, 0.89, 
                0.83, 0.88, 0.91, 1.06, 1.06, 1.06)
# airline BJ ok
  seas12[,4] <- c(0.92, 0.91, 1.04, 1.00, 0.99, 1.10, 
                1.19, 1.18, 1.06, 0.92, 0.78, 0.91)
# "Anzahl von Passagieren im Charterflugverkehr"
# AUA, Austr. Arrows, Lauda, Charter, Personen D(06+07)  
# Verkehrzahlen www.AUA.com Pressearchiv
  seas12[,5] <- c(0.42, 0.44, 0.46, 
                  0.78, 1.01, 1.64, 
                  2.19, 2.05, 1.59, 
                  0.76, 0.30, 0.36 )
# elec MWH  gut
  seas12[,6] <- c(0.64, 0.55, 0.90, 0.73, 1.20, 1.36, 
                  1.63, 1.45, 1.06, 0.99, 0.78, 0.72)

  seas0 <- seas12[,stype] - 1
  }

seas <- rep(seas0, times= nobs/freq)
}

########## expGl (IMA(1,1), Holt (IMA(2,1), Holt-Winters(SIMA(2,1) ######

f_expg <- function(nobs, alpha) {
## generates an IMA(1,1)  y = y(-1) + e + b*e(-1), b=alpha-1
## 
##   without scaling
  maxtrials <- 100;
  time      <- c(1:nobs)
  b         <- alpha - 1
  y         <- c(0,0*2:nobs);
  r2        <- c(0*1:maxtrials);
  r2h <- 0;
  for (i3 in 1:maxtrials) {
      em1  <- f_rbeta_n(1,mean=0,sd=1);
      for (i in 2:nobs) {
##    u      <- rnorm(nobs, mean=0, sd=1);
          e0   <- f_rbeta_n(1,mean=0,sd=1);
          y[i] <- y[i-1] + e0 + b*em1 
          em1   <- e0
          }
     modlt <- lm(y ~ time);
     r2h  <- summary(modlt)$r.squared;
     r2[i3] <- r2h; 
     if (r2h > 0.1 && r2h < 0.25 && modlt$coefficients[2] > 0) break;
     }
  y; 
  }

f_holt <- function(nobs, alpha, beta) {
## generates an IMA(2,2)  (1-L)^2 y = e + b1*e(-1) + b2*e(-2), 
## b1 = -(2 - alpha - alpha*beta),   b2 = -(alpha - 1)
## b1 > 0: sehr glatter Pfad
## vorschlag: alpha=beta=0.1
##   without scaling
  maxtrials <- 100;
  time      <- c(1:nobs)
  b1        <- -2 + alpha + alpha*beta
  b2        <- 1 - alpha
  y         <- c(+.01,-.1,0*3:nobs);
# -.10,-.10; -.1,0.05 ## -.10,-.05; -.1,0; 
#I -.1,.1; 0.1,-.1
  ma2       <- c(0*1:nobs)
  r2        <- c(0*1:maxtrials);
  r2h <- 0;
  for (i3 in 1:maxtrials) {
      em2 <- f_rbeta_n(1,mean=0,sd=1);
      em1 <- f_rbeta_n(1,mean=0,sd=1);
      for (i in 1:nobs) {
##    u      <- rnorm(nobs, mean=0, sd=1);
          e0   <- f_rbeta_n(1,mean=0,sd=1)
          ma2[i] <- e0 + b1*em1 + b2*em2 
          em2   <- em1
          em1   <- e0
          }
      for (i in 3:nobs) {
          y[i] = 2*y[i-1] - y[i-2] + ma2[i]
          }

     modlt <- lm(y ~ time);
     r2h  <- summary(modlt)$r.squared;
     r2[i3] <- r2h; 
 #    if (r2h > 0.3  && modlt$coefficients[2] > 0) break;
     if ( modlt$coefficients[2] > 0) break;
     }
  y; 
  }

f_holtwint <- function(nobs, alpha, beta, gamma, s) {
## generates an IMA(1,s+1)(0,1,0)_s  B_s+1(L)= 1 - Sum_1^{s+1} d_i L^i, 
## d1 = 1 - alpha(1 + beta),      dj = -alpha beta, j=2,...,s-1,
## ds = (1 - gamma)-alpha(beta-gamma),  d_{s+1} = -(1-alpha)(1-gamma)
## Abraham/Ledolter(86) Int.Stat.Rev., 54(1), 51-66, 
## Forecast functions implied by ... ARIMA...
## vorschlag: alpha=beta=0.1
##   without scaling
  n         <- nobs + s + 2 + 100 
  n0        <- n-nobs+1
  maxtrials <- 100;
  time      <- c(1:nobs)
  z         <- c(0*1:nobs)
  sp1       <- s+1
  sp2       <- s+2
  b         <- c(0*1:sp1)
  b[1]      <- -(1-alpha*(1+beta))
  sm1       <- s - 1
  sm2       <- s - 2
  b[2:sm1]  <- rep( alpha*beta,times= sm2)
  b[s]      <- -( (1-gamma)-alpha*(beta-gamma) )
  b[s+1]    <- (1-alpha)*(1-gamma) 
  y         <-  f_rbeta_n(n,mean=0,sd=1);
# -.10,-.10; -.1,0.05 ## -.10,-.05; -.1,0; 
#I -.1,.1; 0.1,-.1
  ma        <- c(0*1:n)
  r2        <- c(0*1:maxtrials);
  r2h <- 0;
  e  <- c(0*1:sp1)
  for (i3 in 1:maxtrials) {
      e <- f_rbeta_n(sp1,mean=0,sd=1);
      for (i in 1:n) {
##    u      <- rnorm(n, mean=0, sd=1);
          e0   <- f_rbeta_n(1,mean=0,sd=1)
          ma[i] <- e0 + sum(b*e) 
          e[2:sp1] <- e[1:s]
          e[1]   <- e0
          }
# (1-L)(1-L^s) = 1 - L - L^s + L^(s+1)
      for (i in sp2:n) {
          y[i] = y[i-1] + y[i-s] - y[i-sp1] + ma[i]
          }

     z[1:nobs] <- y[n0:n];
     modlt <- lm(z ~ time);
     r2h  <- summary(modlt)$r.squared;
     r2[i3] <- r2h; 
 #    if (r2h > 0.3  && modlt$coefficients[2] > 0) break;
     if ( modlt$coefficients[2] > 0) break;
     }
  z; 
  }

f_hw_b <- function(alpha,beta,gamma,s) {
  sp1       <- s+1
  sp2       <- s+2
  b         <- c(0*1:sp1)
  b[1]      <- -(1-alpha*(1+beta))
  sm1       <- s - 1
  sm2       <- s - 2
  b[2:sm1]  <- rep( alpha*beta,times= sm2)
  b[s]      <- -( (1-gamma)-alpha*(beta-gamma) )
  b[s+1]    <- (1-alpha)*(1-gamma) 
  b;
  }

############################################################

f_rbeta_n <- function(nobs=100,mean=0,sd=1) {
## generates a vector of symmetric iid beta(mue,std) variates
## similar to the normal (Kurtosis = 3)
## bmue = m/(m+n)  bvar = m*n/[(m+n+1)(m+n)^2]
## E(X^k) = G(k+m)G(m+n) / [G(m)G(k+m+n)] =
##              ... m=n ...
##   = (m+k-1)...(m+1)m / [(2m+k-1)...(2m+1)(2m)]
## excess-kurtosis = 6*xz/xn
##   xz <- a^3 - a^2*(2*b-1)+b^2*(b+1)-2*a*b*(b+2)
##   xn <- a*b*(a+b+2)*(a+b+3);
##
## symmetric beta --> m=n:  bmue=0.5; bvar=1/[4(2m+1)]

## m=n=10  -->  K-3 = 0.07
##
  m <- 10
  mb = 0.5; sb2 = 1/( 4*(2*m+1) ); sb = sqrt(sb2);
  u <- rbeta(nobs, m, m); 
  u <- (u - mb)/sb;
  u <-  u*sd + mean;
  u 
  }  

f_ar <- function(nobs=100,smue,sstd,rho1) {
## horizontales Muster, AR(1) srho1 < 0.85 fix, WN given nobs
## sd = std(y)
  u <- c(0*1:nobs)
## mu = a/(1 - rho1)
    maxtrials <- 100
    ucs <- sqrt( 1/(1-rho1^2) )
 for (i in 1:maxtrials) {
   u[1] <- f_rbeta_n(1,0,ucs) 
   v    <- f_rbeta_n(nobs,0,1)
   for (j in 2:nobs) { u[j] = rho1*u[j-1] + v[j] }
   acf_u <- acf(u, plot=FALSE)
   rho1h = acf_u$acf[2]
   rho4h = acf_u$acf[5]
   if ( (abs(rho1h) < 0.8) & (abs(rho4h) > 0.30) ) break
    }
   stdu <- sqrt( var(u) )
   u <- sstd*u/stdu + smue;
   u
  }

f_rw <- function(nobs=100,y0,drift,sde) {
## RW, y(0), drift, std(e) 
  y <- c(0*1:nobs)
  maxtrials <- 100
for (i in 1:maxtrials) {
    y[1] <- y0
    v    <- f_rbeta_n(nobs,0,sde)
   for (j in 2:nobs) { y[j] = drift + y[j-1] + v[j] }
   acf_y <- acf(y, plot=FALSE)
   rho1h = acf_y$acf[2,1,1]
   if ( rho1h > 0.90 ) break
   }
   y;
  }

#####################################################################
# Berechnen die Achsenunterteilung der saisonalen ZR-Plots
#
f_yax <- function(ser) {
  start <-   floor( attr(ser,"tsp")[1] )
  end   <-   ceiling( attr(ser,"tsp")[2] )
  freq  <-   attr(ser,"tsp")[3]

  seq(start,end,by=1)
  }

f_sax <- function(ser) {
  start <-   floor( attr(ser,"tsp")[1] )
  end   <-   ceiling( attr(ser,"tsp")[2] )
  freq  <-   attr(ser,"tsp")[3]

  seq(start,end,by=2/freq)
  }
#################################################################### 

 
#####################################################################
# Test
#####################################################################
#f_dat <- function(s) { dat <- vector("list",5); 
#  dat[[1]] <- "title"
#  dat[[2]] <- 1900
#  dat[[3]] <- 4
#  dat[[4]] <- c(1:10)
#  dat;
#  }
#
#dat  <- f_dat(1);
#y.ts <- ts ( dat[[4]], start=dat[[2]],freq=dat[[3]] )
#
#nobs=100; alpha=0.8; beta=0.1; gamma=0.9; s=12;
## OK nobs=100; alpha=0.8; beta=0.1; gamma=0.9; s=12;
#y.ts <- ts( f_holtwint(nobs,alpha,beta,gamma,s), start=1,freq=s ); 
#plot(y.ts)
#f_hw_b(alpha,beta,gamma,s)
#HoltWinters(y.ts)
#
#load("c:/BA-Stat/Daten/souvenirs.rda")
#souv <- souvenirs
