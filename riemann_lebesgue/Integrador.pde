/**
 * Este módulo aproxima la integral de una función f(x) en [0,1] usando:
 * - Riemann: con altura en el punto medio, 
              supremo o ínfimo de cada subintervalo.
 * - Lebesgue: clasificando puntos por su valor f(x) y sumando 
               medidas (frecuencias) de cada banda.
 * La función f(x) se define en FuncDef.pde
*
* Tal vez debieran ser dos integradores separados, pero como comparten f(x) y
* ya está precalculada, así es más fácil.
*/ 

class Integrador {
  String cacheKey = "";
  float rSumMid, rSumSup, rSumInf;
  float lSum;
  float muNivel1;

  // Rectángulos Riemann: cada fila = {x0, x1, fMid, fSup, fInf, strip}
  float[][] rects;
  int totalRects;

  // Curva f(x) precalculada
  float[] curveX, curveY;

  // Lebesgue
  int numBands;
  float[] measures;
  float[] classifyX;
  int[] classifyK;

  void rebuild(int fi, int n, int m, FuncDef f) 
  {
    String key = fi + "-" + n + "-" + m;
    if (key.equals(cacheKey)) 
      return;
    cacheKey = key;

    curveX = new float[N_CURVE + 1];
    curveY = new float[N_CURVE + 1];
    for (int i = 0; i <= N_CURVE; i++) {
      float x = (float) i / N_CURVE;
      curveX[i] = x;
      curveY[i] = constrain(f.eval(x), 0, 1.05);
    }

    // Riemann
    totalRects = n * m;
    rects = new float[totalRects][6];
    rSumMid = 0;
    rSumSup = 0;
    rSumInf = 0;

    for (int i = 0; i < totalRects; i++) {
      float x0   = (float) i / totalRects;
      float x1   = x0 + 1.0 / totalRects;
      float xMid = (x0 + x1) / 2.0;
      float fMid = constrain(f.eval(xMid), 0, 1.05);
      float[] si  = supInfOn(x0, x1, f);
      float fSup = si[0];
      float fInf = si[1];
      int strip  = i / m;

      rects[i][0] = x0;
      rects[i][1] = x1;
      rects[i][2] = fMid;
      rects[i][3] = fSup;
      rects[i][4] = fInf;
      rects[i][5] = strip;

      rSumMid += fMid / totalRects;
      rSumSup += fSup / totalRects;
      rSumInf += fInf / totalRects;
    }

    // Lebesgue
    numBands = n;
    float dy = 1.0 / n;
    int ns = max(N_PREIMG * m, n * 50);

    measures = new float[n];
    classifyX = new float[ns + 1];
    classifyK = new int[ns + 1];

    for (int j = 0; j <= ns; j++) {
      float x = (float) j / ns;
      float fv = constrain(f.eval(x), 0, 1.0 - 1e-6);
      int k = constrain((int)(fv / dy), 0, n - 1);
      measures[k]++;
      classifyX[j] = x;
      classifyK[j] = k;
    }
    for (int k = 0; k < n; k++) 
      measures[k] /= (ns + 1);

    lSum = 0;
    for (int k = 0; k < n; k++) 
      lSum += (k * dy) * measures[k];
    muNivel1 = measures[n - 1];
  }

  // Supremo e ínfimo numérico en [a,b] con 60 muestras
  float[] supInfOn(float a, float b, FuncDef f) 
  {
    float sup = -1e30, inf = 1e30;
    int samples = 60;
    for (int k = 0; k <= samples; k++) {
      float x = a + (b - a) * k / samples;
      float v = constrain(f.eval(x), 0, 1.05);
      if (v > sup) 
        sup = v;
      if (v < inf) 
        inf = v;
    }
    // Para Dirichlet: siempre hay racionales e irracionales en cada intervalo
    if (f.id == 3) { 
      sup = 1; 
      inf = 0; 
    }
    return new float[] { sup, inf };
  }
}
