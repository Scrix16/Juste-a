# Juste-a

Le tableau de bord de ta journée, dans la barre de menu de ton Mac.
Agenda, tâches et (bientôt) mails, musique et bilans quotidiens générés par IA, au même endroit.

> Application native SwiftUI : pas d'Electron, pas de navigateur embarqué. Elle tourne en fond sans peser sur ton Mac.

## Fonctionnalités

| | Statut |
|---|---|
| Agenda du jour (tous les calendriers synchronisés sur le Mac) | ✅ |
| Todo list locale | ✅ |
| Brief du matin à la première ouverture | 🔜 |
| Bilan du soir (check-in de 30 s + résumé IA) | 🔜 |
| Analyse de la semaine | 🔜 |
| Mails (IMAP) | 🔜 |
| Spotify (morceau en cours, contrôles) | 🔜 |
| Planning Epitech (via export iCal) | 🔜 |

## Installation

Prérequis : macOS 14+, Xcode 16+ et [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
git clone git@github.com:Scrix16/Juste-a.git
cd Juste-a
xcodegen              # génère JusteA.xcodeproj depuis project.yml
open JusteA.xcodeproj # puis ⌘R
```

Au premier lancement, macOS demande l'accès au calendrier. L'icône ☀️ apparaît dans la barre de menu.

**Ajouter un agenda (Google, Epitech…)** : ajoute-le dans l'app Calendrier de macOS (compte Google, ou *Fichier › Nouvel abonnement* pour une URL `.ics`). Juste-a le voit automatiquement.

## Architecture

Tout passe par un seul endroit : les données de chaque source arrivent dans le stockage local (SwiftData), et le dashboard comme les bilans lisent ce stockage. C'est ce qui permet de tout croiser, par exemple « tu avais 3 cours et tu as fini 2 tâches sur 5 ».

```
JusteA/
├── JusteAApp.swift        point d'entrée, icône de la barre de menu
├── DashboardView.swift    l'écran principal
├── CalendarService.swift  agenda via EventKit
└── TodoItem.swift         modèle de tâche (SwiftData)
JusteATests/               tests unitaires
project.yml                définition du projet Xcode (le .xcodeproj n'est pas versionné)
```

- **Données** : 100 % locales, rien ne quitte le Mac.
- **IA (à venir)** : seuls des résumés (titres, objets de mails) seront envoyés au modèle, jamais le contenu complet.

## Tests

```sh
xcodebuild test -scheme JusteA -destination 'platform=macOS,arch=arm64'
```

## Contribuer

Les issues et les PR sont bienvenues. Modifie `project.yml` plutôt que les réglages Xcode, puis relance `xcodegen`.

## Licence

[MIT](LICENSE)
