<h2>HA Discovery Status</h2>

Ensure that you have the MQTT Broker configured in the FPP settings page. You will want to ensure FPP is publishing it's status for
HA integration to work. 
<br>
A handy command for checking if the MQTT broker is seeing data from FPP:
mosquitto_sub -v -t homeassistant/device/#
<br>
If you prefer a UI, MQTT Explorer is a great tool to visualize the MQTT topics and data.
<a href="https://mqtt-explorer.com/" target="_blank">MQTT Explorer</a>
<br>

FPP will publish a discovery packet on FPPD restart. You should see the device show up automatically in Home Assistant if MQTT auto discovery is enabled.
<br>

This plugin does not expose any commands or settings other than the basics to establish monitoring of FPP via the MQTT messages it publishes.
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