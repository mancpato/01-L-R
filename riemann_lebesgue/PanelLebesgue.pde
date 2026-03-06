class PanelLebesgue {

  void draw(int px, int py, int pw, int ph, Integrador ig, int sN) {

    int n = sN;
    float dy = 1.0 / n;

    // ── Fondo del panel ────────────────────────────
    fill(10, 22, 11);              // #0a160b
    stroke(37, 69, 42);            // #25452a
    strokeWeight(1);
    rect(px, py, pw, ph, 4);

    // ── Sistema de coordenadas ─────────────────────
    float axX0 = px + PL;
    float axX1 = px + pw - PR;
    float axY0 = py + ph - PB;    // y=0 (abajo)
    float axY1 = py + PT;         // y=1.05 (arriba)

    // ── Cuadrícula sutil ───────────────────────────
    stroke(255, 255, 255, 7);
    strokeWeight(0.5);
    for (int i = 1; i < 4; i++) {
      float gx = map(i / 4.0, 0, 1, axX0, axX1);
      float gy = map(i / 4.0, 0, 1.05, axY0, axY1);
      line(gx, axY1, gx, axY0);
      line(axX0, gy, axX1, gy);
    }

    // ── Bandas horizontales (partición del eje Y) ──
    for (int k = 0; k < n; k++) {
      float y0 = k * dy;
      float y1 = y0 + dy;
      color c = stripColor(k, n, 255);

      // Fondo de la banda
      fill(red(c), green(c), blue(c), 26);
      noStroke();
      float bandTop = map(y1, 0, 1.05, axY0, axY1);
      float bandBot = map(y0, 0, 1.05, axY0, axY1);
      rect(axX0, bandTop, axX1 - axX0, bandBot - bandTop);

      // Línea horizontal en y0
      stroke(red(c), green(c), blue(c), 110);
      strokeWeight(0.8);
      line(axX0, bandBot, axX1, bandBot);
    }
    // Línea en y=1
    stroke(200, 200, 200, 70);
    strokeWeight(0.7);
    line(axX0, map(1.0, 0, 1.05, axY0, axY1), axX1, map(1.0, 0, 1.05, axY0, axY1));

    // ── Barra de preimagen (debajo del eje X) ──────
    int barH = 16;
    float barY = axY0 + 5;
    int totalSamples = ig.classifyX.length;
    int step = max(1, (int)(totalSamples / (axX1 - axX0) * 2));
    for (int j = 0; j < totalSamples; j += step) {
      float xj = ig.classifyX[j];
      int kj = ig.classifyK[j];
      color c = stripColor(kj, n, 210);
      stroke(c);
      strokeWeight(1.6);
      float sx = map(xj, 0, 1, axX0, axX1);
      line(sx, barY, sx, barY + barH - 2);
    }
    noStroke();
    fill(60);
    textSize(7.5);
    textAlign(LEFT, TOP);
    text("preimagen", axX0, barY + barH + 2);

    // ── Barras de medida μ (derecha del panel) ─────
    float mX = axX1 + 4;
    int mMax = 28;
    for (int k = 0; k < n; k++) {
      float y0 = k * dy;
      float y1 = y0 + dy;
      float bw = constrain(ig.measures[k] * mMax * n, 0, mMax);
      color c = stripColor(k, n, 200);
      fill(c);
      noStroke();
      float bTop = map(y1, 0, 1.05, axY0, axY1) + 1;
      float bBot = map(y0, 0, 1.05, axY0, axY1) - 1;
      rect(mX, bTop, bw, bBot - bTop);
    }
    noStroke();
    fill(60);
    textSize(7.5);
    textAlign(LEFT, TOP);
    text("\u03BC", mX, axY1);

    // ── Curva f(x) ─────────────────────────────────
    stroke(255, 235, 70);
    strokeWeight(2.5);
    noFill();
    beginShape();
    for (int i = 0; i <= N_CURVE; i++) {
      float sx = map(ig.curveX[i], 0, 1,    axX0, axX1);
      float sy = map(ig.curveY[i], 0, 1.05, axY0, axY1);
      vertex(sx, sy);
    }
    endShape();

    // ── Ejes ───────────────────────────────────────
    stroke(150);
    strokeWeight(1);
    line(axX0, axY0, axX1, axY0);
    line(axX0, axY0, axX0, axY1);

    noStroke();
    fill(140);
    textSize(11);

    // Eje X
    for (int i = 0; i <= 4; i++) {
      float val = i / 4.0;
      float tx = map(val, 0, 1, axX0, axX1);
      textAlign(CENTER, TOP);
      text(nf(val, 1, 2), tx, axY0 + 5);
      stroke(140);
      strokeWeight(0.8);
      line(tx, axY0, tx, axY0 + 3);
      noStroke();
    }

    // Eje Y
    for (int i = 0; i <= 4; i++) {
      float val = i / 4.0;
      float ty = map(val, 0, 1.05, axY0, axY1);
      textAlign(RIGHT, CENTER);
      text(nf(val, 1, 2), axX0 - 4, ty);
      stroke(140);
      strokeWeight(0.8);
      line(axX0 - 3, ty, axX0, ty);
      noStroke();
    }

    // ── Etiqueta del panel ─────────────────────────
    noStroke();
    fill(200);
    textSize(14);
    textAlign(CENTER, TOP);
    text("LEBESGUE", px + pw / 2, py + 6);

    fill(120);
    textSize(12);
    text("n = " + n + " bandas en Y  |  barra derecha = \u03BC(preimagen)", px + pw / 2, py + ph - 18);
  }
}
