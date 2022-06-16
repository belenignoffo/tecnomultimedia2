
class Paleta {

  PImage imagen;
  color [] colorPaleta; 
  
  Paleta(String nombre) { 
    imagen = loadImage( nombre );
  }

  color darUnColor() {
    int x = int( random( imagen.width ) );
    int y = int( random( imagen.height ) );
    return imagen.get( x, y );
  }

}
