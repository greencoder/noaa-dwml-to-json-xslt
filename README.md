noaa-dwml-to-json-xslt
======================

An XSLT to transform NOAA's DWML time-series forecasts into JSON.

###Background###

NOAA provides DWML (Digital Weather Markup Language) forecasts in XML format, but they don't offer JSON feeds. I feel like I've written the same XML parsing routines in a number of languages, so I decided to bite the bullet and write it once-and-for-all in XSLT. 

*Note: This XSLT is written to the 1.0 specification to be as widely-usable as possible.*

I also cleaned up the wonky `time-layout` mapping nonsense that you have to do when parsing the feeds by hand; each data point has the start time and duration in hours in it. This results in a larger and more verbose output JSON, but you shouldn't have to map `time-layout` values to arrays.  

In order to make this usable to lots of people, I wrote it against the generic *time-series* NOAA feed. The documentation is found at: http://graphical.weather.gov/xml/rest.php. 

Here's an example of the feed for my city:
http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-seriesUnit=e

###Usage###

You'll probably have to look up the best way to use XSLT in your language of choice, but you can use *xsltproc* http://xmlsoft.org/XSLT/xsltproc2.html on OSX and Linux:

    $ xsltproc time_series.xsl source.xml

You can also *curl* the forecast and pipe it into *xsltproc*:

    $ curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-seriesUnit=e" | xsltproc time_series.xsl -

*Note that you use a dash "-" to tell xsltproc to use stdin.*

###Limitations###

XSLT is pretty lousy at pretty-printing, so the JSON it outputs is ugly. (but valid) I like the *JQ* tool <https://github.com/stedolan/jq> to pretty-print the output:

    $ xsltproc time_series.xsl source.xml | jq '.'

You can combine *curl*, *xsltproc*, and *jq* into one command to get pretty-printed output:

    $ curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-seriesUnit=e" | xsltproc time_series.xsl - | jq '.' > sample.json

This command is found in the *fetch_sample.sh* shell script included in the repo.

###Feedback###

I welcome feedback, pull-requests, and bug reports.
