# 🦖 Projet: CFdino Bilingual EN/FR

## Vue d'ensemble

Implémenter un système de gestion de langue bilingue (EN/FR) sur le site CFdino.

**Stack**: CFML (Lucee 7) + HTMX + Tailwind + OVH (DNS) + 9planethosting (hosting)
**Domaines**: `cfdino.com` (EN défaut) + `cfdino.fr` (FR redirect)
**Durée estimée**: 6-8h
**Priorité**: 🔴 Haute

---

## Objectifs

- ✅ Site principal `cfdino.com` fonctionnel EN/FR
- ✅ Redirection `cfdino.fr` → `cfdino.com?lang=fr` avec persistence (cookie 90j)
- ✅ Switch de langue (EN/FR) dans le header accessible sur toutes pages
- ✅ Traductions centralisées (fichiers JSON)
- ✅ Lab projects hérités du système de langue parent
- ✅ Déploiement sur 9planethosting

---

## Phase 1: Infrastructure & Setup

### Tâche 1.1: Application.cfc - Détection & Routing de langue

**Description**: Implémenter la détection de langue avec paramètre URL + cookie + fallback

**Critères d'acceptation**:
- [ ] Paramètre URL `?lang=en` ou `?lang=fr` fonctionne
- [ ] Cookie "lang" persiste 90 jours
- [ ] Session.lang disponible partout
- [ ] Défaut: EN si aucune langue détectée
- [ ] Routing: `cfdino.fr` redirige vers `cfdino.com?lang=fr` (301)
- [ ] `www.cfdino.com` et `www.cfdino.fr` gérés

**Tâches techniques**:
- Ajouter detection logic en onRequestStart()
- Gérer les redirections 301 pour cfdino.fr
- Tester avec 4 scénarios (no cookie, cookie, URL param, domaine .fr)

**Code snippet**:
```cfml
<!-- En haut de Application.cfc / onRequestStart() -->
<cfif structKeyExists(URL, 'lang') AND (URL.lang EQ 'fr' OR URL.lang EQ 'en')>
    <cfset session.lang = URL.lang />
    <cfcookie name="lang" value="#URL.lang#" expires="90" />
<cfelseif structKeyExists(cookie, 'lang')>
    <cfset session.lang = cookie.lang />
<cfelseif structKeyExists(session, 'lang')>
    <!--- Session already set -->
<cfelse>
    <!--- Détecte la langue du navigateur ou défaut EN -->
    <cfset session.lang = "en" />
</cfif>

<!-- Redirect cfdino.fr vers cfdino.com?lang=fr -->
<cfif CGI.SERVER_NAME EQ "cfdino.fr" OR CGI.SERVER_NAME EQ "www.cfdino.fr">
    <cflocation url="https://cfdino.com?lang=fr" addtoken="false" statuscode="301" />
</cfif>
```

---

### Tâche 1.2: Structure de fichiers i18n

**Description**: Créer l'architecture pour les traductions centralisées

**Structure à créer**:
```
/app/i18n/
├── en.json          (Messages EN)
├── fr.json          (Messages FR)
└── i18nHelper.cfm   (Fonctions CFML)
```

**Critères d'acceptation**:
- [ ] Dossier `/app/i18n/` créé
- [ ] `en.json` contient toutes les clés (nav, hero, services, expertise, lab, about, contact)
- [ ] `fr.json` traduit complètement
- [ ] Format JSON valide (testable avec JSONParse)
- [ ] Helper `.cfm` expose `getMessages()` fonction
- [ ] Fallback: si clé manque, retourne clé EN

**Contenu JSON à extraire**:
```json
{
  "nav": {
    "services": "Services",
    "expertise": "Expertise",
    "lab": "Lab",
    "about": "About",
    "contact": "Contact"
  },
  "hero": {
    "title": "Full Stack CFML",
    "subtitle": "Delivering robust, scalable CFML solutions...",
    "cta1": "Get in Touch",
    "cta2": "View Expertise",
    "cta3": "View Work"
  },
  "services": {
    "title": "Services",
    "custom_dev_title": "Custom Development",
    "custom_dev_desc": "Build powerful web applications: CMS, CRM, Intranet, Extranet.",
    "legacy_title": "Legacy Modernization",
    "legacy_desc": "Upgrade and optimize existing ColdFusion applications...",
    "api_title": "API Integration",
    "api_desc": "Connect your ColdFusion applications with third-party services...",
    "perf_title": "Performance Optimization",
    "perf_desc": "Analyze and improve application performance..."
  },
  "expertise": {
    "title": "Expertise",
    "core_tech": "Core Technologies",
    "databases": "Databases",
    "devops": "DevOps & Tooling",
    "frontend": "Modern Front-End Integration"
  },
  "lab": {
    "title": "Dino Lab Projects",
    "dd_title": "Dino Detective",
    "dd_desc": "Upload a photo - a fossil, a toy, a footprint...",
    "test_project": "Test project"
  },
  "about": {
    "title": "About CFdino",
    "subtitle": "With over 25 years of specialized experience...",
    "why_title": "Why Work With Me?",
    "points": [
      "Proven track record with enterprise-level ColdFusion projects",
      "Flexible engagement models: project-based or long-term contracts",
      "Strong communication and remote collaboration experience",
      "Up-to-date with modern development practices and tools"
    ]
  },
  "contact": {
    "title": "Let's Work Together",
    "subtitle": "Ready to discuss your project?",
    "email_label": "Email",
    "message_label": "Message",
    "send_btn": "Send Message"
  },
  "footer": {
    "copyright": "All rights reserved",
    "year": "2026"
  }
}
```

**Code i18nHelper.cfm**:
```cfml
<cffunction name="getMessages" returntype="struct" output="false">
    <cfargument name="lang" type="string" required="true" default="en" />
    
    <cfset var filePath = expandPath("/app/i18n/#arguments.lang#.json") />
    <cfset var messages = {} />
    
    <cfif fileExists(filePath)>
        <cfset messages = deserializeJSON(fileRead(filePath)) />
    <cfelse>
        <!--- Fallback to EN if language file not found -->
        <cfset messages = deserializeJSON(fileRead(expandPath("/app/i18n/en.json"))) />
    </cfif>
    
    <cfreturn messages />
</cffunction>

<cffunction name="t" returntype="string" output="false" hint="Translation shorthand">
    <cfargument name="key" type="string" required="true" />
    <cfargument name="messages" type="struct" required="true" />
    
    <cfif structKeyExists(arguments.messages, arguments.key)>
        <cfreturn arguments.messages[arguments.key] />
    <cfelse>
        <cfreturn "[#arguments.key#]" />
    </cfif>
</cffunction>
```

---

## Phase 2: Refactor Page Principale

### Tâche 2.1: Adapter index.cfm pour utiliser messages JSON

**Description**: Remplacer tous les textes hardcodés par variables de traduction

**Critères d'acceptation**:
- [ ] `index.cfm` charge `messages` depuis JSON approprié
- [ ] Tous les h1, h2, p, button labels utilisent `#messages.key#`
- [ ] Changement de langue (`?lang=fr`) met à jour le contenu
- [ ] Pas de contenu hardcodé en anglais
- [ ] Meta description + title traduites aussi
- [ ] Test: `cfdino.com` affiche EN, `cfdino.com?lang=fr` affiche FR

**Sections à traduire**:
- [ ] Navigation
- [ ] Hero section
- [ ] Services
- [ ] Expertise
- [ ] Dino Detective card
- [ ] About section
- [ ] Contact form
- [ ] Footer

**Code pattern pour index.cfm**:
```cfml
<!--- Au début du fichier index.cfm -->
<cfset messages = getMessages(session.lang) />

<!--- Dans le HTML -->
<title>#messages.nav.title#</title>
<meta name="description" content="#messages.hero.subtitle#" />

<!--- Sections -->
<h1>#messages.hero.title#</h1>
<p>#messages.hero.subtitle#</p>
<a href="#contact">#messages.hero.cta1#</a>
```

---

### Tâche 2.2: Header - Ajouter switch EN/FR

**Description**: Intégrer boutons drapeau 🇬🇧/🇫🇷 dans navbar

**Design Tailwind**:
```html
<div class="flex gap-1 items-center">
  <a href="/?lang=en" 
     class="text-sm px-2 py-1 rounded transition
            <cfif session.lang EQ 'en'>bg-blue-500 text-white font-bold<cfelse>opacity-60 hover:opacity-100</cfif>">
    🇬🇧 EN
  </a>
  <span class="text-gray-400">|</span>
  <a href="/?lang=fr" 
     class="text-sm px-2 py-1 rounded transition
            <cfif session.lang EQ 'fr'>bg-blue-500 text-white font-bold<cfelse>opacity-60 hover:opacity-100</cfif>">
    🇫🇷 FR
  </a>
</div>
```

**Critères d'acceptation**:
- [ ] Drapeau EN/FR visible dans header
- [ ] Bouton actif en surbrillance (bold + bg color)
- [ ] Click sur FR: page passe en français (et vice-versa)
- [ ] Cookie persiste la sélection après refresh
- [ ] Responsive mobile (ne pas casser le layout Tailwind)
- [ ] Pas de flash de contenu EN avant FR (ou vice-versa)

**Variante HTMX (no-reload)**:
```html
<a href="/?lang=fr" 
   hx-get="/?lang=fr" 
   hx-target="body" 
   hx-swap="outerHTML"
   class="text-sm px-2 py-1 rounded">
  🇫🇷 FR
</a>
```

---

## Phase 3: Lab Projects (Sous-applications)

### Tâche 3.1: Dino Detective - Héritage langue parent

**Description**: Adapter `/lab/dd/index.cfm` pour utiliser `session.lang` du parent

**Critères d'acceptation**:
- [ ] `/lab/dd/index.cfm` lit `session.lang` du parent
- [ ] Si pas de session (accès direct), détecte `?lang=` en URL
- [ ] Traductions DD: title, descriptions, boutons
- [ ] Language switch fonctionne aussi dans `/lab/dd/`
- [ ] Pas de duplication i18n (réutilise parent ou JSON dédié minimal)

**Tâches**:
- [ ] Créer `/app/i18n/lab-dd-en.json` (si textes spécifiques à DD)
- [ ] Créer `/app/i18n/lab-dd-fr.json`
- [ ] Adapter template DD pour charger ses propres messages
- [ ] Tester: naviguer vers `/lab/dd` en FR, puis vers DD, vérifier que DD reste en FR

**Code pattern pour /lab/dd/index.cfm**:
```cfml
<!--- Si pas de session lang (accès direct), détecte URL param -->
<cfif !structKeyExists(session, 'lang')>
    <cfset session.lang = structKeyExists(URL, 'lang') ? URL.lang : 'en' />
</cfif>

<!--- Charger messages du parent + spécifiques DD si besoin -->
<cfset parentMessages = getMessages(session.lang) />
<cfset ddMessages = getMessages(session.lang) />
```

---

### Tâche 3.2: Autres Lab projects (future-proof)

**Description**: Template pour ajouter d'autres sous-projets

**Checklist**:
- [ ] Chaque `/lab/*/index.cfm` suit le même pattern héritage
- [ ] Réutiliser `i18nHelper.cfm` parent
- [ ] Documentation pour ajouter futurs projets

---

## Phase 4: Tests & Déploiement

### Tâche 4.1: Tests locaux (Codespaces)

**Description**: Valider tous les scénarios en dev

**Checklist de test**:
- [ ] Accès `http://localhost:8888/?lang=en` → Contenu EN
- [ ] Accès `http://localhost:8888/?lang=fr` → Contenu FR
- [ ] Refresh page → langue persiste via cookie
- [ ] Click drapeau FR → page devient FR (vérifier contenu + URL)
- [ ] Click drapeau EN → page redevient EN
- [ ] Cookie "lang" visible dans DevTools (Application > Cookies)
- [ ] Tous les textes traduits (pas de clés JSON visibles comme "[nav.services]")
- [ ] Accès direct `/lab/dd/` → détecte langue correcte
- [ ] Switch langue dans `/lab/dd/` → met à jour DD + tous les éléments
- [ ] Tests responsive: mobile, tablet, desktop
- [ ] Pas d'erreurs console (F12 > Console)
- [ ] Métadonnées (title, description) traduites

**Scénarios de test détaillés**:
```
1. Clean browser / No cookie
   - Accès cfdino.com → EN
   - Cookie créé avec lang=en

2. Avec cookie EN
   - Accès cfdino.com → EN
   - Click FR → FR
   - Refresh → FR persiste

3. Avec cookie FR
   - Accès cfdino.com → FR
   - Click EN → EN
   - Refresh → EN persiste

4. URL param override
   - Accès cfdino.com?lang=fr (avec cookie en)
   - Affiche FR + met à jour cookie

5. Lab projects
   - Accès /lab/dd en EN → DD en EN
   - Click FR dans /lab/dd → DD en FR
   - Retour à home → Reste en FR
```

---

### Tâche 4.2: Configuration OVH & Déploiement

**Description**: Configurer DNS et déployer sur 9planethosting

**Checklist DNS OVH**:
- [ ] OVH Admin > Domaines > cfdino.com > DNS
- [ ] `cfdino.com` (A record) → IP 9planethosting
- [ ] `www.cfdino.com` (CNAME ou A) → alias vers `cfdino.com`
- [ ] `cfdino.fr` (A record) → IP 9planethosting
- [ ] `www.cfdino.fr` (CNAME) → alias vers `cfdino.fr`
- [ ] Attendre propagation DNS (15-30 min)
- [ ] Tester avec `nslookup cfdino.com` ou `dig cfdino.com`

**Checklist déploiement 9planethosting**:
- [ ] Accès FTP/SFTP à 9planethosting
- [ ] Upload dossier `/app/i18n/` complet
- [ ] Upload `Application.cfc` modifié (avec routing 301)
- [ ] Upload `index.cfm` modifié
- [ ] Upload layout/components modifiés
- [ ] Upload `/lab/dd/` modifications
- [ ] Redémarrer Lucee sur 9planethosting (si possible)
- [ ] Vérifier permissions fichiers (644 ou 755 selon hosting)

**Checklist tests prod**:
- [ ] Test: `https://cfdino.com` → EN
- [ ] Test: `https://cfdino.com?lang=fr` → FR
- [ ] Test: `https://www.cfdino.com` → EN
- [ ] Test: `https://www.cfdino.com?lang=fr` → FR
- [ ] Test: `https://cfdino.fr` → Redirige vers `cfdino.com?lang=fr` (301)
- [ ] Test: `https://www.cfdino.fr` → Redirige vers `cfdino.com?lang=fr` (301)
- [ ] Cookie persiste en prod
- [ ] Pas d'erreurs 404 ou 500
- [ ] Vérifier avec DevTools que redirection 301 est bien HTTP 301
- [ ] Performance: page load time < 2s

**Test redirect avec curl** (depuis terminal):
```bash
curl -i https://cfdino.fr
# Devrait voir: HTTP/1.1 301 Moved Permanently
# Location: https://cfdino.com?lang=fr
```

---

### Tâche 4.3: Optimisations SEO

**Description**: Ajouter hreflang + structured data

**Critères**:
- [ ] Meta hreflang EN: `<link rel="alternate" hreflang="en" href="https://cfdino.com?lang=en" />`
- [ ] Meta hreflang FR: `<link rel="alternate" hreflang="fr" href="https://cfdino.com?lang=fr" />`
- [ ] Meta hreflang x-default: `<link rel="alternate" hreflang="x-default" href="https://cfdino.com" />`
- [ ] Meta description traduite (en.json + fr.json)
- [ ] Title traduit (`<title>`)
- [ ] Lang attribute sur `<html>`: `<html lang="#session.lang#">`
- [ ] Google Analytics tracking `session.lang` (custom dimension ou event)
- [ ] Vérifier avec Google Search Console (hreflang errors)

**Code hreflang**:
```html
<head>
  <link rel="alternate" hreflang="en" href="https://cfdino.com?lang=en" />
  <link rel="alternate" hreflang="fr" href="https://cfdino.com?lang=fr" />
  <link rel="alternate" hreflang="x-default" href="https://cfdino.com" />
  <title>#messages.pageTitle#</title>
  <meta name="description" content="#messages.metaDescription#" />
</head>
<html lang="#session.lang#">
```

---

## Dépendances & Bloqueurs

| Élément | Statut | Notes |
|---------|--------|-------|
| Accès Codespaces | ✅ Prêt | Dev en cours |
| CFML/Lucee 7 | ✅ Prêt | Déjà installé |
| Tailwind | ✅ Prêt | Déjà utilisé |
| Speckit | ✅ Prêt | Récemment installé |
| OVH Admin Access | ⏳ Requis | Pour DNS config |
| 9planethosting FTP/SFTP | ⏳ Requis | Pour déploiement |
| Credentials 9planethosting | ⏳ Requis | Host + FTP login |

---

## Notes Techniques

- **HTMX & Language Switch**: Si on veut pas de reload complet, utiliser `hx-swap="outerHTML"` sur le body entier. Attention: peut cacher la bonne langue si cache HTTP mal configuré.
- **Cache HTTP**: Ajouter `Cache-Control: private` ou `no-cache` pour les pages dynamiques
- **Lucee 7 Native i18n**: Alternative = ResourceBundle.properties, mais JSON est plus simple et flexible ici
- **Form Contact Multilingue**: Subject email doit refléter langue du formulaire (ajouter clé `contact.emailSubject` dans i18n)
- **Browser Language Detection**: Lucee peut détecter navigateur avec `cgi.http_accept_language`, mais paramètre URL/cookie ont priorité
- **Canonical Tags**: Si utilisation de `?lang=` en URL, vérifier que canonical tag pointe vers version appropriée

---

## Ressources Utiles

- [Lucee Documentation - Application.cfc](https://docs.lucee.org/)
- [CFML JSON Functions](https://cfdocs.org/serializejson)
- [HTMX Documentation](https://htmx.org/)
- [Tailwind CSS Responsive](https://tailwindcss.com/docs/responsive-design)
- [OVH DNS Management](https://www.ovh.com/)
- [Google Search Console - hreflang](https://developers.google.com/search/docs/specialty/international/localized-versions)

---

## KPIs de Succès

- ✅ Deux domaines fonctionnels (`cfdino.com` EN + `cfdino.fr` FR)
- ✅ Switch EN/FR accessible et persistant sur toutes pages
- ✅ 100% du contenu traduit (pas de clés JSON visibles)
- ✅ Lab projects bilingues et hérités correctement
- ✅ Déploiement réussi sur 9planethosting
- ✅ SEO hreflang en place et validé
- ✅ Tests prod passés (redirects 301, contenu traduit, cookies)
- ✅ Performance acceptable (< 2s page load)

---

## Historique de Version

| Version | Date | Changements |
|---------|------|-------------|
| 1.0 | 2026-09-20 | Création spec initiale pour Speckit |

---

**Projet créé pour:** CFdino (cfdino.com)  
**Manager:** JC Royer  
**Stack:** CFML/Lucee 7 + HTMX + Tailwind  
**Hosting:** 9planethosting + OVH DNS
