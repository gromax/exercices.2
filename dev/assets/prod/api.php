<?php
use ErrorController as EC;

require_once "../php/constantes.php";
require_once "../php/classAutoLoad.php";
require_once "../php/routes.php";
define("DEV_MODE", false);

$response = $router->load();
EC::header(); // Doit être en premier !
if ($response === false) {
	echo json_encode(array("ajaxMessages"=>EC::messages()));
} else {
	if (isset($response["errors"]) && (count($response["errors"])==0)) {
		unset($response["errors"]);
	}/* else {
		$messages = EC::messages();
		if (count($messages)>0) {
			$response["errors"] = $messages;
		}
	}*/
	echo json_encode($response);
}

?>
