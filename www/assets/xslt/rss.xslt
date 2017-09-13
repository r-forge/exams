<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
<xsl:output method="html" encoding="utf-8" />
<xsl:template match="/rss">
	<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html &gt;</xsl:text>
	<html>
	<head>
		<xsl:text disable-output-escaping="yes"><![CDATA[
			<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<title>RSS Feed (Styled)</title>
	<link rel="stylesheet" type="text/css" href="http://www.R-exams.org/assets/css/styles_feeling_responsive.css" />
	<script src="http://www.R-exams.org/assets/js/modernizr.min.js"></script>

  <script src="https://ajax.googleapis.com/ajax/libs/webfont/1.5.18/webfont.js"></script>
  <script>
    WebFont.load({
      google: {
        families: [ 'Lato:400,700,400italic:latin', 'Noto+Serif:400,700,400italic:latin' ]
      }
    });
  </script>

  <noscript>
    <link href='http://fonts.googleapis.com/css?family=Lato:400,700,400italic|Volkhov' rel='stylesheet' type='text/css' />
  </noscript>

  
	
	<meta name="description" content="Automatic generation  and evaluation of exams. From Markdown, LaTeX and R code to standalone documents, learning management systems and live voting." />

	

	
<link rel="apple-touch-icon" sizes="180x180" href="/assets/icons/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/icons/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/assets/icons/favicon-16x16.png">
<link rel="manifest" href="/assets/icons/manifest.json">
<link rel="mask-icon" href="/assets/icons/safari-pinned-tab.svg" color="#1f7a7a">
<link rel="shortcut icon" href="/assets/icons/favicon.ico">
<meta name="apple-mobile-web-app-title" content="R/exams">
<meta name="application-name" content="R/exams">
<meta name="msapplication-config" content="/assets/icons/browserconfig.xml">
<meta name="theme-color" content="#1f7a7a">


	<!-- Facebook Optimization -->
	<meta property="og:locale" content="en_EN" />
	
	<meta property="og:title" content="RSS Feed (Styled)" />
	<meta property="og:description" content="Automatic generation  and evaluation of exams. From Markdown, LaTeX and R code to standalone documents, learning management systems and live voting." />
	<meta property="og:url" content="http://www.R-exams.org//assets/xslt/rss.xslt" />
	<meta property="og:site_name" content="R/exams" />
	

	

	<!-- Search Engine Optimization -->
	

	<link type="text/plain" rel="author" href="http://www.R-exams.org/humans.txt" />

	

	
</head>

		]]></xsl:text>
	</head>
	<body id="top-of-page">
		<xsl:text disable-output-escaping="yes"><![CDATA[
		
<div id="navigation" class="sticky">
  <nav class="top-bar" role="navigation" data-topbar>
    <ul class="title-area">
      <li class="name">
          <a href="http://www.R-exams.org">
            <img class='nav-logo' src="http://www.R-exams.org/assets/img/logo.svg" alt="R/exams">
          </a>
          <!-- <h1 class="show-for-small-only"><a href="http://www.R-exams.org" class="icon-tree"> R/exams</a></h1> -->
      </li>
       <!-- Remove the class "menu-icon" to get rid of menu icon. Take out "Menu" to just have icon alone -->
      <li class="toggle-topbar menu-icon"><a href="#"><span>Navigation</span></a></li>
    </ul>
    <section class="top-bar-section">

      <ul class="left">
        

              

          
          

            
            

              <li class="has-dropdown">
                <a href="http://www.R-exams.org/">R/exams</a>

                  <ul class="dropdown">
                    

                      

                      <li><a href="http://www.R-exams.org/intro/elearning/">E-Learning</a></li>
                    

                      

                      <li><a href="http://www.R-exams.org/intro/oneforall/">One-for-All</a></li>
                    

                      

                      <li><a href="http://www.R-exams.org/intro/written/">Written Exams</a></li>
                    

                      

                      <li><a href="http://www.R-exams.org/intro/dynamic/">Dynamic Exercises</a></li>
                    
                  </ul>

              </li>
              <li class="divider"></li>
            
          
        

              

          
          

            
            
              <li><a href="http://www.R-exams.org/tutorials/">Tutorials</a></li>
              <li class="divider"></li>

            
            
          
        

              

          
          

            
            
              <li><a href="http://www.R-exams.org/templates/">Exercise Templates</a></li>
              <li class="divider"></li>

            
            
          
        

              

          
          

            
            
              <li><a href="http://www.R-exams.org/blog/">Blog</a></li>
              <li class="divider"></li>

            
            
          
        

              

          
          
        

              

          
          
        

              

          
          
        
        
      </ul>

      <ul class="right">
        

              

          
          
        

              

          
          
        

              

          
          
        

              

          
          
        

              

          
          
            
            
              <li class="divider"></li>
              <li><a href="http://www.R-exams.org/resources/">Resources</a></li>

            
            
          
        

              

          
          
            
            
              <li class="divider"></li>
              <li><a href="http://www.R-exams.org/contact/">Contact</a></li>

            
            
          
        

              

          
          
            
            
              <li class="divider"></li>
              <li><a href="http://www.R-exams.org/search/">Search</a></li>

            
            
          
        
        
      </ul>
    </section>
  </nav>
</div><!-- /#navigation -->

		

<!-- <div id="masthead-no-image-header"> -->
	<!-- <div class="row"> -->
		<!-- <div class="small-12 columns"> -->
			<!-- <a id="logo" href="http://www.R-exams.org" title="R/exams – The One-for-All Exams Generator"> -->
				<!-- <img src="http://www.R-exams.org/assets/img/logo.svg" alt="R/exams – The One-for-All Exams Generator"> -->
			<!-- </a> -->
		<!-- </div>[> /.small-12.columns <] -->
	<!-- </div>[> /.row <] -->
<!-- </div>[> /#masthead <] -->









		


<div class="alert-box warning radius text-center"><p>This <a href="https://en.wikipedia.org/wiki/RSS" target="_blank">RSS feed</a> is meant to be used by <a href="https://en.wikipedia.org/wiki/Template:Aggregators" target="_blank">RSS reader applications and websites</a>.</p>
</div>



		]]></xsl:text>
		<header class="t30 row">
	<p class="subheadline"><xsl:value-of select="channel/description" disable-output-escaping="yes" /></p>
	<h1>
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="channel/link" />
			</xsl:attribute>
			<xsl:value-of select="channel/title" disable-output-escaping="yes" />
		</xsl:element>
	</h1>
</header>
<ul class="accordion row" data-accordion="">
	<xsl:for-each select="channel/item">
		<li class="accordion-navigation">
			<xsl:variable name="slug-id">
				<xsl:call-template name="slugify">
					<xsl:with-param name="text" select="guid" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:element name="a">
				<xsl:attribute name="href"><xsl:value-of select="concat('#', $slug-id)"/></xsl:attribute>
				<xsl:value-of select="title"/>
				<br/>
				<small><xsl:value-of select="pubDate"/></small>
			</xsl:element>
			<xsl:element name="div">
				<xsl:attribute name="id"><xsl:value-of select="$slug-id"/></xsl:attribute>
				<xsl:attribute name="class">content</xsl:attribute>
				<h1>
					<xsl:element name="a">
						<xsl:attribute name="href"><xsl:value-of select="link"/></xsl:attribute>
						<xsl:value-of select="title"/>
					</xsl:element>
				</h1>
				<xsl:value-of select="description" disable-output-escaping="yes" />
			</xsl:element>
		</li>
	</xsl:for-each>
</ul>

		<xsl:text disable-output-escaping="yes"><![CDATA[
		    <div id="up-to-top" class="row">
      <div class="small-12 columns" style="text-align: right;">
        <a class="icon-chevron-up" href="#top-of-page"></a>
      </div><!-- /.small-12.columns -->
    </div><!-- /.row -->


    <footer id="footer-content" class="bg-grau">
      <div id="footer">
        <div class="row">
          <div class="medium-6 large-5 columns">
            <h5 class="shadow-black">About This Site</h5>

            <p class="shadow-black">
              Automatic generation  and evaluation of exams. From Markdown, LaTeX and R code to standalone documents, learning management systems and live voting.
              <!-- <a href="http://www.R-exams.org/about/">More ›</a> -->
            </p>
          </div><!-- /.large-6.columns -->


          <div class="small-6 medium-3 large-3 large-offset-1 columns">
            
              
                <h5 class="shadow-black">Services</h5>
              
            
              
            
              
            
              
            

              <ul class="no-bullet shadow-black">
              
                
                  <li >
                    <a href=""  title=""></a>
                  </li>
              
                
                  <li >
                    <a href="/feed.xml"  title="Subscribe to RSS Feed">RSS</a>
                  </li>
              
                
                  <li >
                    <a href="/atom.xml"  title="Subscribe to Atom Feed">Atom</a>
                  </li>
              
                
                  <li >
                    <a href="/sitemap.xml"  title="Sitemap for Google Webmaster Tools">sitemap.xml</a>
                  </li>
              
              </ul>
          </div><!-- /.large-4.columns -->


          <div class="small-6 medium-3 large-3 columns">
            
              
                <h5 class="shadow-black">Network</h5>
              
            
              
            
              
            

            <ul class="no-bullet shadow-black">
            
              
                <li >
                  <a href=""  title=""></a>
                </li>
            
              
                <li >
                  <a href="https://CRAN.R-project.org/package=exams" target="_blank"  title="Software download">CRAN</a>
                </li>
            
              
                <li >
                  <a href="https://R-Forge.R-project.org/R/?group_id=1337" target="_blank"  title="Package development">R-Forge</a>
                </li>
            
            </ul>
          </div><!-- /.large-3.columns -->
        </div><!-- /.row -->

      </div><!-- /#footer -->


      <div id="subfooter">
        <nav class="row">
          <section id="subfooter-left" class="b30 small-12 medium-6 columns credits">
            <p>
            Built with
            <a href="https://jekyllrb.com/" alt="Page built with Jekyll">
              Jekyll
            </a>
             based on
             <a href="http://phlow.github.io/feeling-responsive/" alt="Page based on Feeling Responisve Theme">
               Feeling Responsive
             </a>
              by
              <a href="http://phlow.de" alt="Theme created by Phlow">Phlow</a>.
            </p>
          </section>

          <section id="subfooter-right" class="small-12 medium-6 columns social-icons">
            <ul class="inline-list">
            
              <li><a href="mailto:info@R-exams.org" target="_blank" class="icon-mail" title="General inquiries"></a></li>
            
              <li><a href="https://CRAN.R-project.org/package=exams" target="_blank" class="icon-cran" title="R package on CRAN"></a></li>
            
              <li><a href="http://R-Forge.R-project.org/R/?group_id=1337" target="_blank" class="icon-code" title="Source code management on R-Forge"></a></li>
            
              <li><a href="http://R-Forge.R-project.org/forum/?group_id=1337" target="_blank" class="icon-chat" title="Discussion forum on R-Forge"></a></li>
            
              <li><a href="https://StackOverflow.com/questions/tagged/exams" target="_blank" class="icon-stackoverflow" title="Ask questions on StackOverflow (tag: exams)"></a></li>
            
              <li><a href="http://twitter.com/AchimZeileis" target="_blank" class="icon-twitter" title="@AchimZeileis on Twitter"></a></li>
            
            </ul>
          </section>
        </nav>
      </div><!-- /#subfooter -->
    </footer>

		


<script src="http://www.R-exams.org/assets/js/javascript.min.js"></script>
<script src="http://www.R-exams.org/assets/js/slick.min.js"></script>
















		]]></xsl:text>
	</body>
	</html>
</xsl:template>
<xsl:template name="slugify">
	<xsl:param name="text" select="''" />
	<xsl:variable name="dodgyChars" select="' ,.#_-!?*:;=+|&amp;/\\'" />
	<xsl:variable name="replacementChar" select="'-----------------'" />
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="lowercased"><xsl:value-of select="translate( $text, $uppercase, $lowercase )" /></xsl:variable>
	<xsl:variable name="escaped"><xsl:value-of select="translate( $lowercased, $dodgyChars, $replacementChar )" /></xsl:variable>
	<xsl:value-of select="$escaped" />
</xsl:template>
</xsl:stylesheet>
