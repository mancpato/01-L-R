class FuncDef {
  int id;
  String nombre;
  String info;
  float exacta;       // -1 si no existe integral de Riemann
  boolean riemannOK;

  FuncDef(int id, String nombre, String info, float exacta, boolean riemannOK) {
    this.id = id;
    this.nombre = nombre;
    this.info = info;
    this.exacta = exacta;
    this.riemannOK = riemannOK;
  }

  float eval(float x) {
    switch (id) {
      case 0:  return x * x;
      case 1:  return sqrt(x);
      case 2:  return thomae(x);
      case 3:  return dirichletN(x, sN);  // sN global — spec: slider n controla D_n
      default: return 0;
    }
  }

  // ── MCD ──────────────────────────────────────────
  int gcd(int a, int b) {
    a = abs(a);
    b = abs(b);
    while (b != 0) { int t = b; b = a % b; a = t; }
    return (a == 0) ? 1 : a;
  }

  // ── Thomae: f(p/q reducida) = 1/q, f(irracional) = 0 ──
  // Tolerancia ajustada para float32 (Processing usa float, no double)
  float thomae(float x) {
    if (x <= 0 || x >= 1) return 0;
    for (int q = 1; q <= 300; q++) {
      int p = round(x * q);
      if (p <= 0 || p >= q) continue;
      float diff = abs(x - (float) p / q);
      // Ventana estrecha: solo matchea si x es "exactamente" p/q en float32
      if (diff < 1e-6) {
        int g = gcd(p, q);
        int qRed = q / g;  // denominador reducido
        return 1.0 / qRed;
      }
    }
    return 0;
  }

  // ── Dirichlet D_n: picos en p/q con q ≤ n ──────
  float dirichletN(float x, int n) {
    float c = 1.0;
    for (int q = 1; q <= n; q++) {
      int p = round(x * q);
      if (p <= 0 || p >= q) continue;
      float dist = abs(x - (float) p / q);
      if (dist < c / (n * q * q)) return 1.0;
    }
    return 0.0;
  }
}
