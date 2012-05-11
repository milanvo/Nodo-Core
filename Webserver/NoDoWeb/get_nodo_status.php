<?php 
/***********************************************************************************************************************
"Nodo Web App" Copyright � 2012 Martin de Graaf

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************************************************************/

require_once('connections/db_connection.php'); 
require_once('include/auth.php');
require_once('include/user_settings.php');

$page_title = "Setup: Nodo settings";	


//HTTPRequest function.
function HTTPRequest($Url){


    
    if (!function_exists('curl_init')){
        die('Sorry cURL is not installed!');
    }
 
    global $nodo_port;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $Url);
    curl_setopt($ch, CURLOPT_USERAGENT, "Nodo Web App");
    curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_PORT, $nodo_port);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
 
    $output = curl_exec($ch);
    curl_close($ch);
	
	return $output;
	
	}



		//Status uitlezen
		$file="STATUS";
		HTTPRequest("http://$nodo_ip/?id=$nodo_id&password=$nodo_password&event=FileErase%20$file");
		HTTPRequest("http://$nodo_ip/?id=$nodo_id&password=$nodo_password&event=FileLog%20$file");
		HTTPRequest("http://$nodo_ip/?id=$nodo_id&password=$nodo_password&event=Status%20All");
		HTTPRequest("http://$nodo_ip/?id=$nodo_id&password=$nodo_password&event=FileLog");
		
			

		//Status van Nodo in array plaatsen
		$script = explode("\n", HTTPRequest("http://$nodo_ip/?id=$nodo_id&password=$nodo_password&file=$file"));
		
			
		//Totaal aantal lijnen tellen in $script
		$total_script_lines = count($script);
		
		

/************************************************************************************************
END status Read															
*************************************************************************************************/
?>	
<?php
if (isset($script)){  

	for($i=0;$i<$total_script_lines;$i++){
		
			
			//<br /> aan het einde van de regels verwijderen
			//$script[$i] = str_replace("<br />","",$script[$i]);
			
			echo $script[$i];
		
	}
	
}


?>