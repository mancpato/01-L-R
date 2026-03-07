class PanelRiemann {

  void draw(int px, int py, int pw, int ph,
            Integrador ig, boolean showBounds, int sN, int sM, int fi) {

    // ── Fondo del panel ────────────────────────────
    fill(11, 11, 28);              // #0b0b1c
    stroke(37, 37, 69);            // #252545
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

    // ── Rectángulos de Riemann (punto medio) ───────
    for (int i = 0; i < ig.totalRects; i++) {
      float x0   = ig.rects[i][0];
      float x1   = ig.rects[i][1];
      float fMid = ig.rects[i][2];
      int strip  = (int) ig.rects[i][5];

      float rx0 = map(x0, 0, 1, axX0, axX1);
      float rx1 = map(x1, 0, 1, axX0, axX1);
      float ryB = map(0,    0, 1.05, axY0, axY1);
      float ryM = map(fMid, 0, 1.05, axY0, axY1);

      color c = stripColor(strip, sN, 140);
      fill(c);
      stroke(red(c), green(c), blue(c), 70);
      strokeWeight(0.4);
      rect(rx0, ryM, rx1 - rx0, ryB - ryM);
    }

    // ── Separadores de partición gruesa ─────────────
    stroke(255, 255, 255, 50);
    strokeWeight(1);
    for (int i = 0; i <= sN; i++) {
      float rx = map((float) i / sN, 0, 1, axX0, axX1);
      line(rx, axY0, rx, axY1);
    }

    // ── Curva f(x) ─────────────────────────────────
    if (fi == 2) {
      // Thomae: línea base y=0 + puntos
      stroke(255, 235, 70, 55); strokeWeight(1);
      line(map(0, 0, 1, axX0, axX1), map(0, 0, 1.05, axY0, axY1),
           map(1, 0, 1, axX0, axX1), map(0, 0, 1.05, axY0, axY1));
      stroke(255, 235, 70, 200); strokeWeight(2.5);
      for (int i = 0; i <= N_CURVE; i++) {
        if (ig.curveY[i] > 0.005) {
          point(map(ig.curveX[i], 0, 1, axX0, axX1),
                map(ig.curveY[i], 0, 1.05, axY0, axY1));
        }
      }
    } else if (fi == 3) {
      // Dirichlet: líneas en y=0 e y=1 + puntos
      stroke(255, 235, 70, 50); strokeWeight(1);
      float y0px = map(0, 0, 1.05, axY0, axY1);
      float y1px = map(1, 0, 1.05, axY0, axY1);
      float x0px = map(0, 0, 1, axX0, axX1);
      float x1px = map(1, 0, 1, axX0, axX1);
      line(x0px, y0px, x1px, y0px);
      line(x0px, y1px, x1px, y1px);
      stroke(255, 235, 70, 180); strokeWeight(2.5);
      for (int i = 0; i <= N_CURVE; i++) {
        point(map(ig.curveX[i], 0, 1, axX0, axX1),
              map(ig.curveY[i], 0, 1.05, axY0, axY1));
      }
    } else {
      // Funciones continuas: polilínea
      stroke(255, 235, 70);
      strokeWeight(2.5);
      noFill();
      beginShape();
      for (int i = 0; i <= N_CURVE; i++) {
        vertex(map(ig.curveX[i], 0, 1, axX0, axX1),
               map(ig.curveY[i], 0, 1.05, axY0, axY1));
      }
      endShape();
    }

    // ── Ejes ───────────────────────────────────────
    stroke(150);
    strokeWeight(1);
    line(axX0, axY0, axX1, axY0);  // eje X
    line(axX0, axY0, axX0, axY1);  // eje Y

    noStroke();
    fill(140);
    textSize(11);

    // Eje X: ticks y labels
    for (int i = 0; i <= 4; i++) {
      float val = i / 4.0;
      float tx  = map(val, 0, 1, axX0, axX1);
      textAlign(CENTER, TOP);
      text(nf(val, 1, 2), tx, axY0 + 5);
      stroke(140);
      strokeWeight(0.8);
      line(tx, axY0, tx, axY0 + 3);
      noStroke();
    }

    // Eje Y: ticks y labels
    for (int i = 0; i <= 4; i++) {
      float val = i / 4.0;
      float ty  = map(val, 0, 1.05, axY0, axY1);
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
    text("RIEMANN", px + pw / 2, py + 6);

    fill(120);
    textSize(12);
    String lbl = "n\u00D7m = " + (sN * sM) + " rect\u00E1ngulos  |  regla del punto medio";
    text(lbl, px + pw / 2, py + ph - 18);
  }
}
