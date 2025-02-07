//+------------------------------------------------------------------+
//|                                                      License.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version "1.00"

#property strict

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

#define LICENSED_TRADE_MODES {ACCOUNT_TRADE_MODE_DEMO}//{ACCOUNT_TRADE_MODE_CONTEST,ACCOUNT_TRADE_MODE_DEMO}
#define LICENSED_EXPIRY_DATE D'2025.06.01'
#define LICENSED_EXPIRY_DAYS 30
#define LICENSED_EXPIRY_DATE_START D'2025.05.01'
#define LICENSED_EXPIRY_DATE_START_COMPILE_TIME __DATETIME__
#define LICENSED_PRIVATE_KEY "Activation Key E"

class License
{
protected:
    string          M_ProductName;
    long             m_AccountLogin;
    int             m_UserID;
    datetime        m_Expiry;
    virtual string LicencePath();
            bool   FileGen(string data);
    
public:
    License();
    ~License();

    string GeneratePasscode(string data);
    void ClinetProgram(string NameExpert, int UserID, datetime Expiry, long LoginAccount = -1);
};

License::License()
{
}

License::~License()
{
}

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| create hash                                                      |
//+------------------------------------------------------------------+
string License::GeneratePasscode(string data)
{
    uchar dataChar[];
    StringToCharArray( data, dataChar, 0, StringLen( data ) );

    uchar cryptChar[];
    CryptEncode( CRYPT_HASH_SHA256, dataChar, dataChar, cryptChar );

    uchar resCharArray[];
    ArrayResize(resCharArray, ArraySize(cryptChar));
    ArrayCopy(resCharArray, cryptChar, 0, 0, ArraySize(cryptChar));

    uchar base64Result[];
    CryptEncode(CRYPT_BASE64, resCharArray, resCharArray, base64Result);
    
    string result = CharArrayToString(base64Result);

    return result;
}

//+------------------------------------------------------------------+
//| create file name to hash                                         |
//+------------------------------------------------------------------+
string License::LicencePath() {return ("License\\"+M_ProductName+"\\"+GeneratePasscode(IntegerToString(m_AccountLogin)+"_"+IntegerToString(m_UserID))+"lic");}

//+------------------------------------------------------------------+
//| set to name prognam, login number, expirytion, user id           |
//+------------------------------------------------------------------+
void License::ClinetProgram(string NameExpert, int UserID, datetime Expiry, long LoginAccount = -1)
{
    if(LoginAccount < 0) {LoginAccount = AccountInfoInteger(ACCOUNT_LOGIN);}
    m_AccountLogin  = LoginAccount;
    M_ProductName   = NameExpert;
    m_UserID        = UserID;
    m_Expiry        = Expiry;
}

//+------------------------------------------------------------------+
//| create file to hash                                              |
//+------------------------------------------------------------------+
bool License::FileGen(string data)
{
    string licencePath = LicencePath();
    int    handle      = FileOpen( licencePath, FILE_WRITE | FILE_BIN | FILE_ANSI );
    if ( handle == INVALID_HANDLE ) {
        PrintFormat( "Could not create licence file %s", licencePath );
        return ( false );
    }

    return true;
}


































