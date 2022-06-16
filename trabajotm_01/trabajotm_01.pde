/*

 TRABAJO PRÁCTICO 1 - Comisión Lisandro
 Gil Tudor Agustina, Vega Lucía Soledad, Ignoffo Lara Belén
 
 */

// ---- Importar la librería
import oscP5.*;

// ---- Variables globales de calibración
float UMBRAL_AMPLITUD = 50;
float UMBRAL_RUIDO = 100;
float UMBRAL_BRILLO = 0.900;

float MIN_AMP = UMBRAL_AMPLITUD;
float MAX_AMP = 80;

float MIN_PITCH = 56;
float MAX_PITCH = 90;

float amortiguacion = 0.9;

boolean monitor = false;

float umbralDeTiempo = 3000;

// ---- Declarar los objetos osc y GestorSenial
OscP5 osc;
GestorSenial gAmp, gPitch;

// ---- Estados
boolean haySonido = false;
boolean antesHabiaSonido = false;
boolean hayRuido = false;
String estado;

// ---- Eventos
boolean empezoElSonido = false;
boolean terminoElSonido = false;

float amp, pitch, brillo;
int ruido, contador;
long marcaDeTiempo;

// ---- Trazos y líneas
ArrayList<Trazo> ts, tf;
ArrayList<Linea> ls;
// ---- Animaciones (BORRAR SI NO SE USA Y ELIMINAR LA CLASE)
Animacion a1, a2, a3, a4, a5, a6;
boolean seMuestran = false;
// ---- Paletas, PGraphics y fondo
PGraphics capatrazos, trazosfondo;
Paleta p, ptrazos;
PImage imgfondo;
int selectorPaleta;

float minTinte, maxTinte;

void setup() {
  size(1100, 950, P2D);
  inicializar();
  inicializarAnimaciones();
}

void draw() {
  background(240, 247, 250);
  pushStyle();
  tint(180, 60);
  image(imgfondo, 0, 0);
  popStyle();

  // ---- Sonido
  gPitch.actualizar(pitch);
  gAmp.actualizar(amp);

  haySonido = gAmp.filtradoNorm() > 0.1; // Estado
  hayRuido = ruido > UMBRAL_RUIDO; // Estado
  empezoElSonido = !antesHabiaSonido && haySonido; //Evento
  terminoElSonido = antesHabiaSonido && !haySonido; //Evento

  // ---- Mapeo el pitch para el tinte y el amp para el tamaño
  float pitchtinte = map(gPitch.filtradoNorm(), 0, 1, minTinte, maxTinte);
  float ampEscala = map(gAmp.filtradoNorm(), 0, 1, 0.95, 1.6);

  // ---- Si seMuestran == true, dibujo las animaciones
  if (seMuestran) {
    a1.dibujar(maxTinte);
    a2.dibujar(maxTinte);
    a3.dibujar(maxTinte);
    a4.dibujar(maxTinte);
    a5.dibujar(maxTinte);
  }

  // ---- TRAZOS FONDO
  trazosfondo.beginDraw();
  trazosfondo.clear();
  trazosfondo.background(255, 0);
  trazosfondo.image(imgfondo, 0, 0);
  trazosfondo.blendMode( DARKEST );
  for (Trazo t : tf) {
    t.dibujar(trazosfondo);
  }
  trazosfondo.endDraw();



  // ---- CAPA TRAZOS
  capatrazos.beginDraw();
  capatrazos.clear();
  capatrazos.background(255, 0);
  capatrazos.blendMode( MULTIPLY );

  // ---- ESTADOS: inicial e interacción
  if (estado.equals("inicial")) { // --- Si el estado es "inicial", se mueven los trazos del fondo
    for (Trazo t : tf) {
      t.mover();
    } 
    if (haySonido) {
      estado = "interaccion";
    }
  }
  if (estado.equals("interaccion")) {
    if (seMuestran) {
      a1.dibujar(255);
    }
    if (empezoElSonido) {
      marcaDeTiempo = millis();
    }
    if (haySonido && !hayRuido) { // --- Siempre que se detecte cualquier sonido se va a dibujar un trazo (los trazos son las pinceladas grandes)
      contador = 0; // --- Actualizamos el contador que usamos en !haySonido
      ts.add(new Trazo(p, random(width), random(height), pitchtinte, floor(random(20)), ampEscala, random(1, 10), radians(random(-2, 2))));
    }
    if (terminoElSonido) {
      long momentoActual = millis();
      if (momentoActual < marcaDeTiempo + umbralDeTiempo) { // --- Si el sonido es corto se dibuja una linea/garabato
        // ---------------------- posición X   , posición Y    , alfa ,       nro de arreglo  , velocidad , ángulo
        ls.add(new Linea(ptrazos, random(width), random(height), pitchtinte, floor(random(19)), random(10), radians(random(-6, 6))));
      }
    }
  }
  if (!haySonido) { // --- Si deja de haber sonido, los trazos/líneas comienzan a moverse de nuevo después de X cantidad de tiempo
    contador ++;
    if (contador >= 5) {
      for (Trazo t : tf) {
        t.mover();
      }
      for (Trazo t : ts) {
        t.mover();
      }
      for (Linea l : ls) {
        l.mover();
      }
    }
  } 
  if (hayRuido && brillo > UMBRAL_BRILLO) { // --- Si se detecta un sonido con un brillo > 900, se actualiza la dirección y velocidad de los trazos/garabatos
    for (Trazo t : ts) {
      t.actualizarDireccion(radians(random(360)), random(1, 10));
    }
    for (Trazo t : tf) {
      t.actualizarDireccion(radians(random(360)), random(1, 10));
    }
    for (Linea l : ls) {
      l.actualizarDireccion(radians(random(360)), random(1, 10));
    }
    // --- Cambian los valores que pasamos como parámetro al pitchtinte
    minTinte = random(50, 160);
    maxTinte = random(160, 255);
    // --- Cambio el estado de la boolean "seMuestran" para mostrar/ocultar las animaciones
    seMuestran = !seMuestran;
    if (!seMuestran) { // --- Si el estado es falso, inicializo nuevamente para cambiar la pos. y los colores de las animaciones
      inicializarAnimaciones();
    }
  }

  for (Trazo t : ts) {
    t.dibujar(capatrazos);
  }
  for (Linea l : ls) {
    l.dibujar(capatrazos);
  }

  capatrazos.endDraw();

  // ---- Acá ponemos límites para que comiencen a borrarse trazos > un máximo para que no quede sobrecargado.
  if (ts.size() > 18) {
    if (tf.size() > 0) {
      tf.remove(0);
    }
  }
  if (ts.size () > 22) {
    ts.remove(0);
  }
  if (ls.size() > 10) {
    ls.remove(0);
  }
  antesHabiaSonido = haySonido;

  image(trazosfondo, 0, 0);
  image(capatrazos, 0, 0);
}

void oscEvent( OscMessage m) {
  if (m.addrPattern().equals("/amp")) {
    amp = m.get(0).floatValue();
  }
  if (m.addrPattern().equals("/pitch")) {
    pitch = m.get(0).floatValue();
  }
  if (m.addrPattern().equals("/ruido")) {
    ruido = m.get(0).intValue();
  }
  if (m.addrPattern().equals("/brillo")) {
    brillo = m.get(0).floatValue();
  }
}

void inicializar() { 
  // ---- Inicialización de objetos osc y gestorSenial
  osc = new OscP5(this, 12345);
  gPitch = new GestorSenial(MIN_PITCH, MAX_PITCH, amortiguacion);
  gAmp = new GestorSenial(MIN_AMP, MAX_AMP, amortiguacion);

  // ---- Inicializar paleta y trazos
  selectorPaleta = floor(random(0, 4));
  p = new Paleta("paleta_0" + selectorPaleta + ".png");
  ptrazos = new Paleta("paletatrazos_0" + selectorPaleta + ".png");

  ts = new ArrayList<Trazo>();
  tf = new ArrayList<Trazo>();
  ls = new ArrayList<Linea>();

  minTinte = 50;
  maxTinte = 255;

  // ---- Inicializar PGraphics
  capatrazos = createGraphics(width, height);
  trazosfondo = createGraphics(width, height);

  estado = "interaccion";

  // ---- Fondo
  for (int i = 0; i < 20; i++) {
    tf.add(new Trazo(p, random(width), random(height), floor(random(60, 160)), int(random(19)), random(1, 1.3), random(1, 10), random(-1.4, 1.5)));
  }
  imgfondo = loadImage("fondo.png");
  contador = 0;
}

void inicializarAnimaciones() {
  a1 = new Animacion(ptrazos, random(50, width-100), random(50, height-100), 18, "aa");
  a2 = new Animacion(ptrazos, random(50, width-100), random(50, height-100), 20, "ab");
  a3 = new Animacion(ptrazos, random(50, width-100), random(50, height-100), 21, "ac");
  a4 = new Animacion(ptrazos, random(50, width-100), random(50, height-100), 32, "ad");
  a5 = new Animacion(ptrazos, random(50, width-100), random(50, height-100), 40, "ae");
}
