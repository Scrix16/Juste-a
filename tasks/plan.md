# Plan : Juste-a v1 — Epitech + Obsidian

Source : `SPEC.md` (validée le 2026-10-15). Tâches détaillées : `tasks/todo.md`.

## Ordre et dépendances

```
T1 Vérifier l'API (curl)                    ✅ fait
 └─ T2 epitech-session (WebView + token)
     └─ T3 epitech-projects (API + inscrit/pas inscrit)
         └─ T4 UI projets (barre de menu + dashboard)    ── checkpoint A : critère 1 vérifié à la main
             ├─ T5 registration-alerts (notifs J-3 / J-1 / nouveau)
             ├─ T6 obsidian-notes (bouton Note)
             └─ T7 lancement au démarrage
                 └─ T8 vérification finale + README       ── checkpoint B : critères 1 à 8
```

T5, T6 et T7 sont indépendantes et peuvent se faire dans n'importe quel ordre.

## Risques et parades

| Risque | Parade |
|---|---|
| Trop de notifications (18 projets ouverts et non inscrits) | 1er rafraîchissement silencieux, puis seulement J-3, J-1 et les nouveaux projets |
| La session Microsoft expire vite dans la WebView | Mesurer pendant T2 à T4 (noter la date de chaque reconnexion). Si elle tient moins d'un jour, on en rediscute avant T8 |
| `evaluateJavaScript` sur une WebView cachée ne s'exécute pas | La WebView vit dans une fenêtre qu'on garde en mémoire, même fermée. Vérifié dès T2 |
| L'API change | Toute erreur de décodage affiche « Epitech indisponible », jamais de plantage (testé en T3) |
| Fuite de données personnelles dans le repo | Fixture anonymisée à la main en T1, `git grep` au checkpoint B |

## Checkpoints

- **A (après T4) :** l'app connectée affiche la vraie liste, et le statut inscrit / pas inscrit correspond à my.epitech.eu sur 5 projets. On s'arrête pour relire avant de continuer.
- **B (après T8) :** les 8 critères de succès de la spec sont cochés, et `xcodebuild test` passe.
