Exercices de maths version 2
==
Introduction
-

Application web contenant des exercices de maths pour lycéens.
Les exercices sont automatiquement générés et corrigés.

Côté client
-
* interface web
* javascript avec Webpack, Marionettejs, jquery, bootstrap
* KaTex pour le rendu des formules mathématiques
* mathquill pour les inputs mathématiques
* jsxGraph pour les graphiques

Côté serveur
-
* php, mysql
* meekroDB pour l'accès à la bdd
* phpMailer pour la gestion des mails

Installation
-

* npm install
* php composer install

Commandes de développement
-

* npm run watch : pour développement avec live reload
* npm version patch : pour augmenter le numéro de version
* npm run prod : pour compiler une version de production

Fichiers utiles pour le serveur de production
-
* Le dossier php
* Le dossier vendor (dépendance meekroDB)
* Le dossier public sur lequel doit pointer la racine du site
