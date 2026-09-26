<cfparam name="url.file" default="">

<cfset fileName = trim(url.file)>

<cfif NOT reFindNoCase("^[A-Za-z0-9_-]+\.(jpg|jpeg|png|webp)$", fileName)>
    <cfheader statuscode="404" statustext="Not Found">
    <cfabort>
</cfif>

<cfset filePath = expandPath("/lab/dd/dinopics/#fileName#")>

<cfif NOT fileExists(filePath)>
    <cfheader statuscode="404" statustext="Not Found">
    <cfabort>
</cfif>

<cfset extension = lCase(listLast(fileName, "."))>
<cfset mediaTypes = {
    "jpg" = "image/jpeg",
    "jpeg" = "image/jpeg",
    "png" = "image/png",
    "webp" = "image/webp"
}>

<cfcontent type="#mediaTypes[extension]#" file="#filePath#">