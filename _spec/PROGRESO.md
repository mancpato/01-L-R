## Estado: Paso 8 completado ✓
Pasos completados: 1, 2, 3, 4, 5, 6, 7, 8
Funciones activas: x², √x, Thomae, Dirichlet Dₙ, sin²(4πx), |x·sin(π/x)|

## Pendiente
- [x] Paso 7: hover + cross-highlight ✓
- [x] Paso 8: sin²(4πx) + |x·sin(π/x)| ✓
- [ ] Paso 9: pulido final  ← SIGUIENTE

## Paso 8 — Nuevas funciones (implementado)
- sin²(4πx): 4 periodos en [0,1], integral exacta = 1/2, case 4 en eval()
- |x·sin(π/x)|: singularidad oscilante en x=0 (lím→0), integral ≈ 0.2817, case 5
- Botones ajustados: bw=105 gap=8 (6 botones en una fila)
- Fórmula de color: i*2 en vez de i*3 (6 funciones caben en gradiente 0..11)
- Barras μ de Lebesgue: escala relativa al máximo (fix para Dirichlet)
- Dirichlet: sin línea de error (limitación computacional, no matemática)

## Paso 7 — Hover cross-highlight (implementado)
- Estado centralizado: hoverPanel (0/1/2), hoverBand, hoverX, hoverY
- mouseMoved() en sketch principal detecta panel y convierte pixel→dominio
- Riemann hover: línea vertical + punto en f(x) + banda resaltada en Lebesgue
- Lebesgue hover: banda resaltada + línea horizontal + rects iluminados en Riemann
- Tooltip contextual (x, f(x), banda k, μ) con auto-posicionamiento
- Highlights dibujados después de curva, antes de ejes (z-order correcto)

## Decisiones tomadas
- Estado hover centralizado en sketch principal (Opción A)
- sin(4πx) → sin²(4πx) para mantener rango [0,1]
- |x·sin(π/x)| con protección x < 1e-6 → 0
- Error de Dirichlet no se muestra: la aritmética de punto flotante no converge limpiamente
- hoverPanel: 0=ninguno, 1=Riemann, 2=Lebesgue
- hoverBand: índice de banda k (reemplaza hoverVal del diseño original)
- Paneles reciben hoverPanel + hoverBand como parámetros read-only

## Geometría actual
CW=1200 CH=800 PW=520 PH=400 P1X=20 P2X=660 PY=185
Botones: bw=105 bh=25 gap=8 (6 funciones)
