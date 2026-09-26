<!--- Work Section not live --->
<cfset workProjects = [
    {
        period = "2006 – Ongoing",
        visual = "/img/clients/liveandwork_com_logo.png",
        project = "live&amp;work CRM",
        client = "Live&amp;Work",
        description = "Suivi.pro is a full-featured CRM tailored to MLM marketing, offering an administrable back-office with multiple views (status, archives, map, custom), integrated search, personalized team websites, and document sharing. Sales tools include order management, PayPal integration, multi-template email campaigns (Mandrill, Gmail), Google Calendar-linked appointment scheduling, inter-distributor lead transfer, automated envelope printing, and itinerary generation.",
        link = "https://liveandwork.com/"
    },
    {
        period = "2019 – 2021",
        visual = "/img/clients/masculin_com_logo.png",
        project = "Masculin.com",
        client = "Big Manitou",
        description = "Complete technical acquisition and overhaul of a high-traffic digital media portal. Designed and executed custom database conversion scripts to migrate historical content from a legacy PHP architecture over to WordPress. Managed ad network integrations and brand content deployment.",
        link = "https://masculin.com/"
    },
    {
        period = "2005 – 2006",
        visual = "/img/clients/reed_midem_helpme_logo.png",
        project = "HelpMe",
        client = "Reed Midem",
        description = "Specification and development of 'HelpMe', an internal corporate HelpDesk and ticket-tracking application built with CFML. Designed to streamline internal support requests and IT issue tracking across departments, with Microsoft Active Directory integration for user authentication and department/permission management.",
        link = ""
    },
    {
        period = "2002 – 2003",
        visual = "/img/clients/franceonly_fr_logo.png",
        project = "FranceOnly.fr",
        client = "FranceOnly",
        description = "Full-stack creation of a pioneer bilingual vacation rental marketplace in CFML. Engineered the search engines, booking mechanics, multi-criteria listings catalog, and client administration panels.",
        link = ""
    },
    {
        period = "2001 – 2002",
        visual = "/img/clients/activeaccess_com_logo.png",
        project = "ActiveAccess",
        client = "Imperial College London",
        description = "Overhaul and ongoing engineering of ActivAccess, a complex bilingual B2B procurement platform developed in CFML. Integrated automated supplier feeds, multi-currency support, and enterprise workflow rules.",
        link = ""
    },
    {
        period = "1999 – 2000",
        visual = "/img/clients/fishing_co_uk_logo.png",
        project = "Fishing.co.uk",
        client = "Highbury House Comm. Plc",
        description = "Web management and full redesign of a major UK thematic media portal. Managed content workflows on EasyPress (Perl-based CMS), implemented feature extensions, and optimized platform traffic and structure.",
        link = "https://fishing.co.uk/"
    }
]>

<!-- Work Section -->
<section id="work" class="py-20 bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-10">
            <h2 class="text-4xl font-bold text-pink mb-4">Work</h2>
            <p class="text-xl text-gray-600 max-w-4xl mx-auto">
                Conceived and deployed tailored, lightweight CFML engines—spanning custom CMS, CRM, Intranet, and Extranet platforms. Built with a core focus on custom permissions, high performance, and backend simplicity. Below are some of the most notable projects.
            </p>
            <div class="h-[20px]">&nbsp;</div>
        </div>

        <cfoutput>
            <div class="space-y-6">
                <cfloop array="#workProjects#" index="projectItem">
                    <article class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-100">
                        <div class="flex flex-col md:flex-row">
                            <div class="flex-1 p-6 md:p-8">
                                <div class="flex flex-wrap items-center gap-3 mb-3 text-sm text-gray-500">
                                    <span class="font-semibold text-primary">#projectItem.period#</span>
                                    <span class="text-gray-300">|</span>
                                    <span class="font-semibold text-primary">#projectItem.project#</span>
                                    <span class="text-gray-300">|</span>
                                    <span class="font-semibold text-primary">#projectItem.client#</span>
                                </div>
                                <div class="flex flex-col sm:flex-row items-start gap-4 sm:gap-6">
                                    <cfset dolink=0>
                                    <cfif structKeyExists(projectItem, "link") AND projectItem.link NEQ ""><cfset dolink=1></cfif>
                                    <cfif dolink><a href="#projectItem.link#" target="_blank"></cfif>
                                    <img src="#projectItem.visual#" alt="#projectItem.project# visual" class="h-auto object-contain flex-shrink-0 border-2 border-primary rounded-lg" style="width:200px; max-width:200px;">
                                    <cfif dolink></a></cfif>
                                    <p class="text-gray-700 leading-relaxed">#projectItem.description#
                                    <cfif dolink>
                                        <br/><a href="#projectItem.link#" target="_blank" class="text-primary font-semibold mt-2 inline-block">View Project</a>
                                    </cfif>
                                    </p>
                                    
                                </div>
                            </div>
                        </div>
                    </article>
                </cfloop>
            </div>
        </cfoutput>
    </div>
</section>
