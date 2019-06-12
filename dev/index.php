<?php
include "../php/constantes.php";
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
  <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
  <title><%= htmlWebpackPlugin.options.title %></title>
</head>
<body>
  <div id="app-container">
    <div id="header-region"></div><br />
    <div id="ariane-region"></div>
    <div id="message-region"></div>
    <div id="main-region" class="container">
        <div class="alert alert-warning" role="alert"> <i class="fa fa-spinner fa-spin fa-2x fa-fw"></i> Contenu en cours de chargement...</div>
    </div>
    <div id="dialog-region"></div>
  </div>
  <iframe id="zoomframe" style="width: 1px; height: 1px; visibility: hidden;" ></iframe>

  <script type="text/javascript">
  const CAS_ENABLED = <?php if (CAS_ENABLED) { echo "true"; } else { echo "false"; }?>;
  </script>

</body>
</html>
