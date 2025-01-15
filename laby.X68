*-----------------------------------------------------------
* Title      : Projet labyrinth
* Written by : Théo Lepin & Mael Lecene
* Date       : 2023-2024
* Description:
*-----------------------------------------------------------

    ORG    $400 ;adresse du programme
    
    * CREE LA FENETRE
    MOVE #1440, D1
    SWAP D1
    MOVE #1080, D1
    JSR RESOLUTION
    
    ;AFFICHE LES REGLES
    MOVE.L  #chainerules, A2
    JSR affchaine
    JSR SAISCAR

    JSR effacage
    ; remet l'affiche en haut a gauche
    MOVE.L    #0, D1
    JSR POS_CURS
    
    ; temps au debut du prog
    JSR GET_TIME
    MOVE.L D1, Time
    
START:
    ; le jeu a 3 lv donc regarde si on est au dernier 
    CMP #4, niveau
    BEQ Finprog
          
    MOVE lg, lg2
    MOVE h, h2
    
    ; -2 pour les bords (espace jouable)
    ADD #-2, lg2
    ADD #-2, h2
    
    ; -1 pour la struct(espace total du laby)
    MOVE lg, lg1
    MOVE h, h1
    ADD #-1, lg1
    ADD #-1, h1
    
    JSR create  ;remplie le laby aléatoirement
    
    * init la couleur du stylo a noir
    MOVE.L #$000000FF, D1
    JSR SET_PEN_COLOR
        
    
    ; positionne en bas a doite (position de depart)
    MOVE lg2, D7
    SWAP D7
    MOVE h2, D7
    SWAP D7 
    
    ; init les registres
    MOVE.L D7, D6
    JSR GET_TIME
    MOVE.L #0,D2
    MOVE D1, D2
    MOVE nRand, D3
    
    ; casser la case de depart 
    JSR casser
    
    ;   parcour le lab et ce dirige aleatoirement pour cree le chemin
    JSR chemin    
    
    
    ; affichage de la case win
    MOVE PX,D1
    MOVE PY,D2
    MULU D6,D1
    SWAP D6
    MULU D6,D2
    SWAP D6
    MOVE D1,D3
    MOVE D2,D4
    ADD PX,D3
    ADD PY,D4
    JSR DRAW_LINE
    MOVE D1,D3
    ADD  PX,D1
    JSR DRAW_LINE 

    
    * init la couleur du stylo a bleu
    MOVE.L #$00FF0000, D1
    JSR SET_PEN_COLOR
    
    
    MOVE.L #T, A0   ;charge l'adresse de la mat dans A0
    
    ; I et J sont des conteurs
    MOVE I ,D5
    SWAP D5
    MOVE J, D5

; parcour la mat (lignes)
WHILE1: SWAP D5
        CMP h1, D5
        BEQ FIN1
        ADD   #1, D5
        SWAP D5
        MOVE  #0, D5
        
; parcour la mat (colonnes)
WHILE2: CMP lg, D5
        BEQ WHILE1
        
        CMP.B #1, (A0)
        BEQ AFF1    ; (mur verticaux)
        
        CMP.B #2, (A0)
        BEQ AFF2    ;(mur horizontaux)
        
FINSI:
        ADD.L #1, A0 
        ADD #1, D5
        BRA WHILE2
        

FIN1:

    ; met en noir la couleur de remplissage et de dessin
    MOVE.L #$000000FF, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    
        
;boucle du jeux
while_jeu:
    ; raz de la chaine pour enlever les dizaine/centaines non voulu
    MOVE.L #chainecoup, A3
    MOVE.B #48, (A3)+
    MOVE.B #48, (A3)+
    MOVE.B #48, (A3)
    
    ; afficher le nb de coups
    ADD  #1, coup
    MOVE coupmax, D0
    SUB coup, D0
    MOVE #chaineaffcoup, A2
    MOVE #chainecoup, A3
    JSR conv
    MOVE #chaineaffcoup, A2
    MOVE #chainecoup, A3
    ADD #10, A2
    ADD #2, A3
    MOVE.B (A3), (A2)+
    MOVE.B -(A3), (A2)+
    MOVE.B -(A3), (A2)
    MOVE #chaineaffcoup, A2
    JSR affchaine
    
    CMP.L D6,D7     ; cmp pose de victoire avec la courante
    BEQ fin_jeu     ; passer au prochain lv
    
    MOVE coupmax, D0    ; test si il reste des coups
    CMP coup, D0        ; defaite quitte le jeu
    BEQ Finprog

  
    JSR AFFPOS  
    JSR SAISCAR ; attend que l'on entre une commande (z q s d )
    
    ; comparer les codes ascii
    CMP.B #$7A,D1
    BEQ up
    
    CMP.B #$73,D1
    BEQ down
    
    CMP.B #$71,D1
    BEQ left
    
    CMP.B #$64,D1
    BEQ right
    
    
    BRA while_jeu
    
fin_jeu:
    ;Variable pour le prochain niveau
    MOVE h, D0
    MULU #2,D0
    MOVE D0, h
    MOVE lg, D0
    MULU #2,D0
    MOVE D0, lg
    MOVE PX, D0
    DIVU #2,D0
    MOVE D0, PX
    MOVE PY, D0
    DIVU #2,D0
    MOVE D0, PY
    
    MOVE nRand, D0
    MULU #2,D0
    MOVE D0, nRand
    
    ADD #2, nbmove 
    
    ADD  #1,niveau
    
    MOVE coupmax, D0
    MULU #4, D0
    MOVE D0, coupmax
    MOVE #-1, coup
    
    JSR effacage
    
    BRA START
    

Finprog:
    
    CMP #4, niveau  ; test si on a win tout les lv
    BNE loosecase
    
wincase:
    JSR GET_TIME 
    SUB.L Time, D1 ; obtention du temps de jeu

    ;sec
    DIVU  #100, D1 
    MOVE D1, D0
    ;min
    DIVU #60, D0
    ; poid fort: sec et faible: minute
    
    MOVE #chainemin, A3
    JSR conv

    SWAP D0
    MOVE #chainesec, A3
    JSR conv
    
    MOVE #chainetime, A2
    MOVE #chainesec, A3
    ADD #38, A2     ; positionne pour ajouter les sec
    ADD #1, A3      ; recupere la fin de la chaine
    
    ;integre A3 dans A2
    MOVE.B (A3), (A2)+ 
    MOVE.B -(A3), (A2)  
    
    MOVE #chainetime, A2    
    MOVE #chainemin, A3 
    ADD #35, A2      ; positionne pour ajouter les min
    ADD #1, A3      ; recupere la fin de la chaine
    
    ;integre A3 dans A2
    MOVE.B (A3), (A2)+
    MOVE.B -(A3), (A2)
   
    
    MOVE #chainetime, A2 ; prepare la chaine a l'affichage
    BRA finleave
    
loosecase:
    JSR effacage
    MOVE    #chainelose, A2    ; prepare la chaine a l'affichage

    
 
finleave:
    ; prepare l'affichage avec draw_string
    MOVE.L  A2, A1
    MOVE    #600, D1
    MOVE    #540, D2
    JSR DRAW_STRING
    
    JMP FINPRG
    

; efface tout    
effacage:
    
    MOVE.L #$00000000, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
     
    MOVE #0, D1
    MOVE #0, D2
    MOVE #1440, D3
    MOVE #1080, D4
    JSR DRAW_FILL_RECT
    
    RTS


; boucle d'affichage d'une chaine contenue dans A2
affchaine:

    CMP.B #0, (A2)
    BEQ finaffchaine
    MOVE.B (A2)+, D1
    JSR AFFCAR
    BRA affchaine
    
finaffchaine:
    RTS
   
 
; convertie de pour un affichage en decimal
conv:
    MOVE    D0,D2
    DIVU    #10,D2
    MOVE.L  D2,D3
    SWAP    D3
    MOVE    D2,D0
    MOVE.L  #0,D2
    MOVE.B  D3,D1
    ADD.B   #48,D1 
    MOVE.B  D1,(A3)+
    CMP     #0,D0
    BNE     conv
finconv

    RTS


; deplacement vers le haut
up:
    JSR CALPOS2
    ADD #10,D1
    JSR GET_PIX_COLOR
    CMP.L  #$00FF0000,D0
    BEQ     while_jeu
    
    MOVE.L #$00000000, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    JSR AFFPOS
    MOVE.L #$000000FF, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    SWAP    D7
    ADD     #-1,D7
    SWAP    D7
    
    BRA     while_jeu
    
; deplacement vers le bas  
DOWN:
    JSR CALPOS2
    ADD #10,D1
    ADD PY,D2
    JSR GET_PIX_COLOR
    CMP.L  #$00FF0000, D0
    BEQ     while_jeu
    
    MOVE.L #$00000000, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    JSR AFFPOS
    MOVE.L #$000000FF, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    SWAP    D7
    ADD     #1,D7
    SWAP    D7

    BRA     while_jeu
    
    
; deplacement vers la gauche    
LEFT:
    JSR CALPOS2
    ADD #10,D2
    JSR GET_PIX_COLOR
    CMP.L  #$00FF0000, D0
    BEQ     while_jeu
    
    MOVE.L #$00000000, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    JSR AFFPOS
    MOVE.L #$000000FF, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    ADD     #-1,D7
   
    BRA     while_jeu


; deplacement vers la droite 
RIGHT:
    JSR CALPOS2
    ADD PX, D1
    ADD #10,D2
    JSR GET_PIX_COLOR
    CMP.L  #$00FF0000, D0
    BEQ     while_jeu
    
    MOVE.L #$00000000, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    JSR AFFPOS
    MOVE.L #$000000FF, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    ADD     #1,D7

    BRA     while_jeu


; affiche les murs verticaux
AFF1: 
    JSR CALPOS
    MOVE.L #0, D0
    MOVE lg, D0
    DIVU #2, D0 
    
    CMP D5, D0 ; test si on est dans la moitier gacuhe ou droite
    BLT IG1
    
    ADD PX, D1 ; si on est a  gauche aligne le mur a droite
    
IG1:
    MOVE D1, D3
    MOVE D2, D4
    ADD PY, D4
    
    JSR DRAW_LINE
    BRA FINSI
    

; affiche les murs horizontaux    
AFF2:
    JSR CALPOS
    MOVE.L #0, D0
    MOVE h, D0
    DIVU #2, D0
    
    SWAP D5
    CMP D5, D0 ; test si on est dans la moitier haute ou base

    BLT IB1
    
    ADD PY, D2  ; si on est en haut aligne le mur en bas

    
    
IB1:
    SWAP D5
    MOVE D1, D3
    MOVE D2, D4
    ADD PX, D3
    
    JSR DRAW_LINE
    BRA FINSI


; conv la pos de memoire a pixel avec D5
CALPOS:
    
    MOVE    #0,D1
    MOVE    #0,D2
    MOVE    PX,D3
    MOVE    PY,D4
    MULU    D5, D3
    SWAP    D5
    MULU    D5, D4
    SWAP    D5
    ADD     D3,D1
    ADD     D4,D2
    RTS
    

 ; de la position en pixel on trace l'ellipse au centre la case
AFFPOS:
   
    JSR CALPOS2
    MOVE    PX,D3
    MOVE    PY,D4
    DIVU    #4,D3
    DIVU    #4,D4
    ADD     D3,D1
    ADD     D4,D2
    MULU    #2,D3
    MULU    #2,D4
    ADD     D1,D3
    ADD     D2,D4
    JSR     DRAW_FILL_ELLIPSE
    
    RTS
   
 
; conv la pos de memoire a pixel avec D7
CALPOS2:
   
    MOVE    #0,D1
    MOVE    #0,D2
    MOVE    PX,D3
    MOVE    PY,D4
    MULU    D7, D3
    SWAP    D7
    MULU    D7, D4
    SWAP    D7
    ADD     D3,D1
    ADD     D4,D2
    
    RTS
    



    INCLUDE 'random.x68'   ; notre bibliotheque qui contient les fonctions d'initialisation du laby aléatoire 
    INCLUDE 'BIBPERIPH.x68'
    INCLUDE 'BIBGRAPH.x68'
    INCLUDE 'BIBLIO.x68'
         

    ORG $1000
    
T:  DS.B 1600   ; declaratrion de la matrice du laby
         
I: DC -1    ; compteur pour l'affichage lignes
J: DC 0     ;compteur pour l'affichage colonnes


PY: DC 80   ; hauteur d'un mur vertical
PX: DC 144  ; longueur d'un mur horizontal

h: DC 10    ; hauteur du laby (lv 1)
lg: DC 10   ; longueur du laby (lv 1)

h2: DC 0    ; hauteur interne (sans les murs)
lg2: DC 0   ; longueur interne  (sans les murs)
h1: DC 0    ; hauteur reel 
lg1: DC 0   ; longueur reel

niveau: DC 1    ; niveau actuelle 
nbmove: DC 2    ; chance sur 8 de refaire le mouvement 
nRand: DC 9     ; nb de deplacement avant de poser la victoir (independent de nbmove)

Time: DS.L 1    ; temp au lancement du jeu

chainerules:
    DC.B 13
    DC.B 'REGLES: 1. Pour ce mouvoir appuyer sur (z q s d) ou (w a s d) selon la configurations du clavier'
    DC.B 13, 10
    DC.B '        2. Toute actions sur le clavier decremente le nombre de coup restant'
    DC.B 13, 10
    DC.B '        3. Atteignez la croix rouge'
    DC.B 13, 10
    DC.B '        4. Amusez-vous :)'
    DC.B 13, 10, 10
    DC.B 'Appuyer sur une touche pour commencer le temps sera lancé', 0

chainetime: DC.B 13,'vous avez gagné avec un temps de: 00:00',0
chainelose: DC.B 13,'vous avez perdu',0
chaineaffcoup: DC.B 13,'plus que 000 coup ',0
chaineaffend: DC.B 13,'Bravo vous avez fini le jeu',0

chainemin: DC.B 48,48
chainesec: DC.B 48,48
chainecoup: DC.B 48,48,48

coupmax: DC 17
coup:   DC -1   ; compteur de nb de coup 

      END    $400


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
