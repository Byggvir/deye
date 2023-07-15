<?php
/**
 *solarlib.php
 *
 * @package default
 */


defined('ABSPATH') or die('No script kiddies please!');


function SolarReport () {
   
  global $mysqli;

  $sensor = 1;

$SQL = "SELECT "
    . "`time`"
  . ", now_p as now_p"
  . ", today_e as today_e"
  . ", total_e as total_e"
  . "  FROM reports "
  . " order by `time` desc limit 60;";
  
  if ($reports = $mysqli->query($SQL)) {
    
    echo '<div style="background: yellow; width:38em; height:30em; overflow:auto;">'. "\n"; 
 
    echo '<table>'
    . '<tr>' . "\n"
    . '<th>Zeit [Lokal]</th>' . "\n"
    . '<th>Leistung<br />[Watt]</th>' . "\n"
    . '<th>Produktion<br />heute [kWh]</th>' . "\n"
    . '<th>Produktion<br />gesamt [kWh]</th>' . "\n"
    . '</tr>' . "\n";
    
    while ($result = $reports->fetch_assoc()) {

      echo '<tr>' . "\n";
      echo '<td>' . $result["time"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["now_p"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["today_e"] . '</td>' . "\n" ;
      echo '<td class="value">' . $result["total_e"] . '</td>' . "\n" ;
      echo '</tr>' . "\n";
        
    }/* end while */
    echo '</table>' . "\n" ;
    echo '</div>'; 
 
    $reports->close();
    
  } /* end if */

} /* End of WeaterReport */

function StationList () {
   
  global $mysqli;
 
  $SQL="SELECT * FROM stations;";
  
  if ($reports = $mysqli->query($SQL)) {
    echo "<table>" ;
    echo "<tr><th>id</th><th>Name</th><th>Seriennummer</th><th>Latitude</th><th>Longitude</th></tr>\n" ;
    
    while ($result = $reports->fetch_assoc()) {

      echo "<tr>\n";
      echo "<td>" . $result["id"] . "</td>\n" ;
      echo "<td>" . $result["name"] . "</td>\n" ;
      echo "<td>" . $result["sn"] . "</td>\n" ;
      echo "<td>" . $result["location_lat"] . "</td>\n" ;
      echo "<td>" . $result["location_lon"] . "</td>\n" ;
      echo "</tr>\n";
 
        
    }/* end while */
    echo "</table>\n" ;

    $reports->close();
    
  } /* end if */

} /* End of StationList */



?>
