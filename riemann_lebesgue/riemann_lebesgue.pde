// ═══════════════════════════════════════════════════════════════════
//  INTEGRAL DE RIEMANN  vs  INTEGRAL DE LEBESGUE
//  Explorador Interactivo — f : [0,1] → ℝ
//  Processing (Java) · UABCS
// ═══════════════════════════════════════════════════════════════════

// ── LIENZO ───────────────────────────────────────────────────────
final int CW = 1200, CH = 800;

// ── GEOMETRÍA DE PANELES ─────────────────────────────────────────
final int PW = 520, PH = 400;
final int P1X = 20,  P2X = 660;
final int PY  = 185;
final int PL = 44, PR = 14, PT = 26, PB = 42;

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
int     fi         = 0;
int     sN         = 8;
int     sM         = 4;
float   animSpeed  = 1.0;
boolean showBounds = false;
String  dragMode   = null;    // "N", "M", o null

// ── HOVER CROSS-HIGHLIGHT ──────────────────────────────
int     hoverPanel = 0;       // 0=ninguno, 1=Riemann, 2=Lebesgue
int     hoverBand  = -1;      // índice de banda k
float   hoverX     = -1;      // x ∈ [0,1] (solo panel Riemann)
float   hoverY     = -1;      // f(x) o y del mouse

// ── OBJETOS ──────────────────────────────────────────────────────
FuncDef[]     funciones;
Integrador    ig;
PanelRiemann  panelR;
PanelLebesgue panelL;

// Cache de posiciones de botones (para detección de clics)
int[][] btnFuncPos;           // [i][4] = {bx, by, bw, bh}
int[] btnBoundsPos;           // {bx, by, bw, bh}

// ═══════════════════════════════════════════════════════════════════
//  SETUP / DRAW
// ═══════════════════════════════════════════════════════════════════
void setup() {
  size(1200, 800);
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

  btnFuncPos  = new int[funciones.length][4];
  btnBoundsPos = new int[4];
}

void draw() {
  background(7, 7, 15);

  drawHeader();
  drawFuncButtons();
  drawBoundsButton();
  drawSliderN();

  ig.rebuild(fi, sN, sM, funciones[fi]);
  panelR.draw(P1X, PY, PW, PH, ig, showBounds, sN, sM, fi, hoverPanel, hoverBand);
  panelL.draw(P2X, PY, PW, PH, ig, sN, fi, hoverPanel, hoverBand);

  drawTooltip();
  drawSliderM();
  drawResults();
  drawLegend();
}

// ═══════════════════════════════════════════════════════════════════
//  UI — ENCABEZADO
// ═══════════════════════════════════════════════════════════════════
void drawHeader() {
  noStroke();
  fill(210);
  textSize(16);
  textAlign(CENTER, TOP);
  text("INTEGRAL DE RIEMANN   vs   INTEGRAL DE LEBESGUE", CW / 2, 12);
  fill(100);
  textSize(14);
  text("f : [0,1] \u2192 \u211D   |   Explorador Interactivo", CW / 2, 32);
}

// ═══════════════════════════════════════════════════════════════════
//  UI — BOTONES DE FUNCIÓN
// ═══════════════════════════════════════════════════════════════════
void drawFuncButtons() {
  int bw = 118, bh = 25, gap = 10;
  int tw = funciones.length * bw + (funciones.length - 1) * gap;
  int sx = CW / 2 - tw / 2;
  int sy = 50;

  for (int i = 0; i < funciones.length; i++) {
    int bx = sx + i * (bw + gap);
    btnFuncPos[i] = new int[] { bx, sy, bw, bh };

    boolean active = (i == fi);
    color c = stripColor(i * 3, 12, 255);

    if (active) {
      fill(red(c), green(c), blue(c), 210);
      stroke(red(c), green(c), blue(c));
      strokeWeight(1.5);
    } else {
      fill(18, 18, 32);
      stroke(50, 50, 75);
      strokeWeight(1);
    }
    rect(bx, sy, bw, bh, 5);

    noStroke();
    fill(active ? 10 : 140);
    textSize(12);
    textAlign(CENTER, CENTER);
    text(funciones[i].nombre, bx + bw / 2, sy + bh / 2);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  UI — BOTÓN SUP/INF
// ═══════════════════════════════════════════════════════════════════
void drawBoundsButton() {
  int bw = 128, bh = 20;
  int bx = CW / 2 - bw / 2;
  int by = 82;
  btnBoundsPos = new int[] { bx, by, bw, bh };

  if (showBounds) {
    fill(180, 90, 30, 180);
    stroke(255, 140, 50);
  } else {
    fill(20, 20, 35);
    stroke(55, 55, 80);
  }
  strokeWeight(1);
  rect(bx, by, bw, bh, 4);

  noStroke();
  fill(showBounds ? 255 : 120);
  textSize(11);
  textAlign(CENTER, CENTER);
  text("[ mostrar sup / inf ]", bx + bw / 2, by + bh / 2);
}

// ═══════════════════════════════════════════════════════════════════
//  UI — SLIDERS
// ═══════════════════════════════════════════════════════════════════
void drawSliderN() {
  float pos = map(sN, 2, 40, SLX, SLX + SLW);

  noStroke();
  fill(120);
  textSize(13);
  textAlign(LEFT, CENTER);
  text("n = particiones  [ eje X \u2192 Riemann  |  eje Y \u2192 Lebesgue ]", SLX, SL_N_Y - 14);

  // Riel
  fill(38, 38, 68);
  rect(SLX, SL_N_Y - 3, SLW, 5, 3);
  fill(60, 120, 255);
  rect(SLX, SL_N_Y - 3, pos - SLX, 5, 3);

  // Knob
  fill(160, 200, 255);
  noStroke();
  ellipse(pos, SL_N_Y, 15, 15);

  // Valor
  fill(90, 155, 255);
  textSize(12);
  textAlign(RIGHT, CENTER);
  text("n = " + sN, SLX + SLW, SL_N_Y - 14);
}

void drawSliderM() {
  float pos = map(sM, 1, 20, SLX, SLX + SLW);

  noStroke();
  fill(120);
  textSize(13);
  textAlign(LEFT, CENTER);
  text("m = sub-divisiones por partici\u00F3n  [ n\u00D7m rect\u00E1ngulos en Riemann / mayor precisi\u00F3n en Lebesgue ]", SLX, SL_M_Y - 14);

  // Riel
  fill(38, 58, 38);
  rect(SLX, SL_M_Y - 3, SLW, 5, 3);
  fill(40, 180, 90);
  rect(SLX, SL_M_Y - 3, pos - SLX, 5, 3);

  // Knob
  fill(150, 235, 180);
  noStroke();
  ellipse(pos, SL_M_Y, 15, 15);

  // Valor
  fill(90, 220, 140);
  textSize(12);
  textAlign(RIGHT, CENTER);
  text("m = " + sM, SLX + SLW, SL_M_Y - 14);
}

// ═══════════════════════════════════════════════════════════════════
//  RESULTADOS NUMÉRICOS
// ═══════════════════════════════════════════════════════════════════
void drawResults() {
  int y = SL_M_Y + 36;

  // Sumas
  noStroke();
  fill(190);
  textSize(13);
  textAlign(CENTER, TOP);

  String rLabel;
  if (showBounds) {
    rLabel = "[" + nf(ig.rSumInf, 1, 5) + ",  " + nf(ig.rSumSup, 1, 5) + "]";
  } else {
    rLabel = nf(ig.rSumMid, 1, 6);
  }
  text("\u03A3 Riemann \u2248  " + rLabel, P1X + PW / 2, y-5);
  text("\u03A3 Lebesgue \u2248  " + nf(ig.lSum, 1, 6), P2X + PW / 2, y-5);

  // Error respecto al valor exacto
  FuncDef f = funciones[fi];
  if (f.riemannOK) {
    float exact = f.exacta;
    float errR = abs(ig.rSumMid - exact);
    float errL = abs(ig.lSum - exact);
    fill(150);
    textSize(13);
    text("error: " + nf(errR, 1, 6), P1X + PW / 2, y + 15);
    text("error: " + nf(errL, 1, 6), P2X + PW / 2, y + 15);
    fill(170);
    textSize(14);
    text("Valor exacto: " + nf(exact, 1, 8), CW / 2, y + 8);
  } else {
    // Dirichlet: no Riemann-integrable
    fill(200, 80, 50);
    textSize(13);
    text("\u2211_sup = " + nf(ig.rSumSup, 1, 4) + "   \u2211_inf = " + nf(ig.rSumInf, 1, 4)
         + "   gap = " + nf(ig.rSumSup - ig.rSumInf, 1, 4),
         P1X + PW / 2, y + 18);
    fill(50, 180, 100);
    text("LI = 0  (\u03BC(\u211A) = 0)", P2X + PW / 2, y + 18);
  }

  // Info de la función
  fill(140);
  textSize(13);
  textAlign(CENTER, TOP);
  text(f.info, CW / 2, y + 56);
}

// ═══════════════════════════════════════════════════════════════════
//  LEYENDA CONCEPTUAL
// ═══════════════════════════════════════════════════════════════════
void drawLegend() {
  int ly = SL_M_Y + 76;
  noStroke();
  fill(120);
  textSize(13);
  textAlign(CENTER, TOP);
  text("Riemann: particiona el DOMINIO (eje X) \u2014 rect\u00E1ngulos verticales   |   "
     + "Lebesgue: particiona el CODOMINIO (eje Y) \u2014 f medida por longitud de preim\u00E1genes (\u03BC)",
       CW / 2, ly);
}

// ═══════════════════════════════════════════════════════════════════
//  TOOLTIP (hover cross-highlight)
// ═══════════════════════════════════════════════════════════════════
void drawTooltip() {
  if (hoverPanel == 0 || hoverBand < 0) return;

  float dy = 1.0 / sN;
  String line1, line2;

  if (hoverPanel == 1) {
    line1 = "x=" + nf(hoverX, 1, 3) + "  f(x)=" + nf(hoverY, 1, 3);
    line2 = "banda k=" + hoverBand + "  [" +
            nf(hoverBand * dy, 1, 3) + ", " +
            nf((hoverBand + 1) * dy, 1, 3) + "]";
  } else {
    float mu = ig.measures[hoverBand];
    line1 = "banda k=" + hoverBand + "  [" +
            nf(hoverBand * dy, 1, 3) + ", " +
            nf((hoverBand + 1) * dy, 1, 3) + "]";
    line2 = "\u03BC \u2248 " + nf(mu, 1, 4);
  }

  textSize(11);
  float tw = max(textWidth(line1), textWidth(line2));
  float th = 30;

  float tx = mouseX + 15;
  float ty = mouseY - 38;
  if (tx + tw + 12 > width) tx = mouseX - tw - 20;
  if (ty < 5) ty = mouseY + 15;

  fill(10, 10, 20, 230);
  stroke(255, 255, 100, 200);
  strokeWeight(1);
  rect(tx, ty, tw + 10, th, 4);

  noStroke();
  fill(255, 255, 150);
  textAlign(LEFT, TOP);
  text(line1, tx + 5, ty + 3);
  text(line2, tx + 5, ty + 16);
}

// ═══════════════════════════════════════════════════════════════════
//  INPUT
// ═══════════════════════════════════════════════════════════════════
void mousePressed() {
  // Botones de función
  for (int i = 0; i < btnFuncPos.length; i++) {
    int bx = btnFuncPos[i][0], by = btnFuncPos[i][1];
    int bw = btnFuncPos[i][2], bh = btnFuncPos[i][3];
    if (mouseX > bx && mouseX < bx + bw && mouseY > by && mouseY < by + bh) {
      fi = i;
      ig.cacheKey = "";  // forzar rebuild
    }
  }

  // Botón sup/inf
  int bx = btnBoundsPos[0], by = btnBoundsPos[1];
  int bw = btnBoundsPos[2], bh = btnBoundsPos[3];
  if (mouseX > bx && mouseX < bx + bw && mouseY > by && mouseY < by + bh) {
    showBounds = !showBounds;
  }

  // Sliders
  if (abs(mouseY - SL_N_Y) < 14 && mouseX >= SLX && mouseX <= SLX + SLW) dragMode = "N";
  if (abs(mouseY - SL_M_Y) < 14 && mouseX >= SLX && mouseX <= SLX + SLW) dragMode = "M";
}

void mouseDragged() {
  float cx = constrain(mouseX, SLX, SLX + SLW);
  if ("N".equals(dragMode)) {
    sN = round(map(cx, SLX, SLX + SLW, 2, 40));
    ig.cacheKey = "";
  }
  if ("M".equals(dragMode)) {
    sM = round(map(cx, SLX, SLX + SLW, 1, 20));
    ig.cacheKey = "";
  }
}

void mouseReleased() {
  dragMode = null;
}

void keyPressed() {
  if (keyCode == LEFT)  { sN = max(2, sN - 1);  ig.cacheKey = ""; }
  if (keyCode == RIGHT) { sN = min(40, sN + 1); ig.cacheKey = ""; }
  if (keyCode == DOWN)  { sM = max(1, sM - 1);  ig.cacheKey = ""; }
  if (keyCode == UP)    { sM = min(20, sM + 1); ig.cacheKey = ""; }
}

void mouseMoved() {
  hoverPanel = 0;
  hoverBand  = -1;
  hoverX     = -1;
  hoverY     = -1;

  // Área de plotting (idéntica en ambos paneles)
  float axX0 = PL;            // offset dentro del panel
  float axX1 = PW - PR;
  float axY0 = PH - PB;       // y=0 (abajo)
  float axY1 = PT;            // y=1.05 (arriba)

  // ── Panel Riemann ──────────────────────────────────
  if (mouseX >= P1X + axX0 && mouseX <= P1X + axX1 &&
      mouseY >= PY  + axY1 && mouseY <= PY  + axY0) {
    hoverPanel = 1;
    hoverX = constrain(map(mouseX, P1X + axX0, P1X + axX1, 0, 1), 0, 1);
    hoverY = constrain(funciones[fi].eval(hoverX), 0, 1.0 - 1e-6);
    float dy = 1.0 / sN;
    hoverBand = constrain((int)(hoverY / dy), 0, sN - 1);
    return;
  }

  // ── Panel Lebesgue ─────────────────────────────────
  if (mouseX >= P2X + axX0 && mouseX <= P2X + axX1 &&
      mouseY >= PY  + axY1 && mouseY <= PY  + axY0) {
    hoverPanel = 2;
    hoverY = constrain(map(mouseY, PY + axY0, PY + axY1, 0, 1.05), 0, 1.05);
    float dy = 1.0 / sN;
    hoverBand = constrain((int)(hoverY / dy), 0, sN - 1);
    return;
  }
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
