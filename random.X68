*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

chemin:  
    CMP #0, D3
    BEQ finchem
    
    JSR rand
    ADD #-1, D3
    BRA chemin
finchem:
    RTS

rands:
    SWAP D6
    
rand:
    JSR suite
    MOVE.L #0, D1
    MOVE D2,  D1
    DIVU #8, D1
    SWAP D1
    
    CMP #3, D1
    BLT goup
    
    CMP #6, D1
    BLT goleft

    CMP #6, D1
    BEQ goright
    
    CMP #7, D1
    BEQ godown
    
FINRANDS:
    SWAP D6
   
FINRAND:
    RTS
    
goup:
    SWAP D6
    
goup2:

    CMP #1, D6
    BEQ rands
   
    ADD #-1, D6
    SWAP D6
    JSR casser
    SWAP D6
    
    JSR suite
    MOVE.L #0, D1
    MOVE D2,  D1
    DIVU #8, D1
    SWAP D1

    CMP nbmove, D1
    BLT goup2
    
    BRA FINRANDS

godown:
    SWAP D6
godown2:
    CMP h2, D6
    BEQ rands
    
    ADD #1, D6
    
    SWAP D6
    JSR casser
    SWAP D6

    JSR suite
    MOVE.L #0, D1
    MOVE D2,  D1
    DIVU #8, D1
    SWAP D1
    CMP nbmove, D1
    BLT godown2

    BRA FINRANDS

goleft:
    CMP #1, D6
    BEQ rand
    
    ADD #-1, D6
    JSR casser
    
    JSR suite
    MOVE.L #0, D1
    MOVE D2,  D1
    DIVU #8, D1
    SWAP D1
    CMP nbmove, D1
    BLT goleft

    BRA FINRAND 
    
goright:
    CMP lg2, D6
    BEQ rand
    
    ADD #1, D6
    JSR casser
    
    JSR suite
    MOVE.L #0, D1
    MOVE D2,  D1
    DIVU #8, D1
    SWAP D1
    CMP nbmove, D1
    BLT goright

    BRA FINRAND
    
    
suite:
    MULU #91,D2
    DIVU #32767,D2
    SWAP D2
    RTS
   

casser:
    MOVE.L #T ,A1
    MOVE.L #0, D0
    
    ; convertie la pos en pos linéaire
    MOVE D6, D0
    ADD.L D0, A1
    SWAP D6
    MOVE D6, D0
    SWAP D6
    MULU lg, D0
    ADD D0, A1  ;place a cette case memoire equivalent 
    
    MOVE.B #0, (A1)
    
    RTS 


create:
    MOVE.L #T, A0
    MOVE I ,D5
    SWAP D5
    MOVE J, D5
    JSR GET_TIME
    MOVE.L D1, D2
    
WHILEcreate1: 
        SWAP D5
        CMP h1, D5
        BEQ FINcreate1
        ADD   #1, D5
        SWAP D5
        MOVE  #0, D5
        
WHILEcreate2: 
        CMP lg, D5
        BEQ WHILEcreate1
        SWAP D5
        CMP #0, D5 
        BEQ HORIZONTAL
        
        CMP h1, D5
        BEQ HORIZONTAL
        
        SWAP D5
        
        CMP lg1, D5
        BEQ VERTICAL
        
        CMP #0, D5
        BEQ VERTICAL


        JSR suite
        MOVE.L #0, D1
        MOVE D2, D1
        DIVU #2, D1
        SWAP D1
        ADD #1, D1
        MOVE.B D1, (A0)
        
             
FINSIcreate:
        ADD.L #1, A0 
        ADD #1, D5
        BRA WHILEcreate2
        

FINcreate1:
    RTS
    
    
COIN:
    MOVE.B #0, (A0)
    bra FINSIcreate


HORIZONTAL:
    SWAP D5
    CMP #0, D5
    BEQ COIN
    
    CMP lg1, D5
    BEQ COIN
    
    MOVE.B #2, (A0)
    bra FINSIcreate     


VERTICAL:
    MOVE.B #1, (A0)
    bra FINSIcreate





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
