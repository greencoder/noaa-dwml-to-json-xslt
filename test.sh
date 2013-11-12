echo "Testing 'time-series' feed:"
curl -s "http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML.txt" | xsltproc noaa.xsl - | python -mjson.tool > /dev/null && echo "Result: Passed."

echo "Testing 'glance' feed:"
curl -s "http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWML_glance.txt" | xsltproc noaa.xsl - | python -mjson.tool > /dev/null && echo "Result: Passed."

echo "Testing '24-hourly' feed:"
curl -s "http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay24hr.txt" | xsltproc noaa.xsl - | python -mjson.tool > /dev/null && echo "Result: Passed."

echo "Testing '12-hourly' feed:"
curl -s "http://graphical.weather.gov/xml/DWMLgen/schema/latest_DWMLByDay12hr.txt" | xsltproc noaa.xsl - | python -mjson.tool > /dev/null && echo "Result: Passed."
