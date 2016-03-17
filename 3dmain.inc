;data structures and other definitions for the ALPiNE 3D-Engine
;written in spring and summer 1997 by Ziron

TObjectLENGTH EQU	112	;length of structure
STRUC	TObject
;used for calculations
O11	DD	?	;orientation matrix
O12	DD	?
O13	DD	?
O21	DD	?
O22	DD	?
O23	DD	?
O31	DD	?
O32	DD	?
O33	DD	?
Xo	DD	?	;X-coordinate of object
Yo	DD	?	;Y-coordinate of object
Zo	DD	?	;Z-coordinate of object
;modificated by the timer
O11T	DD	65536 ;orientation matrix
O12T	DD	0
O13T	DD	0
O21T	DD	0
O22T	DD	65536
O23T	DD	0
O31T	DD	0
O32T	DD	0
O33T	DD	65536
XoT	DD	0	;X-coordinate of object
YoT	DD	0	;Y-coordinate of object
ZoT	DD	0	;Z-coordinate of object

PFirstPoly DD	?	;pointer to first poly
PFirstVertex DD ?	;pointer to first vertex
NrPolys DW	?	;number of polys
NrVertices DW	?	;number of vertices
Status	DB	1	;0=object disabled, 1=object enabled
Seen	DB	0	;is the object in range?
Filler	DW	?
ENDS

TPolyLENGTH EQU 	52	;length of structure
STRUC	TPoly
Xn	DD	?	;X-part of the normal vector (back-face culling)
Yn	DD	?	;Y-part of the normal vector (back-face culling)
Zn	DD	?	;Z-part of the normal vector (back-face culling)
Dn	DD	?	;needed for back-face culling
PE1	DD	?	;pointer to first edge
PE2	DD	?	;pointer to second edge
PE3	DD	?	;pointer to third edge
PTexture DD	?	;pointer to a texture-structure
PEnvMap DD	?	;pointer to a texture-structure
U1	DW	?	;U-coordinate of texture for the 1st edge
V1	DW	?	;V-coordinate of texture for the 1st edge
U2	DW	?	;U-coordinate of texture for the 2nd edge
V2	DW	?	;V-coordinate of texture for the 2nd edge
U3	DW	?	;U-coordinate of texture for the 3rd edge
V3	DW	?	;V-coordinate of texture for the 3rd edge
Seen	DB	?	;0=don't draw poly, 1=draw it
Color	DB	1	;only needed if there are no textures
Attr	DB	0	;attributes
			;0=flat filling 	(supported)
			;1=gouroud shading	(supported)
			;2=flat texture mapping (supported)
			;3=environment mapping	(supported)
Filler	DB	?
ENDS

TVertexLENGTH EQU	40	;length of structure
STRUC	TVertex
Xv	DD	?	;X-coordinate of the vertex
Yv	DD	?	;Y-coordinate of the vertex
Zv	DD	?	;Z-coordinate of the vertex
Xn	DD	?	;X-part of the normal vector (shading)
Yn	DD	?	;Y-part of the normal vector (shading)
Zn	DD	?	;Z-part of the normal vector (shading)
CamDist DD	?	;Distance to the camera (used for sorting)
Xs	DW	?	;X-coordinate on the screen
Ys	DW	?	;Y-coordinate on the screen
Xe	DB	?	;X-position at the environment map
Ye	DB	?	;Y-position at the environment map
Light	DB	?	;brightness of the vertex
Seen	DB	?	;0=vertex can't be seen, 1=vertex can be seen
Attr	DB	?	;determines, what to calculate for this vertex
			;0 = nothing
			;1 = light intensity
			;2 = environment mapping coordinates
			;3 = light intensity and env. mapping coordinates
Temp	DW	?
Filler	DB	3 DUP (?)
ENDS

TTextureLENGTH	EQU	4
STRUC	TTexture
Width	DW	?
Height	DW	?
ENDS

GLOBAL	Init3DEngine:PROC
GLOBAL	CalcSinus:PROC
GLOBAL	CalcArcusSinus:PROC
GLOBAL	SqrRoot:PROC
GLOBAL	CalcPolyNormals:PROC
GLOBAL	CalcVertexNormals:PROC
GLOBAL	MarkSeenObjects:PROC
GLOBAL	PrepareScene:PROC
GLOBAL	SortPolys:PROC
GLOBAL	DrawScene:PROC

GLOBAL	SqrRoot:PROC

GLOBAL	GPObjects:DWORD
GLOBAL	GPSinTable:DWORD

GLOBAL	GSeeingRange:DWORD
GLOBAL	GXEyeDist:DWORD
GLOBAL	GYEyeDist:DWORD
GLOBAL	GNrObjects:WORD
GLOBAL	GXMiddle:WORD
GLOBAL	GYMiddle:WORD

GLOBAL	GCameraO11T:DWORD
GLOBAL	GCameraO12T:DWORD
GLOBAL	GCameraO13T:DWORD
GLOBAL	GCameraO21T:DWORD
GLOBAL	GCameraO22T:DWORD
GLOBAL	GCameraO23T:DWORD
GLOBAL	GCameraO31T:DWORD
GLOBAL	GCameraO32T:DWORD
GLOBAL	GCameraO33T:DWORD
GLOBAL	GCameraXPosT:DWORD
GLOBAL	GCameraYPosT:DWORD
GLOBAL  GCameraZPosT:DWORD