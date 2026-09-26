<!---
    emptypics.cfm - /lab/dd/
    Purges the uploaded pictures folder (/lab/dd/dinopics/).
    Included from /lab/dd/index.cfm on page load. Returns nothing.
    /!\ No <cfcontent reset="true"> here: it would discard the including
    page's already-buffered output (header, styles...). <cfsilent> is the
    safe way to guarantee zero output from an included template.
--->
<cfsilent>
    <cfset picturesDirectory = expandPath("/lab/dd/dinopics/")>
    <cfset deletedCount = 0>

    <cfloop array="#directoryList(picturesDirectory, false, "path")#" index="filePath">
        <cfif reFindNoCase("\.(jpg|jpeg|png|webp)$", filePath)>
            <cfset fileDelete(filePath)>
            <cfset deletedCount++>
        </cfif>
    </cfloop>
</cfsilent>
