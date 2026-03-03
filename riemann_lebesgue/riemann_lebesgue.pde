// ═══════════════════════════════════════════════════════════════════
//  INTEGRAL DE RIEMANN  vs  INTEGRAL DE LEBESGUE
//  Explorador Interactivo — f : [0,1] → ℝ
//  Processing (Java) · UABCS
// ═══════════════════════════════════════════════════════════════════

// ── LIENZO ───────────────────────────────────────────────────────
final int CW = 1100, CH = 720;

// ── GEOMETRÍA DE PANELES ─────────────────────────────────────────
final int PW = 470, PH = 365;
final int P1X = 15,  P2X = 615;
final int PY  = 178;
final int PL = 44, PR = 14, PT = 26, PB = 34;

// ── SLIDERS ──────────────────────────────────────────────────────
final int SLX = 48;
final int SLW = CW - 96;
final int SL_N_Y = 138;
final int SL_M_Y = PY + PH + 58;

// ── MUESTREO ─────────────────────────────────────────────────────
final int N_CURVE  = 3000;
final int N_PREIMG = 4000;

// ═══════════════════════════════════════════════════════════════════
//  ESTADO GLOBAL
// ═══════════════════════════════════════════════════════════════════
int     fi         = 1;
int     sN         = 8;
int     sM         = 4;
float   animSpeed  = 1.0;
boolean showBounds = false;

// ── OBJETOS ──────────────────────────────────────────────────────
FuncDef[]     funciones;
Integrador    ig;
PanelRiemann  panelR;
PanelLebesgue panelL;

// ═══════════════════════════════════════════════════════════════════
//  SETUP / DRAW
// ═══════════════════════════════════════════════════════════════════
void setup() {
  size(1100, 720);
  frameRate(60);
  textFont(createFont("Courier New", 12));

  funciones = new FuncDef[] {
    new FuncDef(0, "x\u00B2",      "Suave. RI = LI = 1/3.",   1.0/3, true),
    new FuncDef(1, "\u221Ax",      "Suave. RI = LI = 2/3.",   2.0/3, true),
    new FuncDef(2, "Thomae",       "f(p/q)=1/q, f(irrac.)=0", 0,     true),
    new FuncDef(3, "Dirichlet",    "f(Q)=1, f(R\\Q)=0",       -1,    false)
  };

  ig     = new Integrador();
  panelR = new PanelRiemann();
  panelL = new PanelLebesgue();
}

void draw() {
  background(7, 7, 15);

  ig.rebuild(fi, sN, sM, funciones[fi]);
  panelR.draw(P1X, PY, PW, PH, ig, showBounds, sN, sM);
  panelL.draw(P2X, PY, PW, PH, ig, sN);
}

// ═══════════════════════════════════════════════════════════════════
//  PALETA DE COLORES (compartida por ambos paneles)
// ═══════════════════════════════════════════════════════════════════
// Gradiente azul(220°) → rojo(0°) via cian, verde, amarillo
color stripColor(int k, int n, int alpha) {
  float t = (n > 1) ? (float) k / (n - 1) : 0;
  float h = 220 * (1 - t);          // grados HLS
  float hr = h / 60.0;
  float s = 0.80, l = 0.55;

  float c1 = (1 - abs(2 * l - 1)) * s;
  float x1 = c1 * (1 - abs(hr % 2 - 1));
  float r, g, b;

  if      (hr < 1) { r = c1; g = x1; b = 0;  }
  else if (hr < 2) { r = x1; g = c1; b = 0;  }
  else if (hr < 3) { r = 0;  g = c1; b = x1; }
  else if (hr < 4) { r = 0;  g = x1; b = c1; }
  else if (hr < 5) { r = x1; g = 0;  b = c1; }
  else             { r = c1; g = 0;  b = x1; }

  float m1 = l - c1 / 2;
  int ri = round((r + m1) * 255);
  int gi = round((g + m1) * 255);
  int bi = round((b + m1) * 255);

  return color(ri, gi, bi, alpha);
}
