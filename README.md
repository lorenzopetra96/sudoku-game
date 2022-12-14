# Sudoku-Game

Progetto per l'esame di Architetture Distribuite per il Cloud dell'anno di corso 2021/2022. Laurea magistrale in Computer Science, curriculum in Cloud Computing.

## Introduzione

L'obiettivo del progetto è quello di implementare un gioco multiplayer basato sul Sudoku. 
Gli utenti, dopo aver effettuato l'accesso inserendo un nickname di lunghezza
compresa tra 3 e 7 lettere, accedono al tabellone sfide in cui possono generare una nuova partita
inserendo "@" insieme al codice partita oppure unirsi ad una delle partite disponibili presenti nel tabellone.

Alla creazione di una sfida, verrà presentato un sudoku da completare, la lista comandi e la lista
dei partecipanti con rispettivo punteggio. La partita inizierà non appena un secondo giocatore avrà effettuato
l'accesso. Una volta avviata la partita, ogni giocatore può abbandonare la partita o inserire un valore all'interno 
della board del sudoku. Per inserire un valore N nella cella (x,y) bisognerà digitare "xy-N". Se il valore inserito
è corretto e non presente fino a quel momento, il giocatore guadagnerà un punto, se già presente non guadagnerà punti,
se il valore è errato perderà un punto. Una volta completato il sudoku, verrà mostrato a video il vincitore con il rispettivo punteggio
e un countdown di secondi prima che ogni giocatore venga reindirizzato al tabellone sfide. La partita terminerà se il tabellone è completato
oppure il numero di giocatori rimasti sono pari a 1, in questo caso non ci sarà un vincitore e il giocatore verrà reindirizzato al tabellone sfide.

Un giocatore presente nel tabellone sfide può partecipare ad una delle partite disponibili mostrate a video inserendo 
">" insieme al codice partita. Una volta entrato a far parte di una partita non può partecipare ad altre sfide. Una volta abbandonata 
la sfida, può accedere ad altre sfide o crearne nuove. 

### Login
![login](https://user-images.githubusercontent.com/74552824/200955802-e4e01708-be1b-40ec-bc1e-60eed6e99525.png)

### Tabellone sfide
![tabellone sfide](https://user-images.githubusercontent.com/74552824/200955800-a1aacab5-62c3-4926-8c73-aa0da7d7c2c3.png)

### Sfida sudoku
![partita](https://user-images.githubusercontent.com/74552824/200955798-c82af045-b204-4437-9915-dc4f0437ff43.png)


### Termine sfida
![termine partita](https://user-images.githubusercontent.com/74552824/201118214-ca8fe4b3-3a88-4bc0-bf65-6ffa5a615665.png)



## Architettura


Il gioco si basa sulla connettività peer-to-peer e in particolare memorizza i suoi dati in una tabella hash distribuita. Il sistema è progettato per mantenere l'elenco dei giocatori connessi in una posizione corrispondente all'hash di una stringa. Lo stesso vale per la lista delle sfide e le singole sfide. 

All'aggiornamento di una delle sfide disponibili presenti nella lista di sfide, un messaggio verrà inviato in maniera diretta a tutti i giocatori connessi in modo tale da poter aggiornare la lista all'ultima versione e vedere, quindi, le nuove sfide, il numero di giocatori aggiornati o se una sfida è terminata. 

Una volta effettuato l'accesso ad una sfida, qualsiasi operazione, per cui c'è bisogno di un aggiornamento a tutti gli altri partecipanti, sarà seguita da due fasi: una prima fase in cui si aggiorna la singola sfida aggiornando la risorsa nella DHT all'ultima versione (recupera l'ultima versione della sfida, esegue l'operazione richiesta e aggiorna la sfida nel DHT); una seconda fase in cui viene mandata la sfida aggiornata a tutti i partecipanti della stessa con un messaggio diretto. Il motivo per cui è stata scelta questa strategia è dato dal fatto che potrebbe capitare che al termine di un'operazione di inserimento valore all'interno della sudoku board oppure abbandono partita da parte di un sfidante, un altro giocatore partecipi alla sfida. In questo modo, il giocatore vedrà l'ultima versione della partita con punteggi e board aggiornati. Lo stesso concetto viene utilizzato anche per l'aggiornamento della lista delle sfide disponibili. 



## Strumenti utilizzati


Il progetto è un applicativo Java sviluppato con TomP2P, libreria utilizzata per creare connessioni Peer-to-Peer e creare una rete DHT. 

Per la parte grafica è stata utilizzata Beryx, una libreria per creare console interattive tramite terminale.

Il progetto, inoltre, è stato testato tramite l'uso JUnit 5.

Infine l'intero progetto è gestito tramite Maven e, tramite un dockerfile, è possibile compilare ed eseguire l'applicazione in un container Docker. 

## Compilazione

Tramite un Dockerfile è possibile costruire un container con le librerie necessarie al funzionamento dell'applicativo. Per creare
tale container bisogna eseguire la seguente istruzione tramite terminale nel path della cartella del progetto con Docker avviato : 

```docker build --no-cache -t sudoku-game  .```

## Esecuzione

Una volta fatto ciò, prima di avviare il nodo master è possibile avviare il nodo master (MASTER-PEER) eseguendo la seguente istruzione:

```docker network create --subnet=172.20.0.0/16 network && docker run -i --net network --ip 172.20.128.0 -e MASTERIP="172.20.128.0" -e ID=0 --name MASTER-PEER sudoku-game```

Dopo il primo lancio, è possibile avviare il master peer con il seguente comando: 

```docker start -i MASTER-PEER```.

Una volta avviato il Master-peer è possibile avviare gli altri peer. Ognuno di essi dovrà collegarsi alla rete
tramite l'indirizzo IP del container utilizzando un nome e un valore dell'ID univoci eseguendo la seguente istruzione:

```docker run -i --net network -e MASTERIP="172.20.128.0" -e ID=X --name PEER-X sudoku-game```

dove "X" rappresenta il valore dell'ID del peer. 

Dopo il primo lancio è possibile avviare il peer con la seguente istruzione: 

```docker start -i PEER-X```

dove "X" rappresenta il valore dell'ID del peer.

## Problemi noti

- L'esecuzione del programma in un qualsiasi altro terminale che non sia implementato su Swing, presenterà un testo senza colori.
- Il refresh della sudoku board e del tabellone sfide sarà automatico se l'esecuzione del programma avviene in locale, altrimenti bisognerà seguire le indicazioni riportate a terminale nel messaggio di avviso di aggiornamento partita/e (cliccare Enter).
