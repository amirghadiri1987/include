//+------------------------------------------------------------------+
//|                                                    MatrixNet.mqh |
//|                                    Copyright (c) 2023, Marketeer |
//|                          https://www.mql5.com/ru/articles/12187/ |
//+------------------------------------------------------------------+
#include <Graphics/Graphic.mqh>
#define PUSH(A,V) (A[ArrayResize(A, ArrayRange(A, 0) + 1, ArrayRange(A, 0) * 2) - 1] = V)

// In your source code you can enable RPROP mode (recommended)
// by placing the following macro in front of #include <MatrixNet.mqh>
// 
// #define BATCH_PROP

//+------------------------------------------------------------------+
//| Main class for backpropagation NN on matrices                    |
//+------------------------------------------------------------------+
class MatrixNet
{
protected:
   const int n;      // number of layers with weights (excluding input layer)
   matrix weights[/* n */];
   matrix outputs[/* n + 1 */];
   ENUM_ACTIVATION_FUNCTION af; // default activation function for all layers
   ENUM_ACTIVATION_FUNCTION of; // output layer activation function (if specified)
   bool ready;
   int dropOutRate;
   
public:
   // data stats and custom info
   struct Stats
   {
      double bestLoss;
      int bestEpoch;
      int trainingSet;
      int validationSet;
      int epochsDone;
   };
   
   Stats getStats() const
   {
      return stats;
   }
   
protected:
   // save best weights every time we got new minimum of loss
   matrix bestWeights[];
   Stats stats;
   
   #ifdef BATCH_PROP
   matrix speed[];
   matrix deltas[];
   #else
   double speed;
   #endif
   
   void allocate()
   {
      ArrayResize(weights, n);
      ArrayResize(outputs, n + 1);
      ArrayResize(bestWeights, n);
      dropOutRate = 0;
      #ifdef BATCH_PROP
      ArrayResize(speed, n);
      ArrayResize(deltas, n);
      plus = 1.1;
      minus = 0.1;
      max = 50;
      min = 0.0;
      #endif
   }
   
   template<typename T>
   struct SubArray
   {
      T data[];
   };
   
   class DropOutState
   {
      SubArray<uint> indices[];
      matrix weights[];
      const int percent;
   public:
      DropOutState(const int p = 10 /* subject of practical selection */): percent(p) { }
      
      bool restoreState(matrix &parent[], const bool cleanup = true)
      {
         const int n = ArraySize(parent);
         
         if(ArraySize(weights) == n)
         {
            for(int i = 0; i < n; ++i)
            {
               for(int j = 0; j < ArraySize(indices[i].data); ++j)
               {
                  parent[i].Flat(indices[i].data[j], weights[i].Flat(indices[i].data[j]));
               }
               if(cleanup) ArrayResize(indices[i].data, 0);
            }
            return true;
         }
         return false;
      }
      
      bool switchState(matrix &parent[])
      {
         const int n = ArraySize(parent);
         
         if(ArraySize(weights) == 0)
         {
            ArrayResize(weights, n);
            ArrayResize(indices, n);
         }
         else if(!restoreState(parent))
         {
            return false;
         }
         
         for(int i = 0; i < n; ++i)
         {
            weights[i].Assign(parent[i]); // save current state
            const int m = (int)(parent[i].Rows() * parent[i].Cols());
            int k = 0;
            while(k++ < m * percent / 100)
            {
               const uint p = (rand() | (rand() << 16)) % m;
               parent[i].Flat(p, 0);
               PUSH(indices[i].data, p);
            }
         }
         return true;
      }
   };
   
public:
   MatrixNet(const int &layers[], const ENUM_ACTIVATION_FUNCTION f1 = AF_TANH,
      const ENUM_ACTIVATION_FUNCTION f2 = AF_NONE):
      ready(false), af(f1), of(f2), n(ArraySize(layers) - 1)
   {
      if(n < 2) return;
      
      allocate();
      for(int i = 1; i <= n; ++i)
      {
         // NB: weights are transposed, that is [row][column] hold [synapse][neuron]
         weights[i - 1].Init(layers[i - 1] + 1, layers[i]);
         #ifdef BATCH_PROP
         speed[i - 1] = weights[i - 1];
         deltas[i - 1] = weights[i - 1];
         #endif
      }
      ready = true;
      randomize();
   }
   
   MatrixNet(const matrix &w[], const ENUM_ACTIVATION_FUNCTION f1 = AF_TANH,
      const ENUM_ACTIVATION_FUNCTION f2 = AF_NONE):
      ready(false), af(f1), of(f2), n(ArraySize(w))
   {
      if(n < 2) return;

      allocate();
      for(int i = 0; i < n; ++i)
      {
         weights[i] = w[i];
         #ifdef BATCH_PROP
         speed[i] = weights[i];
         deltas[i] = weights[i];
         #endif
      }
      
      ready = true;
   }
   
   bool isReady() const
   {
      return ready;
   }
   
   void enableDropOut(const uint percent = 10 /* 0 means disable */)
   {
      dropOutRate = (int)percent;
   }
   
   void setActivationFunction(const ENUM_ACTIVATION_FUNCTION f1, ENUM_ACTIVATION_FUNCTION f2 = AF_NONE)
   {
     af = f1;
     of = f2;
   }

   ENUM_ACTIVATION_FUNCTION getActivationFunction(const bool output = false) const
   {
     return output ? of : af;
   }
   
   bool getWeights(matrix &array[]) const
   {
      if(!ready) return false;
      
      ArrayResize(array, n);
      for(int i = 0; i < n; ++i)
      {
         array[i] = weights[i];
      }
      
      return true;
   }
   
   bool setWeights(matrix &array[])
   {
      if(!ready) return false;
      
      if(ArraySize(array) != n)
      {
         PrintFormat("Number of layers mismatches: got %d, expected %d",
            ArraySize(array), n);
         return false;
      }
      
      for(int i = 0; i < n; ++i)
      {
         if(array[i].Rows() != weights[i].Rows()
         || array[i].Cols() != weights[i].Cols())
         {
            PrintFormat("%d-th layer dimensions mismatch: got %dx%d, expected %dx%d",
               i, array[i].Rows(), array[i].Cols(), weights[i].Rows(), weights[i].Cols());
            return false;
         }
      }
      
      ArraySwap(array, weights);
      
      return true;
   }

   bool getBestWeights(matrix &array[]) const
   {
      if(!ready) return false;
      if(!n || !bestWeights[0].Rows()) return false;
      
      ArrayResize(array, n);
      for(int i = 0; i < n; ++i)
      {
         array[i] = bestWeights[i];
      }
      
      return true;
   }
   
   // NB: change values to appropriate distribution for specific activation function
   void randomize(const double from = -0.5, const double to = +0.5)
   {
      if(!ready) return;

      for(int i = 0; i < n; ++i)
      {
         weights[i].Random(from, to);
      }
   }
   
   double train(const matrix &data, const matrix &target,
      const matrix &validation, const matrix &check,
      const int epochs = 1000, const double accuracy = 0.001,
      const ENUM_LOSS_FUNCTION lf = LOSS_MSE)
   {
      if(!ready) return NaN();
      
      #ifdef BATCH_PROP
      for(int i = 0; i < n; ++i)
      {
         speed[i].Fill(accuracy); // will adjust the speeds on the fly
         deltas[i].Fill(0);
      }
      #else
      speed = accuracy;
      #endif
      
      double mse = DBL_MAX;
      double msev = DBL_MAX;
      double msema = 0;       // averaged training MSE
      double msemap = 0;      // averaged training MSE on previous epoch
      double msevma = 0;      // averaged validation MSE
      double msevmap = 0;     // averaged validation MSE on previous epoch
      double ema = 0;         // exponentional averaging coefficient
      int p = 0, grow = 0;    // ema period
      const int scale = (int)(data.Rows() / (validation.Rows() + 1)) + 1;
      
      p = (int)sqrt(epochs); // FIXME: rule of thumb - reconsider as appropriate
      ema = 2.0 / (p + 1);
      PrintFormat("EMA for early stopping: %d (%f)", p, ema);
      
      stats.bestLoss = DBL_MAX;
      stats.bestEpoch = -1;
      
      DropOutState state(dropOutRate);

      int ep = 0;
      for(; ep < epochs; ep++)
      {
         // NB: on each epoch entire dataset is processed as is,
         // no batches or shuffling - implement yourself
         if(validation.Rows() && check.Rows())
         {
            // if validation is enabled, run it before normal/training pass
            msev = test(validation, check, lf);
            // smooth error stat through epochs
            msevma = (msevma ? msevma : msev) * (1 - ema) + ema * msev;
         }
         
         if(dropOutRate > 0)
         {
            state.restoreState(weights);
         }
         
         mse = test(data, target, lf);  // invokes feedForward(data)
         msema = (msema ? msema : mse) * (1 - ema) + ema * mse;
         
         const double candidate = (msev != DBL_MAX) ? msev : mse;
         if(candidate < stats.bestLoss)
         {
            stats.bestLoss = candidate;
            stats.bestEpoch = ep;
            // get all 'weights' (which can be partially dropped) into 'bestWeights'
            for(int i = 0; i < n; ++i)
            {
               bestWeights[i].Assign(weights[i]);
            }
         }
         
         if(!progress(ep, epochs, mse, msev, msema, msevma))
         {
            PrintFormat("Interrupted by user at epoch %d", ep);
            break;
         }
         
         if(!MathIsValidNumber(mse))
         {
            PrintFormat("NaN at epoch %d", ep);
            break; // will return NaN as error indication
         }

         if(ep > p && candidate > stats.bestLoss * 10)
         {
            PrintFormat("Too big errors at epoch %d", ep);
            break;
         }

         if(msema > msemap)
         {
            if(++grow > p)
            {
               PrintFormat("Stop by growing error at epoch %d", ep);
               break;
            }
         }
         else
         {
            grow = 0;
         }
         
         if(msevmap != 0 && ep > p && msevma > msevmap + scale * (msemap - msema))
         {
            // skip first p epochs to accumulate values for smoothing
            PrintFormat("Stop by validation at %d, v: %f > %f, t: %f vs %f", ep, msevma, msevmap, msema, msemap);
            break;
         }
         
         msevmap = msevma;
         msemap = msema;
         
         if(mse <= accuracy)
         {
            PrintFormat("Done by accuracy limit %f at epoch %d", accuracy, ep);
            break;
         }
         
         if(dropOutRate > 0)
         {
            state.switchState(weights);
         }
         
         if(!backProp(target))
         {
            mse = NaN(); // error flag
            break;
         }
      }
      
      if(ep == epochs)
      {
         PrintFormat("Done by epoch limit %d with accuracy %f", ep, mse);
      }
      
      stats.trainingSet = (int)data.Rows();
      stats.validationSet = (int)validation.Rows();
      stats.epochsDone = ep;
      
      if(dropOutRate > 0) state.restoreState(weights);
      return mse;
   }
   
   double train(const matrix &data, const matrix &target,
      const int epochs = 1000, const double accuracy = 0.001,
      const ENUM_LOSS_FUNCTION lf = LOSS_MSE)
   {
      matrix dummy = {}, fake = {};
      return train(data, target, dummy, fake, epochs, accuracy, lf);
   }
   
   virtual bool progress(const int epoch, const int total,
      const double error, const double valid = DBL_MAX,
      const double ma = DBL_MAX, const double mav = DBL_MAX)
   {
      static uint trap;
      if(GetTickCount() > trap) // by default log every second
      {
         PrintFormat("Epoch %d of %d, loss %.5f%s%s%s", epoch, total, error,
            ma == DBL_MAX ? "" : StringFormat(" ma(%.5f)", ma),
            valid == DBL_MAX ? "" : StringFormat(", validation %.5f", valid),
            valid == DBL_MAX ? "" : StringFormat(" v.ma(%.5f)", mav));
         trap = GetTickCount() + 1000;
      }
      return !IsStopped(); // true keeps running, false will break the training loop
   }
   
   bool feedForward(const matrix &data)
   {
      if(!ready) return false;

      if(data.Cols() != weights[0].Rows() - 1)
      {
         PrintFormat("Column number in data %d <> Inputs layer size %d",
            data.Cols(), weights[0].Rows() - 1);
         return false;
      }
      
      outputs[0] = data;
      for(int i = 0; i < n; ++i)
      {
         // extend each layer with 1 neuron for bias (except for the last layer)
         if(!outputs[i].Resize(outputs[i].Rows(), weights[i].Rows()) ||
            !outputs[i].Col(vector::Ones(outputs[i].Rows()), weights[i].Rows() - 1))
            return false;
         // propagate signal from i-th layer to (i+1)-th layer
         matrix temp = outputs[i].MatMul(weights[i]);
         if(!temp.Activation(outputs[i + 1], i < n - 1 ? af : of))
            return false;
      }
      
      return true;
   }
   
   matrix getResults(const int layer = -1) const
   {
      static const matrix empty = {};
      if(!ready) return empty;
      
      if(layer == -1) return outputs[n];
      if(layer < -1 || layer > n) return empty;
      
      return outputs[layer];
   }
   
   /*
   
      LEGEND for error (loss) backpropagation
      
      last layer:
         loss = (y - t) * derivative(y)
      other layers:
         loss = loss[y[+1]] * w'[y[+1]] * derivative(y)
      update:
         weight += niu * loss * y[-1]
      
      where y is a neuron state in current layer, or
         a reference to connected neuron
         from previous layer y[-1] or next layer y[+1]
      
      NB: lines marked by //* comprise a bugfix released after the article:
      it turned out that the method Derivative() accepts input values of activation functions,
      not output values of activation functions as it was initially supposed
       
   */
   bool backProp(const matrix &target)
   {
      if(!ready) return false;
   
      if(target.Rows() != outputs[n].Rows() ||
         target.Cols() != outputs[n].Cols())
         return false;
      
      // output layer
      matrix temp;
      //*if(!outputs[n].Derivative(temp, of))
      //*  return false;
      if(!outputs[n - 1].MatMul(weights[n - 1]).Derivative(temp, of))
         return false;
      matrix loss = (outputs[n] - target) * temp; // data record per row
     
      for(int i = n - 1; i >= 0; --i) // for each layer except output
      {
         //*// remove unusable pseudo-errors for neurons, added as constant bias source
         //*// (in all layers except for the last (where it wasn't added))
         //*if(i < n - 1) loss.Resize(loss.Rows(), loss.Cols() - 1);
         #ifdef BATCH_PROP
         matrix delta = speed[i] * outputs[i].Transpose().MatMul(loss);
         adjustSpeed(speed[i], delta * deltas[i]);
         deltas[i] = delta;
         #else
         matrix delta = speed * outputs[i].Transpose().MatMul(loss);
         #endif
         
         // NB: i-th index in outputs[] corresponds to
         // the layer of neurons defined by (i-1)-th index in weights[],
         // because input layer (outputs[0]) does not have weights,
         // in other words, weights[0] produce outputs[1],
         // weights[1] produce outputs[2], etc.
         
         //*if(!outputs[i].Derivative(temp, af))
         //*   return false;
         //*loss = loss.MatMul(weights[i].Transpose()) * temp;
         if(i > 0) // backpropagate loss to previous layers
         {
            if(!outputs[i - 1].MatMul(weights[i - 1]).Derivative(temp, af))
               return false;
            matrix mul = loss.MatMul(weights[i].Transpose());
            // remove unusable pseudo-errors for neurons, added as constant bias source
            // (in all layers except for the last (where it wasn't added))
            mul.Resize(mul.Rows(), mul.Cols() - 1);
            loss = mul * temp;
         }
         
         weights[i] -= delta;
      }
      return true;
   }

   double test(const matrix &data, const matrix &target, const ENUM_LOSS_FUNCTION lf = LOSS_MSE)
   { 
      if(!ready || !feedForward(data)) return NaN();
      
      return outputs[n].Loss(target, lf);
   }
   
   static double NaN() // used to signal an error packed in double
   {
      return MathArcsin(2.0); // usefull to trace a problem via breakpoint
   }

   #ifdef BATCH_PROP

   void setupSpeedAdjustment(const double up, const double down,
      const double high, const double low)
   {
      plus = up;
      minus = down;
      max = high;
      min = low;
   }
   
protected:
   double plus;
   double minus;
   double max;
   double min;

   void adjustSpeed(matrix &subject, const matrix &product)
   {
      for(int i = 0; i < (int)product.Rows(); ++i)
      {
         for(int j = 0; j < (int)product.Cols(); ++j)
         {
            if(product[i][j] > 0)
            {
               subject[i][j] *= plus;
               if(subject[i][j] > max) subject[i][j] = max;
            }
            else if(product[i][j] < 0)
            {
               subject[i][j] *= minus;
               if(subject[i][j] < min) subject[i][j] = min;
            }
         }
      }
   }
   #endif
};

//+------------------------------------------------------------------+
//| Helper custom graphic with published work area                   |
//+------------------------------------------------------------------+
class CGraphicView: public CGraphic
{
public:
   int getRight() const
   {
      return m_right;
   }
   int getLeft() const
   {
      return m_left;
   }
   int getTop() const
   {
      return m_up;
   }
   int getBottom() const
   {
      return m_down;
   }
};

//+-------------------------------------------------------------------+
//| Backpropagation NN on matrices with visualization of MSE progress |
//+-------------------------------------------------------------------+
class MatrixNetVisual: public MatrixNet
{
   CGraphicView graphic;
   CCurve *c[5];
   double p[], x[], y[], z[], q[], b[];
   const string objname;
   const double nan;
   double amplitude;

   // prepare chart object for drawing
   void graph()
   {
      ulong width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      ulong height = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

      bool res = false;
      if(ObjectFind(0, objname) >= 0)
         res = graphic.Attach(0, objname);
      else
         res = graphic.Create(0, objname, 0, 0, 0, (int)(width - 0), (int)(height - 0));
      if(!res)
         return;

      c[0] = graphic.CurveAdd(p, x, CURVE_LINES, "Training");
      c[1] = graphic.CurveAdd(p, y, CURVE_LINES, "Validation");
      c[2] = graphic.CurveAdd(p, z, CURVE_LINES, "Val.EMA");
      c[3] = graphic.CurveAdd(p, q, CURVE_LINES, "Train.EMA");
      c[4] = graphic.CurveAdd(p, b, CURVE_POINTS, "Best/Minimum");
      ArrayResize(b, 1);
      amplitude = 0;
      graphic.XAxis().AutoScale(false);
      graphic.YAxis().AutoScale(false);
   }
   
   void plot()
   {
      c[0].Update(p, x);
      c[1].Update(p, y);
      c[2].Update(p, z);
      c[3].Update(p, q);
      double point[1] = {stats.bestEpoch};
      b[0] = stats.bestLoss;
      c[4].Update(point, b);

      const int size = ArraySize(p) - 1;
      graphic.CalculateMaxMinValues();
      graphic.XAxis().Min(0);
      graphic.YAxis().Min(0);
      // find max values on the fly at every last added point
      const double range = y[size] != DBL_MAX ? MathMax(y[size], x[size]) : x[size];
      if(range > amplitude)
      {
         amplitude = range;
      
         double ystep = MathPow(10, MathCeil(MathLog10(amplitude))) / 20;
         if(ystep != 0 && amplitude / ystep < 5) ystep /= 2;
         graphic.YAxis().Max(ystep != 0 ? ystep * (MathCeil(amplitude / ystep)) : 1);
         graphic.YAxis().DefaultStep(ystep);
      }
      
      double xstep = MathPow(10, MathCeil(MathLog10(p[size]))) / 20;
      if(xstep != 0 && p[size] / xstep < 5) xstep /= 2;
      graphic.XAxis().Max(xstep != 0 ? xstep * (MathCeil(p[size] / xstep)) : 1);
      graphic.XAxis().DefaultStep(xstep);

      graphic.CurvePlotAll();
      graphic.TextAdd(graphic.Width() - graphic.getRight() - 5, graphic.getTop() + 5,
         "MSE error (Loss) by Epoch (Cycle)", clrBlack, TA_RIGHT | TA_TOP);
      graphic.Update();
   }

public:
   MatrixNetVisual(const int &layers[], const ENUM_ACTIVATION_FUNCTION f1 = AF_TANH,
      const ENUM_ACTIVATION_FUNCTION f2 = AF_NONE): MatrixNet(layers, f1, f2), objname("BPNNERROR"), nan(NaN())
   {
      graph();
   }

   MatrixNetVisual(const matrix &w[], const ENUM_ACTIVATION_FUNCTION f1 = AF_TANH,
      const ENUM_ACTIVATION_FUNCTION f2 = AF_NONE): MatrixNet(w, f1, f2), objname("BPNNERROR"), nan(NaN())
   {
      graph();
   }
   
   ~MatrixNetVisual()
   {
      if(!MQLInfoInteger(MQL_TESTER))
      {
         graphic.Destroy();
      }
   }
   
   CGraphicView *view() const
   {
      return (CGraphicView *)&graphic;
   }

   virtual bool progress(const int epoch, const int total,
      const double error, const double valid = DBL_MAX,
      const double ma = DBL_MAX, const double mav = DBL_MAX) override
   {
      // accumulate and draw graph of error, valid, ma values
      PUSH(p, epoch);
      PUSH(x, error);
      if(valid != DBL_MAX) PUSH(y, valid); else PUSH(y, nan);
      if(ma != DBL_MAX) PUSH(q, ma); else PUSH(q, nan);
      if(mav != DBL_MAX) PUSH(z, mav); else PUSH(z, nan);
      plot();
      
      return MatrixNet::progress(epoch, total, error, valid, ma, mav);
   }
};

/* EXAMPLE:

bool CreateData(matrix &data, matrix &target, const int count) 
{ 
   if(!data.Init(count, 3) || !target.Init(count, 1)) return false; 
   data.Random(-10, 10);                      
   vector X1 = MathPow(data.Col(0) + data.Col(1) + data.Col(2), 2); 
   vector X2 = MathPow(data.Col(0), 2) + MathPow(data.Col(1), 2) + MathPow(data.Col(2), 2); 
   if(!target.Col(X1 / X2 / 3, 0)) return false;
   return true; 
} 

void OnStart()
{
   const int layers[] = {3, 21, 15, 1};
   MatrixNetVisual net(layers);
   matrix data, target;
   CreateData(data, target, 100);
   matrix valid, test;
   CreateData(valid, test, 25);
   
   // NB: in practice you should normalize and clean up data from outliers
   // before training (here we generate artificially ideal data)
   
   Print(net.train(data, target, valid, test, 1000, 0.0001));
   //Print(net.train(data, target, 1000, 0.00001));
   matrix w[];
   if(net.getBestWeights(w))
   {
      // for(int i = 0; i < ArraySize(w); ++i) Print(w[i]); // debug
      MatrixNet net2(w);
      if(net2.isReady())
      {
         Print("Copy: ", net2.test(data, target));
      }
   }
}
*/
//+-------------------------------------------------------------------+
