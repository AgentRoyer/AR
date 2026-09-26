<cfinclude template="app/i18n/i18nHelper.cfm">
<cfset messages = getMessages(session.lang)>
<cfset fallbackMessages = getMessages("en")>

<!DOCTYPE html>
<cfoutput>
<html lang="#encodeForHtmlAttribute(session.lang)#">
<head>
    <meta charset="UTF-8">
    <title><cfif application.env EQ "dev">DEV&nbsp;</cfif>#encodeForHtml(t("metadata.title", messages, fallbackMessages))#</title>
    <cfif application.env EQ "prod">
    <meta name="robots" content="index, follow">
    <cfelse>
    <meta name="robots" content="noindex, nofollow">
    </cfif>
    <meta name="description" content="#encodeForHtmlAttribute(t("metadata.description", messages, fallbackMessages))#">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="#application.root#/css/tailwind.css">
    <link rel="apple-touch-icon" sizes="180x180" href="#application.root#/favicon/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="#application.root#/favicon/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="#application.root#/favicon/favicon-16x16.png">
    <link rel="manifest" href="#application.root#/favicon/site.webmanifest">
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
    <cfif application.env EQ "prod">
    <cfinclude template="analytics.cfm" />
    </cfif>
</head>
<body class="font-sans antialiased">

    <!-- Navigation -->
    <nav class="fixed w-full bg-white shadow-sm z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-28">
                <div class="flex items-center space-x-4 my-4">
                    <a href="#application.root#" class="flex items-center space-x-2">
                        <img src="#application.root#/img/CFdino.png" alt="CFdino logo" class="w-[80px] h-[80px] rounded-full object-cover">
                        <span class="text-2xl font-bold text-primary">CFdino</span>
                    </a>
                </div>
                <div class="hidden md:flex items-center space-x-8 text-lg">
                    <a href="##services" class="text-gray-700 hover:text-primary transition">#encodeForHtml(t("nav.services", messages, fallbackMessages))#</a>
                    <a href="##expertise" class="text-gray-700 hover:text-primary transition">#encodeForHtml(t("nav.expertise", messages, fallbackMessages))#</a>
                    <!---<a href="##work" class="text-gray-700 hover:text-primary transition">Work</a>--->
                    <a href="#application.root#/lab/index.cfm" class="text-gray-700 hover:text-primary transition" target="_blank" rel="noopener noreferrer">#encodeForHtml(t("nav.lab", messages, fallbackMessages))#</a>
                    <a href="##about" class="text-gray-700 hover:text-primary transition">#encodeForHtml(t("nav.about", messages, fallbackMessages))#</a>
                    <a href="##contact" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">#encodeForHtml(t("nav.contact", messages, fallbackMessages))#</a>
                    <div class="flex gap-1 items-center" role="group" aria-label="#encodeForHtmlAttribute(t("language.switcher_label", messages, fallbackMessages))#">
                        <a href="#application.root#/?lang=en" title="English" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "en">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/en.png" alt="English" class="w-6 h-6">#encodeForHtml(t("language.english", messages, fallbackMessages))#</a>
                        <a href="#application.root#/?lang=fr" title="Français" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "fr">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/fr.png" alt="Français" class="w-6 h-6">#encodeForHtml(t("language.french", messages, fallbackMessages))#</a>
                    </div>
                </div>
                <div class="md:hidden">
                    <button id="mobile-menu-btn" class="text-gray-700">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
        <!-- Mobile Menu -->
        <div id="mobile-menu" class="hidden md:hidden bg-white border-t">
            <div class="px-4 py-3 space-y-3 text-lg">
                <a href="##services" class="block text-gray-700 hover:text-primary">#encodeForHtml(t("nav.services", messages, fallbackMessages))#</a>
                <a href="##expertise" class="block text-gray-700 hover:text-primary">#encodeForHtml(t("nav.expertise", messages, fallbackMessages))#</a>
                <!---<a href="##work" class="block text-gray-700 hover:text-primary">Work</a>--->
                <a href="#application.root#/lab/index.cfm" class="block text-gray-700 hover:text-primary" target="_blank" rel="noopener noreferrer">#encodeForHtml(t("nav.lab", messages, fallbackMessages))#</a>
                <a href="##about" class="block text-gray-700 hover:text-primary">#encodeForHtml(t("nav.about", messages, fallbackMessages))#</a>
                <a href="##contact" class="block bg-primary text-white px-6 py-2 rounded-lg text-center">#encodeForHtml(t("nav.contact", messages, fallbackMessages))#</a>
                <div class="flex gap-3 items-center justify-center pt-2" role="group" aria-label="#encodeForHtmlAttribute(t("language.switcher_label", messages, fallbackMessages))#">
                    <a href="#application.root#/?lang=en" title="English" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "en">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/en.png" alt="English" class="w-6 h-6">#encodeForHtml(t("language.english", messages, fallbackMessages))#</a>
                    <a href="#application.root#/?lang=fr" title="Français" class="language-switch-link inline-flex items-center gap-1 border-2 px-2 py-1 rounded text-sm transition <cfif session.lang EQ "fr">is-active font-bold text-gray-900<cfelse>text-gray-600 opacity-60</cfif>"><img src="#application.root#/img/flags/fr.png" alt="Français" class="w-6 h-6">#encodeForHtml(t("language.french", messages, fallbackMessages))#</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Banner Section -->
    <section style="width: 100%; padding-top: 7rem; padding-bottom: 1.5rem;">
        <div style="width: 100%; max-width: 1920px; margin: 0 auto; overflow: hidden;">
            <img src="#application.root#/img/CFdino-Full-Stack-CFML.jpg" alt="CFdino banner" style="display: block; width: 100%; max-width: 1920px; height: auto; margin: 0 auto;">
        </div>
    </section>

    <!-- Hero Section -->
    <section style="padding-top: 2.5rem; padding-bottom: 4rem; background: linear-gradient(135deg,##eff6ff 0%, ##ffffff 100%);">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div>
                    <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-pink leading-tight mb-6">
                        #encodeForHtml(t("hero.title", messages, fallbackMessages))#
                    </h1>
                    <p class="text-xl text-gray-600 mb-8">
                        #encodeForHtml(t("hero.subtitle", messages, fallbackMessages))#
                    </p>
                    <div class="flex flex-col sm:flex-row gap-4">
                        <a href="##contact" class="bg-primary text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-700 transition text-center">
                            #encodeForHtml(t("hero.contact", messages, fallbackMessages))#
                        </a>
                        <a href="##expertise" class="border-2 border-primary text-primary px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-50 transition text-center">
                            #encodeForHtml(t("hero.expertise", messages, fallbackMessages))#
                        </a>
                    </div>
                </div>
                <div class="hidden md:block">
                    <div class="bg-gradient-to-br from-primary to-blue-700 rounded-2xl p-8 text-white shadow-2xl">
                        <div class="space-y-6">
                            <div class="flex items-center space-x-4">
                                <div class="bg-white bg-opacity-20 p-3 rounded-lg">
                                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <div class="font-semibold">#encodeForHtml(t("hero.years", messages, fallbackMessages))#</div>
                                    <div class="text-sm text-blue-100">#encodeForHtml(t("hero.experience", messages, fallbackMessages))#</div>
                                </div>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="bg-white bg-opacity-20 p-3 rounded-lg">
                                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <div class="font-semibold">#encodeForHtml(t("hero.markets", messages, fallbackMessages))#</div>
                                    <div class="text-sm text-blue-100">#encodeForHtml(t("hero.remote", messages, fallbackMessages))#</div>
                                </div>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="bg-white bg-opacity-20 p-3 rounded-lg">
                                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <div class="font-semibold">#encodeForHtml(t("hero.delivery", messages, fallbackMessages))#</div>
                                    <div class="text-sm text-blue-100">#encodeForHtml(t("hero.quality", messages, fallbackMessages))#</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Services Section -->
    <section id="services" class="py-12 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <h2 class="text-4xl font-bold text-pink mb-4">#encodeForHtml(t("services.title", messages, fallbackMessages))#</h2>
                <p class="text-gray-600">#encodeForHtml(t("services.subtitle", messages, fallbackMessages))#</p>
            </div>
            <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">&lt;/&gt;</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.custom_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.custom_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">🔄</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.legacy_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.legacy_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">📄</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.api_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.api_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">⚙️</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.performance_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.performance_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">🌐</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.i18n_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.i18n_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">🎯</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.consulting_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.consulting_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">🛡️</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.audit_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.audit_description", messages, fallbackMessages))#</p>
                </article>
                <article class="bg-gray-50 p-8 rounded-lg shadow-sm hover:shadow-lg transition text-center">
                    <div class="text-5xl mb-6" aria-hidden="true">🔧</div>
                    <h3 class="text-lg font-bold mb-4">#encodeForHtml(t("services.support_title", messages, fallbackMessages))#</h3>
                    <p class="text-sm text-gray-700">#encodeForHtml(t("services.support_description", messages, fallbackMessages))#</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Expertise Section -->
    <section id="expertise" class="py-20 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16">
                <h2 class="text-4xl font-bold text-pink mb-4">#encodeForHtml(t("expertise.title", messages, fallbackMessages))#</h2>
                <p class="text-xl text-gray-600">#encodeForHtml(t("expertise.subtitle", messages, fallbackMessages))#</p>
            </div>
            <div class="flex flex-col md:flex-row gap-8">
                <div class="flex-1 bg-gradient-to-br from-primary to-blue-700 rounded-2xl p-6 text-white shadow-2xl">
                    <h3 class="text-2xl font-semibold mb-6">#encodeForHtml(t("expertise.core", messages, fallbackMessages))#</h3>
                    <div class="space-y-4">
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>Adobe ColdFusion (4.5 → 2025)</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>Lucee 7</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>REST / SOAP APIs</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>JSON / XML</span>
                        </div>
                    </div>
                </div>
                <div class="flex-1 bg-gradient-to-br from-primary to-blue-700 rounded-2xl p-6 text-white shadow-2xl">
                    <h3 class="text-2xl font-semibold mb-6">#encodeForHtml(t("expertise.databases", messages, fallbackMessages))#</h3>
                    <div class="space-y-4">
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>MariaDB</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>MySQL</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>MS SQL Server</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>PostgreSQL</span>
                        </div>
                    </div>
                </div>
                <div class="flex-1 bg-gradient-to-br from-primary to-blue-700 rounded-2xl p-6 text-white shadow-2xl">
                    <h3 class="text-2xl font-semibold mb-6">#encodeForHtml(t("expertise.devops", messages, fallbackMessages))#</h3>
                    <div class="space-y-4">
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>Git / GitHub</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>VS Code / Codespaces</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>Docker</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-2 h-2 bg-white rounded-full mr-3 shrink-0"></div>
                            <span>Linux / Nginx</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mt-12 bg-white p-8 rounded-xl shadow-sm">
                <h3 class="text-2xl font-semibold mb-4 text-gray-900">#encodeForHtml(t("expertise.frontend_title", messages, fallbackMessages))#</h3>
                <p class="text-gray-600 mb-4">#encodeForHtml(t("expertise.frontend_description", messages, fallbackMessages))#</p>
                <div class="flex flex-wrap items-center gap-3">
                    <span class="bg-gray-100 px-4 py-2 rounded-lg flex items-center"><img src="/img/htmx_logo.png" alt="HTMX" title="HTMX" class="h-6 w-auto"></span>
                    <span class="bg-gray-100 px-4 py-2 rounded-lg flex items-center"><img src="/img/tailwind_css_logo.png" alt="Tailwind CSS" title="Tailwind CSS"  class="h-6 w-auto"></span>
                    <span class="bg-gray-100 px-4 py-2 rounded-lg flex items-center"><img src="/img/jquery_logo.png" alt="jQuery" title="jQuery" class="h-6 w-auto"></span>
                    <span class="bg-gray-100 px-4 py-2 rounded-lg flex items-center"><img src="/img/bootstrap_logo.png" alt="Bootstrap" title="Bootstrap" class="h-6 w-auto"></span>
                </div>
            </div>
        </div> 
    </section>

    <!--- Work Section <cfinclude template="work.cfm"/> --->
    

    <!--- Lab Section --->
    <cfinclude template="/lab/projects.cfm"/>

    <!-- About Section -->
    <section id="about" class="py-20 bg-white">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <h2 class="text-4xl font-bold text-pink mb-4">#encodeForHtml(t("about.title", messages, fallbackMessages))#</h2>
            </div>
            <div class="prose prose-lg mx-auto text-gray-600">
                <div class="overflow-hidden">
                    <p class="text-lg leading-relaxed mb-6">
                        <img src="#application.root#/img/jc-royer-120.png" alt="JC Royer" align="left" width="120" height="120" class="w-[120px] h-[120px] rounded-full object-cover float-left block" style="margin-right:20px; border: 3px solid ##1d4ed8;">
                        #encodeForHtml(t("about.intro_1", messages, fallbackMessages))#<br/><br /> #encodeForHtml(t("about.intro_2", messages, fallbackMessages))#
                        <br /><br />
                        #encodeForHtml(t("about.intro_3", messages, fallbackMessages))#
                    </p>
                </div>
                <div class="bg-blue-50 p-6 rounded-lg mt-8">
                    <h3 class="text-xl font-semibold mb-4 text-gray-900">#encodeForHtml(t("about.why_title", messages, fallbackMessages))#</h3>
                    <ul class="space-y-3 text-gray-700">
                        <li class="flex items-start">
                            <svg class="w-6 h-6 text-primary mr-2 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <span>#encodeForHtml(t("about.point_1", messages, fallbackMessages))#</span>
                        </li>
                        <li class="flex items-start">
                            <svg class="w-6 h-6 text-primary mr-2 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <span>#encodeForHtml(t("about.point_2", messages, fallbackMessages))#</span>
                        </li>
                        <li class="flex items-start">
                            <svg class="w-6 h-6 text-primary mr-2 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <span>#encodeForHtml(t("about.point_3", messages, fallbackMessages))#</span>
                        </li>
                        <li class="flex items-start">
                            <svg class="w-6 h-6 text-primary mr-2 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <span>#encodeForHtml(t("about.point_4", messages, fallbackMessages))#</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section id="contact" class="py-20 bg-gradient-to-br from-primary to-blue-700 text-white">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <h2 class="text-4xl font-bold mb-4">#encodeForHtml(t("contact.title", messages, fallbackMessages))#</h2>
                <p class="text-xl text-blue-100">#encodeForHtml(t("contact.subtitle", messages, fallbackMessages))#</p>
            </div>
            <div class="bg-white bg-opacity-10 backdrop-blur-lg rounded-2xl p-8 md:p-12">
                <div id="contact-feedback"></div>
                <form id="contactForm" novalidate class="space-y-6">
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <label for="email" class="block text-sm font-medium text-blue-100">#encodeForHtml(t("contact.email", messages, fallbackMessages))#</label>
                            <span id="email-error" class="text-sm font-medium text-red-300"></span>
                        </div>
                        <input type="text" id="email" name="email"
                            class="w-full px-4 py-3 rounded-lg bg-white bg-opacity-90 text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-white"
                            placeholder="#encodeForHtmlAttribute(t("contact.email_placeholder", messages, fallbackMessages))#">
                    </div>
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <label for="message" class="block text-sm font-medium text-blue-100">#encodeForHtml(t("contact.message", messages, fallbackMessages))#</label>
                            <span id="message-error" class="text-sm font-medium text-red-300"></span>
                        </div>
                        <textarea id="message" name="message" rows="5"
                            class="w-full px-4 py-3 rounded-lg bg-white bg-opacity-90 text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-white"
                            placeholder="#encodeForHtmlAttribute(t("contact.message_placeholder", messages, fallbackMessages))#"></textarea>
                    </div>
                    <div class="text-center">
                        <button type="submit" id="contactSubmitBtn"
                            class="inline-block bg-white text-primary px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-50 transition">
                            #encodeForHtml(t("contact.send", messages, fallbackMessages))#
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-dark text-gray-300 py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center">
                <p class="text-2xl font-bold text-white mb-2">CFdino</p>
                <p class="mb-6">#encodeForHtml(t("footer.tagline", messages, fallbackMessages))#</p>
                <p class="text-sm text-gray-400">&copy; 2026 CFDino.com #encodeForHtml(t("footer.copyright", messages, fallbackMessages))#.</p>
            </div>
        </div>
    </footer>

    <script>
        // Mobile menu toggle
        const mobileMenuBtn = document.getElementById('mobile-menu-btn');
        const mobileMenu = document.getElementById('mobile-menu');

        if (mobileMenuBtn && mobileMenu) {
            mobileMenuBtn.addEventListener('click', () => {
                mobileMenu.classList.toggle('hidden');
            });
        }

        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="##"]:not([data-no-smooth-scroll])').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    if (mobileMenu) {
                        mobileMenu.classList.add('hidden');
                    }
                }
            });
        });

        // Add scroll effect to navbar
        const nav = document.querySelector('nav');
        window.addEventListener('scroll', () => {
            if (!nav) return;
            if (window.scrollY > 50) {
                nav.classList.add('shadow-md');
            } else {
                nav.classList.remove('shadow-md');
            }
        });

        // Contact form: AJAX/JSON submission, server-side validated by sendmail.cfm
        const contactForm = document.getElementById('contactForm');
        const contactFeedback = document.getElementById('contact-feedback');
        const contactSubmitBtn = document.getElementById('contactSubmitBtn');
        const emailInput = document.getElementById('email');
        const messageInput = document.getElementById('message');
        const emailError = document.getElementById('email-error');
        const messageError = document.getElementById('message-error');
        const contactCopy = {
            sending: #serializeJSON(t("contact.sending", messages, fallbackMessages))#,
            send: #serializeJSON(t("contact.send", messages, fallbackMessages))#,
            success: #serializeJSON(t("contact.success", messages, fallbackMessages))#,
            error: #serializeJSON(t("contact.error", messages, fallbackMessages))#
        };

        if (contactForm && contactFeedback && contactSubmitBtn && emailInput && messageInput && emailError && messageError) {
            contactForm.addEventListener('submit', async (e) => {
                e.preventDefault();

                emailError.textContent = '';
                messageError.textContent = '';
                contactFeedback.innerHTML = '';
                contactSubmitBtn.disabled = true;
                contactSubmitBtn.textContent = contactCopy.sending;

                try {
                    const response = await fetch('#application.root#/sendmail.cfm', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            email: emailInput.value,
                            message: messageInput.value
                        })
                    });
                    const data = await response.json();

                    if (data.success) {
                        contactFeedback.innerHTML = '<div class="bg-green-500 bg-opacity-20 border border-green-300 text-white p-4 rounded-lg mb-8 text-center">' + contactCopy.success + '</div>';
                        contactForm.reset();
                    } else {
                        if (data.errors && data.errors.email) {
                            emailError.textContent = data.errors.email;
                        }
                        if (data.errors && data.errors.message) {
                            messageError.textContent = data.errors.message;
                        }
                    }
                } catch (err) {
                    contactFeedback.innerHTML = '<div class="bg-red-500 bg-opacity-20 border border-red-300 text-white p-4 rounded-lg mb-8 text-center">' + contactCopy.error + '</div>';
                } finally {
                    contactSubmitBtn.disabled = false;
                    contactSubmitBtn.textContent = contactCopy.send;
                }
            });
        }
    </script>
</body>
</html>
</cfoutput>
