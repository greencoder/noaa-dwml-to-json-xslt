noaa-dwml-to-json-xslt
======================

A set of XSLTs to transform NOAA's DWML [time-series](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML.txt), [24-hourly](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay24hr.txt), [12-hourly](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay12hr.txt), and [glance](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML_glance.txt) XML forecasts into JSON.

###Background###

NOAA provides DWML (Digital Weather Markup Language) forecasts in XML format, but they don't offer JSON feeds. I feel like I've written the same XML parsing routines in a number of languages, so I decided to bite the bullet and write it once-and-for-all in XSLT. 

*Note: This XSLT is written to the 1.0 specification to be compatible with as many XSLT libraries as possible.*

I also cleaned up the `time-layout` mapping nonsense that you have to do when parsing the feeds by hand; each data point has the start time and duration in hours in it. This results in a much larger and more verbose output JSON, but you shouldn't have to manually map `time-layout` values to arrays.

###Source Feeds###

NOAA provides four main feeds: [time-series](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML.txt), [24-hourly](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay24hr.txt), [12-hourly](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay12hr.txt), and [glance](http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML_glance.txt). There are parameters you can specify to filter the feeds, but in order to make this usable to lots of people, I wrote the transformations against the default values.

Example *time-series* feed:
http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-series

Example *glance* feed:
http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=glance

Example *24-hourly* feed:
http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?lat=39.7&lon=-104.75&format=24+hourly

Example *12-hourly* feed:
http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?lat=39.7&lon=-104.75&format=12+hourly

Consult the [NOAA REST API documentation](http://graphical.weather.gov/xml/rest.php) for specific information on the feeds.

###Usage###

You'll probably have to look up the best way to use XSLT in your language/platform of choice, but on OSX and Linux you can use [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html):

    $ xsltproc noaa.xsl source_file.xml

You can also *curl* the forecast and pipe it into *xsltproc*:

    $ curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-series" | xsltproc noaa.xsl -

*Note that you use a dash "-" to tell xsltproc to use stdin.*

###Example Output###

You can run the [fetch_examples.sh](../master/fetch_examples.sh) script to generate JSON files for all four feeds. Example files are included in the [examples directory](../master/examples/).

###Tests###

I don't know of any way to unit test XSLT other than to try feeds with it. NOAA provides feed specifications, so I put those into the [test.sh](../master/test.sh) shell script.

I expect there could be edge cases in the feeds that aren't handled properly; send those to me and I'll start a test suite of "bad" feeds.

###Limitations###

XSLT is lousy at pretty-printing, so the JSON it outputs is ugly. (but valid) I like the amazing [JQ tool](https://github.com/stedolan/jq) to pretty-print the output:

    $ xsltproc noaa.xsl source_file.xml | jq '.'

You can also use the `python -mjson.tool` command to format the JSON (I think JQ is a faster, but the Python command should be available on your system by default):

    $ xsltproc noaa.xsl source_file.xml | python -mjson.tool

You can combine the commands into a one-liner to get pretty-printed output:

    $ curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-series" | xsltproc noaa.xsl - | python -mjson.tool > sample_time_series.json

These one-line commands are found in the [fetch_examples.sh](../master/fetch_examples.sh) shell script.

###Feedback###

I welcome feedback, pull requests, and bug reports.

If you find a feed that breaks the XSLT, **please** send it to me in XML format so I can fix the XSLT.

