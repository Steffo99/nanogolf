# Protocolli di networking in Godot

Il gioco pianificato è stato realizzato utilizzando l'[API ad alto livello per il networking] integrato in Godot Engine.

## API ad alto livello

Godot Engine integra nel suo linguaggio di scripting [GDScript] alcuni concetti che facilitano lo sviluppo di applicazioni networked utilizzando il paradigma degli **oggetti condivisi** (o meglio, nel caso di Godot, il paradigma dei *nodi* condivisi).

### Peer, server, client

Le istanze del gioco interconnesse sono chiamate da Godot Engine ***peer***, sia che esse siano ***server*** (e quindi in ascolto per connessioni su un socket), sia che esse siano ***client*** (e quindi che si connettono ad un server).

#### Creare un server

Per far aprire un socket a Godot, e metterlo in ascolto, è necessario istanziare in uno script la classe `ENetMultiplayerPeer`, e poi eseguirne il metodo `create_server`:

```gdscript
const PORT := 12345

func _ready():
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(PORT)
```

Dato che l'elaborazione dei pacchetti ricevuti viene effettuata sincronicamente ad ogni ricezione del segnale `process(delta)`, per fare in modo che Godot inizi a processare i pacchetti, è necessario assegnare l'oggetto `ENetMultiplayerPeer` creato alla proprietà `multiplayer_peer` del `MultiplayerAPI` che utilizza il gioco, a cui tutti i `Node` possiedono una referenza alla proprietà `multiplayer`:

```gdscript
	multiplayer.multiplayer_peer = peer
```

#### Creare un client

La procedura per creare un client e connettersi a un server è molto simile a quella per aprire un server, con la differenza che il metodo utilizzato in questo caso è `create_client`:

```gdscript
const ADDRESS := "127.0.0.1"
const PORT := 12345

func _ready():
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
```

### Separazione di client e server

È inoltre possibile avere simultaneamente più della singola istanza di `MultiplayerAPI` disponibile di default.

A tale scopo, si può usare il metodo `set_multiplayer` dell'albero dei nodi per specificare che un dato sottoalbero deve fare uso di un `MultiplayerAPI` (o di una classe che da esso eredita, come `SceneMultiplayer`) diverso:

```gdscript
func init_server(server_port: int):
	var smp: SceneMultiplayer = SceneMultiplayer.new()
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if peer.create_server(server_port) != OK or peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error(error)
		return
	scene_tree.set_multiplayer(smp, ^"/root/Main/Server")
	smp.multiplayer_peer = peer

func deinit_server():
	var smp = ...
	smp.multiplayer_peer = null
	scene_tree.set_multiplayer(null, ^"/root/Main/Server")
```

Le parti esterne a questi sottoalberi, come il nodo {`Main`}, non sono networked, e sono gestite separatamente da ciascuna istanza dell'applicazione.

## Remote procedure calls

All'interno degli script è possibile taggare alcuni metodi con `@rpc`, nel seguente modo:

```gdscript
var one = 0

@rpc
func add_one():
	one += 1
```

L'esecuzione dei metodi così taggati può essere richiesta dagli altri peer connessi all'istanza del `MultiplayerAPI` del sottoalbero locale.

Diventa quindi possibile chiamare la funzione in tre modi diversi:

- `add_one()`, esegue la funzione solamente sull'istanza locale
- `add_one.rpc()`, richiede l'esecuzione della funzione su tutti gli altri client remoti
- `add_one.rpc_id(ID)`, esegue la funzione solamente sull'istanza remota avente l'identificatore univoco specificato

### Oggetto di esecuzione

Le remote procedure calls vengono effettuate sui nodi remoti che si trovano alla stessa posizione nel sottoalbero del `MultiplayerAPI` del nodo chiamante.

Ad esempio, assumendo che due `SceneMultiplayer` connessi tra loro si trovino a `/root/Server` e `/root/Client`, chiamare `add_one.rpc_id(1)` su un nodo a `/root/Client/Counter` eseguirà la funzione `add_one` sul nodo `/root/Server/Counter`.

### Argomenti

Le remote procedure calls possono avere argomenti specificati come in una normale funzione:

```gdscript
var one = 0

@rpc
func add(val: int):
	one += val

func add_one_rpc():
	add.rpc(1)
```

Essendo però GDScript un linguaggio interamente dinamico, la deserializzazione di oggetti inviati da remoto sarebbe un rischio per la sicurezza, in quanto darebbe la possibilità agli altri peer di eseguire codice arbitrario, quindi essa non è permessa, ed è invece possibile serializzare solamente tipi primitivi, come `int`, `float`, `String` o `Vector2`.

### Modalità, permessi e autorità

È possibile specificare nel tag `@rpc` la ***modalità*** di esecuzione della RPC, in modo da restringere quali client possono eseguire remotamente la funzione:

```gdscript
var one = 0

@rpc("authority")
func add_one():
	one += 1
```

Le modalità attualmente disponibili sono:

- `any_peer`, che permette a qualsiasi altro peer di eseguire la funzione;
- `authority`, che permette di eseguire la funzione solamente al peer con l'identificatore indicato dalla proprietà `multiplayer_authority` del `Node`.

### Sincronizzazione remota e locale

È inoltre possibile specificare nel tag `@rpc` la ***sincronizzazione*** della chiamata, specificando su quali peer questa verrà eseguita se chiamata con `.rpc()`:

```gdscript
var one = 0

@rpc("call_local")
func add_one():
	one += 1
```

Le sincronizzazioni attualmente disponibili sono:

- `call_remote`, che esegue la funzione su tutti i peer *eccetto* quello locale
- `call_local`, che esegue la funzione su tutti i peer *incluso* quello locale

### Canale di trasferimento

Infine, è possibile specificare nel tag `@rpc` il ***canale di trasferimento*** che deve essere utilizzato per inviare la richiesta:

```gdscript
var one = 0

@rpc("reliable")
func add_one():
	one += 1
```

I canali di trasferimento attualmente disponibili sono:

- `unreliable`, che invia le richieste direttamente tramite UDP, non rilevando se esse vengono perse;
- `unreliable_ordered`, che aggiunge un contatore ad ogni pacchetto inviato tramite UDP, facendo in modo che i peer possano ignorare i pacchetti arrivati nell'ordine sbagliato;
- `reliable`, che implementa un protocollo di acknowledgement su UDP molto simile a quello utilizzato da TCP, a costo di una latenza significativamente maggiore.

> Dove non specificato, in questa relazione si assume che una RPC descritta usi sempre il canale `reliable`.

## Nodi di sincronizzazione

Godot mette a disposizione dei `Node` speciali per assistere con la sincronizzazione dello stato del gioco tra tutti i peer.

Essi sono:

- `MultiplayerSpawner`, che utilizza il canale `reliable` per automaticamente istanziare tutte le scene che la sua `multiplayer_authority` vi aggiunge come figli;
- `MultiplayerSynchronizer`, che permette di selezionare un canale e alcune proprietà del nodo genitore per automaticamente replicare sugli altri client ad ogni `process` o `physics_process` il valore che esse hanno sulla `multiplayer_authority`.



[API ad alto livello per il networking]: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
[GDScript]: https://docs.godotengine.org/en/4.2/tutorials/scripting/gdscript/index.html