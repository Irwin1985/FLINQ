if type('_screen.fLinq') != 'c'
	=removeproperty(_screen, 'fLinq')
endif
=addproperty(_screen, 'fLinq', createobject('fLinqClass'))

define class fLinqClass as custom
	errorIndex = 0
	dimension errors(1)
	fsVersion = "v1.0 - 25/07/2021 22:30"

	function init
		this.checkdependecy('wwDotNetBridge.prg')
		this.checkdependecy('wwDotnetBridge.dll')
		this.checkdependecy('wwIPStuff.dll')
		this.checkdependecy('fLinq.dll')
		if !this.hasErrors()
			do wwDotnetBridge
			InitializeDotnetVersion("V4")
		endif
	endfunc

	function checkdependecy(dependencyName)
		if !file(dependencyName)
			this.pushError('[' + dependencyName + '] not found in program path.')
		endif
	endfunc

	function pushError(msg)
		this.errorIndex = this.errorIndex + 1
		dimension this.errors(this.errorIndex)
		this.errors[this.errorIndex] = msg
	endfunc

	function hasErrors
		if alen(this.errors, 1) > 0
			return type('this.errors[1]') == 'C'
		endif
		return .f.
	endfunc

	function printErrors
		if alen(this.errors, 1) > 0
			for each msg in this.errors
				if type('msg') == 'C'
					messagebox(msg, 48, 'fLinq errors')
				endif
			endfor
		endif
		* Reset errors
		dimension this.errors[1]
		this.errors[1] = ''
	endfunc
	function runFile(fileName)
		if !file(fileName)
			messagebox("File not found: " + fileName, 16, "RunFile")
		endif
		return this.runCode(filetostr(fileName))
	endfunc
	function runCode(source)
		try
			result = ""
			loBridge = GetwwDotnetBridge()
			if loBridge.LoadAssembly("flinq.dll")
				loInstance = loBridge.CreateInstance("flinq.Start")
				if !isnull(loInstance)
					result = loInstance.run(source)
				else
					this.pushError('could not create the foxSharp instance')
				endif
			else
				this.pushError('could not load the assembly FoxSharp.dll')
			endif
		catch to loEx
			this.pushError('try/catch error: ' + loEx.message)
		finally
			store .null. to loInstance, loBridge
			release loInstance, loBridge
		endtry
		return result
	endfunc
enddefine
