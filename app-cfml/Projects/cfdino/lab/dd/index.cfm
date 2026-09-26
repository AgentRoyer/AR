<cfinclude template="../../app/i18n/i18nHelper.cfm">
<cfset ddMessages = getMessages(session.lang, "lab-dd")>
<cfset ddFallbackMessages = getMessages("en", "lab-dd")>

<cfoutput>
<cfinclude template="header.cfm">

<!--- Purge leftover uploaded pictures from previous sessions (emptypics.cfm returns nothing) --->
<cfinclude template="emptypics.cfm">

<!--- Fresh page load = fresh state: clear specimen, AI conversation and visible bubbles --->
<cfset session.dinoActuel = structNew()>
<cfset session.dinoAiState = "">
<cfset session.dinoHistorique = arrayNew(1)>

<cfset hasDinoContext = structKeyExists(session.dinoActuel, "espece") AND len(trim(session.dinoActuel.espece))>
<cfif hasDinoContext>
    <cfset contexteBadge = session.dinoActuel.espece>
    <cfset contextePlaceholder = replace(t("page.ask_about", ddMessages, ddFallbackMessages), "{species}", session.dinoActuel.espece)>
<cfelse>
    <cfset contexteBadge = t("page.awaiting", ddMessages, ddFallbackMessages)>
    <cfset contextePlaceholder = t("page.ask_anything", ddMessages, ddFallbackMessages)>
</cfif>

<!--- HTMX is not loaded in header.cfm, so it is included here. --->
<!--- Remove this line if HTMX is later loaded globally in header.cfm. --->
<script src="https://unpkg.com/htmx.org@2.0.4"></script>

<div class="max-w-3xl mx-auto px-4 pt-24 pb-10">

    <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-primary">Dino Detective</h1>
        <p class="text-gray-500 mt-2">#encodeForHtml(t("page.intro", ddMessages, ddFallbackMessages))#</p>
    </div>

    <!-- Section 1: upload and identification -->
    <div class="bg-white rounded-2xl shadow p-6 mb-8 border border-gray-100">
        <form hx-post="#application.root#/lab/dd/endpoints/dino_identifier.cfm"
              hx-target="##zone-resultat"
              hx-swap="innerHTML"
              hx-encoding="multipart/form-data"
              hx-indicator="##spinner-identif"
              class="flex flex-col sm:flex-row gap-3 items-center">

            <div class="flex items-center gap-3 w-full">
                <label for="image-input"
                       class="cursor-pointer whitespace-nowrap py-2 px-4 rounded-full bg-blue-50 text-primary text-sm hover:bg-blue-100 transition">
                    #encodeForHtml(t("page.choose_file", ddMessages, ddFallbackMessages))#
                </label>
                <input type="file" name="image" id="image-input" accept="image/*" required
                       style="position:absolute; width:1px; height:1px; padding:0; margin:-1px; overflow:hidden; clip:rect(0,0,0,0); white-space:nowrap; border:0;"
                       onchange="document.getElementById('image-filename').textContent = this.files.length ? this.files[0].name : '#encodeForJavaScript(t("page.no_file_chosen", ddMessages, ddFallbackMessages))#';">
                <span id="image-filename" class="text-sm text-gray-600 truncate">#encodeForHtml(t("page.no_file_chosen", ddMessages, ddFallbackMessages))#</span>
            </div>

            <button type="submit"
                          class="whitespace-nowrap bg-primary text-white px-5 py-2 rounded-full
                              hover:bg-blue-700 transition">
                      #encodeForHtml(t("page.identify", ddMessages, ddFallbackMessages))#
            </button>
        </form>

        <div id="spinner-identif" class="htmx-indicator mt-4 text-sm text-gray-400 flex items-center gap-2">
            <svg class="animate-spin h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
            </svg>
            #encodeForHtml(t("page.examining", ddMessages, ddFallbackMessages))#
        </div>

        <div id="zone-resultat" class="mt-4">
            <!-- The identified dinosaur profile is displayed here -->
        </div>
    </div>

    <!-- Section 2: contextual chat -->
    <div class="bg-white rounded-2xl shadow p-6 border border-gray-100">
        <div class="flex items-center justify-between mb-3">
            <h2 class="text-lg font-semibold text-gray-700">#encodeForHtml(t("page.chat_title", ddMessages, ddFallbackMessages))#</h2>
            <span id="contexte-badge" class="text-xs bg-blue-50 text-primary px-2 py-1 rounded-full">#encodeForHtml(t("page.context", ddMessages, ddFallbackMessages))# : #encodeForHtml(contexteBadge)#</span>
        </div>

        <div id="zone-chat" class="space-y-3 mb-4 max-h-80 overflow-y-auto">
            <cfloop array="#session.dinoHistorique#" index="msg">
                <cfif msg.role EQ "user">
                    <div class="text-right">
                        <span class="inline-block bg-primary text-white rounded-2xl rounded-br-sm px-4 py-2 max-w-[80%]">
                            #encodeForHtml(msg.texte)#
                        </span>
                    </div>
                <cfelse>
                    <div class="text-left">
                        <span class="inline-block bg-gray-100 text-gray-800 rounded-2xl rounded-bl-sm px-4 py-2 max-w-[80%]">
                            #encodeForHtml(msg.texte)#
                        </span>
                    </div>
                </cfif>
            </cfloop>
        </div>

        <form hx-post="#application.root#/lab/dd/endpoints/dino_chat.cfm"
              hx-target="##zone-chat"
              hx-swap="beforeend"
              hx-indicator="##spinner-chat"
              hx-on::after-request="this.reset()"
              class="flex gap-2">

            <input type="text" name="message" id="chat-message" placeholder="#encodeForHtmlAttribute(contextePlaceholder)#"
                   required autocomplete="off"
                   class="flex-1 border border-gray-200 rounded-full px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">

            <button type="submit"
                    class="bg-gray-800 text-white px-5 py-2 rounded-full hover:bg-gray-900 transition">
                #encodeForHtml(t("page.send", ddMessages, ddFallbackMessages))#
            </button>
        </form>

        <div id="spinner-chat" class="htmx-indicator mt-2 text-sm text-gray-400">#encodeForHtml(t("page.thinking", ddMessages, ddFallbackMessages))#</div>
    </div>

</div>

<cfinclude template="../footer.cfm">
</cfoutput>
