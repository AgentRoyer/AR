<!---
    dino_chat.cfm - /lab/dd/endpoints/
    Receives a user message through HTMX, calls the agent, and returns the two new message bubbles.

    Two separate session values:
    - session.dinoHistorique: display history (UI bubbles), managed here
    - session.dinoAiState: serialized Lucee AI session state (the actual history
                           understood by the model), opaque and managed by DinoAgent.cfc
--->
<cfsetting enablecfoutputonly="true">
<cfinclude template="../../../app/i18n/i18nHelper.cfm">
<cfset ddMessages = getMessages(session.lang, "lab-dd")>
<cfset ddFallbackMessages = getMessages("en", "lab-dd")>

<cfparam name="form.message" default="">
<cfparam name="session.dinoHistorique" default="#arrayNew(1)#">
<cfparam name="session.dinoActuel" default="#structNew()#">
<cfparam name="session.dinoAiState" default="">

<cfif len(trim(form.message)) EQ 0>
    <cfabort>
</cfif>

<cftry>
    <!--- AI engine selected by this.CurrentAgent in Application.cfc (no hard-coded name here) --->
    <cfset agent = new lab.dd.components.DinoAgent()>
    <cfset reponse = agent.discuter(
        message = trim(form.message),
        serializedState = session.dinoAiState,
        dinoActuel = session.dinoActuel,
        lang = session.lang
    )>

    <!--- Update the AI session state for the next message --->
    <cfset session.dinoAiState = reponse.serializedState>

    <!--- Display history (bubbles), independent of the AI state --->
    <cfset arrayAppend(session.dinoHistorique, {role: "user", texte: trim(form.message)})>
    <cfset arrayAppend(session.dinoHistorique, {role: "assistant", texte: reponse.texte})>

    <cfif arrayLen(session.dinoHistorique) GT 20>
        <cfset session.dinoHistorique = arraySlice(session.dinoHistorique, arrayLen(session.dinoHistorique) - 20 + 1, 20)>
    </cfif>

    <cfoutput>
        <div class="text-right">
            <span class="inline-block bg-primary text-white rounded-2xl rounded-br-sm px-4 py-2 max-w-[80%]">
                #encodeForHtml(trim(form.message))#
            </span>
        </div>
        <div class="text-left">
            <span class="inline-block #reponse.succes ? 'bg-gray-100 text-gray-800' : 'bg-red-50 text-red-600'# rounded-2xl rounded-bl-sm px-4 py-2 max-w-[80%]">
                #encodeForHtml(reponse.succes ? reponse.texte : t("page.agent_error", ddMessages, ddFallbackMessages))#
            </span>
        </div>
    </cfoutput>

    <cfcatch type="any">
        <cfoutput>
            <div class="text-left">
                <span class="inline-block bg-red-50 text-red-600 rounded-2xl rounded-bl-sm px-4 py-2">
                    #encodeForHtml(t("page.agent_error", ddMessages, ddFallbackMessages))#
                </span>
            </div>
        </cfoutput>
    </cfcatch>
</cftry>
