# 004 — Claude ColdBox Project — Fix 1

> Constat après test manuel sur l'accueil `lab/cb/`. Ce fichier complète `003 copilot-coldbox-project.md` et `003-copilot-coldbox-project-fix1.md` (ne les remplace pas) et liste les corrections à apporter.

---

## 1. Le login ne fonctionne pas — pas d'accès au CMS

Après soumission du formulaire (avec le compte de démo `testuser@cfdino.com` / `dino_cb_pass` ou un compte fraîchement créé), la page revient toujours sur elle-même : l'utilisateur n'est jamais redirigé vers le CMS et reste déconnecté.

Piste à vérifier en priorité : [Auth.cfc](../lab/cb/handlers/Auth.cfc) compare `hash( password, "SHA-256" )` à `password_hash` en base. Le compte de démo inséré par `db/seed.sql` utilise `SHA2( 'dino_cb_pass', 256 )` côté MariaDB — confirmer que le hash SQL (`SHA2`, hex minuscule) et le hash CFML (`hash()`, hex majuscule par défaut) produisent bien la même valeur une fois comparés (`compare` sensible à la casse ?). Vérifier aussi que `session.user` est bien peuplé et persiste (cookies de session actifs, `this.sessionManagement` dans `Application.cfc`) et que la redirection `relocate( "index.cfm?event=CmsArticles.index" )` n'est pas elle-même repoussée vers le login par une vérification de session qui échoue juste après.

À tester : loguer avec le compte de démo, avec un compte tout juste créé via `/cms/register`, et vérifier dans les deux cas l'accès à `/cms/articles`.

## 2. Colonne Login mal positionnée

Le bloc "Login" apparaît **sous** le bloc "Fiches dinosaures" au lieu d'être affiché **à droite**, dans une colonne latérale d'environ 1/4 de la largeur.

Le layout grid est déjà en place dans [main/index.cfm](../lab/cb/views/main/index.cfm) (`grid gap-8 lg:grid-cols-[minmax(0,3fr)_minmax(260px,1fr)]`, `<aside>` après `<section>`), ce qui *devrait* placer le login à droite sur desktop. Vérifier :
- que Tailwind compile bien la classe arbitraire `lg:grid-cols-[minmax(0,3fr)_minmax(260px,1fr)]` (si le CSS est pré-compilé/purgé, cette classe générée dynamiquement peut être absente du bundle livré) ;
- que rien n'écrase ce grid plus haut dans la cascade (le `<nav>` du layout, le conteneur `max-w-3xl` dans `layouts/Main.cfm` qui pourrait limiter la largeur disponible) ;
- rendu sur la largeur réelle testée (desktop ≥ 1024px pour que `lg:` s'applique — sur mobile/tablette l'empilement vertical est normal et attendu).

## 3. Drapeaux masqués par la nav principale

Le changement de langue fonctionne côté logique (les liens `?lang=fr_FR` / `?lang=en_US` marchent), mais les drapeaux sont visuellement masqués par la nav principale.

Cause probable : le `<nav>` du header global ([header.cfm](../lab/header.cfm)) est en `fixed` (`nav class="fixed w-full ... h-28"`), donc hors du flux. Le `<nav>` secondaire du layout ColdBox ([layouts/Main.cfm](../lab/cb/layouts/Main.cfm)) qui contient les drapeaux est juste après un `<cfinclude template="../../header.cfm">` sans marge de compensation — il se retrouve donc caché sous les 112px (`h-28`) du header fixe. Ajouter un padding/margin-top équivalent à la hauteur du header fixe (ex. `pt-28` ou `mt-28` sur le premier élément après l'include, ou sur le `<nav>` des drapeaux lui-même) pour que ce bloc redescende sous la nav fixe.

## 4. Visuels dinosaure absents

Les fiches n'affichent aucune image : `image_main` n'est renseigné pour aucune des 5 fiches du seed (`db/seed.sql` ne peuple que `slug`, `category_id`, `author_id`, `status`, `published_at` — jamais `image_main`), et la vue `main/index.cfm` masque simplement l'`<img>` quand `len( article.imageMain )` est vide (pas d'image de remplacement).

Deux actions à faire :
- Ajouter un visuel par fiche : soit déposer 5 images sous `/lab/cb/includes/uploads/articles/{slug ou id}/` et mettre à jour `image_main` dans `db/seed.sql` (`UPDATE articles SET image_main = '...' WHERE slug = '...'`), soit prévoir une image placeholder par défaut affichée quand `image_main` est vide (au lieu de ne rien afficher).
- Vérifier que le chemin stocké dans `image_main` est bien résolvable publiquement (URL relative servie par le serveur web, pas un chemin filesystem), conformément à la convention `/lab/cb/includes/uploads/articles/{article_id}/` du §8 de `003 copilot-coldbox-project.md`.

---

## Résumé des actions pour Claude

1. Diagnostiquer et corriger le login (hash de mot de passe / persistance de session) pour que le CMS soit accessible après authentification.
2. Corriger le CSS/layout pour que le bloc Login s'affiche en colonne 1/4 à droite, pas sous le contenu principal.
3. Ajouter l'espace nécessaire sous la nav fixe globale pour que les drapeaux de langue restent visibles.
4. Ajouter des visuels (`image_main`) aux 5 fiches de démonstration, ou a minima une image placeholder par défaut.
