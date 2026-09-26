<!--- COLDFINA — même interface que RUSTINA / PYTHONA / GONA (page commune dans templates/index.html) --->
<cfcontent type="text/html; charset=utf-8" reset="true"><cfoutput>#replace(fileRead(expandPath("templates/index.html"), "utf-8"), "__TIMESTAMP__", dateTimeFormat(now(), "dd/mm/yyyy HH:nn"))#</cfoutput>
