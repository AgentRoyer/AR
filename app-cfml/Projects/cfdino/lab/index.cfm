<cfoutput>
   <cfinclude template="../app/i18n/i18nHelper.cfm">
   <cfset messages = getMessages(session.lang)>
   <cfset fallbackMessages = getMessages("en")>

   <cfinclude template="header.cfm">

   <cfinclude template="projects.cfm">

   <cfinclude template="footer.cfm">
</cfoutput>