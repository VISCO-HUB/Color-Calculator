/*  
[INFO] 

NAME = Color Calculator
VERSION = 1.0.0
AUTHOR = MastaMan
DEV = VISCO
HELP = 

[INSTALL]

MACRO=ColorCalculator
CAT=VISCO
TEXT=Color Calculator
ICON=#("FileLinkActionItems", 6)

[1.0.0]

* First release =

[ABOUT]

This script helps to quickly convert #HEX color code to RGB or HSL format=

[TEST]

[SCRIPT]
*/	

fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)


fn parseToLine m = 
(
	if(m.count == 0) do return ""
	
	l = ""				
	for i in m do l += i + "\n"
	return l
)

rollout _rColorConverter "Color Convert" 
(
	group ""
	(
		colorpicker  clrPicker "" width: 40 across: 3 offset: [-5, 0]
		edittext edtHex "#" fieldWidth: 115 offset: [-28, 2]
		button btnPaste "Paste" offset: [20, 0]
				
		label lblWarn ""
		dropdownlist ddlConvertTo "Convert To:" items: #("HEX -> Linear", "HEX -> sRGB", "HEX -> Float RGB", "HEX -> RGB")		
	)
	
	group "Exit Color"
	(
		edittext edtR "R:" across: 3 height: 20 readonly: true fieldWidth: 55 offset: [-6, 0]
		edittext edtG "G:" height: 20 readonly: true fieldWidth: 55 offset: [2, 0]
		edittext edtB "B:" height: 20 readonly: true fieldWidth: 55 offset: [9, 0]
		button btnCopyR "Copy" across: 3 offset: [1, 0]
		button btnCopyG "Copy" offset: [10, 0]
		button btnCopyB "Copy" offset: [15, 0]
	)
	
	fn floorTo v g: 1000.0 =
	(
		b = v * 10.0 * g		
		b = (ceil b) / 10.0
	
		a = (b as integer) / g

		return a
	)
	
	fn isError v =
	(
		err = false
		a = filterString v "abcdefABCDEF0123456789"
		return a.count > 0
	)
	
	fn convertColor txt =
	(
		edtR.text = ""
		edtG.text = ""
		edtB.text = ""
		lblWarn.caption = ""
		
		v = 
		v = trimLeft txt " #"
		v = trimRight v " "
		
		
		if(v.count != 6 or isError v) do
		(
			lblWarn.caption = "Please enter correct HEX code!"
			return false
		)
		
		r = 0
		g = 0
		b = 0
		
		t = ddlConvertTo.selection
		
		fn toSRGB c = if(c <= 0.0031308) then c * 12.92 else 1.055 * (c ^(1/2.4)) - 0.055
		fn toLINEAR c = if(c <= 0.04045) then c / 12.92 else ((c + 0.055) / 1.055)^2.4
		
		cr  = execute ("0x" + v[1] + v[2])
		cg  = execute ("0x" + v[3] + v[4])
		cb = execute ("0x" + v[5] + v[6])
		
		clrPicker.color = color cr cg cb
		
		case t of
		(
			1:
			(
				r = execute ("0x" + v[1] + v[2]) / 255.0
				g = execute ("0x" + v[3] + v[4]) / 255.0
				b = execute ("0x" + v[5] + v[6]) / 255.0

				r = toLINEAR r
				g = toLINEAR g
				b = toLINEAR b
				
				edtR.text = (floorTo r) as string
				edtG.text = (floorTo g) as string
				edtB.text = (floorTo b) as string
			)
			2:
			(
				r = execute ("0x" + v[1] + v[2]) / 255.0
				g = execute ("0x" + v[3] + v[4]) / 255.0
				b = execute ("0x" + v[5] + v[6]) / 255.0

				r = toSRGB r
				g = toSRGB g
				b = toSRGB b
				
				edtR.text = (floorTo r) as string
				edtG.text = (floorTo g) as string
				edtB.text = (floorTo b) as string
			)
			3:
			(
				r = execute ("0x" + v[1] + v[2]) / 255.0
				g = execute ("0x" + v[3] + v[4]) / 255.0
				b = execute ("0x" + v[5] + v[6]) / 255.0

				edtR.text = (floorTo r) as string
				edtG.text = (floorTo g) as string
				edtB.text = (floorTo b) as string
			)
			4:
			(
				r = execute ("0x" + v[1] + v[2]) 
				g = execute ("0x" + v[3] + v[4]) 
				b = execute ("0x" + v[5] + v[6])

				edtR.text = r as string
				edtG.text = g as string
				edtB.text = b as string
			)
		)
		
		lblWarn.caption = "Color converted!"
	)
	
	on clrPicker changed v do
	(
		s = "#"
		r = (bit.IntAsHex(v.r)) as string
		g = (bit.IntAsHex(v.g)) as string
		b = (bit.IntAsHex(v.b)) as string
		
		if(r.count < 2) do r += "0"
		if(g.count < 2) do g += "0"
		if(b.count < 2) do b += "0"
		
		s += r + g + b
		
		edtHex.text = s
			
		convertColor s	
	)
	
	on edtHex changed v do
	(
		convertColor v
	)
	
	on ddlConvertTo selected  v do
	(		
		convertColor edtHex.text
	)
	
	on btnPaste pressed do
	(
		t = getClipboardText()
		
		if(t != undefined) do
		(
			edtHex.text = t		
			convertColor t
		)
	)
	
	on btnCopyR pressed do setClipboardText edtR.text
	on btnCopyG pressed do setClipboardText edtG.text
	on btnCopyG pressed do setClipboardText edtB.text
)

rollout _rAbout "About" 
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	
	on _rAbout open do
	(		
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
	)
)

try(closeRolloutFloater _rColorCalculator) catch()
global _rColorCalculator = newRolloutFloater "Color Calculator" 250 320

addRollout _rColorConverter _rColorCalculator rolledUp:false 
addRollout _rAbout _rColorCalculator rolledUp:true 