# Intégrer Language Switch avec Vrais Drapeaux PNG dans la Navigation

## Contexte

Stack: CFML (Lucee 7) + HTMX + Tailwind CSS  
Objectif: Ajouter un switch de langue EN/FR avec drapeaux PNG réels dans la navbar  
Design: Bordure bleue 2px sur la langue active (pas de background)

---

## Tâche

1. Télécharger les drapeaux PNG UK et France depuis une source libre
2. Placer les images dans `/img/flags/`
3. Créer/modifier le composant header avec language switcher
4. Active language: bordure 2px bleu + bold
5. Inactive language: grisé avec opacité 60%
6. Responsive Tailwind
7. Intégrer dans index.cfm

---

## Sources de Drapeaux (Télécharger)

### Option 1: FlagCDN (Recommandée - Gratuit + Direct)

**URL direct des drapeaux (format PNG, 64x64px):**

```
🇬🇧 Royaume-Uni/English:
https://flagcdn.com/gb.png (UK Flag - 64x64)
Alternative: https://cdn.jsdelivr.net/gh/lipis/flag-icons/flags/4x3/gb.png

🇫🇷 France/French:
https://flagcdn.com/fr.png (France Flag - 64x64)
Alternative: https://cdn.jsdelivr.net/gh/lipis/flag-icons/flags/4x3/fr.png
```

**Copilot devra:**
1. Télécharger ces deux images
2. Les renommer: `en.png` et `fr.png`
3. Les placer dans `/img/flags/` (créer le dossier s'il n'existe pas)
4. Dimensionner à 32x32px ou 24x24px (pour la nav)

---

## Structure de Fichiers à Créer

```
/img/
├── en.png          (Drapeau UK/English 24x24px)
├── fr.png          (Drapeau France/French 24x24px)
├── CFdino.png      (Logo existant)
└── ... (autres assets)
```

---

## Spécifications Techniques

- **Variable session:** `session.lang` (valeur: "en" ou "fr")
- **URL param:** `?lang=en` ou `?lang=fr`
- **Active state:** `border-2 border-blue-600` + bold (PAS de background!)
- **Inactive state:** `opacity-60 hover:opacity-100`
- **Hover effect:** Scale smooth + color transition
- **Images:** 24x24px ou 32x32px PNG
- **Alt text:** Bilingue ("English" ou "Français")

---

## Code à générer

### Fichier: `/components/header.cfm`

Générer un composant header CFML avec drapeaux PNG:

```cfml
<!--- Header avec Language Switch (Drapeaux PNG) --->
<header class="bg-white shadow">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
    <div class="flex items-center justify-between">
      
      <!-- Logo -->
      <div class="flex items-center gap-2">
        <a href="/">
          <img src="/img/CFdino.png" alt="CFdino" class="h-8" />
        </a>
      </div>
      
      <!-- Navigation (center) -->
      <nav class="hidden md:flex gap-6 absolute left-1/2 transform -translate-x-1/2">
        <a href="#services" class="text-gray-700 hover:text-blue-600 text-sm">#messages.nav.services#</a>
        <a href="#expertise" class="text-gray-700 hover:text-blue-600 text-sm">#messages.nav.expertise#</a>
        <a href="/lab/" class="text-gray-700 hover:text-blue-600 text-sm">#messages.nav.lab#</a>
        <a href="#about" class="text-gray-700 hover:text-blue-600 text-sm">#messages.nav.about#</a>
        <a href="#contact" class="text-gray-700 hover:text-blue-600 text-sm">#messages.nav.contact#</a>
      </nav>
      
      <!-- Language Switcher avec Drapeaux PNG (right) -->
      <div class="flex items-center gap-3">
        
        <!-- English Flag Button -->
        <a href="/?lang=en" 
           title="<cfif session.lang EQ 'en'>English (Current)<cfelse>Switch to English</cfif>"
           class="inline-flex items-center gap-1 px-2 py-1 rounded transition
                  <cfif session.lang EQ 'en'>
                    border-2 border-blue-600 font-semibold
                  <cfelse>
                    border-2 border-transparent opacity-60 hover:opacity-100
                  </cfif>">
          <img src="/img/en.png" alt="English" class="w-6 h-6" />
          <span class="text-sm">EN</span>
        </a>
        
        <!-- Separator -->
        <span class="text-gray-300">|</span>
        
        <!-- French Flag Button -->
        <a href="/?lang=fr" 
           title="<cfif session.lang EQ 'fr'>Français (Courant)<cfelse>Basculer vers Français</cfif>"
           class="inline-flex items-center gap-1 px-2 py-1 rounded transition
                  <cfif session.lang EQ 'fr'>
                    border-2 border-blue-600 font-semibold
                  <cfelse>
                    border-2 border-transparent opacity-60 hover:opacity-100
                  </cfif>">
          <img src="/img/fr.png" alt="Français" class="w-6 h-6" />
          <span class="text-sm">FR</span>
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
<!--- Charger les messages (traductions) --->
<cfset messages = getMessages(session.lang) />

<!--- Charger le header avec language switch --->
<cfinclude template="components/header.cfm" />

<!--- Rest of the page content... --->
```

**Assurances:**
- [ ] `en.png` et `fr.png` sont placés dans `/img/` (racine)
- [ ] Images en 24x24 ou 32x32px
- [ ] `session.lang` est disponible depuis Application.cfc
- [ ] `messages` struct est chargée (depuis i18n JSON)
- [ ] Header est inclus avant le contenu principal
- [ ] Pas d'erreurs de compilation CFML

---

## Télécharger les Drapeaux (Instructions pour Copilot)

**Copilot doit:**

1. Télécharger les deux images PNG depuis FlagCDN:
   ```
   https://flagcdn.com/gb.png → renommer en en.png
   https://flagcdn.com/fr.png → renommer en fr.png
   ```

2. Placer les images directement dans `/img/`:
   ```
   /img/en.png  (Drapeau Royaume-Uni)
   /img/fr.png  (Drapeau France)
   ```

3. Dimensionner les images (optionnel mais recommandé):
   - Taille: 24x24px ou 32x32px
   - Format: PNG avec transparence
   - Copilot peut utiliser ImageMagick ou simple CSS width/height

---

## Design Details

### Bordure Active
```css
border-2 border-blue-600
```
- Épaisseur: 2px
- Couleur: Bleu (Tailwind blue-600)
- Arrondi: Cohérent avec rounded
- Pas de background (propre & moderne)

### État Inactive
```css
border-2 border-transparent
opacity-60
hover:opacity-100
```
- Bordure transparente (réserve l'espace, pas de shift)
- Opacité 60% (grisé discret)
- Hover → opacité 100% (feedback utilisateur)

### Hover/Focus Effect
```css
transition (Tailwind auto)
```
- Smooth transition sur opacité
- Scale peut être ajouté si désiré

---

## Tests à valider

- [ ] Drapeaux téléchargés et placés dans `/img/`
- [ ] `/img/en.png` visible et affiche correctement
- [ ] `/img/fr.png` visible et affiche correctement
- [ ] Quand `session.lang = "en"`: EN a bordure bleue 2px + bold
- [ ] Quand `session.lang = "en"`: FR est grisé (opacity-60)
- [ ] Quand `session.lang = "fr"`: FR a bordure bleue 2px + bold
- [ ] Quand `session.lang = "fr"`: EN est grisé (opacity-60)
- [ ] Pas de layout shift (bordure réserve l'espace)
- [ ] Click sur FR redirige vers `/?lang=fr`
- [ ] Click sur EN redirige vers `/?lang=en`
- [ ] Cookie persiste la sélection
- [ ] Hover sur FR/EN: opacity passe à 100%
- [ ] Responsive mobile (redimensionné ou stacké)
- [ ] Drapeaux lisses (pas pixelisés)
- [ ] Pas d'erreurs 404 sur les images

---

## Critères d'Acceptation

✅ Drapeaux PNG téléchargés depuis FlagCDN  
✅ Images placées dans `/img/flags/`  
✅ Header générée avec switch EN/FR + drapeaux  
✅ Active state: bordure 2px bleu (pas background)  
✅ Inactive state: opacity 60% + border transparent  
✅ Intégrable dans index.cfm (cfinclude)  
✅ Prête à déployer sur 9planethosting  
✅ Pas d'erreurs console (F12)  
✅ Responsive design (mobile, tablet, desktop)  
✅ Alt text lisible et pertinent  

---

## Ressources & Links

- [FlagCDN - Libre de droits](https://flagcdn.com/)
- [Flag Icons CDN - Alternative](https://cdn.jsdelivr.net/gh/lipis/flag-icons/)
- [Tailwind Border Utilities](https://tailwindcss.com/docs/border)
- [Tailwind Opacity](https://tailwindcss.com/docs/opacity)
- [Tailwind Transitions](https://tailwindcss.com/docs/transition-property)

---

## Notes Supplémentaires

- **Drapeaux libres:** FlagCDN sont en Creative Commons (libre d'utilisation)
- **Pas de compression:** Garder PNG pour transparence + qualité
- **Fallback:** Si image ne charge pas, le texte "EN" / "FR" reste lisible
- **Performance:** 24x24px PNG ≈ 1-2KB chacune (très léger)
- **Accessibilité:** Alt text + title attribute pour tooltip
- **Responsive:** Images auto-responsive grâce à Tailwind

---

## Variante Courte (si prompt court)

```markdown
Télécharge les drapeaux PNG UK et France depuis FlagCDN.
Place-les directement dans /img/ (en.png et fr.png).
Crée header.cfm avec language switch:
- Drapeaux PNG + texte "EN" et "FR"
- Active: bordure 2px bleu (#2563eb) + bold
- Inactive: opacity 60% + border transparent (pas de shift)
- session.lang vérifie la langue (en ou fr)
- URL: /?lang=en ou /?lang=fr
Tailwind CSS. Intègre dans index.cfm.
```

---

**Version:** 1.0  
**Date:** 2026-09-20  
**Projet:** CFdino Bilingual EN/FR  
**Stack:** CFML/Lucee 7 + HTMX + Tailwind CSS  
**Design Update:** Drapeaux PNG réels + Bordure bleue (pas background)
