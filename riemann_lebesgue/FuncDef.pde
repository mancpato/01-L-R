class FuncDef {
  int id;
  String nombre;
  String info;
  float exacta;       // -1 si no existe integral de Riemann
  boolean riemannOK;

  FuncDef(int id, String nombre, String info, float exacta, boolean riemannOK) {
    this.id = id;
    this.nombre = nombre;
    this.info = info;
    this.exacta = exacta;
    this.riemannOK = riemannOK;
  }

  float eval(float x) {
    switch (id) {
      case 0:  return x * x;
      case 1:  return sqrt(x);
      default: return 0;  // stub — Thomae y Dirichlet en pasos posteriores
    }
  }
}
