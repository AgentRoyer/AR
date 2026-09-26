# 004 — Claude ColdBox Project — Fix 2

> Suite au test du correctif `004 claude-coldbox-fix1.md`. Ce fichier le complète (ne le remplace pas) et liste les corrections restantes.

---

## 1. Le login ne fonctionne toujours pas — retombe sur le catalogue public

Après soumission du formulaire de login (compte de démo ou autre), l'utilisateur retombe systématiquement sur le catalogue public au lieu d'accéder au CMS. Comportement attendu : à l'authentification réussie, ouverture du CMS de gestion (`CmsArticles.index`), avec les droits déjà associés au compte (`superadmin` ou `editeur`) — le routage vers `CmsArticles.index` et les contrôles de rôle par handler sont déjà en place dans [Auth.cfc](../lab/cb/handlers/Auth.cfc) et [CmsArticles.cfc](../lab/cb/handlers/CmsArticles.cfc), donc le problème est en amont, dans la validation des identifiants ou la persistance de session.

Pistes à vérifier dans l'ordre, sans présumer laquelle est la cause réelle sans test en conditions réelles (Codespaces) :

- **Le seed a-t-il été réellement exécuté sur la base ?** `db/seed.sql` insère `testuser@cfdino.com` avec `SHA2('dino_cb_pass', 256)`, mais rien ne garantit que ce script a été joué contre l'instance MariaDB du Codespace actuel. Si la ligne n'existe pas dans `users`, [UserService.cfc](../lab/cb/models/security/UserService.cfc) → `retrieveUserByUsername()` renvoie une struct vide, `isValidCredentials()` renvoie `false`, et [Auth.cfc](../lab/cb/handlers/Auth.cfc) réaffiche simplement le formulaire (sur l'accueil, ça ressemble à « rien ne s'est passé, je suis toujours sur le catalogue »). Vérifier avec une requête directe : `SELECT email, role, is_active FROM users WHERE email = 'testuser@cfdino.com';`.
- **Le jeton CSRF ajouté en fix1 circule-t-il correctement ?** `cbcsrf` a `enableAutoVerifier: true` dans [Coldbox.cfc](../lab/cb/config/Coldbox.cfc) : toute requête POST sans jeton valide lève une exception (`TokenNotFoundException` / `TokenMismatchException`) interceptée par un `onException` actuellement vide dans [Main.cfc](../lab/cb/handlers/Main.cfc) — ce qui produit une page d'erreur silencieuse plutôt qu'un retour propre au formulaire. Confirmer qu'aucune exception n'est levée côté serveur lors de la soumission (logs Lucee / console).
- **La session persiste-t-elle après le `relocate()` ?** `Application.cfc` a `this.setDomainCookies = true`, ce qui indique à CFML de poser le cookie de session sur le domaine « racine ». Sur un host Codespaces du type `*.app.github.dev`, ce comportement peut mal découper le domaine et empêcher le cookie de session d'être renvoyé sur la requête suivante — dans ce cas, `session.user` disparaît immédiatement après le login et [CmsArticles.cfc](../lab/cb/handlers/CmsArticles.cfc) renvoie vers `Auth.login`. À tester en inspectant le cookie `CFID`/`CFTOKEN`/session dans les DevTools après une tentative de login.

## 2. Pré-remplir le formulaire de login avec le compte de démo

Actuellement les deux champs (email, mot de passe) sont vides par défaut sur l'accueil comme sur `/cms/login`. Pré-remplir avec `testuser@cfdino.com` / `dino_cb_pass` (valeurs par défaut du `value=""` des inputs), dans [main/index.cfm](../lab/cb/views/main/index.cfm) et [auth/login.cfm](../lab/cb/views/auth/login.cfm) — pour que les DSI puissent tester en un clic sans recopier le compte affiché juste en dessous.

## 3. Aligner "Catalogue Connexion [Drapeaux]" à droite, au-dessus du bloc Login

Le sous-menu (Catalogue / Connexion-CMS / Drapeaux) est bien `justify-end` dans [layouts/Main.cfm](../lab/cb/layouts/Main.cfm), mais il ne s'aligne pas visuellement au-dessus du bloc "Login" de la colonne de droite. Cause probable : **incohérence de largeur de conteneur** — le `<nav>` des liens/drapeaux est contraint à `max-w-5xl` (1024px) alors que le contenu principal juste en dessous (`#view()#`, qui contient la grille catalogue + colonne Login de [main/index.cfm](../lab/cb/views/main/index.cfm)) est enveloppé dans un `<div class="max-w-3xl ...">` (768px) — les bords droits des deux blocs ne coïncident donc pas. Aligner les deux conteneurs sur la même largeur maximale (ou faire porter le `max-w-*` par un wrapper commun aux deux) pour que le bord droit du nav retombe exactement au-dessus du bord droit du bloc Login.

## 4. Générer des visuels par fiche dinosaure

Le placeholder générique ajouté en fix1 doit être remplacé par une image simple et distincte par espèce pour les 5 fiches du seed :
`tyrannosaurus-rex`, `velociraptor`, `diplodocus`, `stegosaurus`, `triceratops`.

- Générer une image simple (illustration ou silhouette stylisée suffit, pas besoin de photoréalisme) par espèce.
- Les déposer sous `/lab/cb/includes/uploads/articles/` en suivant la convention du §8 de `003 copilot-coldbox-project.md` (un sous-dossier ou un nom de fichier par `article_id`/slug).
- Mettre à jour la colonne `image_main` de la table `articles` pour chaque fiche avec le chemin/nom de fichier généré — via une mise à jour de `db/seed.sql` (`UPDATE articles SET image_main = '...' WHERE slug = '...';`) pour que le seed reste rejouable.

---

## Résumé des actions pour Claude

1. Diagnostiquer la cause réelle de l'échec de login (seed non joué / exception CSRF silencieuse / cookie de session non persistant sur le domaine Codespaces) et corriger en conséquence pour que l'accès au CMS fonctionne avec les droits du compte connecté.
2. Pré-remplir les champs email/mot de passe des formulaires de login avec le compte de démo.
3. Faire coïncider la largeur du nav (Catalogue/Connexion/Drapeaux) avec celle du contenu principal pour un alignement propre au-dessus du bloc Login.
4. Générer 5 images simples (une par espèce), les uploader dans `includes/uploads/articles/`, et mettre à jour `image_main` en base (et dans `db/seed.sql`) pour chaque fiche.
