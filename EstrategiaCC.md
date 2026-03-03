# Estrategia: VS Code + Claude Code → Processing IDE

**Flujo de trabajo:** Claude Code escribe los `.pde` en VS Code,
tú los pegas en el Processing IDE para verificar visualmente.
Processing es Java con azúcar sintáctica — un `.pde` es Java sin clase wrapper.

---

## Preparación (antes de abrir Claude Code)

### 1. Estructura de carpetas

```
riemann_lebesgue/
├── riemann_lebesgue.pde   ← sketch principal
├── FuncDef.pde
├── Integrador.pde
├── PanelRiemann.pde
├── PanelLebesgue.pde
└── _spec/
    ├── riemann_lebesgue_spec.docx
    └── riemann_lebesgue.html      ← prototipo p5.js
```

> Processing trata todos los `.pde` de una carpeta como un solo programa.
> Claude Code puede editar todos a la vez.

### 2. Extensión VS Code (opcional)

Busca **"Processing Language"** en el marketplace — da syntax highlighting para `.pde`.

---

## Mensaje inicial para Claude Code

Pegar esto textual al abrir la sesión, adjuntando ambos archivos:

```
Tengo este proyecto en Processing (Java).
Contexto:
- spec: [adjunta riemann_lebesgue_spec.docx]
- prototipo funcional en p5.js: [adjunta riemann_lebesgue.html]

La lógica matemática del prototipo es correcta y puedes usarla
como referencia directa. El objetivo es traducirla a Processing
con la arquitectura de clases del spec.

Empieza SOLO con el Paso 1: estructura de clases vacías + setup/draw
funcionando con un canvas en blanco de 1100×720.
```

> El HTML es valioso porque Claude Code puede leer las funciones ya
> validadas (`thomae`, `dirichletN`, `supInfOn`, `stripColor`, `rebuild`)
> y traducirlas directamente en lugar de reinventarlas.

---

## Secuencia de pasos (uno a la vez)

| Paso | Qué pedir a Claude Code | Qué verificar en Processing IDE |
|:----:|-------------------------|--------------------------------|
| 1 | Clases vacías + canvas | Ventana abre sin errores |
| 2 | `FuncDef` con x², √x + `PanelRiemann` básico | Se ven rectángulos y curva |
| 3 | `PanelLebesgue` + bandas + medidas | Ambos paneles visibles |
| 4 | Sliders `n`, `m`, `animSpeed` + botones función | Interacción responde |
| 5 | Resultados numéricos + μ nivel=1 | Números correctos vs. exacta |
| 6 | Thomae + Dirichlet D_n | Dirichlet no converge en Riemann |
| 7 | Hover + cross-highlight | El momento "aha" |
| 8 | sin(4πx) + x·sin(π/x) | Funciones nuevas sin bugs |
| 9 | Pulido: sup/inf, teclas, `animSpeed` | Todo integrado |

### Frase para avanzar entre pasos

```
Paso N verificado. Continúa con Paso N+1: [descripción del spec].
```

### Si algo falla

Copia el error **exacto** de la consola de Processing y díselo.
Los errores de Java de Processing son muy descriptivos.

---

## Diferencias clave p5.js → Processing

Incluir esto en el mensaje inicial o cuando Claude Code cometa el primer error de sintaxis:

```
Diferencias clave del prototipo HTML a Processing:
- map() existe igual en Processing
- constrain() existe igual
- color() devuelve int, no objeto — usar color(r,g,b,a)
- red(), green(), blue() existen igual
- NO existen arrow functions ni let/const — usar float, int, etc.
- El sketch principal NO declara clase; FuncDef.pde etc. SÍ necesitan
  "class FuncDef { ... }"
- frameRate(60) en setup()
- textFont(createFont("Courier New", 12)) en setup()
```
