//+------------------------------------------------------------------+
//|  Enumeration for Windows fonts indices storage                   |
//+------------------------------------------------------------------+


class CFont
{
private:
  string            m_fonts[];

public:
                    CFont(void);
                   ~CFont(void);
  int               FontsTotal(void) const { return(::ArraySize(m_fonts)); }
  string            FontsByIndex(const uint index);

private:
  void              InitializeFontsArray(void);
};

CFont::CFont(void)
{
  InitializeFontsArray();
}

CFont::~CFont(void)
{
  ::ArrayFree(m_fonts);
}



string CFont::FontsByIndex(const uint index)
{
  uint array_size=FontsTotal();
  uint i=(index>=array_size)? array_size-1 : index;
  return(m_fonts[i]);
}


void CFont::InitializeFontsArray(void)
{
  ::ArrayResize(m_fonts,15);
  m_fonts[0]="Arial";
  m_fonts[1]="Comic Sans MS";
  m_fonts[2]="Courier";
  m_fonts[3]="Courier New";
  m_fonts[4]="Georgia";
  m_fonts[5]="Lucida Console Bold";
  m_fonts[6]="Palatino Linotype";
  m_fonts[7]="Small Fonts";
  m_fonts[8]="Tahoma";
  m_fonts[9]="Times New Roman";
  m_fonts[10]="Trebuchet MS";
  m_fonts[11]="Verdana";
  m_fonts[12]="Consolas";
  m_fonts[13]="Simplified Arabic Fixed";
  m_fonts[14]="Sitka Small";
}




