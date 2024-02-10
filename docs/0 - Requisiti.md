# Requisiti

Si intende realizzare un piccolo gioco con [Godot Engine 4.2.1](https://godotengine.org/), utilizzando [le funzionalità di networking ad alto livello](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) che esso fornisce.

Il gioco sarà una versione digitale del [minigolf](https://en.wikipedia.org/wiki/Miniature_golf) vista dall'alto:
1. viene presentato un percorso su schermo, con un tee (partenza) e una buca (arrivo) 
2. inizialmente, ogni giocatore si trova la propria pallina posizionata sul tee
3. quando la rispettiva pallina è ferma, ciascun giocatore può effettuare un putt (applicare una quantità arbitraria di forza in una direzione scelta) alla propria pallina per guidarla verso la buca
4. arrivato alla buca, ciascun giocatore attende che tutti gli altri abbiano completato il percorso
5. quando tutti i giocatori hanno completato il percorso, si passerà a un percorso differente, ripetendo questa procedura dal passo 1
6. al completamento di tutti i percorsi disponibili nell'applicazione, sarà mostrato il numero totale di putt effettuati da ciascun giocatore
7. il giocatore che ha effettuato meno putt vince

Le partite saranno organizzate a stanze, seguendo il modello client-server:
1. un giocatore sceglie di creare una stanza
2. l'applicazione avvia il server in background
3. l'applicazione crea un client per il creatore della stanza
4. l'applicazione connette automaticamente il client al server avviato
5. il creatore della stanza comunica il suo indirizzo IP agli altri giocatori
6. gli altri giocatori scelgono di entrare in una stanza e inseriscono l'indirizzo IP del creatore
7. l'applicazione di ciascun giocatore crea un client per ognuno e lo connette al server
8. la partita inizia

Si rende infine noto che:
- le palline dei giocatori dovranno essere sempre visibili, anche mentre sono in movimento
	- non è necessario che il putt venga riprodotto con precisione perfetta sui client che non l'hanno effettuato
	- si preferisce che la posizione delle palline sia aggiornata con latenza minima
- i percorsi saranno predeterminati
	- si potrebbe considerare di strutturare il codice in modo tale che i percorsi vengano distribuiti a runtime dal server ai client, in modo da permettere una futura estensione che permetta ai giocatori di creare e giocare percorsi personalizzati
- si assume che il giocatore che crea la stanza sia direttamente raggiungibile da Internet
	- non è necessario implementare meccanismi a livello applicazione per effettuare NAT traversal
