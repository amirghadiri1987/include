//+------------------------------------------------------------------+
//|                                               MatrixNetStore.mqh |
//|                                    Copyright (c) 2023, Marketeer |
//|                          https://www.mql5.com/ru/articles/12187/ |
//+------------------------------------------------------------------+
#include "MatrixNet.mqh"

//+------------------------------------------------------------------+
//| General storage interface for custom data                        |
//+------------------------------------------------------------------+
class Storage
{
public:
   virtual bool store(const int h) = 0;
   virtual bool restore(const int h) = 0;
};

//+-----------------------------------------------------------------------+
//| MatrixNet writer/reader with the storage interface invocation.        |
//| By default handles all internal data of NN (structure, size, weights) |
//+-----------------------------------------------------------------------+
class MatrixNetStore
{
   static string signature;
public:
   void static setSignature(const string s)
   {
      signature = s;
   }
   
   string static getSignature()
   {
      return signature;
   }
   
   template<typename M> // M is a MatrixNet
   static M *load(const string filename, Storage *storage = NULL, const int flags = 0)
   {
      int h = FileOpen(filename, FILE_READ | FILE_BIN | FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_ANSI | flags);
      if(h == INVALID_HANDLE) return NULL;
      
      const string header = FileReadString(h, StringLen(signature));
      if(header != signature)
      {
         FileClose(h);
         Print("Incorrect file header");
         return NULL;
      }
      
      const ENUM_ACTIVATION_FUNCTION f1 = (ENUM_ACTIVATION_FUNCTION)FileReadInteger(h);
      const ENUM_ACTIVATION_FUNCTION f2 = (ENUM_ACTIVATION_FUNCTION)FileReadInteger(h);
      const int size = FileReadInteger(h);
      matrix w[];
      ArrayResize(w, size);
      for(int i = 0; i < size; ++i)
      {
         const int rows = FileReadInteger(h);
         const int cols = FileReadInteger(h);
         double a[];
         FileReadArray(h, a, 0, rows * cols);
         w[i].Swap(a);
         w[i].Reshape(rows, cols);
      }
      
      if(storage)
      {
         if(!storage.restore(h)) Print("External info wasn't read");
      }
      
      M *m = new M(w, f1, f2);
      
      FileClose(h);
      return m;
   }
   
   template<typename M> // M is a MatrixNet
   static bool save(const string filename, const M &net, Storage *storage = NULL, const int flags = 0)
   {
      matrix w[];
      if(!net.getBestWeights(w))
      {
         if(!net.getWeights(w))
         {
            return false;
         }
      }
      
      int h = FileOpen(filename, FILE_WRITE | FILE_BIN | FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_ANSI | flags);
      if(h == INVALID_HANDLE) return false;
      
      FileWriteString(h, signature);
      FileWriteInteger(h, net.getActivationFunction());
      FileWriteInteger(h, net.getActivationFunction(true));
      FileWriteInteger(h, ArraySize(w));
      for(int i = 0; i < ArraySize(w); ++i)
      {
         matrix m = w[i];
         FileWriteInteger(h, (int)m.Rows());
         FileWriteInteger(h, (int)m.Cols());
         double a[];
         m.Swap(a);
         FileWriteArray(h, a);
      }

      if(storage)
      {
        if(!storage.store(h)) Print("External info wasn't saved");
      }

      FileClose(h);
      return true;
   }
};

static string MatrixNetStore::signature = "BPNNMS/1.0";
//+-----------------------------------------------------------------------+
