<cfoutput>
<!DOCTYPE html>
<html lang="#encodeForHtmlAttribute(session.lang)#">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>#encodeForHtml(t("metadata.title", ddMessages, ddFallbackMessages))#</title>
    <link rel="stylesheet" href="#application.root#/css/tailwind.css">
    <style>
        .language-switch-link {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            border-radius: 0.5rem;
            border-color: transparent;
            transition: border-color 150ms ease, color 150ms ease, opacity 150ms ease, transform 150ms ease;
        }
        .language-switch-link:hover {
            opacity: 1;
            transform: scale(1.03);
        }
        .language-switch-link.is-active {
            border-color: ##2563eb;
        }
    </style>
</head>
<body class="font-sans antialiased">
    <nav class="fixed w-full bg-white shadow-sm z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
            <div class="flex flex-wrap justify-between items-center gap-3">
                <a href="#application.root#/?lang=#encodeForUrl(session.lang)#" class="flex items-center space-x-2">
                    <img src="#application.root#/img/CFdino.png" alt="CFdino logo" class="w-12 h-12 rounded-full object-cover">
                    <span class="text-xl font-bold text-primary">#encodeForHtml(t("header.lab", ddMessages, ddFallbackMessages))#</span>
                </a>
                <div class="flex flex-wrap items-center gap-3 text-sm">
                    <a href="#application.root#/lab/dd/index.cfm?lang=#encodeForUrl(session.lang)#" class="text-gray-700 hover:text-primary transition">#encodeForHtml(t("header.dino_detective", ddMessages, ddFallbackMessages))#</a>
                    <a href="#application.root#/?lang=#encodeForUrl(session.lang)#" class="text-gray-700 hover:text-primary transition">#encodeForHtml(t("header.back_to_site", ddMessages, ddFallbackMessages))#</a>
                    <div class="flex gap-1 items-center" role="group" aria-label="#encodeForHtmlAttribute(t("language.switcher_label", ddMessages, ddFallbackMessages))#">
                        <a href="#application.root#/lab/dd/index.cfm?lang=en" title="English" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "en">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/en.png" alt="English" class="w-6 h-6">#encodeForHtml(t("language.english", ddMessages, ddFallbackMessages))#</a>
                        <a href="#application.root#/lab/dd/index.cfm?lang=fr" title="Français" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "fr">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/fr.png" alt="Français" class="w-6 h-6">#encodeForHtml(t("language.french", ddMessages, ddFallbackMessages))#</a>
                    </div>
                </div>
            </div>
        </div>
    </nav>
</cfoutput>