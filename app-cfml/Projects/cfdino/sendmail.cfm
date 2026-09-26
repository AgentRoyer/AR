<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfheader name="Content-Type" value="application/json; charset=utf-8">
<cfinclude template="app/i18n/i18nHelper.cfm">
<cfset messages = getMessages(session.lang)>
<cfset fallbackMessages = getMessages("en")>

<cftry>
    <cfset rawBody = toString(getHttpRequestData().content)>
    <cfset requestData = deserializeJSON(rawBody)>
    <cfcatch type="any">
        <cfset requestData = structNew()>
    </cfcatch>
</cftry>

<cfparam name="requestData.email" default="">
<cfparam name="requestData.message" default="">

<cfset emailValue = trim(requestData.email)>
<cfset messageValue = trim(requestData.message)>
<cfset errors = structNew()>

<cfif emailValue eq "" or not isValid("email", emailValue)>
    <cfset errors.email = t("contact.email_error", messages, fallbackMessages)>
</cfif>

<cfif messageValue eq "" or len(messageValue) lt 50>
    <cfset errors.message = t("contact.message_error", messages, fallbackMessages)>
</cfif>

<cfset success = structIsEmpty(errors)>

<cfif success>
   <cfmail
    to="jcroyer@gmail.com"
    from="site@cfdino.com"
    replyto="#emailValue#"
    subject="CFdino.com - message de #emailValue#"
    type="text">
    #messageValue#
    </cfmail>
</cfif>

<cfset jsonErrors = []>
<cfif structKeyExists(errors, "email")>
    <cfset arrayAppend(jsonErrors, '"email":' & serializeJSON(errors.email))>
</cfif>
<cfif structKeyExists(errors, "message")>
    <cfset arrayAppend(jsonErrors, '"message":' & serializeJSON(errors.message))>
</cfif>
<cfset jsonOutput = '{"success":' & (success ? "true" : "false") & ',"errors":{' & arrayToList(jsonErrors, ",") & '}}'>

<cfoutput>#jsonOutput#</cfoutput>
