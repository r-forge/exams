exams2blackboard <- function(file, n = 1L, nsamp = NULL, dir = ".",
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  resolution = 100, width = 4, height = 4, encoding  = "",
  num = NULL, mchoice = NULL, schoice = mchoice, string = NULL, cloze = NULL,
  template = NULL, zip = TRUE,
  points = NULL, eval = list(partial = TRUE, negative = FALSE), ...)
{
  ## set up .html transformer
  htmltransform <- make_exercise_transform_html(...)

  ## create exam
  exm <- xexams(file, n = n, nsamp = nsamp,
    driver = list(
      sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
        resolution = resolution, width = width, height = height,
        encoding = encoding),
      read = NULL, transform = htmltransform, write = NULL),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose)

  ## start .xml assessement creation
  ## get the possible item body functions and options  
  itembody = list(num = num, mchoice = mchoice, schoice = schoice, cloze = cloze, string = string)

  for(i in c("num", "mchoice", "schoice", "cloze", "string")) {
    if(is.null(itembody[[i]])) itembody[[i]] <- list()
    if(is.list(itembody[[i]])) {
      if(is.null(itembody[[i]]$eval))
        itembody[[i]]$eval <- eval
      if(i == "cloze" & is.null(itembody[[i]]$eval$rule))
        itembody[[i]]$eval$rule <- "none"
      itembody[[i]] <- do.call("make_itembody_blackboard", itembody[[i]])
    }
    if(!is.function(itembody[[i]])) stop(sprintf("wrong specification of %s", sQuote(i)))
  }

  ## create a temporary directory
  dir <- path.expand(dir)
  if(is.null(tdir)) {
    dir.create(tdir <- tempfile())
    on.exit(unlink(tdir))
  } else {
    tdir <- path.expand(tdir)
  }
  if(!file.exists(tdir)) dir.create(tdir)

  ## FIXME: templates???

  ## obtain the number of exams and questions
  nx <- length(exm)
  nq <- length(exm[[1L]])

  ## create a name
  if(is.null(name)) name <- "bbexam"

  ## function for internal ids
  make_test_ids <- function(n, type = c("test", "section", "item"))
  {
    switch(type,
      "test" = paste(name, make_id(9), sep = "_"),
      paste(type, formatC(1:n, flag = "0", width = nchar(n)), sep = "_")
    )
  }

  ## generate the test id
  test_id <- make_test_ids(type = "test")

  ## create section ids
  sec_ids <- paste(test_id, make_test_ids(nq, type = "section"), sep = "_")

  ## points setting
  if(!is.null(points))
    points <- rep(points, length.out = nq)

  ## create the directory where the test is stored
  dir.create(test_dir <- file.path(tdir, name))

  xml <- NULL
  for(j in 1:nq) {
    ## create item ids
    item_ids <- paste(sec_ids[j], make_test_ids(nx, type = "item"), sep = "_")

    for(i in 1:nx) {
      ## overule points
      if(!is.null(points)) exm[[i]][[j]]$metainfo$points <- points[[j]]

      ## get and insert the item body
      type <- exm[[i]][[j]]$metainfo$type

      ## create an id
      iname <- paste(item_ids[i], type, sep = "_")

      ## attach item id to metainfo
      exm[[i]][[j]]$metainfo$id <- iname

      ibody <- itembody[[type]](exm[[i]][[j]])

      ## copy supplements
      if(length(exm[[i]][[j]]$supplements)) {
        if(!file.exists(media_dir <- file.path(test_dir, "media")))
          dir.create(media_dir)
        sj <- 1
        while(file.exists(file.path(media_dir, sup_dir <- paste("supplements", sj, sep = "")))) {
          sj <- sj + 1
        }
        dir.create(ms_dir <- file.path(media_dir, sup_dir))
        for(si in seq_along(exm[[i]][[j]]$supplements)) {
          file.copy(exm[[i]][[j]]$supplements[si],
            file.path(ms_dir, f <- basename(exm[[i]][[j]]$supplements[si])))
          if(any(grepl(dirname(exm[[i]][[j]]$supplements[si]), ibody))) {
            ibody <- gsub(dirname(exm[[i]][[j]]$supplements[si]),
              file.path('media', sup_dir), ibody, fixed = TRUE)
          } else {
            if(any(grepl(f, ibody))) {
              ibody <- gsub(paste(f, '"', sep = ''),
                paste('media', sup_dir, f, '"', sep = '/'), ibody, fixed = TRUE)
            }
          }
        }
      }

      ## add item to final xml
      xml <- c(xml, ibody, "")
    }
  }

  ## write to dir
  writeLines(xml, file.path(test_dir, paste(name, "xml", sep = ".")))

  ## compress
  if(zip) {
    owd <- getwd()
    setwd(test_dir)
    zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
    setwd(owd)
  } else zipname <- list.files(test_dir)

  ## copy the final .zip file
  file.copy(file.path(test_dir, zipname), dir, recursive = TRUE)

  ## assign test id as an attribute
  attr(exm, "test_id") <- test_id

  invisible(exm)
}


## Blackboard item body constructor function
make_itembody_blackboard <- function(...)
{
  function(x) {
    return("1")
  }
}


#function for generating random identifiers 
randomstring<-function(a=1,n=31){
z<-vector(length=a)
  for (h in 1:a){
  x<-"n"
  for (i in 1:n){
  if (runif(1)>0.5){
  y<-round(runif(1,-.5,9.5))
      }
      else {y<-letters[round(runif(1,.5,24.5))]
      }                  
  x<-paste(x,y, sep = "")
    }
  z[h]<-x  }
  z
}



#function to write exam items into a Blackboard format
mc2bb<-function(exam.object,inst="Make these items",correct=1,naam="tryout",desc="MC Questions",path="C:\\BB\\"){


  eo<-exam.object
  nritems<-length(eo)
  
  iden<-as.numeric(format(Sys.time(), "%H%M%S"))+100000
  tijd<-format(Sys.time(), "%Y-%m-%d-%H%M")
  dir.create(path, showWarnings = FALSE)  
  dir.create(paste(path,tijd,sep=""))
  dir.create(paste(path,tijd,"\\res00002",sep=""))
  #write info to .bb-package-info, res00001.dat, res00003.dat
  cat(paste("<?xml version=\"1.0\" encoding=\"UTF-8\"?>","\n<CATEGORIES><CATEGORY id=\"_3728_1\"><TITLE>\"OMII-A\"</TITLE><TYPE>category</TYPE><COURSEID value=\"_38547_1\"/></CATEGORY></CATEGORIES>"),sep="",file=paste(path,tijd,"\\res00001.dat",sep=""))
  cat(paste("<?xml version=\"1.0\" encoding=\"UTF-8\"?>","\n<ASSESSMENTCREATIONSETTINGS><ASSESSMENTCREATIONSETTING id=\"_22705_1\"><QTIASSESSMENTID value=\"_",iden,"_1\"/><ANSWERFEEDBACKENABLED>false</ANSWERFEEDBACKENABLED><QUESTIONATTACHMENTSENABLED>true</QUESTIONATTACHMENTSENABLED><ANSWERATTACHMENTSENABLED>false</ANSWERATTACHMENTSENABLED><QUESTIONMETADATAENABLED>false</QUESTIONMETADATAENABLED><DEFAULTPOINTVALUEENABLED>false</DEFAULTPOINTVALUEENABLED><DEFAULTPOINTVALUE>10.0</DEFAULTPOINTVALUE><ANSWERPARTIALCREDITENABLED>false</ANSWERPARTIALCREDITENABLED><ANSWERRANDOMORDERENABLED>true</ANSWERRANDOMORDERENABLED><ANSWERORIENTATIONENABLED>true</ANSWERORIENTATIONENABLED><ANSWERNUMBEROPTIONSENABLED>true</ANSWERNUMBEROPTIONSENABLED></ASSESSMENTCREATIONSETTING></ASSESSMENTCREATIONSETTINGS>",sep=""),file=paste(path,tijd,"\\res00003.dat",sep=""),sep="")
  cat(paste("#CxPackageInfo Property File","\n#",format(Sys.time(), "%A %b %d %X %Y"),"\njava.class.path=\\:/usr/local/blackboard/apps/tomcat/bin/bootstrap.jar\\:/usr/local/blackboard/apps/tomcat/bin/commons-logging-api.jar\ncx.config.course.id=FPP_812005_2007_1\njava.vendor=Sun Microsystems Inc.\nos.name=Linux\nos.arch=i386\njava.home=/usr/java/jdk1.5.0_07/jre\ncx.package.info.version=6.0\ndb.product.name=Oracle\nos.version=2.6.9-67.ELsmp\ncx.config.full.value=CxConfig{operation\\=EXPORT, courseid\\=FPP_812005_2007_1, package\\=/usr/local/blackboard/content/vi/bb_bb60/sessions/1/3/6/0/4/8/5/7/2/session/Pool_ExportFile_FPP_812005_2007_1_",naam,".zip, logs\\=[Log{name\\=/usr/local/blackboard/content/vi/bb_bb60/sessions/1/3/6/0/4/8/5/7/2/session/Pool_ExportFile_FPP_812005_2007_1_",naam,".log, verbosity\\=default}, Log{name\\=stdout, verbosity\\=default}], area_inclusions\\=[], area_exclusions\\=[ALL], object_inclusions\\={POOL\\=[_",iden,"_1]}, object_exclusions\\={}, features\\={CreateOrg\\=false, Bb5LinkToBrokenImageFix\\=true}}\ncx.config.package.name=/usr/local/blackboard/content/vi/bb_bb60/sessions/1/3/6/0/4/8/5/7/2/session/Pool_ExportFile_FPP_812005_2007_1_",naam,".zip\ndb.product.version=Oracle Database 10g Enterprise Edition Release 10.2.0.3.0 - Production\nWith the Partitioning, OLAP and Data Mining options\ndb.driver.name=Oracle JDBC driver\ncx.config.operation=blackboard.apps.cx.CxConfig$Operation\\:EXPORT\njava.version=1.5.0_07\ndb.driver.version=10.2.0.1.0\njava.default.locale=en_US\napp.release.number=7.3.216.0\ncx.config.logs=[Log{name\\=/usr/local/blackboard/content/vi/bb_bb60/sessions/1/3/6/0/4/8/5/7/2/session/Pool_ExportFile_FPP_812005_2007_1_",naam,".log, verbosity\\=default}, Log{name\\=stdout, verbosity\\=default}]",sep=""),file=paste("C:\\BB\\",tijd,"\\.bb-package-info",sep=""))
    
  txta1<-paste("<?xml version=\"1.0\" encoding=\"UTF-8\"?><questestinterop><assessment title=\"")#set name
  txta2<-paste("\"><assessmentmetadata><bbmd_asi_object_id>",paste("_",iden,"_",1,sep=""),sep="")#unique number
  txta3<-paste("</bbmd_asi_object_id><bbmd_asitype>Assessment</bbmd_asitype><bbmd_assessmenttype>Pool</bbmd_assessmenttype><bbmd_sectiontype>Subsection</bbmd_sectiontype><bbmd_questiontype>Multiple Choice</bbmd_questiontype><bbmd_is_from_cartridge>false</bbmd_is_from_cartridge><bbmd_numbertype>none</bbmd_numbertype><bbmd_partialcredit/><bbmd_orientationtype>vertical</bbmd_orientationtype><bbmd_is_extracredit>false</bbmd_is_extracredit><qmd_absolutescore_max>0.0</qmd_absolutescore_max><qmd_weighting>0.0</qmd_weighting></assessmentmetadata><rubric view=\"All\"><flow_mat class=\"Block\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[")#Instructions
  txta4<-paste("<br />]]></mat_formattedtext></mat_extension></material></flow_mat></rubric><presentation_material><flow_mat class=\"Block\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[")#Short description
  txta5<-paste("<br />]]></mat_formattedtext></mat_extension></material></flow_mat></presentation_material><section><sectionmetadata><bbmd_asi_object_id>",paste("_",iden+1,"_",1,sep=""),"</bbmd_asi_object_id><bbmd_asitype>Section</bbmd_asitype><bbmd_assessmenttype>Pool</bbmd_assessmenttype><bbmd_sectiontype>Subsection</bbmd_sectiontype><bbmd_questiontype>Multiple Choice</bbmd_questiontype><bbmd_is_from_cartridge>false</bbmd_is_from_cartridge><bbmd_numbertype>none</bbmd_numbertype><bbmd_partialcredit/><bbmd_orientationtype>vertical</bbmd_orientationtype><bbmd_is_extracredit>false</bbmd_is_extracredit><qmd_absolutescore_max>0.0</qmd_absolutescore_max><qmd_weighting>0.0</qmd_weighting></sectionmetadata>",sep="")#Begin Item part
   txta<-paste(txta1,naam,txta2,txta3,inst,txta4,desc,txta5,sep="")
  
  #text for imsmanifest.xml file
  txtd1<-paste("<?xml version=\"1.0\" encoding=\"UTF-8\"?>","\n<manifest identifier=\"man00001\" xmlns:bb=\"http://www.blackboard.com/content-packaging/\"><organizations default=\"toc00001\"><organization identifier=\"toc00001\"/></organizations><resources><resource bb:file=\"res00001.dat\" bb:title=\"Categories\" identifier=\"res00001\" type=\"course/x-bb-category\" xml:base=\"res00001\"/><resource bb:file=\"res00002.dat\" bb:title=\"",naam,"\" identifier=\"res00002\" type=\"assessment/x-bb-qti-pool\" xml:base=\"res00002\">",sep="")
  txtd2<-paste("</resource><resource bb:file=\"res00003.dat\" bb:title=\"Assessment Creation Settings\" identifier=\"res00003\" type=\"course/x-bb-courseassessmentcreationsettings\" xml:base=\"res00003\"/></resources></manifest>")
  
  #empty text string   
  txt<-""

  
  for (i in 1:nritems){
  
    item<-eo[[i]][[1]]
    #I have to make single string of whole body because if I don't it just takes first element of character string
    #gives bad tables though (writeLines may be better)
    item$body<-Reduce(paste0,item$question)
    item$answers<-Reduce(paste0,item$solutionlist)    
    
    
    
    #begin item
    txtb1<-paste("<item maxattempts=\"0\"><itemmetadata><bbmd_asi_object_id>",paste("_",iden+1+i,"_",1,sep=""),"</bbmd_asi_object_id><bbmd_asitype>Item</bbmd_asitype><bbmd_assessmenttype>Pool</bbmd_assessmenttype><bbmd_sectiontype>Subsection</bbmd_sectiontype><bbmd_questiontype>Multiple Choice</bbmd_questiontype><bbmd_is_from_cartridge>false</bbmd_is_from_cartridge><bbmd_numbertype>letter_lower</bbmd_numbertype><bbmd_partialcredit>false</bbmd_partialcredit><bbmd_orientationtype>vertical</bbmd_orientationtype><bbmd_is_extracredit>false</bbmd_is_extracredit><qmd_absolutescore_max>0.0</qmd_absolutescore_max><qmd_weighting>0.0</qmd_weighting></itemmetadata><presentation><flow class=\"Block\"><flow class=\"QUESTION_BLOCK\"><flow class=\"FORMATTED_TEXT_BLOCK\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[",sep="")
    txtb2<-paste("]]></mat_formattedtext></mat_extension></material></flow></flow>")

    #start response block
    
    txtb<-paste(txtb1,item$body,txtb2,sep="")
    
    
    l<-length(item$questionlist)
    ids<-randomstring(a=l)
    txtc1<-paste("<flow class=\"RESPONSE_BLOCK\"><response_lid ident=\"response\" rcardinality=\"Single\" rtiming=\"No\"><render_choice maxnumber=\"0\" minnumber=\"0\" shuffle=\"Yes\">")
    txtc2<-""
    for (i in 1:l){
    txt01<-paste("<flow_label class=\"Block\"><response_label ident=\"",ids[i],"\" rarea=\"Ellipse\" rrange=\"Exact\" shuffle=\"Yes\"><flow_mat class=\"FORMATTED_TEXT_BLOCK\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[",item$questionlist[i],"<br />]]></mat_formattedtext></mat_extension></material></flow_mat></response_label></flow_label>",sep="")
    txtc2<-paste(txtc2,txt01,sep="")}
    txtc3<-paste("</render_choice></response_lid></flow></flow></presentation>")
    txtc4<-paste("<resprocessing scoremodel=\"SumOfScores\"><outcomes><decvar defaultval=\"0.0\" minvalue=\"0.0\" varname=\"SCORE\" vartype=\"Decimal\"/></outcomes><respcondition title=\"correct\"><conditionvar><varequal case=\"No\" respident=\"response\">",ids[correct],"</varequal></conditionvar><setvar action=\"Set\" variablename=\"SCORE\">SCORE.max</setvar><displayfeedback feedbacktype=\"Response\" linkrefid=\"correct\"/></respcondition><respcondition title=\"incorrect\"><conditionvar><other/></conditionvar><setvar action=\"Set\" variablename=\"SCORE\">0.0</setvar><displayfeedback feedbacktype=\"Response\" linkrefid=\"incorrect\"/></respcondition>",sep="")
    txtc5<-""
    for (i in 1:l){
    txt01<-paste("<respcondition><conditionvar><varequal case=\"No\" respident=\"",ids[i],"\"/></conditionvar><setvar action=\"Set\" variablename=\"SCORE\">0</setvar><displayfeedback feedbacktype=\"Response\" linkrefid=\"",ids[i],"\"/></respcondition>",sep="")
    txtc5<-paste(txtc5,txt01,sep="")}
    txtc6<-paste("</resprocessing><itemfeedback ident=\"correct\" view=\"All\"><flow_mat class=\"Block\"><flow_mat class=\"FORMATTED_TEXT_BLOCK\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[Goed!<br />",item$answers,"<br />]]></mat_formattedtext></mat_extension></material></flow_mat></flow_mat></itemfeedback><itemfeedback ident=\"incorrect\" view=\"All\"><flow_mat class=\"Block\"><flow_mat class=\"FORMATTED_TEXT_BLOCK\"><material><mat_extension><mat_formattedtext type=\"HTML\"><![CDATA[Fout <br />",item$answers,"<br />]]></mat_formattedtext></mat_extension></material></flow_mat></flow_mat></itemfeedback>")
    txtc7<-""
    for (i in 1:l){
    txt01<-paste("<itemfeedback ident=\"",ids[i],"\" view=\"All\"><solution feedbackstyle=\"Complete\" view=\"All\"><solutionmaterial><flow_mat class=\"Block\"><flow_mat class=\"FORMATTED_TEXT_BLOCK\"><material><mat_extension><mat_formattedtext type=\"HTML\"/></mat_extension></material></flow_mat></flow_mat></solutionmaterial></solution></itemfeedback>",sep="")
    txtc7<-paste(txtc7,txt01,sep="")}
    txtc8<-paste("</item>")
     txtc<-paste(txtc1,txtc2,txtc3,txtc4,txtc5,txtc6,txtc7,txtc8,sep="")
    
    txt<-paste(txt,txtb,txtc)
    
    
    }#end of loop
  
  #write to imsmanifest.xml
  cat(paste(txtd1,txtd2,sep=""),file=paste(path,tijd,"\\imsmanifest.xml",sep=""))
  
  #write to res00002.dat
  cat(txta,txt,paste("</section></assessment></questestinterop>"),sep="",file=paste(path,tijd,"\\res00002.dat",sep=""))
  
  test_dir<-paste(path,tijd,sep="")
  owd <- getwd()
  setwd(test_dir)
  zip(zipfile = zipname <- paste(test_dir, "zip", sep = "."),
            files = list.files(test_dir))
  setwd(owd)    

}


## TESTING.
if(FALSE) {
options(SweaveSyntax = SweaveSyntaxNoweb) 
library(exams)
odir <- "C:\\BB"
#exams2html("anova.Rnw",dir=odir)

## to produce the building blocks for the same exerce:
## set up a LaTeX-to-HTML converter based on tth and base64enc
htmltrafo <- make_exercise_transform_html()

## set the options for calling Sweave
args <- list(quiet = TRUE, pdf = FALSE, png = TRUE, resolution = 100,
  height = 4, width = 4)

## generate 1 exam with 1 exercise (anova.Rnw) in HTML+MathML
set.seed(1090)
exm <- xexams("anovans.Rnw", n = 10,
  driver = list(sweave = args, read = NULL, transform = htmltrafo))
  
## question (without multiple choice statements)
exm[[1]][[1]]$question[-11]

## multiple choice statements
exm[[1]][[1]]$questionlist

## correct solution text
exm[[1]][[1]]$solution

## and explanations corresponding to multiple choice statements
exm[[1]][[1]]$solutionlist

#In the $question I excluded line 11 because this contains the PNG image (in Base64 encoding). This is too long to usefully print on the screen...

#To see what the HTML text looks like in a browser you can also do

#exams:::show.html(exm[[1]][[1]]$question)

##source("D:/My Documents/Onderwijs/QTI.XML/exams2BB.R")

mc2bb(exm)
}

