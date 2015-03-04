
// ****************************************************************************************************************************************
// Definities voor Nodo units : CONFIG.C
// ****************************************************************************************************************************************
// Deel 1: geef hier op welke devices er gebruikt worden.
// Voor een volledige, en bijgewerkte lijst van alle beschikbare devices verwijzen we naar de Wiki:
// http://www.nodo-domotica.nl/index.php/Device
// ****************************************************************************************************************************************



#define UNIT_NODO                         15                                    // Na een reset wordt dit het unitnummer van de Nodo
#define HOME_NODO                          1                                    // Home adres. Alleen Nodo's met hetzelde Home adres kunnen ondeling gegevens uitwisselen


// Kaku: Klik-Aan-Klik-Uit
// #define PLUGIN_001
// #define PLUGIN_001_CORE

// NewKAKU: Klik-Aan-Klik-Uit met automatische codering. Tevens bekend als Intertechno.
// #define PLUGIN_002
// #define PLUGIN_002_CORE

// NRF24L01 Plugin
// #define PLUGIN_033                                                              
// #define PLUGIN_033_CORE

// Temperatuursensor Dallas DS18B20
// #define PLUGIN_005
// #define PLUGIN_005_CORE

// DTH-22 Vocht/Temperatuursensor
// #define PLUGIN_006
// #define PLUGIN_006_CORE 22

// BMP085 Luchtdruk sensor
// #define PLUGIN_020
// #define PLUGIN_020_CORE 

// RGB-Led aansturing
// #define PLUGIN_023
// #define PLUGIN_023_CORE
// #define PLUGIN_023_CORE_RGBLED
