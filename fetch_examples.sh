echo "Fetching and parsing 'time-series' feed:"
curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=time-series" | xsltproc noaa.xsl - | python -mjson.tool > examples/time_series.json && echo "Done."

echo "Fetching and parsing 'glance' feed:"
curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?whichClient=NDFDgen&lat=39.7&lon=-104.75&product=glance" | xsltproc noaa.xsl - | python -mjson.tool > examples/glance.json && echo "Done."

echo "Fetching and parsing '12-hourly' feed:"
curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?lat=39.7&lon=-104.75&format=12+hourly" | xsltproc noaa.xsl - | python -mjson.tool > examples/12_hourly.json && echo "Done."

echo "Fetching and parsing '24-hourly' feed:"
curl -s "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?lat=39.7&lon=-104.75&format=24+hourly" | xsltproc noaa.xsl - | python -mjson.tool > examples/24_hourly.json && echo "Done."
