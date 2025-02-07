//+------------------------------------------------------------------+
//|                                                    CSVReader.mqh |
//|                                    Copyright (c) 2019, Marketeer |
//|                            https://www.mql5.com/ru/articles/5913 |
//+------------------------------------------------------------------+

#include <Marketeer/IndexMap.mqh>
#include <Marketeer/GroupSettings.mqh>


input GroupSettings SCV_Settings; // C S V   S E T T I N G S

input string CSVDelimiter = ";" /*mql5 signals use ';' instead of ','*/; // · Delimiter


class CSVConverter
{
  private:
    class File
    {
      int file;
      
      public:
        File(const string name, const int flags, const short delimiter)
        {
          file = FileOpen(name, flags, delimiter, CP_UTF8);
        }
    
        File(const string name, const int flags)
        {
          file = FileOpen(name, flags);
        }
        
        bool isOpened()
        {
          return (file != INVALID_HANDLE);
        }
        
        int handle()
        {
          return file;
        }
        
        ~File()
        {
          if(file != INVALID_HANDLE) FileClose(file);
        }
    };

  public:
    static IndexMap *ReadCSV(const string inputFileName)
    {
      // history.csv - 13 columns, positions.csv - 10 columns
      int columns = StringFind(inputFileName, ".history.csv") > 0 ? 13 : (StringFind(inputFileName, ".positions.csv") > 0 ? 10 : 0);
      if(columns == 0)
      {
        Print("Supported files: *.history.csv and .positions.csv");
        return NULL;
      }
      Print("Reading csv-file ", inputFileName);
      uchar delimiter = (uchar)CSVDelimiter[0];
      File f(inputFileName, FILE_READ|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE, delimiter);
      if(!f.isOpened())
      {
        Alert("Can't read file " + inputFileName);
        return NULL;
      }
      int file = f.handle();
    
      bool headerLine = true;
      IndexMap *data = new IndexMap();
      string headers[];
      uint count = 0;
    
      while(!FileIsEnding(file))
      {
        string stLine = "";
        string stParts[];
        
        stLine = FileReadString(file);
        
        int nParts = StringSplit(stLine, delimiter, stParts);
        if(nParts != columns)
        {
          Print("File " + inputFileName + " contains " + (string)nParts + " columns (" + (string)(columns) + "+ required)");
          Print("Line: ", stLine);
          return NULL;
        }
    
        if(headerLine)
        {
          headerLine = false;
          ArrayCopy(headers, stParts);
          continue;
        }
        
        IndexMap *row = new IndexMap();
    
        for(int i = 0; i < nParts; i++)
        {
          row.setValue((string)i + "." + headers[i], stParts[i]);
        }
    
        data.add((string)count, row);
        ++count;
        
      }
      
      return data;
    }
    
};