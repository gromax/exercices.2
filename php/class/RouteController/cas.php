<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Logged;

class cas
{
    /**
     * paramères de la requète
     * @array
     */
    private $params;
    /**
     * Constructeur
     */
    public function __construct($params)
    {
        $this->params = $params;
    }

    public function authAccess()
    {
        // Utilisation en local
        // $resp = "sdfrgf<cas:user>maxence.klein</cas:user>dfdf";
        // $pattern ="#<cas:user>(.+)</cas:user>#";
        // preg_match($pattern, $resp, $matches, PREG_OFFSET_CAPTURE);
        // if(count($matches) == 0) {
        //     EC::set_error_code("403");
        //     return false;
        // } else {
        //     $loginCas = $matches[1][0];
        //     var_dump($loginCas);
        //     $tryConnexion = Logged::tryConnexionOnCasId($loginCas);
        //     if ($tryConnexion===null) {
        //         EC::header(PATH_TO_SITE."#casloginfailed");
        //         return false;
        //     } else {
        //         EC::header(PATH_TO_SITE."#home");
        //         return array();
        //     }
        // }
        // return array("debugcas"=>$matches);

        if (isset($_GET['ticket'])) {
            $ticket = $_GET['ticket'];
            // Get cURL resource
            $curl = curl_init();
            // Set some options - we are passing in a useragent too here
            curl_setopt_array($curl, array(
                CURLOPT_RETURNTRANSFER => 1,
                CURLOPT_URL => PATH_TO_ENT_CAS_VALIDATE."?ticket=$ticket&service=".PATH_TO_AUTH,
                CURLOPT_USERAGENT => 'User Agent X'
            ));
            // Send the request & save response to $resp
            $resp = curl_exec($curl);
            // Close request to clear up some resources
            curl_close($curl);

            if (preg_match("#<cas:authenticationSuccess>#", $resp)){
                $pattern ="#<cas:user>(.+)</cas:user>#";
                preg_match($pattern, $resp, $matches, PREG_OFFSET_CAPTURE);
                if(count($matches) > 0) {
                    $loginCas = $matches[1][0];
                    $tryConnexion = Logged::tryConnexionOnCasId($loginCas);
                    if ($tryConnexion!==null) {
                        EC::header(PATH_TO_SITE."#home");
                        return array();
                    }
                }
            }
            EC::header(PATH_TO_SITE."#casloginfailed");
            return false;
        } else {
            EC::header(PATH_TO_ENT_CAS);
            return false;
        }
    }
}
?>
