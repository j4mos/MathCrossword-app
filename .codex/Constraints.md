# Constraints
- Keine proprietären Abhängigkeiten, die Builds brechen könnten.
- Architektur: MVVM + reine Domain (Engine), keine Businesslogik in Views.
- Persistenz optional (AppStorage/CoreData später); V1 ohne externe Services.
- Keine personenbezogenen Daten, offline-first.
- Reproduzierbarkeit: Xcode project via XcodeGen/Tuist (empfohlen), oder manuell.
- Coverage-Gate: Fail < 0.90.
