<?php
  require_once PATH_TO_MEEKRODB;
  define("PREFIX_BDD", "exo_"); // Prefixe de la BDD
  // Connexion locale sur la bdd mysql du synology
  DB::$host="localhost";
  DB::$dbName="exercices";
  DB::$user="bdd_user";
  DB::$password="bdd_password";
  DB::$error_handler = false;
  DB::$throw_exception_on_error = true;
?>
