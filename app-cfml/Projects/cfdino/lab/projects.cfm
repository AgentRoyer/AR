<cfset dinoLabProjects = [
	{
		projectname = t("lab.dino_title", messages, fallbackMessages),
		projectvisual = application.root & "/lab/img/dinodetective.png",
		projectdesc = t("lab.dino_description", messages, fallbackMessages),
		projectlink = application.root & "/lab/dd/index.cfm?lang=" & session.lang
	}
]>

<section id="projects" class="py-20 bg-gray-50">
	<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
		<div class="text-center mb-10">
			<cfoutput><h2 class="text-4xl font-bold text-pink mb-4">#encodeForHtml(t("lab.title", messages, fallbackMessages))#</h2></cfoutput>
		</div>

		<cfoutput>
			<div class="space-y-6">
				<cfloop array="#dinoLabProjects#" index="projectItem">
					<article class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-100 p-6 md:p-8">
						<h3 class="text-2xl font-semibold text-primary mb-3">#encodeForHtml(projectItem.projectname)#</h3>
						<div class="flex flex-col sm:flex-row items-start gap-4 sm:gap-6">
							<a href="#projectItem.projectlink#" aria-label="#encodeForHtmlAttribute(t("lab.open_project", messages, fallbackMessages))#">
								<img src="#projectItem.projectvisual#" alt="#encodeForHtmlAttribute(t("lab.visual_alt", messages, fallbackMessages))#" class="h-auto object-contain flex-shrink-0 border-2 border-primary rounded-lg" style="width:200px; max-width:200px;">
							</a>
							<p class="text-gray-700 leading-relaxed">
								#replace(encodeForHtml(projectItem.projectdesc), chr(10), "<br>", "all")#
								<br><a href="#projectItem.projectlink#" class="inline-block bg-primary text-white px-6 py-2 rounded-lg font-semibold hover:bg-blue-700 transition mt-4">#encodeForHtml(t("lab.test_project", messages, fallbackMessages))#</a>
							</p>
						</div>
					</article>
				</cfloop>
			</div>
		</cfoutput>
	</div>
</section>
