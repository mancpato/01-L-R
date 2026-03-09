# Riemann vs. Lebesgue — Explorador Interactivo

**Universidad Autónoma de Baja California Sur (UABCS) · Marzo 2026**  
**Autor:** Miguel Angel Norzagaray Cosío  
**Plataforma:** Processing 4 (Java)

La diferencia entre ambas integrales no es computacional sino epistemológica:
**Riemann particiona el dominio (eje X) — Lebesgue particiona el codominio (eje Y).**
Este simulador hace esa diferencia visible e interactiva.

---

## Instalación y ejecución

```bash
git clone https://github.com/mancpato/01-L-R.git
```

1. Instala [Processing 4](https://processing.org/download)
2. Abre `riemann_lebesgue/riemann_lebesgue.pde`
3. Presiona **Run** (Ctrl+R)

---

## Controles

| Control | Acción |
|---------|--------|
| Slider **n** | Particiones: eje X en Riemann / eje Y en Lebesgue (2–40) |
| Slider **m** | Subdivisiones por partición — mayor precisión (1–20) |
| **← →** | Ajuste fino de n |
| **↑ ↓** | Ajuste fino de m |
| Botones de función | Selecciona la función activa |
| **[ mostrar sup / inf ]** | Activa sumas superior e inferior en Riemann |

### Cross-highlight (hover)
Pasar el mouse sobre un panel resalta el elemento correspondiente en el otro:
- **Hover en Riemann** → ilumina la banda k en Lebesgue donde cae f(x)
- **Hover en Lebesgue** → ilumina todos los rectángulos en Riemann cuyo f(x_mid) cae en esa banda

Es el momento central del simulador: la conexión entre dominio y codominio se vuelve visible en tiempo real.

---

## Funciones

| # | Función | Tipo | Riemann | Lebesgue | Exacta |
|---|---------|------|:-------:|:--------:|--------|
| 0 | x² | Continua | ✓ | ✓ | 1/3 |
| 1 | sqrt(x) | Continua | ✓ | ✓ | 2/3 |
| 2 | Thomae | Discontinua en Q (densa) | ✓ | ✓ | 0 |
| 3 | Dirichlet | Patologica | ✗ | ✓ | LI = 0 |
| 4 | sin²(4πx) | Oscilatoria suave | ✓ | ✓ | 1/2 |
| 5 | \|x·sin(π/x)\| | Oscilatoria singular en 0 | ✓ | ✓ | ~0.2817 |

**Dirichlet** es el caso clave: la suma superior de Riemann es siempre 1
y la inferior siempre 0 — el gap nunca cierra sin importar cuánto aumente n.
Lebesgue integra limpiamente porque mu(Q) = 0.

---

## Experimentos sugeridos

1. **Convergencia básica** — Selecciona x² o sqrt(x), aumenta n de 2 a 40.
   Ambos métodos convergen al mismo valor con velocidades similares.

2. **Discontinuidades que no importan** — Selecciona Thomae.
   A pesar de tener infinitas discontinuidades, Riemann converge a 0.
   La suma superior baja lentamente; la inferior es siempre 0.
   Activa `[ mostrar sup / inf ]` para verlo.

3. **El caso patologico: Dirichlet** — Activa `[ mostrar sup / inf ]`.
   El gap sup - inf = 1.0000 con cualquier n. Luego mira Lebesgue:
   converge a 0 porque la banda y=1 tiene mu = 0.
   Pasa el mouse sobre esa banda: ningun rectangulo se ilumina en Riemann.

4. **Superconvergencia** — Selecciona sin²(4πx) con n=6, m=3.
   Error de Riemann = 0.000000 con solo 18 rectangulos.
   No es un bug: la simetria de la funcion cancela exactamente los errores.

5. **Singularidad oscilatoria** — Selecciona |x·sin(π/x)| y aumenta m.
   Las oscilaciones densas cerca de x=0 requieren mayor subdivision
   para capturar bien la integral. Convergencia mas lenta que las continuas.

---

## Nota tecnica

### Thomae y Dirichlet en aritmetica finita
Ninguna computadora maneja irracionales reales: todos los flotantes son
racionales. Thomae usa tolerancia `1e-6` para identificar p/q con q <= 300.
Dirichlet esta implementada como D_n(x): picos en p/q con q <= n,
ventana `c/(n*q²)`. Al aumentar n los picos proliferan pero su medida
total tiende a 0 — exactamente la intuicion de Lebesgue.
Esta es una aproximacion honesta; "maquillar" resultados no seria
educativamente valioso.

### Rendimiento
Con n=40, m=20 se generan ~80,000 puntos de muestreo. El sketch mantiene
60 fps gracias a un sistema de cache: solo recalcula cuando cambian fi, n o m.

### Arquitectura

| Archivo | Responsabilidad |
|---------|----------------|
| `riemann_lebesgue.pde` | Sketch principal: estado global, UI, eventos |
| `FuncDef.pde` | Definicion de las 6 funciones matematicas |
| `Integrador.pde` | Motor de calculo compartido (Riemann + Lebesgue) |
| `PanelRiemann.pde` | Render del panel izquierdo + cross-highlight |
| `PanelLebesgue.pde` | Render del panel derecho + cross-highlight |

---

## Licencia

Proyecto educativo de codigo abierto. Libre para uso academico.  
Miguel Angel Norzagaray Cosío — UABCS — marzo de 2026

