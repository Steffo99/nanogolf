# Architettura di rete di Nanogolf

## [`Main`](../scenes/main.gd)

Il `Node` `Main`  è alla radice di ogni istanza del gioco, e si occupa di inizializzare e deinizializzare i nodi relativi al contesto attuale in cui si trova il gioco:

- all'avvio, esso inizializza l'interfaccia grafica `MainMenu`, e attende che essa emetta con uno dei due segnali `connecting_confirmed` (l'utente ha richiesto di connettersi a un dato server) o `hosting_confirmed` (l'utente ha richiesto di voler aprire un server);
- alla richiesta di connessione, sostituisce `MainMenu` con `LobbyMenu`, e crea un'istanza di `Game` chiamata "Client", configurandovi uno `SceneMultiplayer` separato e un relativo `ENetMultiplayerPeer` che si connetta al server richiesto;
- alla richiesta di apertura server, sostituisce allo stesso modo `MainMenu` con `LobbyMenu` e crea allo stesso modo "Client", ma la configura per connettersi sempre al server locale `127.0.0.1`, e inoltre crea una ulteriore istanza di `Game` chiamata "Server" con un proprio `SceneMultiplayer` ed `ENetMultiplayerPeer` che accetti connessioni in arrivo sulla porta UDP `12345`;
- all'inizio effettivo della partita, sostituisce `LobbyMenu` con `GameHUD`, che mostra al giocatore lo stato attuale della partita, e vi connette alcuni segnali di "Client";
- al termine della partita, o quando "Client" segnala che è stata persa o chiusa la connessione al server, riporta il giocatore al `MainMenu`.

> Per via di un bug in Godot Engine, attualmente la chiusura imprevista del server causa un crash senza log di errore in tutti i client connessi.

![](img/main.png)

## [`Game`](../scenes/game.gd)

Il `Node` `Game` viene collocato sempre come figlio di `Main`, e rappresenta lo stato di gioco di un peer, che esso sia un server o un client.

Il server ha sempre autorità su di esso, e:

- gestisce connessioni e disconnessioni dei client, utilizzando la sua `PeerNodeDirectory` per mantenerne un indice composto da sottonodi di tipo `PeerNode` e aventi come nome l'identificatore del peer;
- quando un `PeerNode` connesso si identifica con il proprio nome, utilizza la sua `PlayerNodeDirectory` per controllare se è già connesso un giocatore con quel nome, creando un nuovo `PlayerNode` con quel nome se non esiste e dandone il controllo al relativo peer, oppure rimuovendo il controllo al precedente peer per darlo a quello nuovo nel caso esista già;
- quando un `PeerNode` identificato si disconnette, ridà il controllo del relativo `PlayerNode` al server;
- quando il giocatore host richiede attraverso l'interfaccia grafica di iniziare la partita, usa il `PhaseTracker` per cambiare ovunque la fase della partita da `LOBBY` a `PLAYING`, e richiede al `LevelManager` di istanziare il primo livello;
- quando il `LevelManager` segnala che la `LevelPlaylist` selezionata è esaurita, usa il `PhaseTracker` per aggiornare la fase della partita da `PLAYING` a `ENDED`.

## [`PeerNodeDirectory`](../scenes/peernode_directory.gd)

## [`PeerNode`](../scenes/peernode.gd)

## [`PlayerNodeDirectory`](../scenes/playernode_directory.gd)

## [`PlayerNode`](../scenes/playernode.gd)

## [`PhaseTracker`](../scenes/phase_tracker.gd)

## [`LevelPlaylist`](../scenes/level_playlist.gd)

## [`LevelManager`](../scenes/level_manager.gd)

## [`GolfLevel`](../scenes/golf_level.gd)

## [`GolfTee`](../scenes/golf_tee.gd)

## [`GolfBall`](../scenes/golf_ball.gd)

## [`PuttController`](../scenes/putt_controller.gd)
