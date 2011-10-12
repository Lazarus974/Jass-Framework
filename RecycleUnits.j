// You have to define this constants :
// constant integer UnitMax = <Number of units you want>
// constant integer RecyclableUnitId = <Id of dummy unit>

library RecycleUnits initializer init needs Hashtable, Constants
	globals
		integer UnitCount
		integer UnitMin
		unit array UnitPool
	endglobals
	
	private function CreateRecyclableUnit takes nothing returns unit
		return CreateUnit(GetPlayer(15), RecyclableUnitId, 0., 0., 0.)
	endfunction
	
	function CleanUnit takes unit u returns unit
		if u != null then
			call PauseUnit(UnitPool[UnitCount], true)
			call SetUnitX(UnitPool[UnitCount], 0.)
			call SetUnitY(UnitPool[UnitCount], 0.)
			call SetUnitOwner(UnitPool[UnitCount], GetPlayer(15), false)
			call HTFlushChildHashtable(u)
		endif
		return u
	endfunction
	
	function NewUnit takes player owner, real x, real y returns unit
		if UnitCount <= 0 then
			call BJDebugMsg("|cFFF00000Warning: Unit pool empty. Creating a new one.")
			set UnitPool[0] = CreateRecyclableUnit()
		else
			set UnitCount = UnitCount - 1
			if UnitCount <= UnitMax / 20 then
				call BJDebugMsg("|cFFF00000Warning: Unit pool nearly empty.")
			endif
			if UnitPool[UnitCount] == null then
				call BJDebugMsg("|cFFF00000Warning: Null Unit found. Creating a new one instead.")
				set UnitPool[UnitCount] = CreateRecyclableUnit()
			endif
		endif
		if UnitCount < UnitMin then
			set UnitMin = UnitCount
		endif
		call PauseUnit(UnitPool[UnitCount], false)
		call SetUnitX(UnitPool[UnitCount], x)
		call SetUnitY(UnitPool[UnitCount], y)
		call SetUnitOwner(UnitPool[UnitCount], owner, false)
		return CleanUnit(UnitPool[UnitCount])
	endfunction
	
	function DeleteUnit takes unit u returns nothing
		if u != null then
			call CleanUnit(u)
			if UnitCount < UnitMax then
				set UnitPool[UnitCount] = u
				set UnitCount = UnitCount + 1
			else
				call BJDebugMsg("|cFFF00000Warning: Unit pool is full. Destroying the Unit.")
				call KillUnit(u)
				call RemoveUnit(u)
			endif
		endif
	endfunction
	
	function DisplayUnit takes nothing returns nothing
		call BJDebugMsg("Unit�s utilis�es : " + I2S(UnitMax - UnitMin) + " / " + I2S(UnitMax))
	endfunction
	
	private function init takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen i >= UnitMax
			set UnitPool[i] = CreateRecyclableUnit()
			set i = i + 1
		endloop
		set UnitCount = UnitMax
		set UnitMin = UnitMax
	endfunction
endlibrary
