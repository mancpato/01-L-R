## Estado: Paso 7 completado ✓
Pasos completados: 1, 2, 3, 4, 5, 6, 7
Funciones activas: x², √x, Thomae, Dirichlet Dₙ

## Pendiente
- [x] Paso 7: hover + cross-highlight ✓
- [ ] Paso 8: sin(4πx) + x·sin(π/x)  ← SIGUIENTE
- [ ] Paso 9: pulido final

## Paso 7 — Hover cross-highlight (implementado)
- Estado centralizado: hoverPanel (0/1/2), hoverBand, hoverX, hoverY
- mouseMoved() en sketch principal detecta panel y convierte pixel→dominio
- Riemann hover: línea vertical + punto en f(x) + banda resaltada en Lebesgue
- Lebesgue hover: banda resaltada + línea horizontal + rects iluminados en Riemann
- Tooltip contextual (x, f(x), banda k, μ) con auto-posicionamiento
- Highlights dibujados después de curva, antes de ejes (z-order correcto)

## Decisiones tomadas
- Estado hover centralizado en sketch principal (Opción A)
- x·sin(π/x) usar |x·sin(π/x)|
- hoverPanel: 0=ninguno, 1=Riemann, 2=Lebesgue
- hoverBand: índice de banda k (reemplaza hoverVal del diseño original)
- Paneles reciben hoverPanel + hoverBand como parámetros read-only

## Geometría actual
CW=1200 CH=800 PW=520 PH=400 P1X=20 P2X=660 PY=185
