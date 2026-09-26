<!---
    dino_identifier.cfm - /lab/dd/endpoints/
    Receives an image upload through HTMX, calls the agent, and returns an HTML fragment.
--->
<cfsetting enablecfoutputonly="true">
<cfinclude template="../../../app/i18n/i18nHelper.cfm">
<cfset ddMessages = getMessages(session.lang, "lab-dd")>
<cfset ddFallbackMessages = getMessages("en", "lab-dd")>

<cfif NOT isDefined("form.image") OR len(form.image) EQ 0>
    <cfoutput>
        <div class="text-red-600 text-sm">#encodeForHtml(t("page.no_image", ddMessages, ddFallbackMessages))#</div>
    </cfoutput>
    <cfabort>
</cfif>

<cftry>
    <cffile action="upload"
            filefield="image"
            destination="#expandPath('/lab/dd/dinopics/')#"
            nameconflict="makeunique"
            mode="644"
            result="uploadResult"
            accept="image/jpeg,image/png,image/webp">

    <cfset cheminImage = uploadResult.serverDirectory & "/" & uploadResult.serverFile>

    <!--- AI engine selected by this.CurrentVisionAgent in Application.cfc (identification requires vision support) --->
    <cfset agent = new lab.dd.components.DinoAgent(connexion = application.dinoDetectiveVisionConnection)>
    <cfset resultat = agent.identifierImage(cheminImage, session.lang)>

    <!--- <cffile action="delete" file="#cheminImage#"> --->

    <cfif resultat.succes>
        <cfset session.dinoActuel = resultat>
        <!--- New specimen: reset the conversation (AI state + visible bubbles) --->
        <cfset session.dinoAiState = "">
        <cfset session.dinoHistorique = arrayNew(1)>

        <cfoutput>
            <!--- Out-of-band swaps: update the chat context badge + placeholder in the same response --->
            <span id="contexte-badge" hx-swap-oob="true" class="text-xs bg-blue-50 text-primary px-2 py-1 rounded-full">#encodeForHtml(t("page.context", ddMessages, ddFallbackMessages))# : #encodeForHtml(resultat.espece)#</span>
            <cfset placeholderChat = replace(t("page.ask_about", ddMessages, ddFallbackMessages), "{species}", resultat.espece)>
            <input type="text" name="message" id="chat-message" hx-swap-oob="true" placeholder="#encodeForHtmlAttribute(placeholderChat)#" required autocomplete="off" class="flex-1 border border-gray-200 rounded-full px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
            <!--- Clear the visible conversation (a new specimen resets the chat) --->
            <div id="zone-chat" hx-swap-oob="true" class="space-y-3 mb-4 max-h-80 overflow-y-auto"></div>

            <div class="border border-blue-200 bg-blue-50 rounded-xl p-5">
                <img src="#application.root#/lab/dd/endpoints/image.cfm?file=#encodeForUrl(uploadResult.serverFile)#"
                     alt="#encodeForHtmlAttribute(t("page.uploaded_image", ddMessages, ddFallbackMessages))#"
                     class="w-full max-h-64 object-contain rounded-lg mb-4 bg-white">

                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-xl font-bold text-primary">#encodeForHtml(resultat.espece)#</h3>
                    <cfswitch expression="#resultat.confiance#">
                        <cfcase value="haute">
                            <span class="text-xs bg-primary text-white px-2 py-1 rounded-full">#encodeForHtml(t("page.high_confidence", ddMessages, ddFallbackMessages))#</span>
                        </cfcase>
                        <cfcase value="moyenne">
                            <span class="text-xs bg-amber-500 text-white px-2 py-1 rounded-full">#encodeForHtml(t("page.medium_confidence", ddMessages, ddFallbackMessages))#</span>
                        </cfcase>
                        <cfdefaultcase>
                            <span class="text-xs bg-gray-400 text-white px-2 py-1 rounded-full">#encodeForHtml(t("page.low_confidence", ddMessages, ddFallbackMessages))#</span>
                        </cfdefaultcase>
                    </cfswitch>
                </div>

                <dl class="text-sm text-gray-700 grid grid-cols-2 gap-y-1">
                    <cfif structKeyExists(resultat, "periode")>
                        <dt class="font-medium">#encodeForHtml(t("page.period", ddMessages, ddFallbackMessages))#</dt><dd>#encodeForHtml(resultat.periode)#</dd>
                    </cfif>
                    <cfif structKeyExists(resultat, "regime_alimentaire")>
                        <dt class="font-medium">#encodeForHtml(t("page.diet", ddMessages, ddFallbackMessages))#</dt><dd>#encodeForHtml(resultat.regime_alimentaire)#</dd>
                    </cfif>
                    <cfif structKeyExists(resultat, "taille_estimee")>
                        <dt class="font-medium">#encodeForHtml(t("page.estimated_size", ddMessages, ddFallbackMessages))#</dt><dd>#encodeForHtml(resultat.taille_estimee)#</dd>
                    </cfif>
                </dl>

                <cfif structKeyExists(resultat, "anecdote") AND len(resultat.anecdote)>
                    <p class="text-sm text-gray-600 mt-3 italic">#encodeForHtml(t("page.fun_fact_prefix", ddMessages, ddFallbackMessages))#: #encodeForHtml(resultat.anecdote)#</p>
                </cfif>

                <p class="text-xs text-gray-400 mt-3">#encodeForHtml(t("page.ask_below", ddMessages, ddFallbackMessages))#</p>
            </div>
        </cfoutput>
    <cfelse>
        <!--- Identification failed: drop the current context so the chat goes back to "awaiting" --->
        <cfset session.dinoActuel = structNew()>
        <cfset session.dinoAiState = "">
        <cfset session.dinoHistorique = arrayNew(1)>

        <cfoutput>
            <span id="contexte-badge" hx-swap-oob="true" class="text-xs bg-blue-50 text-primary px-2 py-1 rounded-full">#encodeForHtml(t("page.context", ddMessages, ddFallbackMessages))# : #encodeForHtml(t("page.awaiting", ddMessages, ddFallbackMessages))#</span>
            <input type="text" name="message" id="chat-message" hx-swap-oob="true" placeholder="#encodeForHtmlAttribute(t("page.ask_anything", ddMessages, ddFallbackMessages))#" required autocomplete="off" class="flex-1 border border-gray-200 rounded-full px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
            <div id="zone-chat" hx-swap-oob="true" class="space-y-3 mb-4 max-h-80 overflow-y-auto"></div>

            <div class="text-red-600 text-sm">#encodeForHtml(t("page.unexpected_error", ddMessages, ddFallbackMessages))#</div>
        </cfoutput>
    </cfif>

    <cfcatch type="any">
        <cfoutput>
            <div class="text-red-600 text-sm">#encodeForHtml(t("page.unexpected_error", ddMessages, ddFallbackMessages))#</div>
        </cfoutput>
    </cfcatch>
</cftry>
