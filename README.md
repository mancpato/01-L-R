# Riemann vs. Lebesgue: Una Comparativa Visual

Este proyecto es una herramienta educativa desarrollada en **Processing (Java)** para ilustrar las diferencias fundamentales entre la integración de Riemann y la de Lebesgue. 

El objetivo principal es visualizar cómo la integral de Lebesgue logra manejar funciones altamente discontinuas (como la función de Dirichlet) que "rompen" el método tradicional de Riemann.

## Características principales

- **Panel de Riemann:** Visualización basada en la partición del dominio ($x$) y la suma de rectángulos verticales.
- **Panel de Lebesgue:** Visualización basada en la partición del rango ($y$), mostrando la medición de conjuntos de nivel y la "capa de cebolla".
- **Funciones ilustrativas:**
  - Continuas: $x^2$, $\sqrt{x}$.
  - Discontinuas: Función de Salto.
  - Patológicas: Función de Dirichlet ($1-f$) y Función de Thomae.
- **Interactividad:** Control dinámico de particiones ($n$ y $m$) mediante sliders.

## Estructura del Proyecto

- `riemann_lebesgue.pde`: Sketch principal y manejo del ciclo de dibujo.
- `FuncDef.pde`: Definiciones matemáticas de las funciones.
- `Integrador.pde`: Lógica de cálculo de ambas integrales.
- `PanelRiemann.pde` / `PanelLebesgue.pde`: Clases encargadas del renderizado independiente.

## Cómo ejecutar

1. Descarga e instala [Processing 4](https://processing.org/download).
2. Clona este repositorio.
3. Abre el archivo `riemann_lebesgue.pde` en el IDE de Processing.
4. Presiona **Run**.

---
Desarrollado por **Miguel** - Universidad Autónoma de Baja California Sur (UABCS).