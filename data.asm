IDEAL
P386
ASSUME	cs:code32,ds:code32

SEGMENT code32	PARA PUBLIC USE32
MASM
INCLUDE pmode.inc
IDEAL
INCLUDE 'decl.inc'
INCLUDE 'data.inc'

INCLUDE 'palette.inc'
INCLUDE 'texture.inc'
INCLUDE 'backgrnd.inc'
INCLUDE 'object.inc'

ENDS
END