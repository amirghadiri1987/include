//+------------------------------------------------------------------+
//|                                                     Licenses.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#define LICENSED_TRADE_MODES {ACCOUNT_TRADE_MODE_DEMO,ACCOUNT_TRADE_MODE_REAL}//{ACCOUNT_TRADE_MODE_CONTEST,ACCOUNT_TRADE_MODE_DEMO}
#define LICENSED_PRIVATE_KEY "Activation Key E"
#define LICENSED_EXPIRY_DAYS 30

#include "Setting.mqh"
#include "Translations/English.mqh"
#include "FileSave.mqh"

// input group           "((-------------- Security ------------))";
// input long          InpUserId      = 123456;        // User ID
// input datetime      InpExpiry      = D'2020.01.01'; // Expirytion Date
long InpUserId      = 123456;        
datetime InpExpiry  = D'2020.01.01';

class Licenses 
{
private:
    CFileSave       m_fileSave;
    string          g_logMessages;
protected:
    string          m_mqlName;
    string          m_account;
    string          m_userid;
    string          m_expiry;

    string          SanitizeFileName(string fileName);
    string          LicencePath();
    bool            LoadDataServer( string &data );
    bool            LoadDataFile( string &data );
            
    

public:
    Licenses();
    ~Licenses();

            void            Initialization();
    virtual bool            VerifyLicenseWeb();
            bool            CheckIsFile() { return FileIsExist(LicencePath());}
            bool            CreateLicenseFile();
            bool            VerifyLicenseFile();
            bool            FileGen();
            long            Current_Account_Mode() {return AccountInfoInteger(ACCOUNT_TRADE_MODE);}
            bool            CheckTradeModes();
            string          Hash(string data);
            string          KeyGen( string data ); //	Allow account to pass in
    virtual string          IniFileName(const bool Log) const;
    virtual bool            IniFileDelete(void) {return FileDelete("Licence\\"+m_mqlName+"\\" +IniFileName(true));}
    virtual string          LoadPathSetting()   {return ("Licence\\"+m_mqlName+"\\" +IniFileName(false));}
    virtual string          LoadPathLog()       {return ("Licence\\"+m_mqlName+"\\" +IniFileName(true));}
    virtual bool            SaveSettingsOnDisk();
    virtual bool            LoadSettingsFromDisk();

};

Licenses::Licenses()
{    
    
}

Licenses::~Licenses()
{
}

void Licenses::Initialization()
{
    m_mqlName   = MQLInfoString(MQL_PROGRAM_NAME);
    m_account   = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
    IniFileDelete();
    if (!LoadSettingsFromDisk()) {SaveSettingsOnDisk();}
}

string Licenses::SanitizeFileName(string fileName) 
{
    // List of invalid characters to replace/remove
    string invalidChars = "\\/:*?\"<>|";
    
    // Replace invalid characters with an underscore (_)
    for (int i = 0; i < StringLen(invalidChars); i++) {
        // Extract each invalid character as a string
        string invalidChar = StringSubstr(invalidChars, i, 1);
        // Update fileName directly
        StringReplace(fileName, invalidChar, "_");
    }
    
    return fileName;
}

 
string Licenses::LicencePath() 
{
    string rawHash = Hash(m_mqlName + "_" + m_account);
    string sanitizedHash = SanitizeFileName(rawHash);
    return ("Licence\\" + m_mqlName + "\\" + sanitizedHash + ".lic");
}

string Licenses::Hash(string data) 
{
    uchar dataCharArray[];
    StringToCharArray(data, dataCharArray);

    uchar combinedCharArray[];
    int combinedSize = ArraySize(dataCharArray);
    ArrayResize(combinedCharArray, combinedSize);
    ArrayCopy(combinedCharArray, dataCharArray, 0, 0, ArraySize(dataCharArray));

    // Generate SHA-256 hash
    uchar hashResult[];
    if (!CryptEncode(CRYPT_HASH_SHA256, combinedCharArray, combinedCharArray, hashResult)) {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ERROR_HASH + TRANSLATION_MESSAGE_ERROR +IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return "";
    }

        // Base64 encode the hash result
    uchar base64Result[];
    if (!CryptEncode(CRYPT_BASE64, hashResult, hashResult, base64Result)) {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ERROR_BASE + TRANSLATION_MESSAGE_ERROR +IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return "";
    }

    // Convert Base64 result to string for the final passcode
    string result = CharArrayToString(base64Result);

    return result;
}

string Licenses::KeyGen( string data ) {
   string keyString = data + m_mqlName;
   return Hash( keyString );
}

bool Licenses::FileGen() {
    // Step 1: Ensure directory structure exists by creating a dummy file temporarily.
    string licenceDirPath = "Licence\\"+m_mqlName+"\\dummy.txt";
    int dummyHandle = FileOpen(licenceDirPath, FILE_WRITE | FILE_ANSI);
    if (dummyHandle == INVALID_HANDLE) {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_CREATE_DIRECTORY+m_mqlName+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
    FileClose(dummyHandle);
    FileDelete(licenceDirPath); // Delete the dummy file afterward

    // Step 2: Proceed to create the actual licence file
    string licencePath = LicencePath();
    int handle = FileOpen(licencePath, FILE_WRITE | FILE_BIN | FILE_ANSI);
    if (handle == INVALID_HANDLE) {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_NO_CREATE_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }

    // Combine signature and data into one line
    string data_hash = Hash(m_account + "_" + Sets.LoginExpiry + "_" + Sets.LoginUserID + "_" + m_mqlName + "_" + LICENSED_PRIVATE_KEY);
    string signature = KeyGen(data_hash);
    string contents = signature + data_hash + "\n" + Sets.LoginExpiry;
    FileWriteString(handle, contents);
    FileFlush(handle);
    FileClose(handle);

    ResetLastError();
    string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_CREATE_LICENSE_FILE+TRANSLATION_MESSAGE_ERROR+ IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    return true;
}

bool Licenses::CreateLicenseFile()
{
    // Check if the file exists and verify if it matches current inputs
    if(CheckIsFile())
    {
        if(VerifyLicenseFile())  {return true;}
        else
        {
            ResetLastError();
            string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_RETRY+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(txt,false);
            m_fileSave.IniFileSaveRun(txt,false);
            FileDelete(LicencePath());
            return false;
        }
    }
    
    if(FileGen())  
    {
        if(CheckIsFile())  
        {
            ResetLastError();
            string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_TO_CREATE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(txt,false);
            m_fileSave.IniFileSaveRun(txt,false);

            return true;
        } 
    }
    
    return false;
}

// Function to verify that the current license file matches the input parameters
bool Licenses::VerifyLicenseFile()
{
    string licencePath = LicencePath();
    int handle = FileOpen(licencePath, FILE_READ | FILE_BIN | FILE_ANSI);
    if(handle == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_FAILET_TO_OPEN_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }

    // Read the file contents
    string fileContents = FileReadString(handle);
    FileClose(handle);
    
    // Generate the expected data hash
    string data_hash = Hash(m_account + "_" + Sets.LoginExpiry + "_" + Sets.LoginUserID + "_" + m_mqlName + "_" + LICENSED_PRIVATE_KEY);
    string signature = KeyGen(data_hash);
    string expectedContents = signature + data_hash + "\n" + Sets.LoginExpiry;
   
    // Check if the file contents match the expected format and data
    if (fileContents == expectedContents) {return true;}
    ResetLastError();
    string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_NO_VERIFY_INPUTS+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    return false;
}

bool Licenses::LoadDataServer( string &data ) 
{
    string headers = "";
    char   postData[];
    char   resultData[];
    string resultHeaders;
    int    timeout = 5000; // 1 second, may be too short for a slow connection

    string mRegistration = Hash(m_mqlName+"_"+m_account);
    string url     = "https://raw.githubusercontent.com";
    // string api     = StringFormat( "%s/amirghadiri1987/License/blob/main/%s.txt", url, mRegistration );
    string api     = StringFormat( "%s/amirghadiri1987/License/refs/heads/main/%s.lic", url, mRegistration );


    ResetLastError();
    int response  = WebRequest( "GET", api, headers, timeout, postData, resultData, resultHeaders );

    // Add this code to handle 303 redirect but it creates more problems
    // if (response==303) {
    //	int locStart = StringFind(resultHeaders, "Location: ", 0)+10;
    //	int locEnd = StringFind(resultHeaders, "\r", locStart);
    //	api = StringSubstr(resultHeaders, locStart, locEnd-locStart);
    //	ResetLastError();
    //	response  = WebRequest( "GET", api, headers, timeout, postData, resultData, resultHeaders );
    //	errorCode = GetLastError();
    //}

    data          = CharArrayToString( resultData );

    switch ( response ) {
    case -1:
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ERROR_RESPONSE+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        ResetLastError();
        txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ADD_URL + url + TRANSLATION_LICENSE_ADD_URL2+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
        break;
    case 200:
        //--- Success
        return true;
        break;
    case 404:
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ERROR_404+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
    }
        break;
    default:
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_ERROE_UNEXPECTED+ IntegerToString(response)+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
        break;
    }

return false;
}

bool Licenses::LoadDataFile( string &data ) {

   string licencePath = LicencePath();
   int    handle      = FileOpen( licencePath, FILE_READ | FILE_BIN | FILE_ANSI );
   if ( handle == INVALID_HANDLE ) {
        ResetLastError();
        string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_NO_OPEN_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return ( false );
   }

   int len = ( int )FileSize( handle );
   data    = FileReadString( handle, len );
   FileClose( handle );
   return true;
}

bool Licenses::VerifyLicenseWeb()
{
    if (CreateLicenseFile())
    {
        Print("a1 ");
        string data_server, data_file;
        if (!LoadDataServer(data_server))   return false;
        if (!LoadDataFile(data_file))       return false;
        Print("a2 ");
        // Server
        int pos_Server = StringFind( data_server, "\n" );
        if ( pos_Server <= 0 ) {
            ResetLastError();
            string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_INVALID_LICENSE_SERVER+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(txt,false);
            m_fileSave.IniFileSaveRun(txt,false);
            return false;
        }

        // File
        int pos_File = StringFind( data_file, "\n" );
        if ( pos_File <= 0 ) {
            ResetLastError();
            string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_INVALID_LICENSE_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(txt,false);
            m_fileSave.IniFileSaveRun(txt,false);
            return false;
        }

        string signature_Server = StringSubstr( data_server, 0, pos_Server );
        string expiry_Server = StringSubstr( data_server, pos_Server + 1 );

        string signature_File = StringSubstr( data_file, 0, pos_File );
        string expiry_File = StringSubstr( data_file, pos_File + 1 );

        if (signature_Server != signature_File || expiry_Server != expiry_File) {
            ResetLastError();
            string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_VERIFY_LICENSE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(txt,false);
            m_fileSave.IniFileSaveRun(txt,false);
            Alert(TRANSLATION_LICENSE_VERIFY_LICENSE);
            return false;
        }

    }
    else return false;

    return true;
}

// -- check trade mode user
bool Licenses::CheckTradeModes(){
  int validModes[] = LICENSED_TRADE_MODES;
  for (int i = ArraySize(validModes) - 1; i >= 0; i--) {
    if (Current_Account_Mode() == validModes[i]) {
      return true;  
    }
  }
  ResetLastError();
  string txt = __FUNCTION__+":: "+TRANSLATION_LICENSE_AUTHORIZED+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
  m_fileSave.IniFileSave(txt,false);
  m_fileSave.IniFileSaveRun(txt,false);
  Alert(TRANSLATION_LICENSE_AUTHORIZED);
  return false;  // Return false if no valid mode was found
}

string Licenses::IniFileName(const bool Log) const
{
   string name;

   name=m_mqlName;

   if(Log) {name+="_Log";}
   else {name+="_Setttings";}
   name+="_Ini.txt";

   return(name);
}

bool Licenses::SaveSettingsOnDisk()
{
    Sets.LoginUserID = IntegerToString(InpUserId);
    Sets.LoginExpiry = TimeToString(InpExpiry,TIME_DATE);

    ResetLastError();
    string txt = __FUNCTION__+":: "+ TRANSLATION_TRYING_TO_SAVE_FILE + IniFileName(false)+TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    int fh;
    // Save to new format only.
    fh = FileOpen(LoadPathSetting(), FILE_CSV | FILE_WRITE);
    if (fh == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+ TRANSLATION_LICENSE_FILED_TO_OPEN_ + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }

    //--- Sets
    FileWrite(fh, "LoginUserID");
    FileWrite(fh, Sets.LoginUserID);
    FileWrite(fh, "LoginExpiry");
    FileWrite(fh, Sets.LoginExpiry);


    FileClose(fh);

    ResetLastError();
    txt = __FUNCTION__+":: "+ TRANSLATION_SAVE_DONE + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    return true;
}

bool Licenses::LoadSettingsFromDisk()
{
    ResetLastError();
    string txt = __FUNCTION__+":: "+ TRANSLATION_LICENSE_TRYING_TO_LOAD + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    int fh;
    if (!FileIsExist(LoadPathSetting()))
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+ TRANSLATION_LICENSE_NO_SETTINGS + IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
    fh = FileOpen(LoadPathSetting(), FILE_CSV | FILE_READ);
    if (fh == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = __FUNCTION__+":: "+ TRANSLATION_LICENSE_FAILED_TO_OPEN_FILE_READING+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
    while (!FileIsEnding(fh))
    {
        string var_name = FileReadString(fh);
        string var_content = FileReadString(fh);

        if (var_name == "LoginUserID")
            Sets.LoginUserID = (var_content);
        else if (var_name == "LoginExpiry")
            Sets.LoginExpiry = (var_content);       
    }
    FileClose(fh);

    ResetLastError();
    txt = __FUNCTION__+":: "+ TRANSLATION_LICENSE_LOADED_DONE + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(txt,false);

    return true;
}











