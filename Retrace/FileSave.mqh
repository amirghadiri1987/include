//+------------------------------------------------------------------+
//|                                                     FileSave.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class CFileSaving
{
private:
    MqlDateTime     m_date;
    string          m_mqlName;
    string          m_path;
    string          m_expertRunLogPath;
public:
    CFileSaving(void);
    ~CFileSaving(void);

            void            IniFileSave(string errortxt, bool symbol);
            void            IniFileSaveRun(string errortxt, bool symbol);
            string          IniFileName();
            bool            Save(const int file_handle, string errortxt, bool symbol);
    virtual string          DirectoryLogFile() {return (m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) + "\\"+IntegerToString(GenerateMagicNumbers())+ "\\Log\\Log.txt");}
    
};

CFileSaving::CFileSaving(void)
{
    // FileDelete(m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) + "\\Log\\Log.txt");
    m_mqlName   = MQLInfoString(MQL_PROGRAM_NAME);
    TimeToStruct(TimeCurrent(), m_date);
    string logFile = StringFormat("%04d%02d%02d", m_date.year, m_date.mon, m_date.day) + ".txt";
    m_path = m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) + "\\" + IntegerToString(GenerateMagicNumbers())+ "\\Log\\" + logFile;
    m_expertRunLogPath = m_mqlName + " EA" + "\\" + AccountInfoString(ACCOUNT_COMPANY) + "\\"+ IntegerToString(GenerateMagicNumbers())+ "\\Log\\Log.txt";
}

CFileSaving::~CFileSaving(void)
{
}


void CFileSaving::IniFileSave(string errortxt, bool symbol)
{
    string filename=m_path;
    int handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV);
    if(handle!=INVALID_HANDLE)
    {
        Save(handle,errortxt,symbol);
        FileClose(handle);
    }
}

void CFileSaving::IniFileSaveRun(string errortxt, bool symbol)
{
    string filename=m_expertRunLogPath;
    int handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV);
    if(handle!=INVALID_HANDLE)
    {
        Save(handle,errortxt,symbol);
        FileClose(handle);
    }
}


string CFileSaving::IniFileName()
{
   string name;

   name=m_mqlName;
   name+="_Log";
   name+="_Ini.txt";

   return(name);
}

bool CFileSaving::Save(const int file_handle, string errortxt, bool symbol)
{
    datetime currentTime = TimeCurrent();
    string dateTimeStr = TimeToString(currentTime, TIME_DATE | TIME_MINUTES);
    string str = symbol ? "  " + Symbol() : "  " ;

    FileSeek(file_handle,0,SEEK_END); 
    bool success = FileWriteString(file_handle,dateTimeStr + str + errortxt + "\n");
    return success;
}

long GenerateMagicNumbers()
{
    string expNames = MQLInfoString(MQL_PROGRAM_NAME);
    string symbol = Symbol();         // Get the current symbol (e.g., "EURUSD")
    // string expName = MQLInfoString(MQL_PROGRAM_NAME); // Get the expert name
    int baseMagicNumber = 10000;      // Base magic number

    // Calculate a unique number for the symbol
    int symbolCode = 0;
    for (int i = 0; i < StringLen(symbol); i++)
    {
        symbolCode += StringGetCharacter(symbol, i); // Sum the ASCII values of the symbol's characters
    }

    // Calculate a unique number for the expert name
    int expNameCode = 0;
    for (int i = 0; i < StringLen(expNames); i++)
    {
        expNameCode += StringGetCharacter(expNames, i); // Sum the ASCII values of the expert name's characters
    }

    // Combine base magic number, symbol code, and expert name code
    return baseMagicNumber + symbolCode + expNameCode;
}