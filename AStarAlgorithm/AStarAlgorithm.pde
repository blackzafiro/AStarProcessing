import java.util.LinkedList;
import java.util.Hashtable;
import java.util.PriorityQueue;

PFont fuente;               // Fuente para mostrar texto en pantalla
int tamanioMosaico = 70;    // Tamanio de cada mosaico cuadrado (en pixeles).
int columnas = 11;
int renglones = 10;

Mapa mapa;
boolean expande = false;    // Bandera para solicitar la expansión del siguiente nodo.
AStar algoritmo;

/** Configuracion inicial */
void setup(){
  size(columnas * tamanioMosaico, renglones * tamanioMosaico);
  background(50);
  fuente = createFont("Arial",12,true);
  textFont(fuente, 12);
  mapa = new Mapa(columnas, renglones);
  mapa.mundo[2][5].tipo = Tipo.OBSTACULO;
  mapa.mundo[2][6].tipo = Tipo.OBSTACULO;
  mapa.mundo[3][6].tipo = Tipo.OBSTACULO;
  mapa.mundo[4][6].tipo = Tipo.OBSTACULO;
  mapa.mundo[5][6].tipo = Tipo.OBSTACULO;
  mapa.mundo[6][6].tipo = Tipo.OBSTACULO;
  mapa.mundo[6][5].tipo = Tipo.OBSTACULO;
  
  algoritmo = new AStar();
  Mosaico estadoInicial = mapa.mundo[5][3];
  Mosaico estadoFinal = mapa.mundo[4][8];
  
  algoritmo.inicializa(estadoInicial, estadoFinal);
}

void draw(){
  if(expande) {
    algoritmo.expandeNodoSiguiente();
    expande = false;
  }
  // Pintar el mundo con sus cuadrículas
  Mosaico m;
  Situacion s;
  for(int i = 0; i < renglones; i++){
    for(int j = 0; j < columnas; j++){
      m = mapa.mundo[i][j];
      s = m.situacion;
      // Dibujar cuadro
      switch(s) {
        case SIN_VISITAR:
          stroke(0); fill(50); break;
        case EN_LISTA_CERRADA:
          stroke(0); fill(200,200,0); break;
        case EN_LISTA_ABIERTA:
          stroke(0); fill(0,200,200); break;
        case ACTUAL:
          stroke(0); fill(150,0,150); break;
        case EN_SOLUCION:
          stroke(255); fill(0,0,100); break;
        default:
          stroke(0); fill(0);
      }
      switch(m.tipo) {
        case OBSTACULO:
          stroke(0); fill(200); break;
        case ESTADO_INICIAL:
          stroke(0,200,0); fill(0,200,0); break;
        case ESTADO_FINAL:
          stroke(200,0,0); fill(200,0,0); break;
      }
      rect(j*tamanioMosaico, i*tamanioMosaico, tamanioMosaico, tamanioMosaico);
      // Escribir datos
      fill(0);
      switch(m.tipo){
        case ESTADO_INICIAL:
          text("h(n)=" + m.hn, j*tamanioMosaico+4, (i+1)*tamanioMosaico - 4);
          continue;
      }
      switch(s) {
        case EN_SOLUCION:
          fill(255);
        case ACTUAL:
        case EN_LISTA_ABIERTA:
        case EN_LISTA_CERRADA:
          text("f(n)=" + m.fn(), j*tamanioMosaico+4, i*tamanioMosaico + 15);
          text("g(n)=" + m.gn, j*tamanioMosaico+4, (i+1)*tamanioMosaico - 20);
          text("h(n)=" + m.hn, j*tamanioMosaico+4, (i+1)*tamanioMosaico - 4);
          ellipse((0.5 + j) * tamanioMosaico, (0.5 + i) * tamanioMosaico, 10, 10);
          line((0.5 + j) * tamanioMosaico, (0.5 + i) * tamanioMosaico,
               (0.5 + j) * tamanioMosaico + (m.padre.columna - m.columna) * 20,
               (0.5 + i) * tamanioMosaico + (m.padre.renglon - m.renglon) * 20);
          break;
      }
      
    }
  }
}

/** Indica que se desea expandir el siguiente nivel. */
void mouseClicked() {
  expande = true;
}

// --- Clase Mosaico
// Representa cada casilla del mundo, corresponde a un estado posible del agente.
class Mosaico{
  Situacion situacion = Situacion.SIN_VISITAR;
  Tipo tipo = Tipo.VACIO;
  int renglon, columna;  // Coordenadas de este mosaico
  int gn;                // Distancia que ha tomado llegar hasta aquí.
  int hn;                // Distancia estimada a la meta.
  Mosaico padre;         // Mosaico desde el cual se ha llegado.
  Mapa mapa;             // Referencia al mapa en el que se encuentra este mosaico.
  
  Mosaico(int renglon, int columna, Mapa mapa){
    this.renglon = renglon;
    this.columna = columna;
    this.mapa = mapa;
  }
  
  /** Devuelve el valor actual de fn. */
  int fn() {
    return gn + hn;
  }
  
  /** Calcula la distancia Manhattan a la meta. */
  void calculaHeuristica(Mosaico meta){
     hn = (Math.abs(meta.renglon - renglon) + Math.abs(meta.columna - columna)) * 10; 
  }
  
  /**
  * Devuelve una referencia al mosaico del mapa a donde se movería el agente
  * con la acción indicada.
  */
  Mosaico aplicaAccion(Accion a){
    Mosaico vecino;
    switch(a) {
      case MOVE_UP:
      if(renglon > 0) {
        vecino = mapa.mundo[renglon - 1][columna];
      } else return null;
      break;
      case MOVE_DOWN:
      if(renglon < mapa.renglones - 1) {
        vecino = mapa.mundo[renglon + 1][columna];
      } else return null;
      break;
      case MOVE_LEFT:
      if(columna > 0) {
        vecino = mapa.mundo[renglon][columna - 1];
      } else return null;
      break;
      case MOVE_RIGHT:
      if(columna < mapa.columnas - 1) {
        vecino = mapa.mundo[renglon][columna + 1];
      } else return null;
      break;
      case MOVE_NW:
      if(renglon > 0 && columna > 0) {
        vecino = mapa.mundo[renglon - 1][columna - 1];
      } else return null;
      break;
      case MOVE_NE:
      if(renglon < mapa.renglones - 1 && columna > 0) {
        vecino = mapa.mundo[renglon + 1][columna - 1];
      } else return null;
      break;
      case MOVE_SW:
      if(renglon > 0 && columna < mapa.columnas - 1) {
        vecino = mapa.mundo[renglon - 1][columna + 1];
      } else return null;
      break;
      case MOVE_SE:
      if(renglon < mapa.renglones - 1 && columna < mapa.columnas - 1) {
        vecino = mapa.mundo[renglon + 1][columna + 1];
      } else return null;
      break;
      default:
      throw new IllegalArgumentException("Acción inválida" + a);
    }
    if (vecino.tipo == Tipo.OBSTACULO) return null;
    else return vecino;
  }
}

// --- Clase Mapa
class Mapa {
  int columnas, renglones;
  Mosaico[][] mundo;
  
  Mapa(int columnas, int renglones) {
    this.columnas = columnas;
    this.renglones = renglones;
    mundo = new Mosaico[renglones][columnas];
    for(int i = 0; i < renglones; i++)
        for(int j = 0; j < columnas; j++)
          mundo[i][j] = new Mosaico(i, j, this);
  }
  
}

// --- Clase nodo de búsqueda
class NodoBusqueda implements Comparable<NodoBusqueda> {
  NodoBusqueda padre;  // Nodo que generó a este nodo.
  Accion accionPadre;  // Acción que llevó al agente a este nodo.
  Mosaico estado;      // Refencia al estado al que se llegó.
  int gn;              // Costo de llegar hasta este nodo.
  
  NodoBusqueda(Mosaico estado) {
    this.estado = estado; 
  }
  
  /** Asume que hn ya fue calculada. */
  int getFn() {
    return gn + estado.hn;
  }
  
  /** Calcula los nodos de búsqueda sucesores. */
  LinkedList<NodoBusqueda> getSucesores() {
      LinkedList<NodoBusqueda> sucesores = new LinkedList();
      Mosaico sucesor;
      NodoBusqueda nodoSucesor;
      for(Accion a : Accion.values()) {
          sucesor = estado.aplicaAccion(a);
          if(sucesor != null) {
              nodoSucesor = new NodoBusqueda(sucesor);
              nodoSucesor.gn = this.gn + a.costo();
              nodoSucesor.padre = this;
              nodoSucesor.accionPadre = a;
              sucesores.add(nodoSucesor);
          }
      }
      return sucesores;
  }
  
  int compareTo(NodoBusqueda nb){
    return getFn() - nb.getFn();
  }
  
  /** En la lista abierta se considera que dos nodos son iguales si se refieren al mismo estado. */
  boolean equals(Object o) {
    NodoBusqueda otro = (NodoBusqueda)o;
    return estado.equals(otro.estado);
  }
}

// --- A*
class AStar {
  private PriorityQueue<NodoBusqueda> listaAbierta;
  private Hashtable<Mosaico, Mosaico> listaCerrada;
  Mosaico estadoFinal;  // Referencia al mosaico meta.
  boolean resuelto;
  
  NodoBusqueda nodoActual;
  NodoBusqueda nodoPrevio;
  
  void inicializa(Mosaico estadoInicial, Mosaico estadoFinal) {
    this.estadoFinal = estadoFinal;
    listaAbierta = new PriorityQueue();
    listaCerrada = new Hashtable();
    estadoInicial.calculaHeuristica(estadoFinal);
    estadoInicial.tipo = Tipo.ESTADO_INICIAL;
    estadoFinal.tipo = Tipo.ESTADO_FINAL;
    
    nodoPrevio = new NodoBusqueda(estadoInicial);
    listaAbierta.offer(nodoPrevio);
  }
  
  void expandeNodoSiguiente() {
    if(resuelto) return;
    nodoActual = listaAbierta.poll();
    if(nodoActual != null) {
      listaCerrada.put(nodoActual.estado, nodoActual.estado);
      nodoPrevio.estado.situacion = Situacion.EN_LISTA_CERRADA;
      nodoActual.estado.situacion = Situacion.ACTUAL;
      nodoActual.estado.gn = nodoActual.gn;
      
      // Función objetivo
      if(nodoActual.estado.renglon == estadoFinal.renglon && 
         nodoActual.estado.columna == estadoFinal.columna) {
           resuelto = true;
           
           // Pintar la ruta elegida de otro color.
           NodoBusqueda temp = nodoActual.padre;
           while(temp.padre != null) {
             temp.estado.situacion = Situacion.EN_SOLUCION;
             temp = temp.padre;
           }
      }
      
      // Considerar sucesores.
      for(NodoBusqueda nodo : nodoActual.getSucesores()) {
        if (listaCerrada.containsValue(nodo.estado)) continue; // No revisitamos el nodo.
        if (listaAbierta.contains(nodo)) {
          // Si el nodo ya ha sido generado, pero aún no lo visitamos, aún podría tener un mejor padre.
          // Como la cola de prioridades de java no nos deja recuperar el nodo hay que buscarlo a mano.
          NodoBusqueda nodoPadrePrevio = null;
          Object[] openListArray = listaAbierta.toArray();
          for (int i = 0; i < openListArray.length; i++ ){
            if (nodo.equals(openListArray[i])) {
              nodoPadrePrevio = (NodoBusqueda)openListArray[i];
              break;
            }
          }
          if(nodoPadrePrevio.gn > nodo.gn) {
            // Removemos el nodo con el padre anterior y agregamos un nodo con el nuevo padre y la nueva distancia.
            listaAbierta.remove(nodoPadrePrevio);
            listaAbierta.offer(nodo);
            nodo.estado.gn = nodo.gn;
            nodo.estado.padre = nodo.padre.estado;
          }
        } else {
          nodo.estado.calculaHeuristica(estadoFinal);
          listaAbierta.add(nodo);
          nodo.estado.situacion = Situacion.EN_LISTA_ABIERTA;
          nodo.estado.gn = nodo.gn;
          nodo.estado.padre = nodo.padre.estado;
        }
      }
      nodoPrevio = nodoActual;
    }
  }
}
