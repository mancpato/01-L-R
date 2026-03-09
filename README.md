# INTEGRAL DE RIEMANN vs INTEGRAL DE LEBESGUE
## Explorador Interactivo

**Autor:** Miguel Angel Norzagaray Cosío
**Institución:** Universidad Autónoma de Baja California Sur (UABCS)
**Fecha:** Marzo 2026
**Plataforma:** Processing (Java)

---

## Descripción

Este sketch permite comparar visualmente la integral de Riemann y la integral de Lebesgue para funciones definidas en el intervalo [0,1]. Ambas aproximaciones usan el mismo integrador numérico, pero muestran cómo cada método construye las sumas de manera fundamentalmente diferente:

- **Riemann:** Particiona el **DOMINIO** (eje X) en subintervalos y construye rectángulos verticales.
- **Lebesgue:** Particiona el **CODOMINIO** (eje Y) en bandas horizontales y mide la longitud de las preimágenes (μ).

El objetivo principal es visualizar por qué la integral de Lebesgue logra manejar funciones altamente discontinuas (como la función de Dirichlet) que "rompen" el método tradicional de Riemann.

---

## Funciones Incluidas

### 0. **f(x) = x²**
- Función suave y continua
- Integral exacta: RI = LI = 1/3
- Ilustra convergencia rápida en ambos métodos

### 1. **f(x) = √x**
- Función suave y continua (derivada no acotada en x=0)
- Integral exacta: RI = LI = 2/3
- Ilustra convergencia rápida en ambos métodos

### 2. **Thomae (palomitas de maíz)**
- f(p/q) = 1/q para racionales en forma reducida
- f(x) = 0 para irracionales
- Integral exacta: RI = LI = 0
- Riemann-integrable a pesar de tener infinitas discontinuidades
- **Nota:** Las computadoras no manejan números irracionales reales, así que se usa aproximación con tolerancia ajustada a float32

### 3. **Dirichlet (función lluvia)**
- f(Q) = 1 para racionales
- f(R\Q) = 0 para irracionales
- **NO es Riemann-integrable** (diferencia entre suma superior e inferior nunca converge)
- **SÍ es Lebesgue-integrable:** LI = 0 (porque μ(Q) = 0)
- Este es el caso donde Lebesgue demuestra su superioridad
- **Nota:** La versión implementada es Dirichlet_n, controlada por el slider n, que aproxima la función

### 4. **sin²(4πx)**
- 4 periodos completos en [0,1]
- Integral exacta: RI = LI = 1/2
- La regla del punto medio es **exacta por simetría** (superconvergencia)
- Ilustra comportamiento oscilatorio suave

### 5. **|x·sin(π/x)|**
- Singularidad oscilante en x=0 (lím_{x→0} = 0)
- Oscilaciones cada vez más densas cerca del origen
- Integral exacta: RI = LI ≈ 0.2932
- Riemann-integrable pero convergencia más lenta cerca de x=0

---

## Arquitectura del Código

### `riemann_lebesgue.pde` (sketch principal)
- Maneja el ciclo de dibujo y la interfaz de usuario
- Controla el estado global: función seleccionada (fi), particiones (sN), subdivisiones (sM)
- Implementa sliders interactivos para n y m
- Sistema de análisis al pasar el ratón entre paneles
- Tooltips contextuales con información de x, f(x), banda k y medida μ

### `FuncDef.pde`
Define las 6 funciones matemáticas con:
- `eval(x)`: Evaluación de f(x)
- `Thomae(x)`: Implementación de la función del palomitero
- `DirichletN(x, n)`: Aproximación de la función de Dirichlet
- Propiedades: nombre, info, valor exacto de la integral, flag riemannOK

**Aclaración importante sobre Thomae y Dirichlet:** Ninguna computadora maneja números irracionales reales, así que se usan aproximaciones con tolerancia ajustada a float32. La alternativa de "maquillar" la irracionalidad complicaría mucho el código y terminaría siendo un engaño al usuario.

### `Integrador.pde`
Aproxima la integral de una función f(x) en [0,1]:
- **Riemann:** Altura en el punto medio, supremo o ínfimo de cada subintervalo
- **Lebesgue:** Clasifica puntos por su valor f(x) y suma medidas (frecuencias) de cada banda
- Ambos métodos comparten la función f(x) precalculada para eficiencia
- Sistema de caché para evitar recálculos innecesarios

**Nota:** Tal vez deberían ser dos integradores separados, pero como comparten f(x) precalculada, esta arquitectura es más eficiente.

### `PanelRiemann.pde`
- Renderiza la visualización de Riemann
- Dibuja n×m rectángulos verticales usando regla del punto medio
- Colores asignados por strip (partición gruesa) usando gradiente azul→rojo
- Muestra opcionalmente sumas superior e inferior
- Implementa cross-highlight cuando se hace hover en panel Lebesgue

### `PanelLebesgue.pde`
- Renderiza la visualización de Lebesgue
- Dibuja n bandas horizontales coloreadas
- Barra de preimagen (debajo del eje X) muestra clasificación de puntos por color
- Barras μ (derecha) muestran la medida de cada banda (escaladas relativamente)
- Implementa cross-highlight cuando se hace hover en panel Riemann

---

## Características Interactivas

### Sliders
- **n (particiones):** Controla el número de divisiones del intervalo [0,1]
  - Eje X → Riemann: n particiones gruesas
  - Eje Y → Lebesgue: n bandas horizontales
  - Rango: 2 a 40

- **m (subdivisiones):** Controla la precisión de muestreo
  - n×m rectángulos totales en Riemann
  - Mayor precisión en Lebesgue (más puntos muestreados)
  - Rango: 1 a 20

### Botones
- **6 funciones:** Selección de la función a integrar
- **[ mostrar sup / inf ]:** Toggle para mostrar sumas superior e inferior en Riemann

### Resaltado al pasar el ratón
- **Resaltado en Riemann (x):** Resalta la banda k en Lebesgue donde f(x) cae
  - Muestra línea vertical en x
  - Punto amarillo en f(x) sobre la curva
  - Tooltip: "x=... f(x)=... banda k=..."

- **Resaltado en Lebesgue (banda k):** Resalta todos los rectángulos en Riemann cuyo f(punto medio) cae en esa banda
  - Muestra línea horizontal en y
  - Tooltip: "banda k=... [..., ...] mu ~ ..."

### Teclado
- **←/→:** Disminuir/aumentar n
- **↓/↑:** Disminuir/aumentar m

---

## Detalles de Implementación

### Geometría fija [ más fácil :-) ]
- Canvas: 1200×800 px
- Paneles: 520×400 px cada uno
- Panel Riemann: x=20, y=185
- Panel Lebesgue: x=660, y=185
- Padding interno: L=44, R=14, T=26, B=42

### Muestreo
- **N_CURVE = 3000:** Puntos para dibujar la curva de f(x)
  - Si fuera la misma cantidad que los píxeles, el aliasing haría que funciones como Thomae o Dirichlet se vean como 0
- **N_PREIMG = 4000:** Puntos base para muestrear preimágenes en Lebesgue
  - El número real de puntos es `max(N_PREIMG * m, n * 50)` para adaptarse a m

### Paleta de Colores
- Gradiente HLS: del azul al rojo pasando por cian, verde, amarillo
- Función `stripColor(k, n, alpha)` genera colores consistentes entre ambos paneles
- Los rectángulos/bandas de la misma partición k comparten color

### Portabilidad
- Hay varias cosas por probar
- Caracteres Unicode Latin-1 (²×áó) funcionan en todas las plataformas
- Símbolos matemáticos complejos (ℝ, ℚ, Σ, μ, π) reemplazados por ASCII (R, Q, Sum, mu, pi)
- Courier New como fuente por defecto (disponible universalmente)

---

## Casos de Uso Educativos

### 1. Convergencia de funciones continuas
Selecciona x² o √x y aumenta n gradualmente. Observa cómo tanto Riemann como Lebesgue convergen rápidamente al mismo valor (1/3 o 2/3).

### 2. Funciones discontinuas pero Riemann-integrables
Selecciona Thomae. A pesar de tener infinitas discontinuidades, ambos métodos convergen a 0. Las discontinuidades son "pequeñas" en sentido de Lebesgue (conjunto de medida 0).

### 3. El caso patológico: Dirichlet
Selecciona Dirichlet. Observa:
- **Riemann:** El gap entre suma superior (≈1) e inferior (≈0) nunca cierra
- **Lebesgue:** Converge limpiamente a 0 porque μ(Q) = 0
- Este es el ejemplo clásico que motivó la teoría de Lebesgue

### 4. Superconvergencia: sin²(4πx)
Selecciona sin²(4πx) con n=6, m=3. La regla del punto medio da error = 0.000000 con solo 18 rectángulos. Esto no es un bug — es una propiedad matemática: la simetría de la función hace que los sobreestimados cancelen exactamente los subestimados.

### 5. Singularidades oscilantes: |x·sin(π/x)|
Selecciona |xsin(pi/x)| y aumenta m. Observa cómo las oscilaciones cerca de x=0 requieren mayor subdivisión para capturar bien la integral. Es Riemann-integrable pero converge más lento que las funciones suaves.

---

## Limitaciones y Consideraciones

### Aritmética de Punto Flotante
Processing usa `float` (32 bits), no `double`. Esto limita la precisión a ~6-7 dígitos significativos. Para Dirichlet, la suma de Lebesgue no converge exactamente a 0 por limitaciones computacionales (muestreo finito de racionales), no matemáticas. Por eso no se muestra el "error" para Dirichlet — sería engañoso.

### Aproximación de Irracionales
Las funciones Thomae y Dirichlet requieren distinguir racionales de irracionales, algo imposible en aritmética finita. Se usa tolerancia `1e-6` para identificar racionales p/q con q ≤ 300. Esto es una aproximación honesta — la alternativa de "maquillar" resultados no sería educativamente honesto.

### Rendimiento
Con n=40 y m=20 se generan 800 rectángulos y ~80,000 puntos de muestreo. El sketch mantiene 60 fps gracias al sistema de caché — solo recalcula cuando cambian fi, n o m.

---

## Requisitos

- Processing 4.x
- Sistema operativo: Windows, macOS o Linux
- Fuente: Courier New (incluida por defecto en todos los OS)

---

## Cómo Ejecutar

1. Descarga e instala [Processing 4](https://processing.org/download)
2. Clona este repositorio o descarga los archivos
3. Abre `riemann_lebesgue.pde` en el IDE de Processing
4. Presiona **Run** (▶) o Ctrl+R

---

## Referencias Teóricas

- **Integral de Riemann:** Aproximación mediante sumas de rectángulos basadas en partición del dominio
- **Integral de Lebesgue:** Aproximación mediante medición de conjuntos de nivel (partición del codominio)
- **Teorema:** Toda función Riemann-integrable es Lebesgue-integrable, y ambas integrales coinciden
- **Contraejemplo:** La función de Dirichlet es Lebesgue-integrable pero NO Riemann-integrable

---

## Licencia

Proyecto educativo de código abierto. Libre para uso académico.

## Contacto

Miguel Angel Norzagaray Cosío
Universidad Autónoma de Baja California Sur (UABCS)

---

**Versión:** 1.0 (Marzo 2026)
