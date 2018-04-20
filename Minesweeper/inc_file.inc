
KeyTest PROTO

CoordToOffset PROTO,
	row:BYTE,
	col:BYTE,
	row_size:BYTE

GetData PROTO,
	data_arr:DWORD, ; PTR BYTE
	row:BYTE,
	col:BYTE,
	row_size:BYTE

SetData PROTO,
	data_arr:DWORD, ; PTR BYTE
	row:BYTE,
	col:BYTE,
	row_size:BYTE,
	data_:BYTE

Clamp PROTO,
	numRef:DWORD, ; PTR SBYTE
	min:SBYTE,
	max:SBYTE

ClampXY PROTO,
	xRef:DWORD, ; PTR SBYTE
	yRef:DWORD, ; PTR SBYTE
	minX:SBYTE,
	maxX:SBYTE,
	minY:SBYTE,
	maxY:SBYTE

ProbeForBomb PROTO,
	data_arr:DWORD, ; PTR BYTE
	rows:BYTE,
	cols:BYTE,
	bombCount:DWORD, ; PTR BYTE
	x:BYTE,
	y:BYTE,
	x_offset:SBYTE,
	y_offset:SBYTE

SetBombNeighbors PROTO,
	data_arr:DWORD, ; PTR BYTE
	rows:BYTE,
	cols:BYTE

GenerateBombs PROTO,
	data_arr:DWORD, ; PTR BYTE
	rows:BYTE,
	cols:BYTE

PrintData PROTO,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE

GotoPrint PROTO,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE

FloodFill PROTO,
	disp_arr:DWORD,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE,
	x:BYTE,
	y:BYTE,
	x_offset:SBYTE,
	y_offset:SBYTE