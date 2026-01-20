<?php
require_once '/opt/fpp/www/common.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HA Discovery</title>
</head>
<body>
    <h1>Welcome</h1>
    This plugin helps Home Assistant automatically discover and setup your FPP instance via MQTT auto discovery.<br>
    <br>
    <h1>Getting Started</h1>
    Out of the box, the FPP HA Discovery plugin requires FPP MQTT be cnfgured.<br>
    <i>If your FPP MQTT configuration is unconfigured, you will need to configure that before this plugin will work.</i>
    <br>
    <br>

       <ul>
       <li><strong>Broker Host:</strong> Your broker host or ip.</li>
        <li><strong>Broker Port:</strong> 1883 or the port your broker is using if other than the default.</li>
        <li><strong>Client ID:</strong> the hostname for this fpp instance or any unique value to distiquish this publisher.</li>
        <li><strong>Topic Prefix:</strong> Topic prefix for other FPP messages to be posted to.</li>
        <li><strong>Username:</strong> Leave blank unless your broker requres authentication</li>
        <li><strong>Password:</strong> Leave blank unless your broker requres authentication</li>
        <li><strong>CA File:</strong> Leave Blank</li>
        <li><strong>Publish FPPD Status Frequency:</strong> 1 or more</li>
    </ul>
    If you already have MQTT configured, there is nothing more to do. The plugin will send the auto discovery payload on startup.
    
</body>
</html>
