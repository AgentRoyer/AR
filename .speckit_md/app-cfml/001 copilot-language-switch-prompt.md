# Intégrer Language Switch avec Emojis dans la Navigation

## Contexte

Stack: CFML (Lucee 7) + HTMX + Tailwind CSS  
Objectif: Ajouter un switch de langue EN/FR avec emojis 🇬🇧 🇫🇷 dans la navbar

---

## Tâche

1. Créer/modifier le composant header avec language switcher
2. Utiliser emojis de drapeaux (pas d'images PNG)
3. Active language en bleu/bold, inactive language grisé
4. Responsive Tailwind
5. Intégrer dans index.cfm

---

## Spécifications Techniques

- **Variable session:** `session.lang` (valeur: "en" ou "fr")
- **URL param:** `?lang=en` ou `?lang=fr`
- **Active state:** `bg-blue-600 text-white` + bold
- **Inactive state:** `opacity-60 hover:opacity-100`
- **Hover effect:** Scale smooth + color transition
- **Emojis:** 🇬🇧 pour EN, 🇫🇷 pour FR

---

## Code à générer

### Fichier: `/components/header.cfm`

Générer un composant header CFML avec:

```cfml
<!--- Header avec Language Switch --->
<header class="bg-white shadow">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
    <div class="flex items-center justify-between">
      
      <!-- Logo -->
      <div class="flex items-center">
        <img src="/img/CFdino.png" alt="CFdino" class="h-8" />
      </div>
      
      <!-- Navigation (center) -->
      <nav class="hidden md:flex gap-6 absolute left-1/2 transform -translate-x-1/2">
        <a href="#services" class="text-gray-700 hover:text-blue-600">#messages.nav.services#</a>
        <a href="#expertise" class="text-gray-700 hover:text-blue-600">#messages.nav.expertise#</a>
        <a href="/lab/" class="text-gray-700 hover:text-blue-600">#messages.nav.lab#</a>
        <a href="#about" class="text-gray-700 hover:text-blue-600">#messages.nav.about#</a>
        <a href="#contact" class="text-gray-700 hover:text-blue-600">#messages.nav.contact#</a>
      </nav>
      
      <!-- Language Switcher (right) -->
      <div class="flex items-center gap-2">
        <a href="/?lang=en" 
           class="px-2 py-1 rounded text-sm font-semibold transition
                  <cfif session.lang EQ 'en'>
                    bg-blue-600 text-white shadow
                  <cfelse>
                    text-gray-600 opacity-60 hover:opacity-100
                  </cfif>">
          🇬🇧 EN
        </a>
        <span class="text-gray-300">|</span>
        <a href="/?lang=fr" 
           class="px-2 py-1 rounded text-sm font-semibold transition
                  <cfif session.lang EQ 'fr'>
                    bg-blue-600 text-white shadow
                  <cfelse>
                    text-gray-600 opacity-60 hover:opacity-100
                  </cfif>">
          🇫🇷 FR
        </a>
      </div>
      
    </div>
  </div>
</header>
```

---

## Intégration dans index.cfm

**Au début du fichier `index.cfm`:**

```cfml
<!--- Charger le message translations --->
<cfset messages = getMessages(session.lang) />

<!--- Charger le header --->
<cfinclude template="components/header.cfm" />

<!--- Rest of the page content... --->
```

**Assurances:**
- [ ] `session.lang` est disponible depuis Application.cfc
- [ ] `messages` struct est chargée (depuis i18n JSON)
- [ ] Header est inclus avant le contenu principal
- [ ] Pas d'erreurs de compilation CFML

---

## Tests à valider

- [ ] 🇬🇧 EN est bleu/bold quand `session.lang = "en"`
- [ ] 🇫🇷 FR est grisé quand `session.lang = "en"`
- [ ] 🇫🇷 FR est bleu/bold quand `session.lang = "fr"`
- [ ] 🇬🇧 EN est grisé quand `session.lang = "fr"`
- [ ] Click sur FR redirige vers `/?lang=fr`
- [ ] Click sur EN redirige vers `/?lang=en`
- [ ] Cookie persiste la sélection
- [ ] Responsive mobile (stacké ou adapté si besoin)
- [ ] Pas de flicker ou layout shift
- [ ] Compatibilité tous navigateurs modernes

---

## Critères d'Acceptation

✅ Header générée avec switch EN/FR emojis  
✅ Active/inactive states avec Tailwind CSS  
✅ Intégrable dans index.cfm (cfinclude)  
✅ Prête à déployer sur 9planethosting  
✅ Pas d'erreurs console (F12)  
✅ Responsive design (mobile, tablet, desktop)  

---

## Notes Supplémentaires

- **Pas de fichiers PNG:** Utilise emojis natifs (plus léger, plus simple)
- **Emojis universels:** Supportés par tous les navigateurs modernes
- **Accessible:** Alt-text auto via le emoji
- **Maintenance facile:** Pas de gestion d'assets
- **Performance:** Zéro requête HTTP pour les drapeaux

---

## Ressources

- [Tailwind CSS Transitions](https://tailwindcss.com/docs/transition-property)
- [CFML Conditional Rendering](https://cfdocs.org/cfif)
- [Unicode Flags](https://en.wikipedia.org/wiki/Regional_indicator_symbol)

---

## Variante Courte (si prompt court)

Si tu veux utiliser une version plus courte dans Copilot:

```
Ajoute un language switcher EN/FR avec emojis 🇬🇧 🇫🇷 dans ma nav.
- Active language: blue background + bold
- Inactive: grey + opacity 60%
- Tailwind CSS
- Vérifie session.lang (valeur: "en" ou "fr")
- URL: /?lang=en ou /?lang=fr
- Fichier: /components/header.cfm
- Intègre dans index.cfm avec cfinclude
```

---

**Version:** 1.0  
**Date:** 2026-09-20  
**Projet:** CFdino Bilingual EN/FR  
**Stack:** CFML/Lucee 7 + HTMX + Tailwind CSS
