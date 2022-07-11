//------------------------------------------------------------------------
//	sprite bars by grzegorzsun@gmail.com
//  LoveByte 2021
//------------------------------------------------------------------------

SDMCTL  equ $022f; $D400

WSYNC   equ $D40A
VCOUNT  equ $D40B

PPLAYER0 equ $D000 ; pozycja gracza 0
SPLAYER0 equ $D008 ; size player0
GPLAYER0 equ $D00D ; rejestr grafiki gracza 0    
CPLAYER0 equ $D012 ; kolor gracza 0
HPOSP0      	= $d000

consol = $d01f
RTCLOCK  equ $0012;
RANDOM  equ $D20A
sin_t  = $2000 ; <- adres tabicy sinusa (tablica zajmuje 1 stronê pamiêci)

   org	$80
;one line + dma for players
   lsr SDMCTL
x1 jmp x1 
   inx
 
   stx GPLAYER0;
   stx GPLAYER0+1;
loopb1 equ * 
   LDA VCOUNT;
   STA WSYNC;
   ADC rtclock+2;
;   ADC RANDOM
   ASL RANDOM
   STA CPLAYER0;
   STA SPLAYER0;

   lda rtclock+2
   bne loopb1

;ef2
    inc rtclock+2;
    iny
    sty splayer0;
    sty splayer0+1;

ef2 ldy #$01
ef2loopb2	equ *
    lda vcount
	adc rtclock+2

; tez fajny z eor #$ff
	eor #$ff
	sta opcodb1+1

; cos dziwnego
    	lda vcount;
; cos dziwnego 2
;	lda rtclock+2;  random
opcodb1	and #$00
	adc #$26
	eor ef2tab,y
	sta pplayer0,y
	lda vcount
	ora #$07
	sta cplayer0,y
	dey
	bpl ef2loopb2
	lda rtclock+2
	bne ef2

;ef3 sinus

;procka zajmuje 42b na ZP albo 45b poza ZP - koala/Agenda
;amplituda sinusa: $00-$ff
	ldy #$3f
	ldx #0
	; txa ;nie ma przymusu zerowanie akumulatora (nie zauwa¿y³em jakiegoœ wiêkszego wp³ywu na tworzon¹ tablicê)
loop
__1	adc #$00
	bcs __2
	inc __3+1
__2
	inc __1+1
	pha
__4	lda #0
	and #%11
	bne skp

__3	lda #$7f ;<- za pomoc¹ tego mo¿na przesówaæ na inne œwiartki sinusa
	sta sin_t+$00,x
	sta sin_t+$40,y
	eor #$ff
	sta sin_t+$80,x
	sta sin_t+$c0,y
	inx
	dey
skp
	pla
	inc __4+1
	bne loop

;sinusiatka
    ldy #3;
    sty splayer0;
    sty splayer0+1;

vco ;jmp vco
    lda vcount
    bne vco
	tay

next_char

    lda font_offsets,y
    sta font_lo+1
	
colorloop	
    dex
font_lo
	lda $e100
    sta wsync
	sta GPLAYER0
	sta GPLAYER0+1

	txa
;    sta $d01f;consol;

    eor #$ff
    sta CPLAYER0+1
    sta CPLAYER0

	and #%11110000
    sta wsync
	sta $d01a
    lda vcount
	adc 20
	tax
;zwykly sinus`
;    lda sin_t,x
;drzenie
	lda random
    and #$2    
    adc sin_t,x
    sta consol
	sta HPOSP0
    eor #$ff
    sta HPOSP0+1
    
	inc font_lo+1
	lda font_lo+1
	and #7
	bne font_lo

	iny
	cpy #23; lost party #21
	bne next_char
;	bne colorloop
	beq vco



ef2tab equ *
    dta $00,$ff

font_offsets
; spacje
		dta $f6,$f6,$f6,$f6,$f6,$f6,$f6,$f6
; s i l l y
;		dta $98,$48,$60,$60,$c8,$f6,$f6
; v e n t u r e
;		dta $b0,$28,$70,$a0,$a8,$90,$28
;l o s t
        dta $60,$60+3*8,$98,$a0
;spacje
        dta $f6,$f6,$f6,$f6,$f6
;party
        dta $90-2*8,$28-4*8,$90,$a0,$c8,$f6
	