template<typename T1,typename T2>
class Converter
{
  private:
    union _L2D
    {
      T1 L;
      T2 D;
    }
    L2D;
  
  public:
    T2 operator[](const T1 L)
    {
      L2D.L = L;
      return L2D.D;
    }

    T1 operator[](const T2 D)
    {
      L2D.D = D;
      return L2D.L;
    }
};
