//#######################################################################################################
//#################################### Device-025: ExtWiredOut ##########################################
//#######################################################################################################

/*********************************************************************************************\
 * Dit protocol zorgt voor aansturing van de PCF8574 I2C IO-Expander (fabrikant NXP/Philips)
 * 
 * Auteur             : Nodo-team (Martinus van den Broek) www.nodo-domotica.nl
 * Support            : www.nodo-domotica.nl
 * Datum              : 10 Sep 2013
 * Versie             : 1.0
 * Nodo productnummer : 
 * Compatibiliteit    : Vanaf Nodo build nummer 555
 * Syntax             : "ExtWiredOut <Par1:Poort>, <Par2:On/Off>"
 *********************************************************************************************
 * Technische beschrijving:
 *
 * Compiled size      : <grootte> bytes voor een Mega en <grootte> voor een Small.
 * Externe funkties   : <geef hier aan welke funkties worden gebruikt. 
 *
 * De PCF8574 is een IO Expander chip die via de I2C bus moet worden aangesloten
 * Het basis I2C adres = 0x20. Dit kan worden gewijzigd via adres pinnen A0,A1,A2, tussen 0x20 en 0x27.
 * Elke chip heeft 8 digitale pinnen die we hier als output gebruiken.
 * Voor de eenvoud nummeren we de poorten gewoon door indien je meerdere chips aansluit:
 *   dus poort 1 is poort 1 van de eerste chip op adres 0x20
 *       poort 9 is poort 1 van de tweede chip op adres 0x21
 *       poort 17 is poort 1 van de derde chip op adres 0x22
 *       etc.
 * Max 8 chips, dus max 64 poorten aan te sturen
 * De PCF8574 uitgangen zijn active low en kunnen genoeg 'sink' current leveren voor een LED (b.v. van een optocoupler)
 * Deze wel aansluiten tussen VCC en de output. Het commande 'On' maakt de uitgang laag.
 \*********************************************************************************************/

#define DEVICE_NAME_025 "ExtWiredOut"
boolean Device_025(byte function, struct NodoEventStruct *event, char *string)
  {
  boolean success=false;

  #ifdef DEVICE_025_CORE
  switch(function)
    {    
    case DEVICE_COMMAND:
      {
      byte portvalue=0;
      byte unit = (event->Par1-1) / 8;
      byte port = event->Par1 - (unit * 8);
      uint8_t address = 0x20 + unit;

      // get the current pin status
      Wire.requestFrom(address, (uint8_t)0x1);
      if(Wire.available())
      {
        portvalue = Wire.read();
        if (event->Par2==VALUE_OFF)
          portvalue |= (1 << (port-1));
        else
          portvalue &= ~(1 << (port-1));
        
        Wire.beginTransmission(address);
        Wire.write(portvalue);
        Wire.endTransmission();
        success=true;
      }
      break;
      }
      
    #endif // CORE
    
    #if NODO_MEGA // alleen relevant voor een Nodo Mega want de Small heeft geen MMI!
    case DEVICE_MMI_IN:
      {
      char *TempStr=(char*)malloc(26);
      string[25]=0;

      if(GetArgv(string,TempStr,1))
        {
        if(strcasecmp(TempStr,DEVICE_NAME_025)==0)
          {
          if(GetArgv(string,TempStr,2)) 
            {
            if(GetArgv(string,TempStr,3))
              {
              if(event->Par1>0 && event->Par1<65 && (event->Par2==VALUE_ON || event->Par2==VALUE_OFF))            
                {
                  event->Type = NODO_TYPE_DEVICE_COMMAND;
                  event->Command = 25; // Device nummer  
                  success=true;
                 }
              }
            }
          }
        }
      free(TempStr);
      break;
      }

    case DEVICE_MMI_OUT:
      {
      strcpy(string,DEVICE_NAME_025);
      strcat(string," ");
      strcat(string,int2str(event->Par1));
      strcat(string,",");
      if(event->Par2==VALUE_ON)
        strcat(string,"On");  
      else strcat(string,"Off");
      break;
      }
    #endif //MMI
    }
    
  return success;
  }