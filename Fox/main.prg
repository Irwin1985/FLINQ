SET PATH TO "redist" additive
* Create FoxSharp class
do fLinq.prg
if _screen.fLinq.hasErrors()
	_screen.fLinq.printErrors()
ENDIF