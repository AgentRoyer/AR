# 06 — Copilot ColdBox Project Spec : CMS bilingue "Fiches Dinosaures"

> Ce fichier sert de contexte pour GitHub Copilot (mode agent). Il décrit l'environnement, l'architecture, le modèle de données et les règles métier du projet. Toute génération de code doit respecter ces contraintes — en particulier l'absence de CommandBox en production.

---

## 1. Environnement

| | |
|---|---|
| **Framework** | ColdBox 8.1.0 |
| **Moteur CFML** | Lucee 7 |
| **Base de données** | MariaDB `10.11.18-MariaDB-ubu2204` |
| **Dev** | GitHub Codespaces — racine app : `/lab/cb/` (dans `/var/www/`) |
| **URL de test (dev)** | `https://fictional-acorn-9qg4vvrvjphx7rv-8888.app.github.dev/lab/cb/` *(URL éphémère, change si le Codespace est recréé)* |
| **Prod (cible)** | `cfdino.com/lab/cb/` — hébergement mutualisé 9planethosting, **sans accès Admin Lucee, sans CommandBox** |
| **Datasource** | `this.datasources["coldbox"]` déclarée en dur dans `Application.cfc` (voir fichier existant) |

⚠️ **Règle absolue** : tous les modules/librairies tiers sont installés **manuellement** (zip GitHub → dossier `/lab/cb/modules/`), jamais via `box install`. Le dossier `modules/` est auto-scanné par ColdBox, aucun mapping supplémentaire n'est requis dans `Application.cfc`.

---

## 2. Modules à installer

Même méthode que pour `coldbox/system` et `cbi18n` : télécharger le zip de la branche `development`, ne garder que le contenu utile (ignorer `.github/`, `.vscode/`, `test-harness/`, `build/`, `box.json`, `server-*.json`, `changelog.md`, `readme.md`), copier dans le dossier cible.

| Module | Rôle | Source | Destination |
|---|---|---|---|
| `cbstorages` | Stockage session/cookie (déjà fait) | `github.com/coldbox-modules/cbstorages` | `/lab/cb/modules/cbstorages/` |
| `cbi18n` | i18n interface + contenu (déjà fait) | `github.com/coldbox-modules/cbi18n` | `/lab/cb/modules/cbi18n/` |
| `cbauth` | Service de session d'authentification | `github.com/coldbox-modules/cbauth` | `/lab/cb/modules/cbauth/` |
| `cbcsrf` | Protection CSRF sur les formulaires | `github.com/coldbox-modules/cbcsrf` | `/lab/cb/modules/cbcsrf/` |
| `cbsecurity` | Firewall / règles d'accès par rôle | `github.com/coldbox-modules/cbsecurity` | `/lab/cb/modules/cbsecurity/` |

Pattern de téléchargement pour chacun :
```
https://github.com/coldbox-modules/{nom-module}/archive/refs/heads/development.zip
```

---

## 3. Modèle de données

```sql
-- Utilisateurs
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NULL,        -- NULL si login Google uniquement
    google_id     VARCHAR(255) NULL UNIQUE, -- NULL si login classique
    display_name  VARCHAR(100) NOT NULL,
    role          ENUM('superadmin','editeur') NOT NULL DEFAULT 'editeur',
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Catégories (gérées par superadmin uniquement)
CREATE TABLE categories (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    slug       VARCHAR(100) NOT NULL UNIQUE,
    icon       VARCHAR(50)  NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE category_translations (
    category_id INT NOT NULL,
    locale      VARCHAR(10) NOT NULL,   -- 'fr_FR' | 'en_US'
    name        VARCHAR(150) NOT NULL,
    PRIMARY KEY (category_id, locale),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Fiches dinosaures
CREATE TABLE articles (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    slug          VARCHAR(150) NOT NULL UNIQUE,
    category_id   INT NOT NULL,
    author_id     INT NOT NULL,
    image_main    VARCHAR(255) NULL,  -- photo listing
    image_2       VARCHAR(255) NULL,  -- illustration description
    image_3       VARCHAR(255) NULL,  -- illustration description
    status        ENUM('draft','pending','published') NOT NULL DEFAULT 'draft',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at  DATETIME NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (author_id)   REFERENCES users(id)
);

CREATE TABLE article_translations (
    article_id INT NOT NULL,
    locale     VARCHAR(10) NOT NULL,
    title      VARCHAR(200) NOT NULL,
    excerpt    VARCHAR(500) NULL,
    content    LONGTEXT NOT NULL,  -- JSON Editor.js (blocs)
    PRIMARY KEY (article_id, locale),
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE
);
```

**Compte de démonstration** (affiché en clair sur la page d'accueil pour les DSI) :
```
email    : testuser@cfdino.com
password : dino_cb_pass
role     : editeur
```

---

## 4. Authentification

### 4.1 cbauth — `UserService`

À créer dans `models/security/UserService.cfc`, implémentant :
- `isValidCredentials( username, password )`
- `retrieveUserByUsername( username )`
- `retrieveUserById( id )`
- L'objet utilisateur retourné doit exposer `getId()`

Config dans `config/ColdBox.cfc` :
```cfc
moduleSettings = {
    cbauth = {
        userServiceClass = "UserService@models"
    }
};
```

### 4.2 Inscription libre (éditeurs uniquement)

- Formulaire simple : email + mot de passe → crée un `user` avec `role = 'editeur'`.
- Hash du mot de passe : `hash( password, "SHA-256" )` minimum, idéalement bcrypt si disponible côté Lucee.
- Les superadmins ne peuvent **pas** être créés par ce formulaire (rôle attribué uniquement en base par vous).

### 4.3 Login Google — **PROD UNIQUEMENT**

- En dev (Codespaces) : bouton "Se connecter avec Google" **masqué**, seul le login email/password est actif — l'URL Codespace étant éphémère, elle ne peut pas être enregistrée comme *redirect URI* côté Google Cloud Console.
- En prod (`cfdino.com`) : afficher le bouton, une fois l'OAuth configuré avec l'URI définitive `https://cfdino.com/lab/cb/auth/google/callback`.
- Implémentation : détection d'environnement dans `config/ColdBox.cfc` (`function production(){ ... }`) pour activer/désactiver ce bouton côté vue.

---

## 5. Permissions

| Action | Superadmin | Éditeur |
|---|---|---|
| Gérer les catégories (CRUD) | ✅ | ❌ |
| Créer une fiche | ✅ | ✅ |
| Modifier / supprimer **sa propre** fiche | ✅ | ✅ |
| Modifier / supprimer la fiche **d'un autre** éditeur | ✅ | ❌ |
| Publier directement une fiche | ✅ | ❌ (passe par validation) |
| Valider / rejeter une fiche en attente | ✅ | ❌ |
| Gérer les comptes utilisateurs | ✅ | ❌ |

### Workflow de statut d'une fiche

```
draft  -->  pending  -->  published
  ↑            |
  └────────────┘  (rejet superadmin, retour en brouillon)
```

- `draft` : l'éditeur travaille dessus, non visible publiquement.
- `pending` : soumise par l'éditeur, en attente de validation superadmin.
- `published` : validée par un superadmin, visible sur le site public.
- Le superadmin peut passer directement `draft → published` sur ses propres fiches (pas de workflow pour lui-même).

Contrôle d'accès via `cbsecurity`, règles par préfixe de route (voir §6).

---

## 6. Routing

```
# Public (bilingue)
/:lang/dinosaures                    -> Articles.index   (liste, filtrée par catégorie en option)
/:lang/dinosaures/:categorie         -> Articles.index
/:lang/dinosaures/:categorie/:slug   -> Articles.show

# Authentification
/cms/login                           -> Auth.login
/cms/register                        -> Auth.register
/cms/auth/google/callback            -> Auth.googleCallback   (prod uniquement)
/cms/logout                          -> Auth.logout

# CMS (protégé — cbsecurity, rôle editeur ou superadmin)
/cms/articles                        -> CmsArticles.index    (liste : toutes si superadmin, siennes si editeur)
/cms/articles/new                    -> CmsArticles.new
/cms/articles/:id/edit               -> CmsArticles.edit
/cms/articles/:id/submit             -> CmsArticles.submit    (draft -> pending)

# CMS (protégé — rôle superadmin uniquement)
/cms/articles/:id/validate           -> CmsArticles.validate  (pending -> published)
/cms/articles/:id/reject             -> CmsArticles.reject    (pending -> draft)
/cms/categories                      -> CmsCategories.index
/cms/categories/new                  -> CmsCategories.new
/cms/users                           -> CmsUsers.index
```

Interface `/cms/*` : **bilingue** (FR/EN), pilotée par `cbi18n` avec un bundle de resources dédié `includes/i18n/admin` (distinct du bundle public `includes/i18n/main`).

---

## 7. Éditeur de contenu

- Librairie : **[Editor.js](https://editorjs.io/)** — éditeur par blocs (paragraphe, titre, liste, citation, image), le plus proche de l'expérience Gutenberg sans dépendance lourde.
- Contenu stocké en `LONGTEXT` (colonne `content` de `article_translations`) au format JSON natif d'Editor.js.
- Rendu public : parser simple JSON → HTML côté vue (`ArticleRenderer.cfc` à créer dans `models/`).

## 8. Upload d'images

- 3 slots par fiche : `image_main` (listing + en-tête fiche), `image_2` et `image_3` (illustrations dans le corps de la fiche).
- Formats acceptés : `.jpg`, `.jpeg`, `.png`, `.webp`.
- Taille max recommandée : 2 Mo/image.
- Stockage : `/lab/cb/includes/uploads/articles/{article_id}/`.

---

## 9. Points restant à trancher en cours de dev

- Choix définitif éditeur (Editor.js retenu par défaut — à confirmer).
- Politique de nommage des fichiers uploadés (slug + timestamp recommandé pour éviter les collisions).
- Faut-il un email de notification au superadmin quand une fiche passe en `pending` ? (hors scope initial, à ajouter si souhaité)
