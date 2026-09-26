# 003 — Copilot ColdBox Project — Fix 1

> Suite au premier test sur `https://fictional-acorn-9qg4vvrvjphx7rv-8888.app.github.dev/lab/cb/`. Ce fichier complète `06 copilot-coldbox-project.md` (ne le remplace pas) et liste les corrections à apporter avant de poursuivre le développement du CMS.

---

## Constat actuel

La page d'accueil affiche encore la vue par défaut générée lors du scaffolding :
- Une box **"Database test (datasource "coldbox")"** — diagnostic de connexion DB.
- Une box **"Registered event handlers"** listant `CmsCategories`, `CmsArticles`, `Main`, `CmsUsers`, `Articles`, `Auth` — ce sont des liens de debug internes au scaffold, pas la navigation réelle du site.
- Un bouton **"Voir les fiches dinosaures"** qui ne mène nulle part de fonctionnel.
- Aucun des liens ci-dessus ne répond correctement.
- Aucun formulaire de connexion visible.

Ce n'est pas la page d'accueil publique attendue. À remplacer entièrement.

---

## 1. Supprimer la box "Database test"

Retirer complètement ce bloc de `views/main/index.cfm` (ou d'où qu'il soit inclus). Ce n'était qu'un test de connexion pendant l'installation, il n'a plus lieu d'être visible publiquement.

Si un test de connectivité DB reste utile en dev, le garder uniquement dans `/lab/cb/dbtest.cfm` **non lié depuis aucune vue**, à appeler manuellement en direct par URL si besoin.

## 2. Réparer les liens

Aucun lien du site ne fonctionne actuellement. Vérifier systématiquement, pour chaque handler listé (`Main`, `Articles`, `Auth`, `CmsArticles`, `CmsCategories`, `CmsUsers`) :
- que les routes correspondantes existent bien dans `config/Router.cfc`, conformes à la table de routing du §6 de `06 copilot-coldbox-project.md` ;
- que chaque action référencée (`index`, `show`, `new`, `edit`, `login`, etc.) existe réellement dans le `.cfc` du handler, même sous forme de stub temporaire ;
- que la vue associée existe au chemin attendu (`views/{handler}/{action}.cfm`) — un lien qui pointe vers une vue manquante est une cause fréquente d'erreur silencieuse ou de 500.

Tester chaque route une par une après correction, y compris en navigation directe par URL.

## 3. Retirer le bloc "Registered event handlers" de l'accueil — sécuriser le CMS

Ce bloc n'a rien à faire sur une page publique : il expose la structure interne de l'admin sans authentification.

- Supprimer ce bloc de la vue d'accueil.
- Toutes les routes `/cms/*` (handlers `CmsArticles`, `CmsCategories`, `CmsUsers`) doivent être protégées par le firewall `cbsecurity`, selon la matrice de permissions déjà définie (§5 de `06 copilot-coldbox-project.md`) :
  - Non connecté → redirection vers `/cms/login`.
  - Connecté en `editeur` mais route réservée `superadmin` (`CmsCategories`, `CmsUsers`) → 403 / redirection.
- Une fois connecté en `superadmin`, un lien vers le tableau de bord CMS peut apparaître dans le header du site (à la place de "Voir les fiches dinosaures"), mais jamais sur une page accessible sans authentification.

## 4. Ajouter le formulaire de login sur l'accueil

Conformément au besoin initial (compte de démo visible en clair pour que les DSI puissent tester sans naviguer), le formulaire de connexion doit être **directement présent sur la page d'accueil publique**, pas seulement accessible via `/cms/login`.

Contenu attendu sur l'accueil :
- Un petit bloc "Espace éditeur" avec :
  - champ email, champ mot de passe, bouton "Se connecter"
  - lien "Créer un compte éditeur" → `/cms/register`
  - bouton Google **masqué en dev** (Codespaces), affiché uniquement en prod (`cfdino.com`) — voir §4.3 du fichier initial
- Juste au-dessus ou à côté du formulaire, en clair, non masqué :
  ```
  Compte de démonstration :
  email : testuser@cfdino.com
  mot de passe : dino_cb_pass
  ```

## 5. Page d'accueil = listing des fiches dinosaures

Le bouton "Voir les fiches dinosaures" devient inutile : l'accueil doit directement afficher la grille des fiches publiées (`status = 'published'`), dans la langue courante (via `cbi18n`), avec pour chaque fiche :
- image principale (`image_main`)
- titre (`article_translations.title`)
- extrait (`article_translations.excerpt`)
- catégorie (nom traduit)
- lien vers la fiche détail

Filtrage optionnel par catégorie (liens ou onglets en haut de la grille) — peut être ajouté dans une itération suivante si pas prioritaire maintenant.

---

## 6. Jeu de données de démonstration

La base est vide pour l'instant. Insérer 3 catégories et 5 fiches factices, en FR et EN.

### 6.1 Catégories

```sql
INSERT INTO categories (slug, icon) VALUES
  ('theropodes', 'paw'),
  ('sauropodes', 'leaf'),
  ('herbivores-cuirasses', 'shield');

INSERT INTO category_translations (category_id, locale, name) VALUES
  ((SELECT id FROM categories WHERE slug='theropodes'), 'fr_FR', 'Théropodes'),
  ((SELECT id FROM categories WHERE slug='theropodes'), 'en_US', 'Theropods'),
  ((SELECT id FROM categories WHERE slug='sauropodes'), 'fr_FR', 'Sauropodes'),
  ((SELECT id FROM categories WHERE slug='sauropodes'), 'en_US', 'Sauropods'),
  ((SELECT id FROM categories WHERE slug='herbivores-cuirasses'), 'fr_FR', 'Herbivores cuirassés'),
  ((SELECT id FROM categories WHERE slug='herbivores-cuirasses'), 'en_US', 'Armored herbivores');
```

### 6.2 Compte de test

⚠️ Ne pas insérer le mot de passe directement en SQL en clair : le hash doit correspondre exactement à la méthode utilisée par `UserService.cfc`. Créer ce compte via le formulaire d'inscription réel de l'application (`/cms/register`), avec :
```
email    : testuser@cfdino.com
password : dino_cb_pass
```
Puis passer son rôle en `editeur` s'il n'est pas déjà le rôle par défaut à l'inscription :
```sql
UPDATE users SET role = 'editeur', is_active = TRUE
WHERE email = 'testuser@cfdino.com';
```

### 6.3 Les 5 fiches

Une fois le compte de test créé (récupère son `id`), exécuter :

```sql
SET @author_id = (SELECT id FROM users WHERE email = 'testuser@cfdino.com');
SET @cat_thero = (SELECT id FROM categories WHERE slug = 'theropodes');
SET @cat_sauro = (SELECT id FROM categories WHERE slug = 'sauropodes');
SET @cat_cuir  = (SELECT id FROM categories WHERE slug = 'herbivores-cuirasses');

INSERT INTO articles (slug, category_id, author_id, status, published_at) VALUES
  ('tyrannosaurus-rex', @cat_thero, @author_id, 'published', NOW()),
  ('velociraptor',      @cat_thero, @author_id, 'published', NOW()),
  ('diplodocus',        @cat_sauro, @author_id, 'published', NOW()),
  ('stegosaurus',       @cat_cuir,  @author_id, 'published', NOW()),
  ('triceratops',       @cat_cuir,  @author_id, 'published', NOW());

-- Tyrannosaurus Rex
INSERT INTO article_translations (article_id, locale, title, excerpt, content) VALUES
((SELECT id FROM articles WHERE slug='tyrannosaurus-rex'), 'fr_FR',
 'Tyrannosaurus Rex',
 'Le roi des prédateurs du Crétacé supérieur, avec une mâchoire capable de broyer les os.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"Un chasseur redoutable","level":2}},{"type":"paragraph","data":{"text":"Le Tyrannosaurus rex vivait en Amérique du Nord il y a environ 68 a 66 millions d''annees, a la toute fin du Cretace."}},{"type":"paragraph","data":{"text":"Sa morsure figure parmi les plus puissantes jamais mesurees chez un animal terrestre, capable de briser les os de ses proies."}}],"version":"2.28.2"}'),
((SELECT id FROM articles WHERE slug='tyrannosaurus-rex'), 'en_US',
 'Tyrannosaurus Rex',
 'The king of Late Cretaceous predators, with a bite powerful enough to crush bone.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"A fearsome hunter","level":2}},{"type":"paragraph","data":{"text":"Tyrannosaurus rex lived in North America around 68 to 66 million years ago, right at the end of the Cretaceous period."}},{"type":"paragraph","data":{"text":"Its bite ranks among the most powerful ever measured in a land animal, strong enough to crush the bones of its prey."}}],"version":"2.28.2"}');

-- Velociraptor
INSERT INTO article_translations (article_id, locale, title, excerpt, content) VALUES
((SELECT id FROM articles WHERE slug='velociraptor'), 'fr_FR',
 'Velociraptor',
 'Petit theropode rapide et intelligent, bien plus modeste en taille que dans les films.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"Un chasseur agile","level":2}},{"type":"paragraph","data":{"text":"Le velociraptor mesurait environ 2 metres de long pour un poids d''une quinzaine de kilos, bien loin des versions geantes vues au cinema."}},{"type":"paragraph","data":{"text":"Il possedait une grande griffe recourbee sur chaque pied arriere, probablement utilisee pour maitriser ses proies."}}],"version":"2.28.2"}'),
((SELECT id FROM articles WHERE slug='velociraptor'), 'en_US',
 'Velociraptor',
 'A small, fast and intelligent theropod - much smaller than the movies suggest.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"An agile hunter","level":2}},{"type":"paragraph","data":{"text":"Velociraptor was about 2 meters long and weighed around fifteen kilograms, far from the oversized movie versions."}},{"type":"paragraph","data":{"text":"It had a large curved claw on each hind foot, likely used to grip and control its prey."}}],"version":"2.28.2"}');

-- Diplodocus
INSERT INTO article_translations (article_id, locale, title, excerpt, content) VALUES
((SELECT id FROM articles WHERE slug='diplodocus'), 'fr_FR',
 'Diplodocus',
 'Un geant herbivore au cou interminable, parmi les animaux les plus longs ayant jamais existe.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"Un cou hors norme","level":2}},{"type":"paragraph","data":{"text":"Le diplodocus pouvait atteindre pres de 25 metres de long, dont une grande partie occupee par son cou et sa queue en forme de fouet."}},{"type":"paragraph","data":{"text":"Malgre sa taille impressionnante, il se nourrissait exclusivement de vegetaux."}}],"version":"2.28.2"}'),
((SELECT id FROM articles WHERE slug='diplodocus'), 'en_US',
 'Diplodocus',
 'A giant herbivore with an impossibly long neck, among the longest animals to ever exist.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"An extraordinary neck","level":2}},{"type":"paragraph","data":{"text":"Diplodocus could reach nearly 25 meters in length, much of it taken up by its long neck and whip-like tail."}},{"type":"paragraph","data":{"text":"Despite its impressive size, it fed exclusively on plants."}}],"version":"2.28.2"}');

-- Stegosaurus
INSERT INTO article_translations (article_id, locale, title, excerpt, content) VALUES
((SELECT id FROM articles WHERE slug='stegosaurus'), 'fr_FR',
 'Stegosaure',
 'Reconnaissable a ses plaques dorsales et sa queue armee de piques defensives.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"Une silhouette unique","level":2}},{"type":"paragraph","data":{"text":"Le stegosaure arborait une double rangee de grandes plaques osseuses le long du dos, dont le role exact reste debattu par les paleontologues."}},{"type":"paragraph","data":{"text":"Sa queue se terminait par quatre longues piques, une arme defensive redoutable face aux predateurs."}}],"version":"2.28.2"}'),
((SELECT id FROM articles WHERE slug='stegosaurus'), 'en_US',
 'Stegosaurus',
 'Instantly recognizable by its back plates and spiked defensive tail.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"A distinctive silhouette","level":2}},{"type":"paragraph","data":{"text":"Stegosaurus carried a double row of large bony plates along its back, whose exact purpose is still debated among paleontologists."}},{"type":"paragraph","data":{"text":"Its tail ended in four long spikes, a formidable defensive weapon against predators."}}],"version":"2.28.2"}');

-- Triceratops
INSERT INTO article_translations (article_id, locale, title, excerpt, content) VALUES
((SELECT id FROM articles WHERE slug='triceratops'), 'fr_FR',
 'Triceratops',
 'Trois cornes et une immense collerette osseuse pour repousser les predateurs.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"Un herbivore bien arme","level":2}},{"type":"paragraph","data":{"text":"Le triceratops possedait trois cornes faciales et une large collerette osseuse pouvant depasser deux metres de long."}},{"type":"paragraph","data":{"text":"Il comptait parmi les proies favorites du Tyrannosaurus rex, avec lequel il partageait le meme habitat."}}],"version":"2.28.2"}'),
((SELECT id FROM articles WHERE slug='triceratops'), 'en_US',
 'Triceratops',
 'Three horns and a massive bony frill to fend off predators.',
 '{"time":1,"blocks":[{"type":"header","data":{"text":"A well-armed herbivore","level":2}},{"type":"paragraph","data":{"text":"Triceratops had three facial horns and a wide bony frill that could exceed two meters in length."}},{"type":"paragraph","data":{"text":"It was among the favorite prey of Tyrannosaurus rex, with which it shared the same habitat."}}],"version":"2.28.2"}');
```

*(Accents omis volontairement dans le JSON/SQL ci-dessus pour éviter tout souci d'encodage lors du copier-coller — à corriger/enrichir une fois le rendu confirmé fonctionnel.)*

---

## Résumé des actions pour Copilot

1. Supprimer la box de test DB de l'accueil.
2. Auditer et corriger routes + actions + vues pour que tous les liens répondent.
3. Retirer le bloc "Registered event handlers" de l'accueil ; sécuriser `/cms/*` via `cbsecurity` selon la matrice de rôles.
4. Ajouter un formulaire de login sur l'accueil public + afficher le compte de démo en clair.
5. Remplacer le bouton "Voir les fiches dinosaures" par le listing réel des fiches publiées.
6. Exécuter le seed : 3 catégories + création du compte test via `/cms/register` + 5 fiches bilingues.
