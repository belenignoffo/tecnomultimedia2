class Trazo {

  // ---- Datos de posición y movimientp
  float x, y, angulo, escala;
  float dir, vel;
  int cantidad, cual;
  // ---- Datos de paleta, color y alfa
  Paleta p;
  float alfa;
  color colorRelleno;
  // ---- Imágenes y máscara 
  PImage [] trazo;
  PImage mascara;

  int signo;

  Trazo(Paleta p, float x, float y, float alfa, int cual, float escala, float vel, float angulo) {
    this.p = p;
    this.x = x;
    this.y = y;
    this.alfa = alfa;
    this.cual = cual;
    this.escala = escala;
    this.vel = vel;
    this.angulo = angulo;

    colorRelleno = p.darUnColor();
    cargarImagenes();
    dir = radians( random( 360 ) );
    signo = floor(random(-1, 2));
  }

  void cargarImagenes() {
    cantidad = 20;
    trazo = new PImage[cantidad];
    for (int i = 0; i < cantidad; i++) {
      String nombre = "trazo" + nf(i, 2) + ".png";
      mascara = loadImage( nombre );
      mascara.filter( INVERT );
      trazo[i] = createImage( 300, 300, RGB );
      trazo[i].filter( INVERT );
      trazo[i].mask( mascara );
    }
  }
  void dibujar(PGraphics g) {
    g.pushStyle();
    g.pushMatrix();
    g.imageMode( CENTER );
    g.tint(colorRelleno, alfa);
    g.translate( x, y );
    g.scale( escala );
    g.rotate( angulo );
    g.image(trazo[cual], 0, 0);
    g.popMatrix();
    g.popStyle();
  }

  void mover() {

    float dx = vel * cos( dir );
    float dy = vel * sin( dir );

    x = x + dx;
    y = y + dy;

    rebotes();
    rotar();
  }

  void rebotes() {
    if ( x >= width+80 ) {
      dir = 180;
    }
    if ( x < -80) {
      dir = 0;
    }
    if ( y >= height+80 ) {
      dir = 270;
    }
    if ( y <= -80 ) {
      dir = 90;
    }
  }
  void rotar() {
    angulo += 0.01 * signo;
  }
  void actualizarDireccion(float dir, float vel) {
    this.dir = dir;
    this.vel = vel;
    signo = floor(random(-1, 2));
  }
}
