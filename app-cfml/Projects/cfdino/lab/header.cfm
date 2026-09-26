<cfoutput>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="#application.root#/css/tailwind.css">
	<script>
		function closeLabPage() {
			window.close();
		}
	</script>
</head>
<body class="font-sans antialiased">
	<nav class="fixed w-full bg-white shadow-sm z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-28">
                <div class="flex items-center space-x-4 my-4">
                    <a href="#application.root#/lab" class="flex items-center space-x-2">
                        <span class="text-2xl font-bold text-primary">LAB</span>
                    </a>
                </div>
                <div class="hidden md:flex items-center space-x-8 text-lg">
                    <a href="#application.root#/lab/dd/index.cfm" class="text-gray-700 hover:text-primary transition">Dino Detective</a>
                    <button id="close-lab-page-btn" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition" onclick="closeLabPage()">Fermer</button>
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
                <a href="#application.root#/lab/dd/index.cfm" class="block text-gray-700 hover:text-primary">Dino Detective</a>
                <button id="close-lab-page-btn-mobile" class="block bg-primary text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition w-full text-center" onclick="closeLabPage()">Fermer</button>
            </div>
        </div>
    </nav>

	<h1 class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">LAB</h1>
</cfoutput>