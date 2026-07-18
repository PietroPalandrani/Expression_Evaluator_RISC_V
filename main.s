.data
menoTrecentoVentiQuattro: .string "((1+2)*(3*2))-(1+(1024/3))"
sette: .string "1+(1+(1+(1+(1+(1+(1+0))))))"
menoDuemilaQuarantotto: .string "((00000-2)*(1024+1024)) / 2"
ofMul: .string "2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(1024*1024)))))))))))"
due: .string "2147483647+0"
ofSum: .string "2147483647+1"
dueSub: .string "(0-2147483647)-1"
ofSub: .string "(0-2147483647)-2"
erroreParentesi: .string "32+(7-(2+3)"

#ERRORI
errore_overflow_div: .string "overflow divisione"
divisione0: .string "stai cercando di dividere per 0"
errore_overflow_mul: .string "overflow causato da moltiplicazione"
errore_not_digit: .string "la stringa inserita non è una cifra"
errore_stringa: .string "la stringa inserita non è corretta"
of_sub: .string "overflow causato da una sottrazione"
of_sum: .string "overflow causato da una somma"
errore_parentesi_stringa: .string "una o più parentesi non sono chiuse o non sono state aperte"

.text # t0 byte, a1 stringa, t1 counter
main:
    li s0 1 # s0 = 1
    li s1 2 # carico 2 in s1
    li s2 48 # carico 48, 0 in ASCII
    li s3 58 # carico 58, il valore successivo a 9 in ASCII
    li s4 32 # carico 32, lo spazio in ASCII
    li s5 40 # carico 40, "(" in ASCII
    li s6 41 # carico 41, ")" in ASCII
    li s7 42 # carico 42, "*" in ASCII
    li s8 43 # carico 43, "+" in ASCII
    li s9 45 # carico 45, "-" in ASCII
    li s10 47 # carico 47, "/" in ASCII
    la a1 erroreParentesi # carico la stringa in a1
    j eval
    
eval:
    lb t0 0(a1) # carico il carattere puntato da a1 in t0
    beqz t0 pop # se t0 è 0, termina
    beq t0 s4 passo # se t0 è spazio, salto
    beq t0 s5 parentesi_aperta # se t0 è "(", salto
    beq t0 s6 pop # se t0 è ")", estraggo gli ultimi tre elementi e svolgo il calcolo
    blt t0 s2 not_digit_eval # se t0 < 48, non è un numero
    bge t0 s3 not_digit_eval # se t0 >= 58, non è un numero
    jal string_2_int # altrimenti converto il numero in intero
    j char_successivo

    not_digit_eval:
        beq t0 s7 carica_operatore # se è un operatore, lo carico nello stack
        beq t0 s8 carica_operatore
        beq t0 s9 carica_operatore
        beq t0 s10 carica_operatore
        la a0 errore_stringa
        li a7 4
        ecall
        j fine_main

    carica_operatore:
        mv a0 t0
        addi a1 a1 1 # passo al char successivo
        j char_successivo

    parentesi_aperta:
        addi a6 a6 1 # segnalo parentesi aperta
        j passo

    passo:
        addi a1 a1 1 # passo al char successivo
        j eval

    char_successivo:
        addi sp sp -4
        sw a0 0(sp) # salvo il numero/operatore nello stack
        j eval

    pop:
        addi a6 a6 -1 # segnalo parentesi chiusa
        addi a1 a1 1
        mv a3 a1
        lw a2 0(sp) # carico il secondo operando
        addi sp sp 4
        lw a0 0(sp) # carico l'operatore
        addi sp sp 4
        lw a1 0(sp) # carico il primo operando
        addi sp sp 4
        beq a0 s7 eval_mul # se l'operatore è *, salto
        beq a0 s8 eval_sum # se l'operatore è +, salto
        beq a0 s9 eval_sub # se l'operatore è -, salto
        beq a0 s10 eval_div # se l'operatore è /, salto
        addi a6 a6 2
        addi sp sp -12
        lw a0 0(sp)
        j check_parentesi

    check_parentesi:
        beqz a6 stampa
        j errore_parentesi

    check_fine_eval:
        mv a1 a3
        addi a1 a1 -1
        lb t0 0(a1)
        addi a1 a1 1
        beqz t0 op_finale
        ret

    op_finale:
        addi sp sp -4
        sw a0 0(sp)
        mv a1 a3
        j pop

    eval_mul:
        jal mul
        jal check_fine_eval
        addi sp sp -4
        sw a0 0(sp)
        j eval

    eval_div:
        jal div
        jal check_fine_eval
        addi sp sp -4
        sw a0 0(sp)
        mv a1 a3
        j eval

    eval_sum:
        add a0 a1 a2 # a0 = a1 + a2
        jal check_overflow_sum
        jal check_fine_eval
        addi sp sp -4
        sw a0 0(sp)
        mv a1 a3
        j eval

    check_overflow_sum:
        blt a0 a1  overflow_sum # se ris minore di operando overflow
        ret

    eval_sub:
        sub a0 a1 a2 # a0 = a1 - a2
        jal check_overflow_sub
        jal check_fine_eval
        addi sp sp -4
        sw a0 0(sp)
        mv a1 a3
        j eval

    check_overflow_sub:
        bge a0 a1 overflow_sub
        ret

string_2_int:
    addi sp sp -4
    sw ra 0(sp)
    li t1 0
    li a0 0 # inizializzo a0 a 0
    li a2 1 # carico 1, fattore di moltiplicazione, in a2
    li a5 0

    counter_loop:
        lb t0 0(a1) # carico il carattere puntato da a1 in t0
        beqz t0 fine_stringa # se t0 è 0, termino
        beq t0 s5 fine_stringa # se t0 è "(", termino
        beq t0 s6 fine_stringa # se t0 è ")", termino
        beq t0 s7 fine_stringa # se t0 è *, termino
        beq t0 s8 fine_stringa # se t0 è +, termino
        beq t0 s9 fine_stringa # se t0 è -, termino
        beq t0 s10 fine_stringa # se t0 è /, termino
        blt t0 s2 not_digit # se t0 < 48, non è un numero
        bge t0 s3 not_digit # se t0 >= 58, non è un numero
        addi t1 t1 1 # incremento il contatore
        addi a1 a1 1 # incremento il puntatore
        addi a5 a5 1
        j counter_loop # ripeto il ciclo

    fine_stringa:
        addi a1 a1 -1 # Torna all'ultimo carattere valido
        lb t0 0(a1)    # Leggi l'ultimo byte valido
        addi sp sp -16 # Riserva spazio sullo stack per 4 word

        sw t1 0(sp)    # Salva il counter
        sw a1 4(sp)    # Salva l'indirizzo dell'ultimo carattere valido
        sw a0 8(sp)    # Salva il risultato parziale
        sw a2 12(sp)   # Salva il fattore moltiplicativo

        addi t0 t0 -48 # Converte il carattere in un numero intero
        mv a1 t0        # Prepara a1 per la chiamata a 'mul'
        jal mul          # Chiama la funzione di moltiplicazione

        lw a2 12(sp)    # Recupera il fattore moltiplicativo
        mv t3 a0        # Salva il risultato della moltiplicazione in t3

        lw a0 8(sp)     # Recupera il risultato parziale
        add a0 a0 t3   # Aggiunge il risultato della moltiplicazione al risultato parziale
        sw a0 8(sp)

        li a1 10        # Imposta 10 in a1 per la prossima moltiplicazione del fattore
        jal mul          # Moltiplica il fattore moltiplicativo per 10
        mv a2 a0        # Aggiorna il fattore moltiplicativo in a2

        lw a0 8(sp)      # Recupera il risultato parziale
        lw a1 4(sp)     # Recupera l'indirizzo dell'ultimo carattere valido
        lw t1 0(sp)     # Recupera il counter
        sw a2 12(sp)     # Salva il fattore moltiplicativo
        addi sp sp 16  # Libera lo spazio sullo stack

        addi t1 t1 -1  # Decrementa il counter
        bnez t1 fine_stringa # Se il counter non è zero, ripeti il processo

        j fine_string_2_int # Se il counter è zero, procedi alla fine

    fine_string_2_int:
        addi a5 a5 -1
        add a1 a1 a5
        addi a1 a1 1
        lw ra 0(sp)
        addi sp sp 4
        ret

mul:
    addi sp sp -4
    sw ra 0(sp)
    addi sp sp -4
    sw a1 0(sp)
    li a0 0          # a0 = prodotto = 0
    li t0 0 # flag segno inizializzato a 0
    beqz a1 mol0     # se moltiplicando è 0 salta a mol0
    beqz a2 mol0     # se moltiplicatore è 0 salta a mol0
    beq a1 s0 moltiplicando1  # se moltiplicando è 1 salta a moltiplicando1
    beq a2 s0 moltiplicatore1 # se moltiplicatore è 1 salta a moltiplicatore1

    check_segno:
        bltz a1 moltiplicando_negativo # se moltiplicando è negativo salta a negativo
        bltz a2 moltiplicatore_negativo # se moltiplicatore è negativo salta a negativo
        j loop            # altrimenti esegui il ciclo

    moltiplicando_negativo:
        addi t0 t0 1
        neg a1 a1
        bltz a2 moltiplicatore_negativo # se moltiplicatore è negativo salta a negativo
        j loop

    moltiplicatore_negativo:
        addi t0 t0 1
        neg a2 a2
        j loop

    loop:
        beqz a2 check_fine     # se il moltiplicatore è 0 check_fine
        andi t1 a2 1    # controlla il bit meno significativo
        beq t1 s0 somma_moltiplicando # se il bit meno significativo è 1 somma
        j shift # altrimenti shifta

    somma_moltiplicando:
        add a0 a0 a1    # somma moltiplicando al prodotto

    shift:
        slli a1 a1 1    # shifta il moltiplicando a sinistra di 1 (equivale a moltiplicare per 2)
        srli a2 a2 1    # shifta il moltiplicatore a destra di 1 (equivale a dividere per 2)
        j loop            # ripeti il ciclo

    moltiplicando1:
        mv a0 a2         # se il moltiplicando è 1 il prodotto è uguale al moltiplicatore
        j check_fine

    moltiplicatore1:
        mv a0 a1         # se il moltiplicatore è 1 il prodotto è uguale al moltiplicando
        j check_fine

    mol0:
        li a0 0          # se uno dei due è 0 il prodotto è 0
        j check_fine

    check_fine:
        beqz t0 check_overflow # se t0 = 0 o 2 vai alla fine_mul
        beq t0 s1 check_overflow
        neg a0 a0 # altrimenti nega il risultato e vai alla fine_mul
        j check_overflow    

    check_overflow:
        bltz a0 check_ris_negativo
        j check_ris_positivo

    check_ris_negativo:
        beq t0 s0  fine_mul # se t0 = 1 ok
        j overflow

    check_ris_positivo:
        beqz t0 fine_mul
        beq t0 s1 fine_mul
        j overflow

    fine_mul:
        lw a1 0(sp)
        addi sp sp 4
        lw ra 0(sp)
        addi sp sp 4
        ret
    
div:
    addi sp sp -4
    sw ra 0(sp)
    addi sp sp -4
    sw a1 0(sp)
    li a0 0
    beqz a2 divisione_zero
    beq a2 s0 divisione_uno
    beqz a1 fine_div
    beq a1 s0 check_uno_div

    check_dividendo:
        bltz a1 nega_dividendo

    check_divisore:
        bltz a2 nega_divisore
        j carico

    nega_dividendo:
        addi t2 t2 1
        neg a1 a1
        j check_divisore

    nega_divisore:
        addi t2 t2 1
        neg a2 a2

    carico:
        li t0 17 # carico 17 nel counter
        mv t1 a1 # carico il dividendo in t1
        slli t1 t1 1 # shifto a sx di 1 in dividendo
        slli a2 a2 16 # shifto il divisore nella prima metà

    loop_div:
        beqz t0 shift_finale_div
        sub t1 t1 a2 # resto -= divisore
        bgez t1 resto_positivo
        j resto_negativo

    resto_positivo:
        slli a0 a0 1 # shifto a sx il resto
        ori a0 a0 1 # aggiungo 1 nel lsb
        srli a2 a2 1 # shifto a dx di 1 il divisore
        addi t0 t0 -1
        j loop_div

    resto_negativo:
        add t1 t1 a2 # ripristino il resto
        slli a0 a0 1 # shifto il risultato a sx di 1
        srli a2 a2 1 # shifto a dx si 1 il divisore
        addi t0 t0 -1
        j loop_div

    shift_finale_div:
        srli a0 a0 1
        bltz a0 overflow_div

    check_ris_div:
        beq t2 s0 nega_ris_div
        j fine_div

    check_uno_div:
        bne a2 s0 fine_div
        li a0 1

    fine_div:
        lw a1 0(sp)
        addi sp sp 4
        lw ra 0(sp)
        addi sp sp 4
        ret

    divisione_uno:
        mv a0 a1
        j fine_div

    nega_ris_div:
        neg a0 a0
        j fine_div

stampa:
    li a7 1
    ecall
    j fine_main

#ERRORI

errore_parentesi:
    la a0 errore_parentesi_stringa
    li a7 4
    ecall
    j fine_main

overflow_sum:
    la a0 of_sum
    li a7 4
    ecall
    j fine_main

overflow_sub:
    la a0 of_sub
    li a7 4
    ecall
    j fine_main

not_digit:
    la a0 errore_not_digit
    li a7 4
    ecall
    j stampa

divisione_zero:
    la a0 divisione0
    li a7 4
    ecall
    j fine_main

overflow:
    la a0 errore_overflow_mul
    li a7 4
    ecall
    j fine_main

overflow_div:
    la a0 errore_overflow_div
    li a7 4
    ecall
    j fine_main

fine_main:
    nop