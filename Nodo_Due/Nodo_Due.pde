
// Todo:
// Commando 'SendStatus' toegevoegd als vervanger van 'StatusEvent'. T.b.v. uitvragen status van een Nodo via IR/RF.
// Testen groepcommando's verzenden met KAKU: ook daadwerkelijk door KAKU ontvanger te ontvangen?
// uitvragen AnalyeSettings geeft een hex-code
// Testen: Na een SendUserEvent wordt het event nu ook door de Nodo zelf uitgevoerd.

// Done:
// Na een SendUserEvent wordt het event nu ook door de Nodo zelf uitgevoerd. (nog testen !)
// Issue 115: Terugzetten van een Divert na uitvoer van een Divert.


 /*****************************************************************************************************\

  Compiler            : 0019  
  Hardware            : - Arduino ATMeg328 processor @16Mhz.
                        - Hardware en Arduino penbezetting volgens schema Nodo Due Rev.003

 ********************************************************************************************************

 * Arduino project "Nodo Due" © Copyright 2010 Paul Tonkes
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You received a copy of the GNU General Public License
 * along with this program in tab '_COPYING'.
 *
 * voor toelichting op de licentievoorwaarden zie    : http://www.gnu.org/licenses
 * Voor discussie: Zie Logitech Harmony forum        : http://www.harmony-forum.nl 
 * Uitgebreide documentatie is te vinden op          : http://members.chello.nl/p.tonkes8/index.html
 * bugs kunnen worden gelogd op                      : https://code.google.com/p/arduino-nodo/
 * Compiler voor deze programmacode te downloaden op : http://arduino.cc
 * Voor vragen of suggesties, mail naar              : p.k.tonkes@gmail.com
 *
 ********************************************************************************************************/

#define VERSION                   95 // Nodo Version nummer
#define BAUD                   19200 // Baudrate voor seriële communicatie.
#define SERIAL_TERMINATOR_1     0x0A // Met dit teken wordt een regel afgesloten. 0x0A is een linefeed <LF>, default voor EventGhost
#define SERIAL_TERMINATOR_2     0x00 // Met dit teken wordt een regel afgesloten. 0x0D is een Carriage Return <CR>, 0x00 = niet in gebruik.
#define RF_ENDSIGNAL_TIME       1000 // Dit is de tijd in milliseconden waarna wordt aangenomen dat het ontvangen één RF signaal beëindigd is
#define IR_ENDSIGNAL_TIME       1000 // Dit is de tijd in milliseconden waarna wordt aangenomen dat het ontvangen één IR signaal beëindigd is

//****************************************************************************************************************************************

#include "pins_arduino.h"
#include "ctype.h"
#include <EEPROM.h>
#include <Wire.h>
#include <avr/pgmspace.h>

// ********alle strings naar PROGMEM om hiermee RAM-geheugen te sparen ***********************************************
prog_char PROGMEM Text_01[] = "NODO-Due (Beta) V0.";
prog_char PROGMEM Text_02[] = "SUNMONTHUWEDTHUFRISAT";
prog_char PROGMEM Text_03[] = ", Home ";
prog_char PROGMEM Text_05[] = "Dim";
prog_char PROGMEM Text_06[] = "SYSTEM: Unknown command!";
prog_char PROGMEM Text_07[] = "EXECUTE: Divert to unit ";
prog_char PROGMEM Text_09[] = "SYSTEM: Break!";
prog_char PROGMEM Text_10[] = "INPUT: ";
prog_char PROGMEM Text_11[] = "OUTPUT: ";
prog_char PROGMEM Text_12[] = "SYSTEM: ";
prog_char PROGMEM Text_13[] = "EXECUTE: ";
prog_char PROGMEM Text_14[] = ", Unit ";
prog_char PROGMEM Text_15[] = "EVENTLIST: ";
prog_char PROGMEM Text_26[] = "SYSTEM: Waiting for RF/IR event...";
prog_char PROGMEM Text_30[] = ", Rawsignal=(";
prog_char PROGMEM Text_50[] = "SYSTEM: Nesting error!";

#define RANGE_VALUE 19 // alle codes kleiner of gelijk aan deze waarde zijn vaste Nodo waarden.
#define RANGE_EVENT 72 // alle codes groter of gelijk aan deze waarde zijn een event.
#define COMMAND_MAX 92 // aantal commando's (geteld vanaf 0)

#define CMD_OFF 0
#define CMD_ON 1
#define CMD_SOURCE_CLOCK 2
#define CMD_TYPE_COMMAND 3
#define CMD_TYPE_EVENT 4
#define CMD_SOURCE_MACRO 5
#define CMD_TYPE_UNKNOWN 6
#define CMD_PORT_IR 7
#define CMD_TYPE_OTHERUNIT 8
#define CMD_PORT_RF 9
#define CMD_PORT_SERIAL 10
#define CMD_SOURCE_SYSTEM 11
#define CMD_SOURCE_TIMER 12
#define CMD_SOURCE_VARIABLE 13
#define CMD_PORT_WIRED 14
#define CMD_VALUE_RES1 15
#define CMD_VALUE_RES2 16
#define CMD_VALUE_RES3 17
#define CMD_VALUE_RES4 18
#define CMD_VALUE_RES5 19
#define CMD_ANALYSE_SETTINGS 20
#define CMD_BREAK_ON_VAR_EQU 21
#define CMD_BREAK_ON_VAR_LESS 22
#define CMD_BREAK_ON_VAR_MORE 23
#define CMD_BREAK_ON_VAR_NEQU 24
#define CMD_CLOCK_DATE 25
#define CMD_CLOCK_YEAR 26
#define CMD_CLOCK_DLS 27
#define CMD_CLOCK_TIME 28
#define CMD_CLOCK_DOW 29
#define CMD_DELAY 30
#define CMD_DIVERT 31
#define CMD_EVENTLIST_ERASE 32
#define CMD_EVENTLIST_SHOW 33
#define CMD_EVENTLIST_WRITE 34
#define CMD_DIVERT_SETTINGS 35
#define CMD_HOME 36
#define CMD_RAWSIGNAL_GET 37
#define CMD_RAWSIGNAL_PUT 38
#define CMD_RESET 39
#define CMD_RESET_FACTORY 40
#define CMD_SEND_KAKU 41
#define CMD_SEND_KAKU_NEW 42
#define CMD_SEND_RAW 43
#define CMD_SIMULATE 44
#define CMD_SIMULATE_DAY 45
#define CMD_SOUND 46
#define CMD_STATUS 47
#define CMD_SEND_STATUS 48
#define CMD_STATUS_LIST 49
#define CMD_TIMER_RANDOM 50
#define CMD_TIMER_RESET 51
#define CMD_TIMER_SET 52
#define CMD_TRACE 53
#define CMD_UNIT 54
#define CMD_VARIABLE_CLEAR 55
#define CMD_VARIABLE_DAYLIGHT 56
#define CMD_VARIABLE_DEC 57
#define CMD_VARIABLE_INC 58
#define CMD_VARIABLE_SET 59
#define CMD_VARIABLE_VARIABLE 60
#define CMD_VARIABLE_WIRED_ANALOG 61
#define CMD_WAITFREERF 62
#define CMD_WIRED_ANALOG 63
#define CMD_WIRED_OUT 64
#define CMD_WIRED_PULLUP 65
#define CMD_WIRED_SMITTTRIGGER 66
#define CMD_WIRED_THRESHOLD 67
#define CMD_SEND_USEREVENT 68
#define CMD_COMMAND_RES2 69
#define CMD_COMMAND_RES3 70
#define CMD_COMMAND_RES3 71
#define CMD_COMMAND_RES3 72
#define CMD_COMMAND_RES3 73
#define CMD_BOOT_EVENT 74
#define CMD_CLOCK_EVENT_DAYLIGHT 75
#define CMD_CLOCK_EVENT_ALL 76
#define CMD_CLOCK_EVENT_SUN 77
#define CMD_CLOCK_EVENT_MON 78
#define CMD_CLOCK_EVENT_TUE 79
#define CMD_CLOCK_EVENT_WED 80
#define CMD_CLOCK_EVENT_THU 81
#define CMD_CLOCK_EVENT_FRI 82
#define CMD_CLOCK_EVENT_SAT 83
#define CMD_STATUS_EVENT 84
#define CMD_KAKU 85
#define CMD_KAKU_NEW 86
#define CMD_TIMER_EVENT 87
#define CMD_USER_EVENT 88
#define CMD_VARIABLE_EVENT 89
#define CMD_WILDCARD_EVENT 90
#define CMD_WIRED_IN_EVENT 91

prog_char PROGMEM Cmd_0[]="Off";
prog_char PROGMEM Cmd_1[]="On";
prog_char PROGMEM Cmd_2[]="Clock";
prog_char PROGMEM Cmd_3[]="Command";
prog_char PROGMEM Cmd_4[]="Event";
prog_char PROGMEM Cmd_5[]="EventList";
prog_char PROGMEM Cmd_6[]="EventUnknown";
prog_char PROGMEM Cmd_7[]="IR";
prog_char PROGMEM Cmd_8[]="OtherUnit";
prog_char PROGMEM Cmd_9[]="RF";
prog_char PROGMEM Cmd_10[]="Serial";
prog_char PROGMEM Cmd_11[]="System";
prog_char PROGMEM Cmd_12[]="Timers";
prog_char PROGMEM Cmd_13[]="Variables";
prog_char PROGMEM Cmd_14[]="Wired";
prog_char PROGMEM Cmd_15[]="";
prog_char PROGMEM Cmd_16[]="";
prog_char PROGMEM Cmd_17[]="";
prog_char PROGMEM Cmd_18[]="";
prog_char PROGMEM Cmd_19[]="";
prog_char PROGMEM Cmd_20[]="AnalyseSettings";
prog_char PROGMEM Cmd_21[]="BreakOnVarEqu";
prog_char PROGMEM Cmd_22[]="BreakOnVarLess";
prog_char PROGMEM Cmd_23[]="BreakOnVarMore";
prog_char PROGMEM Cmd_24[]="BreakOnVarNEqu";
prog_char PROGMEM Cmd_25[]="ClockDate";
prog_char PROGMEM Cmd_26[]="ClockYear";
prog_char PROGMEM Cmd_27[]="ClockDLS";
prog_char PROGMEM Cmd_28[]="ClockTime";
prog_char PROGMEM Cmd_29[]="ClockDOW";
prog_char PROGMEM Cmd_30[]="Delay";
prog_char PROGMEM Cmd_31[]="Divert";
prog_char PROGMEM Cmd_32[]="EventlistErase";
prog_char PROGMEM Cmd_33[]="EventlistShow";
prog_char PROGMEM Cmd_34[]="EventlistWrite";
prog_char PROGMEM Cmd_35[]="DivertSettings";
prog_char PROGMEM Cmd_36[]="Home";
prog_char PROGMEM Cmd_37[]="RawsignalGet";
prog_char PROGMEM Cmd_38[]="RawsignalPut";
prog_char PROGMEM Cmd_39[]="Reset";
prog_char PROGMEM Cmd_40[]="ResetFactory";
prog_char PROGMEM Cmd_41[]="SendKAKU";
prog_char PROGMEM Cmd_42[]="SendNewKAKU";
prog_char PROGMEM Cmd_43[]="SendRaw";
prog_char PROGMEM Cmd_44[]="Simulate";
prog_char PROGMEM Cmd_45[]="SimulateDay";
prog_char PROGMEM Cmd_46[]="Sound";
prog_char PROGMEM Cmd_47[]="Status";
prog_char PROGMEM Cmd_48[]="SendStatus";
prog_char PROGMEM Cmd_49[]="StatusList";
prog_char PROGMEM Cmd_50[]="TimerRandom";
prog_char PROGMEM Cmd_51[]="TimerReset";
prog_char PROGMEM Cmd_52[]="TimerSet";
prog_char PROGMEM Cmd_53[]="Trace";
prog_char PROGMEM Cmd_54[]="Unit";
prog_char PROGMEM Cmd_55[]="VariableClear";
prog_char PROGMEM Cmd_56[]="VariableDaylight";
prog_char PROGMEM Cmd_57[]="VariableDec";
prog_char PROGMEM Cmd_58[]="VariableInc";
prog_char PROGMEM Cmd_59[]="VariableSet";
prog_char PROGMEM Cmd_60[]="VariableVariable";
prog_char PROGMEM Cmd_61[]="VariableWiredAnalog";
prog_char PROGMEM Cmd_62[]="WaitFreeRF";
prog_char PROGMEM Cmd_63[]="WiredAnalog";
prog_char PROGMEM Cmd_64[]="WiredOut";
prog_char PROGMEM Cmd_65[]="WiredPullup";
prog_char PROGMEM Cmd_66[]="WiredSmittTrigger";
prog_char PROGMEM Cmd_67[]="WiredThreshold";
prog_char PROGMEM Cmd_68[]="SendUserEvent";
prog_char PROGMEM Cmd_69[]="";
prog_char PROGMEM Cmd_70[]="";
prog_char PROGMEM Cmd_71[]="";
prog_char PROGMEM Cmd_72[]="";
prog_char PROGMEM Cmd_73[]="";
prog_char PROGMEM Cmd_74[]="Boot";
prog_char PROGMEM Cmd_75[]="ClockDaylight";
prog_char PROGMEM Cmd_76[]="ClockAll";
prog_char PROGMEM Cmd_77[]="ClockSun";
prog_char PROGMEM Cmd_78[]="ClockMon";
prog_char PROGMEM Cmd_79[]="ClockTue";
prog_char PROGMEM Cmd_80[]="ClockWed";
prog_char PROGMEM Cmd_81[]="ClockThu";
prog_char PROGMEM Cmd_82[]="ClockFri";
prog_char PROGMEM Cmd_83[]="ClockSat";
prog_char PROGMEM Cmd_84[]="StatusEvent";
prog_char PROGMEM Cmd_85[]="KAKU";
prog_char PROGMEM Cmd_86[]="NewKAKU";
prog_char PROGMEM Cmd_87[]="Timer";
prog_char PROGMEM Cmd_88[]="UserEvent";
prog_char PROGMEM Cmd_89[]="Variable";
prog_char PROGMEM Cmd_90[]="Wildcard";
prog_char PROGMEM Cmd_91[]="WiredIn";


// tabel die refereert aan de commando strings
PROGMEM const char *CommandText_tabel[]={
  Cmd_0 ,Cmd_1 ,Cmd_2 ,Cmd_3 ,Cmd_4 ,Cmd_5 ,Cmd_6 ,Cmd_7 ,Cmd_8 ,Cmd_9 ,
  Cmd_10,Cmd_11,Cmd_12,Cmd_13,Cmd_14,Cmd_15,Cmd_16,Cmd_17,Cmd_18,Cmd_19,
  Cmd_20,Cmd_21,Cmd_22,Cmd_23,Cmd_24,Cmd_25,Cmd_26,Cmd_27,Cmd_28,Cmd_29,
  Cmd_30,Cmd_31,Cmd_32,Cmd_33,Cmd_34,Cmd_35,Cmd_36,Cmd_37,Cmd_38,Cmd_39,
  Cmd_40,Cmd_41,Cmd_42,Cmd_43,Cmd_44,Cmd_45,Cmd_46,Cmd_47,Cmd_48,Cmd_49,
  Cmd_50,Cmd_51,Cmd_52,Cmd_53,Cmd_54,Cmd_55,Cmd_56,Cmd_57,Cmd_58,Cmd_59,
  Cmd_60,Cmd_61,Cmd_62,Cmd_63,Cmd_64,Cmd_65,Cmd_66,Cmd_67,Cmd_68,Cmd_69,
  Cmd_70,Cmd_71,Cmd_72,Cmd_73,Cmd_74,Cmd_75,Cmd_76,Cmd_77,Cmd_78,Cmd_79,          
  Cmd_80,Cmd_81,Cmd_82,Cmd_83,Cmd_84,Cmd_85,Cmd_86,Cmd_87,Cmd_88,Cmd_89,
  Cmd_90,Cmd_91};

PROGMEM prog_uint16_t Sunrise[]={         
  528,525,516,503,487,467,446,424,401,378,355,333,313,295,279,268,261,259,263,271,283,297,312,329,
  345,367,377,394,411,428,446,464,481,498,512,522,528,527};
      
PROGMEM prog_uint16_t Sunset[]={          
  999,1010,1026,1044,1062,1081,1099,1117,1135,1152,1169,1186,1203,1219,1235,1248,1258,1263,1264,1259,
  1249,1235,1218,1198,1177,1154,1131,1107,1084,1062,1041,1023,1008,996,990,989,993,1004};

// Declaratie aansluitingen op de Arduino
// D0 en D1 kunnen niet worden gebruikt. In gebruik door de FTDI-chip voor seriele USB-communiatie (TX/RX).
// A4 en A5 worden gebruikt voor I2C communicatie voor o.a. de real-time clock
#define IR_ReceiveDataPin          3  // Op deze input komt het IR signaal binnen van de TSOP. Bij HIGH bij geen signaal.
#define IR_TransmitDataPin        11  // Aan deze pin zit een zender IR-Led. (gebufferd via transistor i.v.m. hogere stroom die nodig is voor IR-led)
#define RF_TransmitPowerPin        4  // +5 volt / Vcc spanning naar de zender.
#define RF_TransmitDataPin         5  // data naar de zender
#define RF_ReceiveDataPin          2  // Op deze input komt het 433Mhz-RF signaal binnen. LOW bij geen signaal.
#define RF_ReceivePowerPin        12  // Spanning naar de ontvanger via deze pin.
#define MonitorLedPin             13  // bij iedere ontvangst of verzending licht deze led kort op.
#define BuzzerPin                  6  // luidspreker aansluiting
#define WiredAnalogInputPin_1      0  // vier analoge inputs van 0 tot en met 3
#define WiredDigitalOutputPin_1    7  // vier digitale outputs van 7 tot en met 10

#define UNIT                       0x1 // Unit nummer van de Nodo. Bij gebruik van meerdere nodo's deze uniek toewijzen [1..F]
#define HOME                       0x1 // Home adres van de Nodo. Bij gebruik van meerdere nodo's deze hetzelfde houden [1..F]
#define BASECODE                   0x0 // Base code voor 26-bit code. Geeft de mogenlijkheid een bestaande zender te emuleren. Hierbij worden de nodo-home & unit codes en de home codes van het NewKAKU commando bij opgeteld.
#define Eventlist_OFFSET            64 // Eerste deel van het EEPROM geheugen is voor de settings. Reserveer __ bytes. Deze niet te gebruiken voor de Eventlist.
#define Eventlist_MAX              120 // aantal events dat de lijst bevat in het EEPROM geheugen van de ATMega328. Iedere event heeft 8 bytes nodig. eerste adres is 0
#define USER_TIMER_MAX              15 // aantal beschikbare timers voor de user.
#define USER_VARIABLES_MAX          15 // aantal beschikbare gebbruikersvariabelen voor de user.
#define RAW_BUFFER_SIZE            200 // Maximaal aantal te ontvangen bits*2. 

#define DIRECTION_IN                 1
#define DIRECTION_OUT                2
#define DIRECTION_INTERNAL           3
#define DIRECTION_EXECUTE            4

#define DIVERT_TYPE_USEREVENT        0 
#define DIVERT_TYPE_EVENTS           1 
#define DIVERT_TYPE_ALL              2 
#define DIVERT_PORT_IR_RF            0
#define DIVERT_PORT_IR               1
#define DIVERT_PORT_RF               2 

#define WAITFREERF_OFF               0
#define WAITFREERF_SERIES            1
#define WAITFREERF_ALL               2

#define EVENT_PART_COMMAND           1
#define EVENT_PART_HOME              2
#define EVENT_PART_UNIT              3
#define EVENT_PART_PAR1              4
#define EVENT_PART_PAR2              5

unsigned long UserTimer[USER_TIMER_MAX];
byte TimerCounter=0;
byte UserVarPrevious[USER_VARIABLES_MAX];
boolean WiredInputStatus[4],WiredOutputStatus[4];   // Wired variabelen
unsigned int RawSignal[RAW_BUFFER_SIZE];            // Tabel met de gemeten pulsen in microseconden. eerste waarde is het aantal bits*2
unsigned long EventTimeCodePrevious;                // t.b.v. voorkomen herhaald ontvangen van dezelfde code binnen ingestelde tijd
byte DaylightPrevious;                              // t.b.v. voorkomen herhaald genereren van events binnen de lopende minuut waar dit event zich voordoet
byte Simulate,DivertUnit;
void(*Reset)(void)=0; //declare reset function @ address 0
uint8_t RFbit,RFport,IRbit,IRport;
struct RealTimeClock {int Hour,Minutes,Seconds,Date,Month,Day,Daylight,Year;} Time;

struct Settings
  {
  int Version;
  boolean DaylightSaving;
  byte WiredInputThreshold[4], WiredInputSmittTrigger[4], WiredInputPullUp[4];
  byte AnalyseSharpness;
  int AnalyseTimeOut;
  byte UserVar[USER_VARIABLES_MAX];
  byte Unit;
  byte Home;
  byte Trace;
  byte DivertPort,DivertType;
  }S;
  

void setup() 
  {    
  pinMode(IR_ReceiveDataPin,INPUT);
  pinMode(RF_ReceiveDataPin,INPUT);
  pinMode(RF_TransmitDataPin,OUTPUT);
  pinMode(RF_TransmitPowerPin,OUTPUT);
  pinMode(RF_ReceivePowerPin,OUTPUT);
  pinMode(IR_TransmitDataPin,OUTPUT);
  pinMode(MonitorLedPin,OUTPUT);
  pinMode(BuzzerPin, OUTPUT);
  
  digitalWrite(IR_ReceiveDataPin,HIGH);  // schakel pull-up weerstand in om te voorkomen dat er rommel binnenkomt als pin niet aangesloten
  digitalWrite(RF_ReceiveDataPin,HIGH);  // schakel pull-up weerstand in om te voorkomen dat er rommel binnenkomt als pin niet aangesloten
  digitalWrite(RF_ReceivePowerPin,HIGH); // Spanning naar de RF ontvanger aan.

  RFbit=digitalPinToBitMask(RF_ReceiveDataPin);
  RFport=digitalPinToPort(RF_ReceiveDataPin);  
  IRbit=digitalPinToBitMask(IR_ReceiveDataPin);
  IRport=digitalPinToPort(IR_ReceiveDataPin);

  Wire.begin();        // zet I2C communicatie gereed voor uitlezen van de realtime clock.
  Serial.begin(BAUD);  // Initialiseer de seriële poort
  SerialHold(true);    // Zend een X-Off zodat de nodo geen seriele tekens ontvangt die nog niet verwerkt kunnen worden
  IR38Khz_set();       // Initialiseet de 38Khz draaggolf voor de IR-zender.
  LoadSettings();      // laad alle settings zoals deze in de EEPROM zijn opgeslagen
  DivertUnit=S.Unit;
  
  if(S.Version!=VERSION)ResetFactory(); // Als versienummer in EEPROM niet correct is, dan een ResetFactory.
  
  // initialiseer de Wired in- en uitgangen
  for(byte x=0;x<=3;x++)
    {
    pinMode(WiredDigitalOutputPin_1+x,OUTPUT); // definieer Arduino pin's voor Wired-Out
    digitalWrite(14+WiredAnalogInputPin_1+x,S.WiredInputPullUp[x]?HIGH:LOW);// Zet de pull-up weerstand van 20K voor analoge ingangen. Analog-0 is gekoppeld aan Digital-14
    }
    
  //Zorg ervoor dat er niet direct na een boot een CMD_CLOCK_DAYLIGHT event optreedt
  ClockRead();
  SetDaylight();
  DaylightPrevious=Time.Daylight;

  // Zet statussen WIRED_IN op hoog, anders wordt direct wij het opstarten vier maal een event gegenereerd omdat de pull-up weerstand analoge de waarden op FF zet
  for(byte x=0;x<4;x++){WiredInputStatus[x]=true;}

  // Print Welkomsttekst
  PrintTerm();
  PrintLine();
  Serial.print(Text(Text_01));
  Serial.print(S.Version,DEC);
  Serial.print(Text(Text_03));
  Serial.print(S.Home,DEC);
  Serial.print(Text(Text_14));
  Serial.print(S.Unit,DEC);PrintTerm();
  PrintLine();
 
  ProcessEvent(command2event(CMD_BOOT_EVENT,0,0),CMD_SOURCE_SYSTEM,0,0);  // Voer het 'Boot' event uit.
  }

#define Loop_INTERVAL_1          500  // tijdsinterval in ms. voor achtergrondtaken.
#define Loop_INTERVAL_2         5000  // tijdsinterval in ms. voor achtergrondtaken.
#define SHARP_TIME              1000  // tijd dat de nodo gefocust moet blijven luisteren naar één dezelfde poort na binnenkomst van een signaal

void loop() 
  {
  unsigned long Content=0L,StaySharpTimer=millis();
  unsigned long LoopIntervalTimer_1=millis();// millis() maakt dat de intervallen van 1 en 2 niet op zelfde moment vallen => 1 en 2 nu asynchroon
  unsigned long LoopIntervalTimer_2=0L;
  unsigned long PauseTimerIR,PauseTimerRF,ContentPrevious; // t.b.v. voorkomen onbedoeld achter elkaar herhaald ontvangen van codes
  unsigned long Checksum=0L;
  byte x,y,z, WiredCounter=0, VariableCounter;

  SerialHold(false); // er mogen weer tekens binnen komen van SERIAL

  while(true)// dit is een tijdkritische loop die wacht tot binnegekomen event op IR, RF, SERIAL, CLOCK, DAYLIGHT, TIMER
    {            
    digitalWrite(MonitorLedPin,LOW);           // LED weer uit

    // SERIAL: *************** kijk of er data klaar staat op de seriële poort **********************
    do
      {
      if(Serial.available()>0)
        {
        if(Content=Receive_Serial())
          ProcessEvent(Content,CMD_PORT_SERIAL,0,0);      // verwerk binnengekomen event.
        StaySharpTimer=millis()+SHARP_TIME;
        SerialHold(false);
        }
      }while(millis()<StaySharpTimer);

    // IR: *************** kijk of er data staat op IR en genereer een event als er een code ontvangen is **********************
    do
      {
      if((*portInputRegister(IRport)&IRbit)==0)// Kijk if er iets op de IR poort binnenkomt. (Pin=LAAG als signaal in de ether). 
        {
        if(IRFetchSignal())// Als het een duidelijk signaal was
          {
          Content=AnalyzeRawSignal(); // Bereken uit de tabel met de pulstijden de 32-bit code. 
          if(Content)// als AnalyzeRawSignal een event heeft opgeleverd
            {
            StaySharpTimer=millis()+SHARP_TIME;
            if(Content==Checksum && (millis()>PauseTimerIR || Content!=ContentPrevious))
               {
               PauseTimerIR=millis()+IR_ENDSIGNAL_TIME; // zodat herhalingen niet opnieuw opgepikt worden
               ProcessEvent(Content,CMD_PORT_IR,0,0); // verwerk binnengekomen event.
               ContentPrevious=Content;
               }
            Checksum=Content;
            }
          }
        }
      }while(millis()<StaySharpTimer);
  
  
    // RF: *************** kijk of er data start op RF en genereer een event als er een code ontvangen is **********************
    do// met StaySharp wordt focus gezet op luisteren naar RF, doordat andere input niet wordt opgepikt
      {
      if((*portInputRegister(RFport)&RFbit)==RFbit)// Kijk if er iets op de RF poort binnenkomt. (Pin=HOOG als signaal in de ether). 
        {
        if(RFFetchSignal())// Als het een duidelijk signaal was
          {
          Content=AnalyzeRawSignal(); // Bereken uit de tabel met de pulstijden de 32-bit code. 
          if(Content)// als AnalyzeRawSignal een event heeft opgeleverd
            {
            StaySharpTimer=millis()+SHARP_TIME;
            if(Content==Checksum && (millis()>PauseTimerRF || Content!=ContentPrevious))// tweede maal ontvangen als checksum
               {
               PauseTimerRF=millis()+RF_ENDSIGNAL_TIME; // zodat herhalingen niet opnieuw opgepikt worden
               ProcessEvent(Content,CMD_PORT_RF,0,0); // verwerk binnengekomen event.
               ContentPrevious=Content;
               }
            Checksum=Content;
            }
          }
        }
      }while(millis()<StaySharpTimer);
 
    
    // 2: niet tijdkritische processen die periodiek uitgevoerd moeten worden
    if(LoopIntervalTimer_2<millis()) // lange interval
      {
      LoopIntervalTimer_2=millis()+Loop_INTERVAL_2; // reset de timer

      // CLOCK: **************** Lees periodiek de realtime klok uit en check op events  ***********************
      Content=ClockRead(); // Lees de Real Time Clock waarden in de struct Time
      if(CheckEventlist(Content) && EventTimeCodePrevious!=Content)
        {
        EventTimeCodePrevious=Content; 
        ProcessEvent(Content,CMD_SOURCE_CLOCK,0,0);      // verwerk binnengekomen event.
        }
      else
        Content=0L;
      
      // DAYLIGHT: **************** Check zonsopkomst & zonsondergang  ***********************
      SetDaylight();
      if(Time.Daylight!=DaylightPrevious)// er heeft een zonsondergang of zonsopkomst event voorgedaan
        {
        Content=command2event(CMD_CLOCK_EVENT_DAYLIGHT,Time.Daylight,0L);
        DaylightPrevious=Time.Daylight;
        ProcessEvent(Content,CMD_SOURCE_CLOCK,0,0);      // verwerk binnengekomen event.
        }
      }// lange interval

    // 1: niet tijdkritische processen die periodiek uitgevoerd moeten worden
    if(LoopIntervalTimer_1<millis())// korte interval
      {
      LoopIntervalTimer_1=millis()+Loop_INTERVAL_1; // reset de timer 
      
      // WIRED: *************** kijk of statussen gewijzigd zijn op WIRED **********************
     if(WiredCounter<3)
       WiredCounter++;
     else
       WiredCounter=0;

     // als de huidige waarde groter dan threshold EN de vorige keer was dat nog niet zo DAN verstuur code
     z=false; // vlag om te kijken of er een wijziging is die verzonden moet worden.
     y=analogRead(WiredAnalogInputPin_1+WiredCounter)>>2;
     
     if(y>S.WiredInputThreshold[WiredCounter]+S.WiredInputSmittTrigger[WiredCounter] && !WiredInputStatus[WiredCounter])
       {
       WiredInputStatus[WiredCounter]=true;
       z=true;
       }
     if(y<S.WiredInputThreshold[WiredCounter]-S.WiredInputSmittTrigger[WiredCounter] && WiredInputStatus[WiredCounter])
       {
       WiredInputStatus[WiredCounter]=false;
       z=true;
       }
   
     if(z)// er is een verandering van status op de ingang. 
       {    
       Content=command2event(CMD_WIRED_IN_EVENT,WiredCounter+1,WiredInputStatus[WiredCounter]);
       ProcessEvent(Content,CMD_PORT_WIRED,0,0);      // verwerk binnengekomen event.
       }

    // TIMER: **************** Genereer event als één van de Timers voor de gebruiker afgelopen is ***********************
    if(TimerCounter<USER_TIMER_MAX-1)
      TimerCounter++;
    else
      TimerCounter=0;
    if(UserTimer[TimerCounter]!=0L)// als de timer actief is
        {
        if(UserTimer[TimerCounter]<millis()) // als de timer is afgelopen.
          {
          UserTimer[TimerCounter]=0L;// zet de timer op inactief.
          Content=command2event(CMD_TIMER_EVENT,TimerCounter+1,0);
          ProcessEvent(Content,CMD_SOURCE_TIMER,0,0);      // verwerk binnengekomen event.
          }
        }
        
      // VARIABLE: *************** Behandel gewijzigde variabelen als en binnengekomen event ******************************
      for(x=0;x<USER_VARIABLES_MAX;x++)
        {
        if(S.UserVar[x]!=UserVarPrevious[x]) // de eerste gewijzigde variabele
          {
          UserVarPrevious[x]=S.UserVar[x];
          Content=command2event(CMD_VARIABLE_EVENT,x+1,S.UserVar[x]);
          ProcessEvent(Content,CMD_SOURCE_VARIABLE,0,0);      // verwerk binnengekomen event.
          }
        }
      }// korte interval
    }
  }


