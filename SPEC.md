# Spec : Juste-a v1 — Epitech + Obsidian

> Statut : **validée le 2026-10-15**. Langue : français. Dernière mise à jour : 2026-10-15.

## Objectif

Aujourd'hui, l'étudiant fait le lien à la main entre my.epitech.eu, ses mails, Calendrier et ses notes. Il perd du temps à vérifier quand les projets commencent et s'il y est inscrit.

La v1 de Juste-a :
1. affiche les **projets Epitech en cours** avec leurs dates (début, fin des inscriptions, fin) et le statut **inscrit / pas inscrit** ;
2. **prévient par notification macOS** quand les inscriptions à un projet où il n'est pas inscrit vont fermer ;
3. propose sur chaque projet un bouton **« Note »** qui crée la note `Epitech/<Projet>.md` dans le vault Obsidian si elle n'existe pas, puis l'ouvre dans Obsidian.

**Utilisateur :** une seule personne, le propriétaire du Mac, étudiant Epitech.

**Succès :** il n'ouvre plus my.epitech.eu pour vérifier ses inscriptions, il ne rate plus de fin d'inscription, et chaque projet a sa note en un clic.

### Hors v1
Activités Epitech (soutenances, kick-offs), mails, ajout automatique des dates Epitech dans Calendrier, brief du matin et bilans IA, Spotify, lecture ou recherche de notes dans Juste-a, plugin Obsidian, inscription à un projet depuis Juste-a.

## Carte des modules

| Module | Rôle | Dépend de |
|---|---|---|
| `epitech-session` | Connexion à my.epitech.eu dans une WebView, lecture du token | — |
| `epitech-projects` | Appels API, modèle `EpitechProject`, calcul inscrit / pas inscrit | `epitech-session` |
| `registration-alerts` | Décide quand notifier, envoie la notification, sans doublon | `epitech-projects` |
| `obsidian-notes` | Choix du vault, création et ouverture de la note | `epitech-projects` (nom et dates du projet) |

Ordre de construction : `epitech-session` → `epitech-projects` → `registration-alerts` et `obsidian-notes` (indépendants l'un de l'autre).

## Ce qu'on sait de l'API (relevé le 2026-10-15 dans les DevTools)

API privée et non documentée, servie par Express sur `https://my.epitech.eu/api/`.

- **Auth :** header `Authorization: Bearer <JWT>`. Les cookies ne sont pas nécessaires.
- **Token :** le site se connecte via MSAL (compte Microsoft Epitech) et range son propre JWT dans `localStorage["@account"]` (JSON, champ `token`). Il dure environ **6 h** (`exp - iat ≈ 21 400 s`) et MSAL le renouvelle tout seul tant que la session Microsoft est vivante.
- **Liste des projets :** `GET /api/units/instances/projects?page=1&limit=50&status=ongoing&schoolYear=2026`. La réponse a la forme `{"data": [...], "meta": {"page", "limit", "total", "pages", "hasNext", "hasPrev"}}`. Le 2026-10-15 : 28 projets en une seule page, environ 170 Ko.
- **Chaque projet de la liste contient `isUserRegistered` (bool)** : **un seul appel suffit**. Vérifié : identique au filtre `registeredOnly=true`, qu'on n'utilise donc pas. `registrations` ne contient que ma propre inscription, pas celles des autres.
- **Détail d'un projet :** `GET /api/units/{schoolYear}/{unitCode}/{instanceCode}/projects/{id}` (environ 84 Ko, avec la liste de tous les inscrits). **On ne l'appelle pas en v1.**
- **Champs utiles (présents dans la liste, vérifiés) :** `id`, `name`, `schoolYear`, `startDate`, `endRegistrationDate`, `endDate` (ISO 8601 en UTC avec millisecondes), `isUserRegistered`, `unitInstance.{unitCode, code, name, timezone}`. Le fuseau du campus est `Indian/Reunion`.
  - ⚠️ Utiliser `endRegistrationDate` **du projet**, pas celui de `projectTemplate` (qui diffère).
- **URL de la page du projet :** `https://my.epitech.eu/units/{schoolYear}/{unitCode}/{instanceCode}/projects/{id}`

## Comportement attendu

### `epitech-session`
- Au premier lancement, ou quand la session est perdue : une fenêtre affiche `https://my.epitech.eu` dans une `WKWebView` et l'utilisateur se connecte normalement.
- La WebView utilise le `WKWebsiteDataStore` par défaut (persistant), pour que la session Microsoft survive aux redémarrages.
- Le token est lu avec `evaluateJavaScript("localStorage.getItem('@account')")`, puis décodé en JSON. **Juste-a ne stocke jamais le token**, ni sur disque ni dans le Keychain : il le relit dans la WebView chaque fois qu'il en a besoin.
- Si le token est absent ou expire dans moins de 10 minutes (`exp` lu dans le payload du JWT), la WebView recharge la page en arrière-plan et le token est relu. S'il manque toujours, l'état passe à « déconnecté ».
- À l'état « déconnecté », la barre de menu affiche « Reconnecte-toi à Epitech », et un clic ouvre la fenêtre de connexion.

### `epitech-projects`
- Rafraîchit au lancement, à l'ouverture de la barre de menu (au plus une fois toutes les 15 min) et **toutes les 2 h** tant que l'app tourne.
- Fait **un seul appel** à la liste `ongoing`, puis lit `isUserRegistered` dans chaque projet. Enchaîne les pages tant que `meta.hasNext` est vrai.
- Un `401` ou `403` fait passer la session à « déconnecté ». Toute autre erreur (réseau, JSON inattendu) affiche « Epitech indisponible » et garde la dernière liste en mémoire. L'app ne plante jamais.
- L'affichage, dans la barre de menu et dans le dashboard :
  - d'abord les projets **pas inscrits dont les inscriptions sont ouvertes**, triés par date de fin d'inscription la plus proche, avec « ferme dans X j » ;
  - puis les projets où je suis inscrit, triés par date de fin.
  - Chaque ligne affiche le nom, le module et les dates en heure locale, avec un bouton « Ouvrir » vers la page my.epitech.eu et un bouton « Note ».

### `registration-alerts`
- Après chaque rafraîchissement, et pour chaque projet **pas inscrit** dont les inscriptions sont encore ouvertes :
  - notifie à **J-3** et à **J-1** avant `endRegistrationDate`, une fois par seuil et par projet ;
  - notifie aussi **la première fois qu'un tel projet apparaît** (« Nouveau projet : X, inscriptions jusqu'au … »).
- **Premier rafraîchissement réussi : aucune notification.** Tous les projets visibles sont enregistrés comme « déjà vus », avec les seuils déjà dépassés. Sans ça, le premier lancement enverrait environ 18 notifs d'un coup : le 2026-10-15, 18 projets non inscrits avaient leurs inscriptions ouvertes. À partir du deuxième rafraîchissement, les règles ci-dessus s'appliquent normalement.
- La clé anti-doublon `"<projectId>:<seuil>"` est rangée dans `UserDefaults`. La notification est le seul effet de bord.
- Le texte ressemble à : « Inscriptions à *Cloud Architecting* : ferment dans 1 jour (lun. 26/10, 00:42) ». Un clic sur la notification ouvre la page du projet.
- L'autorisation de notifier (`UNUserNotificationCenter.requestAuthorization`) est demandée au premier rafraîchissement réussi.

### Lancement au démarrage
- Au premier lancement, l'app s'enregistre comme élément d'ouverture avec `SMAppService.mainApp.register()`. On peut la désactiver dans Réglages Système › Général › Ouverture. Une erreur d'enregistrement est ignorée sans planter.

### `obsidian-notes`
- Au premier clic sur « Note », un `NSOpenPanel` demande de choisir le dossier du vault. Le choix est mémorisé grâce à un **security-scoped bookmark**, rangé dans `UserDefaults`.
- Nom du fichier : `Epitech/<name>.md`. Les caractères `/ \ : * ? " < > |` sont remplacés par `-` et les espaces en trop sont supprimés. Le dossier `Epitech/` est créé s'il manque.
- Si le fichier existe, il **n'est jamais réécrit**. Sinon, il est créé avec ce modèle :
  ```markdown
  ---
  epitech_id: 5617
  module: User Group - AWS
  start: 2026-09-14
  registration_end: 2026-10-26
  end: 2027-01-18
  url: https://my.epitech.eu/units/2026/S-INN-000/ALL-1/projects/5617
  ---
  # [PRIMARY] - Cloud Architecting

  ```
  Les dates sont en heure locale, au format `yyyy-MM-dd`.
- Le fichier est ensuite ouvert avec `NSWorkspace.shared.open(URL("obsidian://open?path=<chemin absolu encodé>"))`.
- Si le bookmark est périmé ou le dossier introuvable, l'app redemande le dossier.

## Stack technique

Celle qui existe déjà, **sans nouvelle dépendance** :
- Swift 6, SwiftUI, macOS 14+, projet généré par XcodeGen (`project.yml`)
- `WebKit` (WKWebView), `URLSession`, `UserNotifications`, `ServiceManagement` (SMAppService), `AppKit` (NSOpenPanel, NSWorkspace)
- `UserDefaults` pour l'anti-doublon et le bookmark. Pas de nouveau modèle SwiftData en v1 : la liste des projets reste en mémoire.

## Commandes

```sh
xcodegen                                                       # régénère JusteA.xcodeproj après toute modif de project.yml
xcodebuild build -scheme JusteA -destination 'platform=macOS,arch=arm64'
xcodebuild test  -scheme JusteA -destination 'platform=macOS,arch=arm64'
open JusteA.xcodeproj                                          # puis ⌘R pour lancer
```

## Structure du projet

```
JusteA/
├── EpitechSession.swift     WKWebView de connexion + lecture et expiration du token
├── EpitechService.swift     appels API, modèle EpitechProject, inscrit/pas inscrit, rafraîchissement
├── RegistrationAlerts.swift décision « faut-il notifier ? » (fonction pure) + envoi
├── ObsidianNotes.swift      bookmark du vault, nom de fichier, modèle de note, ouverture
├── Widgets.swift            + carte « Projets Epitech » partagée par le dashboard et la barre de menu
└── (existants inchangés sauf DashboardView, MenuBarView, JusteAApp pour brancher le service)
JusteATests/
├── Fixtures/projects-page.json   réponse de liste ANONYMISÉE (2–3 projets, aucun login réel)
├── EpitechServiceTests.swift
├── RegistrationAlertsTests.swift
└── ObsidianNotesTests.swift
```

Modifications de `project.yml` :
- entitlement `com.apple.security.files.user-selected.read-write: true` (écriture dans le vault)
- entitlement `com.apple.security.files.bookmarks.app-scope: true`
- `Fixtures/` ajouté aux ressources de la cible de tests

## Style de code

On suit le code existant : services `@MainActor @Observable final class`, état en `private(set) var`, un commentaire `///` en français pour dire **pourquoi**, des fonctions pures testables à côté du service.

```swift
import Foundation

struct EpitechProject: Decodable, Identifiable {
    let id: Int
    let name: String
    let startDate: Date
    let endRegistrationDate: Date
    let endDate: Date
    let isUserRegistered: Bool

    /// Les inscriptions comptent seulement si je ne suis pas inscrit et qu'elles sont encore ouvertes.
    func needsRegistration(at now: Date) -> Bool {
        !isUserRegistered && endRegistrationDate > now
    }
}
```

- Noms en anglais dans le code, textes de l'interface et commentaires en français.
- Pas de `try!` ni de force unwrap sur les données réseau ou les fichiers.
- Dates décodées avec `JSONDecoder.dateDecodingStrategy = .iso8601` (avec les fractions de seconde), affichées avec `Date.formatted`, jamais formatées à la main.

## Stratégie de test

XCTest, comme `TodoItemTests`. On teste la logique pure, pas le réseau ni la WebView.

| Quoi | Niveau | Comment |
|---|---|---|
| Décodage d'une page de liste | unitaire | fixture JSON anonymisée |
| `needsRegistration`, tri, pagination (`meta.hasNext`) | unitaire | données en dur, date « maintenant » injectée |
| Expiration du JWT (lecture de `exp`) | unitaire | faux JWT construit dans le test |
| Décision de notification (J-3, J-1, nouveau projet, pas de doublon, 1er rafraîchissement silencieux) | unitaire | fonction pure `(projects, now, alreadySent) -> [Alert]` |
| Nom de fichier assaini, contenu du modèle de note | unitaire | chaînes en dur |
| Connexion, renouvellement du token, appels réels, notifications, ouverture d'Obsidian | manuel | checklist dans les critères de succès |

Tous les tests passent avant chaque commit (`xcodebuild test …`).

## Limites

- **Toujours :** relancer `xcodegen` après toute modif de `project.yml` ; lancer les tests avant de proposer un commit ; anonymiser toute réponse d'API avant d'en faire une fixture ; gérer chaque erreur réseau sans planter.
- **Demander d'abord :** ajouter une dépendance ; ajouter un modèle SwiftData ; appeler un endpoint qui **modifie** quelque chose (inscription, désinscription) ; changer la fréquence de rafraîchissement sous 1 h.
- **Jamais :** écrire le token ou un identifiant sur disque, dans les logs ou dans un fichier versionné ; committer une réponse d'API non anonymisée (données d'autres étudiants) ; réécrire une note Obsidian existante ; faire `git commit` ou `git push` (c'est l'utilisateur qui gère git).

## Critères de succès

1. Après connexion dans la fenêtre Epitech, la barre de menu liste les projets `ongoing`, avec un statut inscrit / pas inscrit **identique à my.epitech.eu** pour au moins 5 projets vérifiés à la main.
2. Après un redémarrage de l'app, la liste se recharge **sans redemander de connexion** (tant que la session Microsoft est vivante).
3. Après plus de 6 h, l'app rafraîchit toute seule sans intervention, ou affiche « Reconnecte-toi à Epitech ». Jamais d'erreur muette, jamais de plantage.
4. Avec l'heure système avancée à J-1 d'une fin d'inscription, une notification apparaît **une seule fois**, et un clic dessus ouvre la page du projet.
5. « Note » sur un projet crée `Epitech/<Projet>.md` avec le modèle et l'ouvre dans Obsidian. Un second clic l'ouvre sans la modifier.
6. `xcodebuild test` passe, avec des tests pour chaque ligne « unitaire » du tableau de test.
7. Après un redémarrage du Mac, Juste-a est lancé tout seul (icône dans la barre de menu).
8. Aucun token ni login d'un autre étudiant dans le repo (`git grep -E 'eyJ|@epitech\.eu'` ne renvoie que des valeurs anonymisées).

## Questions ouvertes

1. **Combien de temps dure la session Microsoft dans la WebView ?** À mesurer sur quelques jours. Ça décide si le critère 2 tient ou s'il faudra se reconnecter régulièrement.

### Décisions prises (2026-10-15)
- Lancement au démarrage : **oui, en v1**.
- Seuils de notification : **J-3 et J-1**.
- API vérifiée en T1 : un seul appel, `isUserRegistered` présent dans la liste.
- Activités Epitech : **hors v1**.
