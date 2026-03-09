/**
* Este módulo define las funciones a integrar y sus propiedades.
* 
* Funciones incluidas:
* 0: f(x) = x^2
* 1: f(x) = sqrt(x)
* 2: Thomae(x) = 1/q si x = p/q en forma reducida, 0 si x es irracional
* 3: DirichletN(x) = 1 si x es racional, 0 en otro caso 

Aclaración importante: Hay que ser realistas con las dos funciones anteriores, 
ninguna computadora maneja números irracionales, así que se usan 
aproximaciones con tolerancia ajustada a float32. La otra opción es simular 
y maquillar la irracionalidad, pero eso complica mucho el código y 
termina siendo un engaño al usuario.

* 4: f(x) = sin^2(4 pi x)
* 5: f(x) = | x sin(pi/x) | para x > 0, f(0) = 0
* Es tentador que el usuario pueda definir su propia función, 
* pero eso complica mucho la interfaz (y el código).
*/


class FuncDef {
  int id;
  String nombre;
  String info;
  float exacta;       // -1 si no existe integral de Riemann
  boolean riemannOK;

  FuncDef(int id, String nombre, String info, float exacta, boolean riemannOK) 
  {
    this.id = id;
    this.nombre = nombre;
    this.info = info;
    this.exacta = exacta;
    this.riemannOK = riemannOK;
  }

  float eval(float x) 
  {
    switch (id) {
      case 0:  return x * x;
      case 1:  return sqrt(x);
      case 2:  return Thomae(x);
      case 3:  return DirichletN(x, sN);  // sN global — spec: slider n controla D_n
      case 4:  return sin(4 * PI * x) * sin(4 * PI * x);
      case 5:  return (x < 1e-6) ? 0 : abs(x * sin(PI / x));
      default: return 0;
    }
  }

  int gcd(int a, int b) 
  {
    a = abs(a);
    b = abs(b);
    while (b != 0) { // El inolvidable algoritmo de Euclides
        int t = b; 
        b = a % b; 
        a = t; 
    }
    return (a == 0) ? 1 : a;
  }

  // Thomae: f(p/q reducida) = 1/q, f(irracional) = 0
  // Tolerancia ajustada para float32 (Processing usa float, no double)
  float Thomae(float x) 
  {
    if (x <= 0 || x >= 1) 
      return 0;
    for (int q = 1; q <= 300; q++) {
      int p = round(x * q);
      if (p <= 0 || p >= q) 
        continue;
      float diff = abs(x - (float) p / q);
      // Válido si x es "exactamente" p/q en float32
      if (diff < 1e-6) {
        int g = gcd(p, q);
        int qRed = q / g;  // denominador reducido
        return 1.0 / qRed;
      }
    }
    return 0;
  }

  // Dirichlet: picos en p/q con q <= n
  float DirichletN(float x, int n) 
  {
    float c = 1.0;
    for (int q = 1; q <= n; q++) {
      int p = round(x * q);
      if (p <= 0 || p >= q) 
        continue;
      float dist = abs(x - (float) p / q);
      if (dist < c / (n * q * q)) 
        return 1.0;
    }
    return 0.0;
  }
}
