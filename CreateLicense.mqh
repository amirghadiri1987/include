//+------------------------------------------------------------------+
//|                                                CreateLicense.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class CreateLicense
{
private:
    string          mProductName;
    string          mProductKey;
    string          mExpiry;
    string          mUserID;
    string          mAccount;
public:
    CreateLicense(void);
    ~CreateLicense(void);

    void            initalization(string productName, string productKey, datetime expiry, long userid, long account);
    string          KeyGen( string data ); //	Allow account to pass in
    string          Hash( string data );
    bool            FileGen( string data );
    void            CreateTestLicenseFile();
};

CreateLicense::CreateLicense(void)
{
}

CreateLicense::~CreateLicense(void)
{
}

void CreateLicense::initalization(string productName, string productKey, datetime expiry, long userid, long account)
{
    mProductName    = productName;
    mProductKey     = productKey;
    mExpiry         = TimeToString(expiry,TIME_DATE);
    mUserID         = IntegerToString(userid);
    mAccount        = IntegerToString(account);
}

string CreateLicense::Hash( string data ) {
    uchar dataCharArray[];
    StringToCharArray(data, dataCharArray);

    uchar combinedCharArray[];
    int combinedSize = ArraySize(dataCharArray);
    ArrayResize(combinedCharArray, combinedSize);
    ArrayCopy(combinedCharArray, dataCharArray, 0, 0, ArraySize(dataCharArray));

    // Generate SHA-256 hash
    uchar hashResult[];
    if (!CryptEncode(CRYPT_HASH_SHA256, combinedCharArray, combinedCharArray, hashResult)) {
        Print("Error generating SHA-256 hash.");
        return "";
    }

     // Base64 encode the hash result
    uchar base64Result[];
    if (!CryptEncode(CRYPT_BASE64, hashResult, hashResult, base64Result)) {
        Print("Error encoding to Base64.");
        return "";
    }
    
    // Convert Base64 result to string for the final passcode
    string result = CharArrayToString(base64Result);
    
    return result;
}

bool CreateLicense::FileGen( string data ) {

    string licencePath = Hash( mProductName + "_" + mAccount ) + ".lic";

    int    handle      = FileOpen( licencePath, FILE_WRITE | FILE_BIN | FILE_ANSI );
    if ( handle == INVALID_HANDLE ) {
        PrintFormat( "Could not create licence file %s", licencePath );
        return ( false );
    }
    string data_hash = Hash(mAccount + "_" + mExpiry + "_" + mUserID + "_" + mProductName + "_" + mProductKey);
    string signature = KeyGen(data_hash);
    string contents = signature + data_hash + "\n" + mExpiry;   
    FileWriteString( handle, contents );
    FileFlush( handle );
    FileClose( handle );

    Print( "Licence file '" + licencePath + "' created" );
    return ( true );
}

string CreateLicense::KeyGen( string data ) {
   string keyString = data + mProductName;
   return Hash( keyString );
}


void CreateLicense::CreateTestLicenseFile() {
    string data = Hash(mAccount + "_" + mExpiry + "_" + mUserID + "_" + mProductName + "_" + mProductKey);
   //	Create the file to ship to the customer
   if ( !FileGen( data ) ) {
      Print( "Failed to create licence file" );
      return;
   }

   Print( "Created licence file" );
}


