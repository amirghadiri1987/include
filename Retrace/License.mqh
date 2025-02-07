//+------------------------------------------------------------------+
//|                                                      License.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#define LICENSED_TRADE_MODES {ACCOUNT_TRADE_MODE_DEMO,ACCOUNT_TRADE_MODE_REAL}//{ACCOUNT_TRADE_MODE_CONTEST,ACCOUNT_TRADE_MODE_DEMO}
#define LICENSED_PRIVATE_KEY "Activation Key E"
#define LICENSED_EXPIRY_DAYS 30

#include "Setting.mqh"
#include "FileSave.mqh"
#include "Translations/English.mqh"
long InpUserId      = 123456;        
datetime InpExpiry  = D'2020.01.01';

class License 
{
private:
    CFileSaving     m_fileSave;
    string          g_logMessages;
protected:
    string          m_mqlName;
    string          m_account;
    string          m_userid;
    string          m_expiry;

    
            
    

public:
    License();
    ~License();

        void            Initialization();
        bool            CheckTradeModes();
        bool            VerifyLicenseWeb();
        bool            CheckAccountMarginMode();
private:
        string          IniFileName(const bool Log) const;
        bool            IniFileDelete(void) {return FileDelete(m_fileSave.DirectoryLogFile());}
        string          LoadPathSetting()   {return ("Licence\\"+m_mqlName+"\\" +IniFileName(false));}
        bool            SaveSettingsOnDisk();
        bool            LoadSettingsFromDisk();
        bool            FileGen();
        string          Hash(string data);
        string          KeyGen( string data );
        bool            CheckIsFile() { return FileIsExist(LicencePath());}
        bool            CreateLicenseFile();
        bool            VerifyLicenseFile();
        string          LicencePath();
        bool            LoadDataFile( string &data );
        string          SanitizeFileName(string fileName);
        long            Current_Account_Mode() {return AccountInfoInteger(ACCOUNT_TRADE_MODE);}
        bool            LoadDataServer( string &data );
        

};

License::License()
{    
}

License::~License()
{
}


void License::Initialization()
{
    m_mqlName   = MQLInfoString(MQL_PROGRAM_NAME);
    m_account   = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
    IniFileDelete();
    string txt = "\n"+__FUNCTION__+":: "+TRANSLATION_EXPERT_START;
    m_fileSave.IniFileSave(txt,false);
    m_fileSave.IniFileSaveRun(TRANSLATION_EXPERT_START,false);
    if (!LoadSettingsFromDisk()) {SaveSettingsOnDisk();}
}

string License::IniFileName(const bool Log) const
{
   string name;

   name=m_mqlName;

   if(Log) {name+="_Log";}
   else {name+="_Setttings";}
   name+="_Ini.txt";

   return(name);
}

bool License::SaveSettingsOnDisk()
{
    Sets.LoginUserID = IntegerToString(InpUserId);
    Sets.LoginExpiry = TimeToString(InpExpiry,TIME_DATE);

    ResetLastError();
    string txt = TRANSLATION_TRYING_TO_SAVE_FILE + IniFileName(false)+TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(__FUNCTION__+":: "+ txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    int fh;
    // Save to new format only.
    fh = FileOpen(LoadPathSetting(), FILE_CSV | FILE_WRITE);
    if (fh == INVALID_HANDLE)
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_LICENSE_FILED_TO_OPEN_ + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
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
    txt = TRANSLATION_SAVE_DONE + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(__FUNCTION__+":: "+ txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    return true;
}

bool License::LoadSettingsFromDisk()
{
    ResetLastError();
    string txt = TRANSLATION_LICENSE_TRYING_TO_LOAD + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(__FUNCTION__+":: "+ txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    int fh;
    if (!FileIsExist(LoadPathSetting()))
    {
        ResetLastError();
        string txt = " ⚠ "+ TRANSLATION_LICENSE_NO_SETTINGS + IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }
    fh = FileOpen(LoadPathSetting(), FILE_CSV | FILE_READ);
    if (fh == INVALID_HANDLE)
    {
        ResetLastError();
        string txt =" ⚠ "+ TRANSLATION_LICENSE_FAILED_TO_OPEN_FILE_READING+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
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
    txt = TRANSLATION_LICENSE_LOADED_DONE + IntegerToString(GetLastError());
    m_fileSave.IniFileSave(__FUNCTION__+":: "+ txt,false);
    m_fileSave.IniFileSaveRun(txt,false);

    return true;
}

string License::Hash(string data) 
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
        string txt = TRANSLATION_LICENSE_ERROR_HASH + TRANSLATION_MESSAGE_ERROR +IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+":: "+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return "";
    }

        // Base64 encode the hash result
    uchar base64Result[];
    if (!CryptEncode(CRYPT_BASE64, hashResult, hashResult, base64Result)) {
        ResetLastError();
        string txt = TRANSLATION_LICENSE_ERROR_BASE + TRANSLATION_MESSAGE_ERROR +IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+":: "+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return "";
    }

    // Convert Base64 result to string for the final passcode
    string result = CharArrayToString(base64Result);

    return result;
}

string License::KeyGen( string data ) {
   string keyString = data + m_mqlName;
   return Hash( keyString );
}

bool License::FileGen() {
    // Step 1: Ensure directory structure exists by creating a dummy file temporarily.
    string licenceDirPath = "Licence\\"+m_mqlName+"\\dummy.txt";
    int dummyHandle = FileOpen(licenceDirPath, FILE_WRITE | FILE_ANSI);
    if (dummyHandle == INVALID_HANDLE) {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_CREATE_DIRECTORY+m_mqlName+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
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
        string txt = " ⚠ "+TRANSLATION_LICENSE_NO_CREATE_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        return false;
    }

    // Combine signature and data into one line
    string data_hash = Hash(m_account + "_" + Sets.LoginExpiry + "_" + Sets.LoginUserID + "_" + m_mqlName + "_" + LICENSED_PRIVATE_KEY);
    string signature = KeyGen(data_hash);
    string contents = signature + data_hash + "\n" + Sets.LoginExpiry;
    // Print(licencePath); // show name file
    // Print(contents); // show hahs
    FileWriteString(handle, contents);
    FileFlush(handle);
    FileClose(handle);

    ResetLastError();
    string txt = TRANSLATION_LICENSE_CREATE_LICENSE_FILE+TRANSLATION_MESSAGE_ERROR+ IntegerToString(GetLastError());
    m_fileSave.IniFileSave(__FUNCTION__+":: "+txt,false);
    m_fileSave.IniFileSaveRun(txt,false);
    return true;
}

bool License::CreateLicenseFile()
{
    // Check if the file exists and verify if it matches current inputs
    if(CheckIsFile())
    {
        if(VerifyLicenseFile())  {return true;}
        else
        {
            ResetLastError();
            string txt = " ⚠ "+TRANSLATION_LICENSE_RETRY+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
            m_fileSave.IniFileSaveRun(txt,false);
            FileDelete(LicencePath());
            Alert(TRANSLATION_LICENSE_RETRY+".");
            return false;
        }
    }
    
    if(FileGen())  
    {
        if(CheckIsFile())  
        {
            ResetLastError();
            string txt =TRANSLATION_LICENSE_TO_CREATE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(__FUNCTION__+":: "+txt,false);
            m_fileSave.IniFileSaveRun(txt,false);

            return true;
        } 
    }
    
    return false;
}

bool License::VerifyLicenseFile()
{
    string licencePath = LicencePath();
    int maxAttempts = 2; // Allow one retry
    int attempt = 0;

    while (attempt < maxAttempts)
    {
        attempt++;

        // Attempt to open the file
        int handle = FileOpen(licencePath, FILE_READ | FILE_BIN | FILE_ANSI);
        if (handle == INVALID_HANDLE)
        {
            ResetLastError();
            string txt = " ⚠ "+TRANSLATION_LICENSE_FAILET_TO_OPEN_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(__FUNCTION__+"::"+txt, false);
            m_fileSave.IniFileSaveRun(txt, false);
            Alert(TRANSLATION_LICENSE_FAILET_TO_OPEN_FILE+".");
            return false; // Cannot open file, no retry possible
        }

        // Read the file contents
        string fileContents = FileReadString(handle);
        FileClose(handle);

        // Generate the expected data hash
        string data_hash = Hash(m_account + "_" + Sets.LoginExpiry + "_" + Sets.LoginUserID + "_" + m_mqlName + "_" + LICENSED_PRIVATE_KEY);
        string signature = KeyGen(data_hash);
        string expectedContents = signature + data_hash + "\n" + Sets.LoginExpiry;

        // Check if the file contents match the expected format and data
        if (fileContents == expectedContents)
        {
            return true; // Verification succeeded
        }

        // Log the error for this attempt
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_NO_VERIFY_INPUTS+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt, false);
        m_fileSave.IniFileSaveRun(txt, false);

        // Retry if more attempts are allowed
        if (attempt < maxAttempts)
        {
            ResetLastError();
            string txt =" ⚠ "+TRANSLATION_LICENSE_FAILED_RETRY_CREATE+IntegerToString(attempt+1)+TRANSLATION_LICENSE_FAILED_RETRY_CREATE+
                    IntegerToString(maxAttempts)+")"+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
            m_fileSave.IniFileSave(__FUNCTION__+"::"+txt, false);
            m_fileSave.IniFileSaveRun(txt, false);
            Sleep(500); // Add a small delay before retrying
            continue;
        }

        // After maximum attempts, show alert and fail
        ResetLastError();
        txt = " ⚠ "+TRANSLATION_LICENSE_FAILED_RETRY_ERROR1+"\n"+TRANSLATION_LICENSE_FAILED_RETRY_ERROR2+"\n"+
            TRANSLATION_LICENSE_FAILED_RETRY_ERROR3+"\n"+TRANSLATION_LICENSE_FAILED_RETRY_ERROR4+"\n"+TRANSLATION_LICENSE_ERROR_404_2+
            TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());

        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt, false);
        m_fileSave.IniFileSaveRun(txt, false);
        Alert(TRANSLATION_LICENSE_FAILED_RETRY_ERROR1+"\n"+TRANSLATION_LICENSE_FAILED_RETRY_ERROR2+"\n"+
              TRANSLATION_LICENSE_FAILED_RETRY_ERROR3+"\n"+TRANSLATION_LICENSE_FAILED_RETRY_ERROR4+"\n"+TRANSLATION_LICENSE_ERROR_404_2+".");
        return false;
    }

    return false;
}

// bool License::VerifyLicenseFile()
// {


    
//     string licencePath = LicencePath();
//     int handle = FileOpen(licencePath, FILE_READ | FILE_BIN | FILE_ANSI);
//     if(handle == INVALID_HANDLE)
//     {
//         ResetLastError();
//         string txt = __FUNCTION__+":: ⚠ "+TRANSLATION_LICENSE_FAILET_TO_OPEN_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
//         m_fileSave.IniFileSave(txt,false);
//         m_fileSave.IniFileSaveRun(txt,false);
//         Alert(TRANSLATION_LICENSE_FAILET_TO_OPEN_FILE+".");
//         return false;
//     }

//     // Read the file contents
//     string fileContents = FileReadString(handle);
//     FileClose(handle);
    
//     // Generate the expected data hash
//     string data_hash = Hash(m_account + "_" + Sets.LoginExpiry + "_" + Sets.LoginUserID + "_" + m_mqlName + "_" + LICENSED_PRIVATE_KEY);
//     string signature = KeyGen(data_hash);
//     string expectedContents = signature + data_hash + "\n" + Sets.LoginExpiry;
   
//     // Check if the file contents match the expected format and data
//     if (fileContents == expectedContents) {return true;}
//     ResetLastError();
//     string txt = __FUNCTION__+":: ⚠ "+TRANSLATION_LICENSE_NO_VERIFY_INPUTS+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
//     m_fileSave.IniFileSave(txt,false);
//     m_fileSave.IniFileSaveRun(txt,false);
//     Alert(TRANSLATION_LICENSE_NO_VERIFY_INPUTS+".");
//     return false;
// }

bool License::LoadDataFile( string &data ) {

   string licencePath = LicencePath();
   int    handle      = FileOpen( licencePath, FILE_READ | FILE_BIN | FILE_ANSI );
   if ( handle == INVALID_HANDLE ) {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_NO_OPEN_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_NO_OPEN_FILE+".");
        return ( false );
   }

   int len = ( int )FileSize( handle );
   data    = FileReadString( handle, len );
   FileClose( handle );
   return true;
}

string License::LicencePath() 
{
    string rawHash = Hash(m_mqlName + "_" + m_account);
    string sanitizedHash = SanitizeFileName(rawHash);
    return ("Licence\\" + m_mqlName + "\\" + sanitizedHash + ".lic");
}

string License::SanitizeFileName(string fileName) 
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

// -- check trade mode user
bool License::CheckTradeModes(){
  int validModes[] = LICENSED_TRADE_MODES;
  for (int i = ArraySize(validModes) - 1; i >= 0; i--) {
    if (Current_Account_Mode() == validModes[i]) {
      return true;  
    }
  }
  ResetLastError();
  string txt = " ⚠ "+TRANSLATION_LICENSE_AUTHORIZED+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
  m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
  m_fileSave.IniFileSaveRun(txt,false);
  Alert(TRANSLATION_LICENSE_AUTHORIZED+".");
  return false;  // Return false if no valid mode was found
}

bool License::LoadDataServer( string &data ) 
{
    string headers = "";
    char   postData[];
    char   resultData[];
    string resultHeaders;
    int timeout = 10000; // 10 seconds standard timeout
    int delayThreshold = 5000;

    string rawHash = Hash(m_mqlName + "_" + m_account);
    string mRegistration = SanitizeFileName(rawHash);
    

    string url     = "https://raw.githubusercontent.com";
    // string api     = StringFormat( "%s/amirghadiri1987/License/blob/main/%s.txt", url, mRegistration );
    string api     = StringFormat( "%s/amirghadiri1987/License/refs/heads/main/%s.lic", url, mRegistration );

    // Start tracking the time for feedback
    datetime startTime = TimeLocal();

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

    if ((TimeLocal() - startTime) > delayThreshold / 1000) {
        Comment("The license check is taking longer than expected. Please wait...");
    }

    data          = CharArrayToString( resultData );

    switch ( response ) {
    case -1:
    {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_ERROR_RESPONSE+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        ResetLastError();
        txt = " ⚠ "+TRANSLATION_LICENSE_ADD_URL + url + TRANSLATION_LICENSE_ADD_URL2+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_ADD_URL + url + TRANSLATION_LICENSE_ADD_URL2+".");
        Comment("");
        return false;
    }
        break;
    case 200:
        //--- Success
        Comment("");
        return true;
        break;
    case 404:
    {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_ERROR_404+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_ERROR_404+"\n"+TRANSLATION_LICENSE_ERROR_404_2+".");
        Comment("");
        return false;
    }
        break;
    default:
    {
        ResetLastError();
        string txt = TRANSLATION_LICENSE_ERROE_UNEXPECTED+ IntegerToString(response)+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+":: "+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Comment("");
        return false;
    }
        break;
    }

    Comment(""); // Clear any comment on exit
    return false;
}

bool License::VerifyLicenseWeb()
{
   // Check if license file creation was successful
    if (!CreateLicenseFile())
    {
        return false;
    }

    // Load data from server and file
    string data_server, data_file;
    if (!LoadDataServer(data_server))
    {
        return false;
    }
    if (!LoadDataFile(data_file))
    {
        return false;
    }
    
    // Parse server data
    int pos_Server = StringFind(data_server, "\n");
    if (pos_Server <= 0)
    {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_INVALID_LICENSE_SERVER+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_INVALID_LICENSE_SERVER+".");
        return false;
    }
    
    // Parse file data
    int pos_File = StringFind(data_file, "\n");
    if (pos_File <= 0)
    {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_INVALID_LICENSE_FILE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_INVALID_LICENSE_FILE+".");
        return false;
    }

    string signature_Server = StringSubstr( data_server, 0, pos_Server );
    string expiry_Server = StringSubstr( data_server, pos_Server + 1 );

    string signature_File = StringSubstr( data_file, 0, pos_File );
    string expiry_File = StringSubstr( data_file, pos_File + 1 );
    Sets.SHowExpiry = expiry_Server;
    // Validate signatures and expiry dates
    if (signature_Server != signature_File || expiry_Server != expiry_File) {
        ResetLastError();
        string txt = " ⚠ "+TRANSLATION_LICENSE_VERIFY_LICENSE+TRANSLATION_MESSAGE_ERROR+IntegerToString(GetLastError());
        m_fileSave.IniFileSave(__FUNCTION__+"::"+txt,false);
        m_fileSave.IniFileSaveRun(txt,false);
        Alert(TRANSLATION_LICENSE_VERIFY_LICENSE);
        return false;
    }

    // All checks passed
    return true; 
}

bool License::CheckAccountMarginMode()
{
    if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
    {
        ResetLastError();
        string txt = TRANSLATION_TERMINAL_MARGIN_MODE_HEDGE + TRANSLATION_MESSAGE_ERROR + IntegerToString(GetLastError());
        m_fileSave.IniFileSaveRun(txt,false);
        m_fileSave.IniFileSave(__FUNCTION__+":: "+ txt, false);
        Alert(TRANSLATION_TERMINAL_MARGIN_MODE_HEDGE+".");
        return false;
        
    }
    return true;
}













