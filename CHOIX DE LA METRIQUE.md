FE = Flight Early
NI = Next Information
OT = Flight On Time
DL = Flight Delayed
NO = No status

Lorsqu'on évalue des modèles de machine learning pour prédire des retards, les métriques de régression classiques sont généralement utilisées. Cependant, la meilleure métrique dépend de ce qui est le plus critique dans votre contexte. Voici quelques considérations :

1. **Mean Absolute Error (MAE)** :
   - **Description** : C'est la moyenne des erreurs absolues entre les prédictions et les valeurs réelles.
   - **Utilisation** : Le MAE est une métrique simple et intuitive. Elle donne une idée de la magnitude moyenne des erreurs en minutes de retard, sans privilégier les grandes erreurs.
   - **Avantage** : Facile à interpréter ; il représente directement la moyenne des écarts en termes de temps.

2. **Mean Squared Error (MSE) et Root Mean Squared Error (RMSE)** :
   - **Description** : Le MSE est la moyenne des carrés des erreurs, tandis que le RMSE est sa racine carrée.
   - **Utilisation** : Ces métriques amplifient les grandes erreurs (car elles les mettent au carré), ce qui peut être utile si les grandes erreurs sont particulièrement indésirables.
   - **Avantage** : Le RMSE est plus sensible aux grandes erreurs que le MAE, ce qui peut être crucial dans les scénarios où les gros retards sont beaucoup plus problématiques que les petits.

3. **R² (Coefficient de détermination)** :
   - **Description** : C'est une mesure statistique de la proportion de la variance expliquée par le modèle.
   - **Utilisation** : Bien qu'il ne soit pas toujours directement lié aux erreurs de prédiction, il donne une idée de la performance globale du modèle par rapport à la variance totale des données.
   - **Avantage** : Utile pour comparer des modèles entre eux et comprendre combien de variance des retards est expliquée par le modèle.

### Recommandation
Pour les retards, le **MAE** est souvent une bonne métrique car il donne une estimation claire et directe de l'erreur moyenne en minutes, ce qui est facilement compréhensible et utile pour les décisions opérationnelles. Le **RMSE** est également très pertinent si vous souhaitez pénaliser davantage les grandes erreurs de prédiction, ce qui est souvent le cas dans la gestion des retards, où les grands écarts peuvent avoir des impacts significatifs.

En pratique, il est judicieux d'examiner plusieurs métriques pour avoir une vue complète de la performance de votre modèle, en particulier MAE et RMSE, et de choisir la plus appropriée en fonction des priorités et des risques associés aux prédictions erronées.

