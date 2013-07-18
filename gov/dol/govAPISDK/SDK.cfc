<!--- Created by the U.S. Department of Labor --->
<!--- Released to the Public Domain --->
<cfcomponent displayname="federalAPISDK" hint="Federal-wide API SDK">
	<cfscript>
		THIS.API_URL = "";
		THIS.API_HOST = "";
		THIS.API_KEY = "";
		THIS.argumentString = "";
	</cfscript>
	
	
	
	<cffunction name="submitRequest" access="public">
		<cfargument name="API_METHOD" type="string" required="true" />
		<cfargument name="API_ARGUMENTS" type="struct" required="false" />
		<!--- address arguments in agency api-specfic manners --->
		<!--- first-up: DOL --->
		<cfif THIS.API_HOST eq "http://api.dol.gov">
			<cfset THIS.argumentString = "?KEY=#THIS.API_KEY#">
			<cfif isdefined("arguments.API_ARGUMENTS")>
				<!--- if valid arguments are used, add them to the arguments string --->
				<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
					<cfif (#cmd# eq "top") OR (#cmd# eq "skip") OR (#cmd# eq "select") OR (#cmd# eq "orderby") OR (#cmd# eq "filter") OR (#cmd# eq "format") OR (#cmd# eq "query") OR (#cmd# eq "region") OR (#cmd# eq "locality") OR (#cmd# eq "skipcount")>
					<cfset THIS.argumentString = "#THIS.argumentString#&$#LCase(cmd)#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
					</cfif> 
				</cfloop>
			</cfif>
		<cfelseif (THIS.API_HOST eq "http://api.census.gov") OR (THIS.API_HOST eq "http://pillbox.nlm.nih.gov")>
			<!--- 
			CENSUS.GOV
			NIH Pillbox
			--->
			<cfset THIS.argumentString = "?key=#THIS.API_KEY#">
			<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
				<cfset THIS.argumentString = "#THIS.argumentString#&#cmd#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
			</cfloop>	
		<cfelseif (THIS.API_HOST eq "http://api.eia.gov") OR (THIS.API_HOST eq "http://developer.nrel.gov") OR (THIS.API_HOST eq "http://api.stlouisfed.org") OR (THIS.API_HOST eq "http://healthfinder.gov")>
			<!--- 
			Energy EIA API (beta)
			Energy NREL
			St. Louis Fed
			NIH Healthfinder
			--->
			<cfset THIS.argumentString = "?api_key=#THIS.API_KEY#">
			<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
				<cfset THIS.argumentString = "#THIS.argumentString#&#cmd#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
			</cfloop>	
		<cfelseif (THIS.API_HOST eq "http://www.ncdc.noaa.gov")>
			<!--- 
			NOAA National Climatic Data Center
			--->
			<cfset THIS.argumentString = "?token=#THIS.API_KEY#">
			<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
				<cfset THIS.argumentString = "#THIS.argumentString#&#cmd#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
			</cfloop>	
		<cfelseif (THIS.API_HOST eq "https://go.usa.gov")>
			<!--- 
			USA.gov URL Shortener
			--->
			<cfset THIS.argumentString = "?apiKey=#THIS.API_KEY#">
			<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
				<cfset THIS.argumentString = "#THIS.argumentString#&#cmd#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
			</cfloop>	
		<cfelse>
			<cfloop collection=#arguments.API_ARGUMENTS# item="cmd">
				<cfset THIS.argumentString = "#THIS.argumentString#&#cmd#=#URLEncodedFormat(arguments.API_ARGUMENTS[cmd])#">
			</cfloop>	
		</cfif>
		<!--- create the URL for the cfhttp request --->
		<cfset requestURL = "#THIS.API_HOST#" & "#THIS.API_URL#" & "/#API_METHOD#" & "#THIS.argumentString#">
		<cfhttp url="#requestURL#" result="resultData">
			<cfif THIS.API_HOST eq "http://api.dol.gov">
				<cfhttpparam type="header" name="Accept" value="application/json">
			</cfif>
		</cfhttp>
		<!--- determine the mime type of the response and deserialize if JSON --->
		<cfif resultData.mimeType eq "application/json">
			<cfreturn DeserializeJSON(resultData.Filecontent)>
		<cfelse>
			<cfreturn resultData>
		</cfif>
</cffunction>
</cfcomponent>