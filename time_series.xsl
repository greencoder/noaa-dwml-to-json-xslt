<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

	<!-- Function to generate the time periods -->
	<xsl:template name="generate-periods">
		<xsl:param name="layout-key" />
		<xsl:param name="duration" />
		<xsl:param name="position" />
		<xsl:param name="quote-values" select="false" />
		{
			"start-time": "<xsl:value-of select="//layout-key[text()=$layout-key]/../start-valid-time[position()=$position]" />",
			"duration-hours": <xsl:value-of select="$duration" />,
			"value": 
				<xsl:if test="current()/@xsi:nil='true'">null</xsl:if>
				<xsl:if test="not(current()/@xsi:nil='true')">
					<xsl:if test="$quote-values=1">"</xsl:if><xsl:value-of select="current()" /><xsl:if test="$quote-values=1">"</xsl:if>
				</xsl:if>
		}		
	</xsl:template>
	
	<!-- Function to get number of hours from a time layout key -->
	<xsl:template name="find-period-duration">
		<xsl:param name="layout-key" />
		<xsl:if test="contains($layout-key, 'h-n')">
			<xsl:variable name="tmp" select="substring-after($layout-key, 'k-p')" />
			<xsl:variable name="hours" select="substring-before($tmp, 'h-n')" />
			<xsl:value-of select="$hours" />
		</xsl:if>
		<xsl:if test="contains($layout-key, 'd-n')">
			<xsl:variable name="tmp" select="substring-after($layout-key, 'k-p')" />
			<xsl:variable name="days" select="substring-before($tmp, 'd-n')" />
			<xsl:value-of select="$days*24" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="/dwml">
		<xsl:if test="@version != '1.0'">
			{ "error": "Unrecognized DWML version" }
		</xsl:if>
		<xsl:if test="@version = '1.0'">
			{
				"head": {
					<xsl:apply-templates select="head" />
				},
				"data": {
					<xsl:apply-templates select="data" />
				}
			}
		</xsl:if>
	</xsl:template>
   
	<!-- dwml/head -->
	<xsl:template match="head">
		"title": "<xsl:value-of select="product/title" />",
		"creation-date": "<xsl:value-of select="product/creation-date" />",
		"credit": "<xsl:value-of select="source/credit" />",
		"credit-logo": "<xsl:value-of select="source/credit-logo" />",
		"title": "<xsl:value-of select="product/title" />",
		"disclaimer": "<xsl:value-of select="source/disclaimer" />",
		"feedback": "<xsl:value-of select="source/feedback" />"
	</xsl:template>
   
	<!-- dwml/data -->
    <xsl:template match="data">
		"location": {
			"latitude": <xsl:value-of select="location/point/@latitude" />,
			"longitude": <xsl:value-of select="location/point/@longitude" />
		},
		"more-information": "<xsl:value-of select="moreWeatherInformation" />",
		"parameters": {
			"temperature": {
				<xsl:for-each select="parameters/temperature">
					<xsl:call-template name="temperature" /><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			},
			"probability-of-precipitation": {
				<xsl:apply-templates select="parameters/probability-of-precipitation" />
			},
			"precipitation": {
				<xsl:for-each select="parameters/precipitation">
					<xsl:call-template name="precipitation" /><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			},
			"wind": {
				<xsl:for-each select="parameters/wind-speed">
					<xsl:call-template name="wind-speed" /><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			},
			"cloud-amount": {
				<xsl:apply-templates select="parameters/cloud-amount" />
			},
			"humidity": {
				<xsl:apply-templates select="parameters/humidity" />
			},
			"conditions": {
				<xsl:apply-templates select="parameters/weather" />
			},
			"condition-icons": {
				<xsl:apply-templates select="parameters/conditions-icon" />
			}
		}
    </xsl:template>

	<!-- conditions icons -->
	<xsl:template match="conditions-icon">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"name": "<xsl:value-of select="name" />",
		"periods": [
			<xsl:for-each select="icon-link">
				<xsl:call-template name="generate-periods">
					<xsl:with-param name="layout-key" select="$tl-key" />
					<xsl:with-param name="position" select="position()" />
					<xsl:with-param name="duration" select="$duration" />
					<xsl:with-param name="quote-values" select="1" />
				</xsl:call-template><xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		]
	</xsl:template>	

	<!-- humidity -->
	<xsl:template match="humidity">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"name": "<xsl:value-of select="name" />",
		"units": "<xsl:value-of select="@units" />",
		"periods": [
			<xsl:for-each select="value">
				<xsl:call-template name="generate-periods">
					<xsl:with-param name="layout-key" select="$tl-key" />
					<xsl:with-param name="position" select="position()" />
					<xsl:with-param name="duration" select="$duration" />
				</xsl:call-template><xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		]
	</xsl:template>

	<!-- cloud-amount -->
	<xsl:template match="cloud-amount">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"name": "<xsl:value-of select="name" />",
		"units": "<xsl:value-of select="@units" />",
		"periods": [
			<xsl:for-each select="value">
				<xsl:call-template name="generate-periods">
					<xsl:with-param name="layout-key" select="$tl-key" />
					<xsl:with-param name="position" select="position()" />
					<xsl:with-param name="duration" select="$duration" />
				</xsl:call-template><xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		]
	</xsl:template>
	
	<!-- wind-speed (multiple types) -->
	<xsl:template name="wind-speed">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"<xsl:value-of select="@type" />": {
			"name": "<xsl:value-of select="name" />",
			"units": "<xsl:value-of select="@units" />",
			"periods": [
				<xsl:for-each select="value">
					<xsl:call-template name="generate-periods">
						<xsl:with-param name="layout-key" select="$tl-key" />
						<xsl:with-param name="position" select="position()" />
						<xsl:with-param name="duration" select="$duration" />
					</xsl:call-template><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			]
		}
	</xsl:template>
	
	<!-- weather conditions -->
	<xsl:template match="weather">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"name": "<xsl:value-of select="name" />",
		"periods": [
			<xsl:for-each select="weather-conditions">
				<xsl:variable name="pos" select="position()" />
				{
					"start-time": "<xsl:value-of select="//layout-key[text()=$tl-key]/../start-valid-time[position()=$pos]" />",
					"duration-hours": <xsl:value-of select="$duration" />,
					"coverage": "<xsl:value-of select="value/@coverage" />",
					"intensity": "<xsl:value-of select="value/@intensity" />",
					"type": "<xsl:value-of select="value/@weather-type" />",
					"qualifier": "<xsl:value-of select="value/@qualifier" />",
					"visibility": "<xsl:value-of select="value/visibility" />"
				}<xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		]
	</xsl:template>
	
	<!-- temperatures (multiple types) -->
	<xsl:template name="temperature">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>		
		"<xsl:value-of select="@type" />": {
			"name": "<xsl:value-of select="name" />",
			"units": "<xsl:value-of select="@units" />",
			"periods": [
				<xsl:for-each select="value">
					<xsl:call-template name="generate-periods">
						<xsl:with-param name="layout-key" select="$tl-key" />
						<xsl:with-param name="position" select="position()" />
						<xsl:with-param name="duration" select="$duration" />
					</xsl:call-template>
					<xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			]
		}
	</xsl:template>
	
	<!-- probability-of-precipitation -->
	<xsl:template match="probability-of-precipitation">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"name": "<xsl:value-of select="name" />",
		"units": "<xsl:value-of select="@units" />",
		"periods": [
		<xsl:for-each select="value">
			<xsl:call-template name="generate-periods">
				<xsl:with-param name="layout-key" select="$tl-key" />
				<xsl:with-param name="position" select="position()" />
				<xsl:with-param name="duration" select="$duration" />
			</xsl:call-template>
			<xsl:if test="position() != last()">, </xsl:if>
		</xsl:for-each>
		]
	</xsl:template>
	
	<!-- precipitation (multiple types) -->
	<xsl:template name="precipitation">
		<xsl:variable name="tl-key" select="@time-layout" />
		<xsl:variable name="duration">
			<xsl:call-template name="find-period-duration">
				<xsl:with-param name="layout-key" select="$tl-key" />
			</xsl:call-template>
		</xsl:variable>
		"<xsl:value-of select="@type" />": {
			"name": "<xsl:value-of select="name" />",
			"units": "<xsl:value-of select="@units" />",
			"periods": [
			<xsl:for-each select="value">
				<xsl:call-template name="generate-periods">
					<xsl:with-param name="layout-key" select="$tl-key" />
					<xsl:with-param name="position" select="position()" />
					<xsl:with-param name="duration" select="$duration" />
				</xsl:call-template>
				<xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
			]
		}
	</xsl:template>
	
</xsl:stylesheet>