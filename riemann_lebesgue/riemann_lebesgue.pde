/*** riemann_lebesgue.pde
*
*  INTEGRAL DE RIEMANN  vs  INTEGRAL DE LEBESGUE
*  Explorador Interactivo — f : [0,1] → ℝ
*  Processing (Java) · UABCS
*
* @author: Miguel Angel Norzagaray Cosío
* @date: marzo de 2026
*
* Descripción:
* Este sketch permite comparar la integral de Riemann y 
* la integral de Lebesgue para algunas funciones. Ambas usan la misma función 
* de integración (mismo integrador), pero muestran visualmente cómo 
* se construyen las sumas de cada una.
*
* Todas las funciones están acotadas al intervalo [0,1]. 
* Las funciones incluidas son:
*  - f(x) = x²
*  - f(x) = √x
*  - f(x) = Thomae (f(p/q)=1/q, f(irrac.)=0)
*  - f(x) = Dirichlet (f(Q)=1, f(ℝ\Q)=0) 
*
* El usuario puede ajustar el número de particiones (n) y 
* sub-divisiones (m) para mejorar la precisión.
*
* Debiera usar 🎉 cuando una aproximación esté bien y un símbolo como
* ⚠️ cuando no lo esté (por ejemplo, la suma de Riemann para Dirichlet no
* converge a nada, pero la de Lebesgue sí converge a 0). Sin embargo, 
* Processing no tiene soporte nativo para emojis, y usar imágenes sería un
* poco complicado, así que por ahora solo muestro los números y dejo que el
* usuario saque sus propias conclusiones. Quizás en una futura versión se me
* ocurrar alguna forma de agregar esos símbolos de manera visual.
*/ 

// Ventana
// Me gusta la idea de una ventana que cambie de tamaño, pero la vida es 
// demasiado corta.
final int CW = 1200, CH = 800;

// Nunca he sido partidario de los números mágicos, pero debo reconocer que 
// en Processing a veces es más práctico usar coordenadas fijas para 
// muchas cosas, en vez de complicarse la vida con cálculos relativos.

// Paneles
final int PW = 520, PH = 400; // ancho y alto de cada panel
final int P1X = 20,  P2X = 660;
final int PY  = 185;
final int PL = 44, PR = 14, PT = 26, PB = 42;

// Deslizadores (para m y n)
final int SLX = 48;
final int SLW = CW - 96;
final int SL_N_Y = 138;
final int SL_M_Y = PY + PH + 58;

// Son más puntos de muestreo para que la curva de f se vea suave, 
// y en realidad no afectan los cálculos de las integrales.
// Si fuera la misma cantidad que los pixeles reales el aliasing haría 
// que funciones como Thomae o Dirichlet se vean como 0.
final int N_CURVE  = 3000; // puntos para dibujar la curva de f
final int N_PREIMG = 4000; // puntos para muestrear preimágenes (Lebesgue)

//  ESTADO GLOBAL
int     fi         = 0; // Función seleccionada
int     sN         = 8; // número de particiones (n)
int     sM         = 4; // número de sub-divisiones por partición (m)
float   animSpeed  = 1.0; // Idea a futuro
boolean showBounds = false; // mostrar SumInf y SumSup de Riemann
String  dragMode   = null;    // "N", "M", o null

// Resaltado al pasar el mouse (hover), 
// Estos son los valores iniciales, se actualizan en mouseMoved()
int     hoverPanel = 0;       // 0=ninguno, 1=Riemann, 2=Lebesgue
int     hoverBand  = -1;      // índice de banda k
float   hoverX     = -1;      // x ∈ [0,1] (solo panel Riemann)
float   hoverY     = -1;      // f(x) o y del mouse

// Los objetos principales
FuncDef[]     funciones;
Integrador    ig; // Calcula sumas de Riemann y Lebesgue, con caching
// El caching es importante porque el cálculo de la integral de Lebesgue
// es costoso, y no queremos recalcularlo cada vez que se dibuja el panel, 
// sino solo cuando cambian los parámetros relevantes (fi, sN, sM).
PanelRiemann  panelR;
PanelLebesgue panelL;
// Es desafortunado que Riemann y Lebesgue coincidan en la misma letra con
// Right y Left, pero bueno, así es la vida. Podría haber usado otras letras,
// pero R y L son tan intuitivas para cada panel que no pude resistirme.

// Cache de posiciones de botones (para detección de clics)
int[][] btnFuncPos;  // [i][4] = {bx, by, bw, bh}
int[] btnBoundsPos;  // {bx, by, bw, bh}

void setup() 
{
  size(1200, 800);
  frameRate(60);  // No me crean y pongan 30 si quieren, pero con 60 se ve 
                  // más fluida la interacción al mover los sliders.
  textFont(createFont("Courier New", 12));

  funciones = new FuncDef[] {
    new FuncDef(0, "x\u00B2",              "Suave. RI = LI = 1/3.",              1.0/3,  true),
    new FuncDef(1, "sqrt(x)",             "Suave. RI = LI = 2/3.",              2.0/3,  true),
    new FuncDef(2, "Thomae",               "f(p/q)=1/q, f(irrac.)=0",            0,      true),
    new FuncDef(3, "Dirichlet",            "f(Q)=1, f(R\\Q)=0",                 -1,      false),
    new FuncDef(4, "sin\u00B2(4pi*x)",     "4 periodos. RI = LI = 1/2. Pto. medio es exacto por simetria.", 0.5, true),
    new FuncDef(5, "|xsin(pi/x)|",        "Oscila en 0. RI = LI ~ 0.28114",    0.2932, true)
  };

  ig     = new Integrador();
  panelR = new PanelRiemann();
  panelL = new PanelLebesgue();

  btnFuncPos  = new int[funciones.length][4];
  btnBoundsPos = new int[4];
}

void draw() 
{
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

void drawHeader() 
{
  noStroke();
  fill(210);
  textSize(16);
  textAlign(CENTER, TOP);
  text("INTEGRAL DE RIEMANN   vs   INTEGRAL DE LEBESGUE", CW / 2, 12);
  fill(140);
  textSize(14);
  text("f : [0,1] -> R   |   Explorador Interactivo", CW / 2, 32);
}

void drawFuncButtons() 
{
  int bw = 105, bh = 25, gap = 8;
  int tw = funciones.length * bw + (funciones.length - 1) * gap;
  int sx = CW / 2 - tw / 2;
  int sy = 50;

  for (int i = 0; i < funciones.length; i++) {
    int bx = sx + i * (bw + gap);
    btnFuncPos[i] = new int[] { bx, sy, bw, bh };

    boolean active = (i == fi);
    color c = stripColor(i * 2, 12, 255);

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

void drawBoundsButton() 
{
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

//  UI — SLIDERS
void drawSliderN() 
{
  float pos = map(sN, 2, 40, SLX, SLX + SLW);

  noStroke();
  fill(150);
  textSize(13);
  textAlign(LEFT, CENTER);
  text("n = particiones  [ eje X -> Riemann  |  eje Y -> Lebesgue ]",
              SLX, SL_N_Y - 14);

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

void drawSliderM() 
{
  float pos = map(sM, 1, 20, SLX, SLX + SLW);

  noStroke();
  fill(150);
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

//  RESULTADOS NUMÉRICOS
void drawResults() 
{
  int y = SL_M_Y + 36;

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
  text("Sum Riemann ~  " + rLabel, P1X + PW / 2, y-5);
  text("Sum Lebesgue ~  " + nf(ig.lSum, 1, 6), P2X + PW / 2, y-5);

  // Error con respecto al valor exacto
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
    // Dirichlet: no Riemann-integrable, pero Lebesgue SÍ → 0
    fill(200, 80, 50);
    textSize(13);
    text("Sum_sup = " + nf(ig.rSumSup, 1, 4) + "   Sum_inf = " + nf(ig.rSumInf, 1, 4)
         + "   gap = " + nf(ig.rSumSup - ig.rSumInf, 1, 4),
         P1X + PW / 2, y + 18);
    fill(50, 180, 100);
    text("LI = 0  (mu(Q) = 0)", P2X + PW / 2, y + 18);
    fill(170);
    textSize(14);
    text("Valor exacto (Lebesgue): 0", CW / 2, y + 8);
  }

  // Info de la función
  fill(160);
  textSize(13);
  textAlign(CENTER, TOP);
  text(f.info, CW / 2, y + 56);
}

//  LEYENDA CONCEPTUAL
void drawLegend() 
{
  int ly = SL_M_Y + 76;
  noStroke();
  fill(150);
  textSize(13);
  textAlign(CENTER, TOP);
  text("Riemann: particiona el DOMINIO (eje X) -- rect\u00E1ngulos verticales   |   "
     + "Lebesgue: particiona el CODOMINIO (eje Y) -- f medida por longitud de preim\u00E1genes (mu)",
       CW / 2, ly);
}

//  TOOLTIP (hover cross-highlight)
void drawTooltip() 
{
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
    line2 = "mu ~ " + nf(mu, 1, 4);
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

void mousePressed() 
{
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

void mouseDragged() 
{
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

void mouseReleased() 
{
  dragMode = null;
}

void keyPressed() 
{
  if (keyCode == LEFT)  { sN = max(2, sN - 1);  ig.cacheKey = ""; }
  if (keyCode == RIGHT) { sN = min(40, sN + 1); ig.cacheKey = ""; }
  if (keyCode == DOWN)  { sM = max(1, sM - 1);  ig.cacheKey = ""; }
  if (keyCode == UP)    { sM = min(20, sM + 1); ig.cacheKey = ""; }
}

void mouseMoved() 
{
  // Estos valores es inician así para indicar que no hay selección
  // y se actualizan si el mouse está sobre alguno de los paneles.
  hoverPanel = 0; 
  hoverBand  = -1;
  hoverX     = -1;
  hoverY     = -1;

  float axX0 = PL;            // 
  float axX1 = PW - PR;       // x=0 (izq) a x=1 (der)
  float axY0 = PH - PB;       // y=0 (abajo)
  float axY1 = PT;            // y=1.05 (arriba)

  // Panel Riemann 
  if (mouseX >= P1X + axX0 && mouseX <= P1X + axX1 &&
      mouseY >= PY  + axY1 && mouseY <= PY  + axY0) {
    hoverPanel = 1;
    hoverX = constrain(map(mouseX, P1X + axX0, P1X + axX1, 0, 1), 0, 1);
    hoverY = constrain(funciones[fi].eval(hoverX), 0, 1.0 - 1e-6);
    float dy = 1.0 / sN;
    hoverBand = constrain((int)(hoverY / dy), 0, sN - 1);
    return;
  }

  // Panel Lebesgue 
  if (mouseX >= P2X + axX0 && mouseX <= P2X + axX1 &&
      mouseY >= PY  + axY1 && mouseY <= PY  + axY0) {
    hoverPanel = 2;
    hoverY = constrain(map(mouseY, PY + axY0, PY + axY1, 0, 1.05), 0, 1.05);
    float dy = 1.0 / sN;
    hoverBand = constrain((int)(hoverY / dy), 0, sN - 1);
    return;
  }
}

// Colores para las bandas y rectángulos
// Gradiente azul al rojo pasando por cian, verde, amarillo
color stripColor(int k, int n, int alpha) 
{
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
