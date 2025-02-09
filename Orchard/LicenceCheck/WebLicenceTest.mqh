/*
   WebLicenceTest
   Copyright 2021, Orchard Forex
   https://www.orchardforex.com
*/

#include <Orchard/LicenceCheck/LicenceWebCheck.mqh>

input string InpProductName = "product1"; //	Product name used in file name
input string InpProductKey  = "key1";     //	Secret product key
input int    InpAccount     = 123456;     //	Customer Account number
input bool   InpTesting     = false;      // Is this a test

CLicenceWeb *licenceWeb;

void         OnStart_() {

   licenceWeb = new CLicenceWeb( InpProductName, InpProductKey, "", InpAccount );
   licenceWeb.SetRegistration();
   if ( !InpTesting ) {
      Make();
   }
   else {
      Test();
   }
   string data1;
   licenceWeb.chekload1(data1);
   
   Print("data1  ",data1);
   delete licenceWeb;
}

void Make() {

   //	Just making up some data here
   //	You could use anything that works for you
   //	Account number, expiry time, grace expiry time
   string data = licenceWeb.Hash( string( InpAccount ) ) + "\n" + licenceWeb.Hash( InpProductName ) + "\n" + TimeToString( TimeCurrent() + ( 86400 * 30 ) ) + "\n" +
                 TimeToString( TimeCurrent() + ( 86400 * 33 ) );

   //	Not necessary to do this, just for demonstration
   string signature = licenceWeb.KeyGen( data );
   Print( "The signature is " + signature );

   //	Create the file to ship to the customer
   if ( !licenceWeb.FileGen( data ) ) {
      Print( "Failed to create licence file" );
      return;
   }

   Print( "Created licence file" );
}

void Test() {

   Print( "Now testing licence" );
   if ( !licenceWeb.Check() ) {
      Print( "Oops, problem with the licence" );
      return;
   }

   Print( "Valid Licence" );
   string parts[];
   string licenceData = licenceWeb.GetData();
   StringSplit( licenceData, '\n', parts );

   PrintFormat( "Account=%s, %s", parts[0], ( parts[0] == licenceWeb.Hash( string( InpAccount ) ) ) ? "correct" : "fail" );

   PrintFormat( "Product=%s, %s", parts[1], ( parts[1] == licenceWeb.Hash( InpProductName ) ) ? "correct" : "fail" );

   PrintFormat( "Expires at %s", parts[2] );
   PrintFormat( "Grace expires at %s", parts[3] );
}

// bnH1yjYYpwp+dBDfzfvgUzmOGVhtv6hTHeYX7MwVhcQ=.lic
// bnH1yjYYpwp+dBDfzfvgUzmOGVhtv6hTHeYX7MwVhcQ=
