# Tâches : Juste-a v1

Voir `tasks/plan.md` pour l'ordre, et `SPEC.md` pour le comportement attendu.

- [x] **T1 — Vérifier l'API avec curl** — fait le 2026-10-15 : `isUserRegistered` est dans la liste, un seul appel suffit, la pagination passe par `meta.hasNext` *(c'est l'utilisateur qui lance la commande : le token reste chez lui)*
  - Acceptance : nom exact du filtre « inscrit » connu ; présence (ou non) de `endRegistrationDate`, `startDate`, `endDate` et `unitInstance.{unitCode,code,name}` dans la liste confirmée ; comportement de la pagination connu. `JusteATests/Fixtures/projects-page.json` créé, **anonymisé**, avec 2–3 projets.
  - Verify : `SPEC.md` mise à jour (questions ouvertes 1 et 2 fermées) ; `grep -E 'eyJ|@epitech' JusteATests/Fixtures/*` ne renvoie rien de réel.
  - Files : `JusteATests/Fixtures/projects-page.json`, `SPEC.md`

- [ ] **T2 — `epitech-session` : connexion WebView et lecture du token**
  - Acceptance : une fenêtre « Connexion Epitech » affiche my.epitech.eu ; après la connexion, `EpitechSession.token()` renvoie le JWT ; l'état passe à `connected` ou `disconnected` ; le token est relu (et la page rechargée) quand il lui reste moins de 10 min.
  - Verify : test unitaire de la lecture de `exp` sur un faux JWT ; à la main, se connecter, relancer l'app et constater qu'elle reste connectée.
  - Files : `JusteA/EpitechSession.swift`, `JusteA/JusteAApp.swift`, `JusteATests/EpitechSessionTests.swift`

- [ ] **T3 — `epitech-projects` : API, modèle, inscrit / pas inscrit**
  - Acceptance : `EpitechService.refresh()` fait un seul appel (pages enchaînées tant que `meta.hasNext`) et décode `EpitechProject` (avec `isUserRegistered`). Un 401 ou 403 passe la session à déconnecté ; une autre erreur donne `.unavailable` et garde l'ancienne liste. Rafraîchissement au lancement puis toutes les 2 h.
  - Verify : tests de décodage (fixture `projects-page.json`), `needsRegistration`, tri, « inscriptions ouvertes », JSON invalide qui ne plante pas.
  - Files : `JusteA/EpitechService.swift`, `JusteA/JusteAApp.swift`, `JusteATests/EpitechServiceTests.swift`

- [ ] **T4 — UI des projets** → **checkpoint A**
  - Acceptance : la carte « Projets Epitech » s'affiche dans la barre de menu et dans le dashboard : d'abord les projets pas inscrits (« ferme dans X j »), puis ceux où je suis inscrit ; bouton « Ouvrir » vers la page du projet ; « Reconnecte-toi à Epitech » ou « Epitech indisponible » selon l'état ; rafraîchissement à l'ouverture de la barre de menu, au plus une fois toutes les 15 min.
  - Verify : critère de succès 1, à la main sur 5 projets.
  - Files : `JusteA/Widgets.swift`, `JusteA/MenuBarView.swift`, `JusteA/DashboardView.swift`

- [ ] **T5 — `registration-alerts`**
  - Acceptance : la fonction pure `alertsToSend(projects:now:alreadySent:)` renvoie les alertes J-3, J-1 et « nouveau projet », sans doublon ; l'envoi passe par `UNUserNotificationCenter`, avec l'autorisation demandée au premier rafraîchissement réussi ; un clic sur la notif ouvre la page du projet.
  - Verify : tests unitaires (J-4 → rien, J-3 → une alerte, J-3 déjà envoyée → rien, J-1, inscrit → rien, inscriptions fermées → rien, nouveau projet, 1er rafraîchissement → rien) ; critère 4 vérifié à la main.
  - Files : `JusteA/RegistrationAlerts.swift`, `JusteA/EpitechService.swift`, `JusteATests/RegistrationAlertsTests.swift`

- [ ] **T6 — `obsidian-notes`**
  - Acceptance : au premier clic sur « Note », l'app demande le dossier du vault (bookmark mémorisé) ; elle crée `Epitech/<nom assaini>.md` avec le modèle s'il n'existe pas, sans jamais réécrire une note, puis l'ouvre via `obsidian://open?path=`.
  - Verify : tests de l'assainissement du nom et du contenu du modèle ; critère 5 vérifié à la main.
  - Files : `JusteA/ObsidianNotes.swift`, `JusteA/Widgets.swift`, `project.yml` (entitlements), `JusteATests/ObsidianNotesTests.swift`

- [ ] **T7 — Lancement au démarrage**
  - Acceptance : `SMAppService.mainApp.register()` est appelé au lancement, et une erreur ne fait pas planter l'app.
  - Verify : critère 7 (redémarrer le Mac, ou se déconnecter de la session macOS puis se reconnecter).
  - Files : `JusteA/JusteAApp.swift`

- [ ] **T8 — Vérification finale** → **checkpoint B**
  - Acceptance : les critères 1 à 8 de la spec sont cochés ; le tableau des fonctionnalités du README est à jour (Epitech et Obsidian ✅), et la ligne « Planning Epitech (via export iCal) » est remplacée.
  - Verify : `xcodebuild test -scheme JusteA -destination 'platform=macOS,arch=arm64'` ; `git grep -E 'eyJ|@epitech\.eu'` ne renvoie rien de réel.
  - Files : `README.md`, `SPEC.md` (si un écart a été constaté)
