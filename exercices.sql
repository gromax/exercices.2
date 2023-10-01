-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : sam. 30 sep. 2023 à 23:59
-- Version du serveur : 10.6.12-MariaDB-0ubuntu0.22.04.1
-- Version de PHP : 8.1.2-1ubuntu2.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `exercices`
--

-- --------------------------------------------------------

--
-- Structure de la table `exo_assocEF`
--

CREATE TABLE `exo_assocEF` (
  `id` int(11) NOT NULL,
  `idE` varchar(6) NOT NULL,
  `options` text NOT NULL,
  `idFiche` int(11) NOT NULL,
  `num` int(11) NOT NULL,
  `coeff` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_assocUE`
--

CREATE TABLE `exo_assocUE` (
  `id` int(11) NOT NULL,
  `aUF` int(11) NOT NULL COMMENT 'assoc User/Fiche',
  `aEF` int(11) NOT NULL COMMENT 'assoc Exo/Fiche',
  `date` datetime NOT NULL,
  `note` int(11) NOT NULL,
  `inputs` text NOT NULL,
  `answers` text NOT NULL,
  `finished` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_assocUF`
--

CREATE TABLE `exo_assocUF` (
  `id` int(11) NOT NULL,
  `idUser` int(11) NOT NULL,
  `idFiche` int(11) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `date` date NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_classes`
--

CREATE TABLE `exo_classes` (
  `id` int(11) NOT NULL,
  `nom` text NOT NULL,
  `description` text NOT NULL,
  `idOwner` int(11) NOT NULL,
  `pwd` text NOT NULL,
  `date` date NOT NULL,
  `ouverte` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_connexion_history`
--

CREATE TABLE `exo_connexion_history` (
  `id` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `identifiant` text NOT NULL,
  `pwd` varchar(50) NOT NULL,
  `success` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_exams`
--

CREATE TABLE `exo_exams` (
  `id` int(11) NOT NULL,
  `idFiche` int(11) NOT NULL,
  `nom` text NOT NULL,
  `date` date NOT NULL,
  `data` text NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_fiches`
--

CREATE TABLE `exo_fiches` (
  `id` int(11) NOT NULL,
  `idOwner` int(11) NOT NULL,
  `nom` text NOT NULL,
  `description` text NOT NULL,
  `date` date NOT NULL,
  `visible` tinyint(1) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `notation` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_initKeys`
--

CREATE TABLE `exo_initKeys` (
  `id` int(11) NOT NULL,
  `initKey` text NOT NULL,
  `idUser` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_messages`
--

CREATE TABLE `exo_messages` (
  `id` int(11) NOT NULL,
  `idOwner` int(11) NOT NULL,
  `message` text NOT NULL,
  `aUE` int(11) NOT NULL DEFAULT 0,
  `date` datetime NOT NULL,
  `idDest` int(11) NOT NULL,
  `lu` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `exo_users`
--

CREATE TABLE `exo_users` (
  `id` int(11) NOT NULL,
  `nom` text NOT NULL,
  `prenom` text NOT NULL,
  `email` text NOT NULL,
  `rank` varchar(10) NOT NULL,
  `idClasse` int(11) DEFAULT NULL,
  `date` datetime NOT NULL,
  `pref` text NOT NULL,
  `hash` char(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `cas` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Déchargement des données de la table `exo_users`
--

INSERT INTO `exo_users` (`id`, `nom`, `prenom`, `email`, `rank`, `idClasse`, `date`, `pref`, `hash`, `cas`) VALUES
(1, 'Root', '', 'root', 'Root', NULL, '2023-09-30 23:55:27', '{\"mathquill\":true}', '$2y$10$c.fb.SQFCZWe./jtK2heyuRJJ3ShBHbV4s/g0tjoNibE7tr245.JW', '');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `exo_assocEF`
--
ALTER TABLE `exo_assocEF`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_assocUE`
--
ALTER TABLE `exo_assocUE`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_assocUF`
--
ALTER TABLE `exo_assocUF`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_classes`
--
ALTER TABLE `exo_classes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_connexion_history`
--
ALTER TABLE `exo_connexion_history`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_exams`
--
ALTER TABLE `exo_exams`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_fiches`
--
ALTER TABLE `exo_fiches`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_initKeys`
--
ALTER TABLE `exo_initKeys`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_messages`
--
ALTER TABLE `exo_messages`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `exo_users`
--
ALTER TABLE `exo_users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `exo_assocEF`
--
ALTER TABLE `exo_assocEF`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_assocUE`
--
ALTER TABLE `exo_assocUE`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_assocUF`
--
ALTER TABLE `exo_assocUF`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_classes`
--
ALTER TABLE `exo_classes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_connexion_history`
--
ALTER TABLE `exo_connexion_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_exams`
--
ALTER TABLE `exo_exams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_fiches`
--
ALTER TABLE `exo_fiches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_initKeys`
--
ALTER TABLE `exo_initKeys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_messages`
--
ALTER TABLE `exo_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `exo_users`
--
ALTER TABLE `exo_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
