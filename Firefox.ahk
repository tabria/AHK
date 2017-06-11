;========================================================================================
; FireFox Class	 working for FF version 52.0.2											            
;========================================================================================
	#NoEnv
		
	#Include Z:\SPODELEN\UCB\lib\Acc.ahk
	#Include Z:\SPODELEN\UCB\lib\BrowserBase.ahk
	#Include Z:\SPODELEN\UCB\lib\vlibrary.ahk
	#KeyHistory 0
	#MaxThreads 225
	#MaxMem 256
	ListLines, Off
	CoordMode, Mouse, Screen
	SetTitleMatchMode 2
	SetKeyDelay, 50, 10
	SetBatchLines, -1
	StringCaseSense, Locale
	
	
	Class FireFox extends BrowserBase {
			checksArray		:= [".yandex","images/search?","video/search?","yandex","ya.ru"]
			urlAttrib		:= {" ":"","https://":"bqdyiy","http://":"bqdyiy","www.":"bqdyiy","`r":"bqdyiy", "`n":"bqdyiy", "«ð://":"bqdyiy"}
			objectsRegion	:=[]
			childPath		:=[]
			
	;Waiting for Firefox to load completely the page
		FFwaitAll(repetitions="2", sleeptime="1000" ) {
			ffWaitArray := ["application.tool_bar3.combo_box1.push_button"]
			loading := "Stop loading this page"
			loaded  := "Reload current page"
			Loop, %repetitions%
			{
				time1:=10
				n:=0
				
				this.browserWinAction("Firefox", "activate")
				Loop 
				{
					n:=n+1
					if (n >7) 
					{
						n:=0
						sleep 1
						continue
					}
					
					buttonLoc := ffWaitArray[1] . n
					description := Acc_Get("Name", buttonLoc, 0, "ahk_class MozillaWindowClass")
					
					if (description = loaded)  
					{
						break
					}	
					
					if (time1>3020)
					{
						this.Escap()
						this.messagebox("Infinite Loop vzemat se merki")
						sleep 200
						break 2
					}
					sleep, 10
					time1:=time1+5
					sleep 1
				}
				sleep %sleeptime%
			}
			sleep 100
			return
		}
		
	;Closing Refresh msg on the bottom of Firefox Browser
		FFRefreshCloser() {
			ffAlertLoc:="application.alert1.push_button2"
			AlertX:= Acc_GetX("Location", ffAlertLoc, 0, "ahk_class MozillaWindowClass")
			AlertY:= Acc_GetY("Location", ffAlertLoc, 0, "ahk_class MozillaWindowClass")
			if (AlertX!="") && (AlertY!="")
			{
				this.OffsetLMouseClick(AlertX, AlertY, 8, 13)
			}
			return
		}
		
	;Obtaining the current URL from Firefox address bar
		FFGetCurrUrl(){
			curl1loc := "application.tool_bar3.combo_box1.editable_text1"
			
			curl1value:=Acc_Get("Value", curl1loc, 0, "ahk_class MozillaWindowClass")
			return, curl1value
		}
		
	;Extract Firefox status bar
		FFStatBarNow(){
			url1locstatraw := "application.grouping1.property_page.x.status_bar1"
			
			activetab:=this.FFNomerActiveTab()
			StringReplace, url1locstat, url1locstatraw, .x, %activetab%
			statbartext := Acc_Get("Name", url1locstat, 0, "ahk_class MozillaWindowClass")
			return, statbartext
		}
	;Returning the number of the current active tab
		FFNomerActiveTab() {
			loaded  := "Reload current page"
			loading := "Stop loading this page"
	
			Loop {
				n:=0
				time:=0
				tabNumber:=0
				httpCheck=
				countTabs:=tabobj .accChildCount
				buttonRaw:="application.tool_bar3.combo_box1.push_button.x"
				
				this.FFwaitAll(2, 100)
				
				activeNameTab:=Acc_Get("Name", "application", 0, "ahk_class MozillaWindowClass")
				StringReplace, activeNameTab, activeNameTab, %A_Space%-%A_Space%Mozilla%A_Space%Firefox,,
				
				tabObj:=Acc_Get("Object", "application.tool_bar2.page_tab_list", 0, "ahk_class MozillaWindowClass")
				for each, child in Acc_Children(tabObj) {
					tabNumber:=tabNumber + 1
					nameTab:=child .accName(0)
					if (nameTab=0) {
						break
					}
					
					if (nameTab=activeNameTab) {
						break 2
					}
					
					if (activeNameTab="Mozilla Firefox") {
						StringCaseSense, Locale
						IfInString, nameTab, %httpCheck% 
						{
							break 2
						}
					}
					
					if (nameTab="Connecting…") {
						Loop {
							n:=n+1
							if (n>7) {
								n:=0
								sleep 1
								continue
							}
							StringReplace, button, buttonRaw, .x,%n%
							description := Acc_Get("Name", button, 0, "ahk_class MozillaWindowClass")
							if (description = loading) or (description = loaded) {
									break
							}
						}
						
						description := Acc_Get("Name", button, 0, "ahk_class MozillaWindowClass")
						StringCaseSense, Locale
						
						IfInString, description, %loaded% 
						{
								break 2
						}
					}
					
					if (tabNumber>countTabs) {
							break
					}
					sleep 2
				}
				sleep 2
			}
			return, tabNumber
		}
		
	;Turn path from Getpath to normal
		FFNormalPath(pathChange) {
			structure:= ["24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40"]
			
			for what, with in structure {
				IfInString, pathChange, %with%
				{
					StringReplace, pathChange, pathChange, 4.%with%.1, 4.%with%.2
				}
			}
			return, pathChange
		}
		
	;extract the Search Engine
		FFSEextract(searchInto, firstSearch, secondSearch, offset) {
			
			StringReplace, searchInto, searchInto, `r`n, %a_space%, All	
			StringGetPos, firstSearchPos, searchInto, %firstSearch%
			StringLeft, afterFirstTrim, searchInto, % (firstSearchPos-offset)
			StringGetPos, secondSearchPos, afterFirstTrim, %secondSearch%
			StringTrimLeft, afterSecondTrim, afterFirstTrim, % (secondSearchPos+StrLen(secondSearch))
			StringReplace, afterSecondTrim, afterSecondTrim, -,%A_Space%
			StringGetPos, spacePos, afterSecondTrim, %A_space%
			if (spacePos<0) {
				goto, nospacelabel
			}
			StringLeft, afterSecondTrim, afterSecondTrim, % spacePos
			nospacelabel:
			return, afterSecondTrim
		}
		
	;firefox enter + FFwait
		FFEnterFFWait() {
			this.Ente()
			this.FFwaitAll(2, 1500)
			sleep 200
			return
		}

	;Scroll up firefox direction - 0 up , 1 down
		FFScroll(x, y, direction) {
			MouseClick, left, x, y, 1, 3
			sleep 50
			Loop, 16
			{
				PostMessage, 0x115, %direction%,,, ahk_class MozillaWindowClass
				sleep 1
			}
			return
		}
	;Loading search Engine into firefox tab
		FFSeLoad(words, includeL="includeL", newTab="newTab") {
			StringCaseSense, Locale
			if (newTab = "newTab") {
				this.CrT()
			}
			sleep 200
			if (includeL = "includeL") {
				this.sendingKeysPageLoad(words, "L", 1)
				sleep 100
			}else if (includeL = "includeE") {
				this.sendingKeysPageLoad(words, "E", 1)
			} else {
				this.sendingKeysPageLoad(words, "A", 1)
			}
			
			sleep 200
			return
		}
		
		sendingKeysPageLoad(wordToSend, controlAction="NA", enterAction=1, delay=200)
		{
			If (controlAction = "L") {
				this.MouseCrA()
			} else if (controlAction = "A") {
				this.CrA()
			} else if (controlAction = "E") {
				this.En()
				this.Spac()
			}else {
				sleep 20
			}
			
			sleep 100
			send % this.sendRandomDelay(wordToSend)
			
			if (enterAction = 0)
			{
				sleep 400
			} else {
				this.Ente()
				sleep 100
				this.FFwaitAll()
				sleep 100
			}
			
			sleep 400
			return
		}	
		
		sendRandomDelay(stringToSend)
		{
			Loop, parse, stringToSend 
			{
				send % A_LoopField
				random, t, 42, 233
				sleep, %t%
			}
		}
	;get position(path) for website in search
		FFWebPos(urlArray, sitesNoGo, se="yandex", targetPage="No") {
			
			linkValue:=urlArray .accValue(0)
			
			if (se = "google") {
				If ( InStr(linkValue, "google") and InStr(linkValue, "/search?q") ) or ( InStr(linkValue, "javascript:;") ) {
					goto, endFunc
				}
			} else {
				For key, val in this.checksArray {	
					If InStr(linkValue, val) {
						goto, endFunc
					}
					sleep 1
				}
			}

			if (targetPage = "Yes") {
				pathchange:=this.FFTargetSitePath(urlArray, sinkValue, sitesNoGo)
				goto, endFunc
			}

			if (isObject(sitesNoGo)) {
				For element, url in sitesNoGo {	
					If InStr(linkValue, url) {
						goto, endFunc
					}
					sleep 1
				}
			}

			WinGet, hwnd, ID, ahk_class MozillaWindowClass
			pathChange:=this.FFNormalPath(GetAccPath(urlArray, hwnd))
			endFunc:
			
			return, pathChange
		}
		
		FFTargetSitePath(currentObject,currentPageValue, pageToFind) {
			
			WorkSiteValue:=RemoveExtraChars(currentPageValue)
			
			IfInString, WorkSiteValue, %pageToFind%
			{
				StringGetPos, searchWordPos, WorkSiteValue, %pageToFind%
				StringTrimLeft, searchWordTrim, WorkSiteValue, % (searchWordPos+StrLen(pageToFind))
				
				if (StrLen(searchWordTrim)>0) {
					goto, endReturnPath
				}
				
				if (WorkSiteValue=pageToFind)
				{
					WinGet, hwnd, ID, ahk_class MozillaWindowClass
					pathPage:=this.FFNormalPath(GetAccPath(currentObject, hwnd)) 
					return, pathPage
				}
			}
			endReturnPath:
			
			return, pathPage:="Ne e path"
		}
		
	;errors on the site
		FFsitErrors() {
			replace		:= {"err1":"Secure Connection Failed", "err2":"The Connection has timed out", "err3":"Server not found", "err4":"Address Not Found", "err5":"The connection was reset", "err6":"404 Not Found", "err7":"Problem loading page", "err8":"504 Gateway Timed-out", "err8":"Service Unavailable"}
			errorLoc	:="application"
			errorNumber	:=0
				
			errorName := Acc_Get("Name", errorloc, 0, "ahk_class MozillaWindowClass")
			StringReplace, errorName, errorName, -%A_Space%Mozilla Firefox,,
			errorName=%errorName%
			
			for what, with in replace {
				StringCaseSense , Locale
				if (errorName=with) {
					errorNomer:=1
					sleep 300
					break
				}
				sleep 2
			}
			sleep 200
			return, errorNumber
		}
	;check if find bar exists
		FFSearchBarChecker() {
				activeTab:=this.NomerActiveTab()
				searchBarUrlRaw := "application.grouping1.property_page.x.tool_bar1"
				
				StringReplace, searchBarUrl, searchBarUrlRaw, .x, %activeTab%
				searchBarRole := Acc_Get("Role", searchBarUrl, 0, "ahk_class MozillaWindowClass")
				
				If (searchBarRole="tool bar")
				{
					goto, exitSearch
				}
				else
				{
					WinActivate, ahk_class MozillaWindowClass
					sleep 50
					send {ctrl down}{f down}{f up}{ctrl up}
					sleep 100
				}
				
				exitSearch:
				sleep 200
				return
			}
			
	;Mouse moves
		FFRandomScroll(currentError="0") {
			
				moveArray:= ["HorMouseMove", "VertMousemove", "ElipseMousemove", "UpDownMousemove"]
				moveArray2:= ["sleepnow", "HorMouseMove", "VertMousemove", "ElipseMousemove", "UpDownMousemove"]
				
				Random, sleepRand2, 1200, 1700
				sleep %sleepRand2%
				
				Random, scrollOrMove, 1, 3
				sleep 200
				
				this.browserWinAction("Firefox", "activate")
				if (scrollOrMove = 2) and (currentError = 0) {
					scrollCheckResult := this.FFScrollCheckNoMove()
					sleep 100
					if (scrollCheckResult != 0) {
						Random, countDown, 1, 3
						Loop, %countDown%
						{
							posScroll:=this.FFVScrollPosPix()
							posStart:=posScroll + 4
							posSend:=posScroll + 44
							MouseClick, left, 1010, %posstart%, 1, 3, D
							sleep 200
							MouseClick, left, 1010, %possend%, 1, 3, U
							sleep 200
							Random, sleepRand, 100, 500
							sleep %sleepRand%
						}
					}
				}
				
				if (scrollOrMove=1) {
					Random, randMove, 1, 4
					for what, with in moveArray {
						IfInString, randMove, %what%
						{
							WinActivate, ahk_class MozillaWindowClass
							sleep 50
							%with%()
							goto, sndTime
						}
						sleep 1
					}
					
					sndTime:
					sleep 700
					
					Random, randMove2, 1, 5
					for key, val in moveArray2 {
						IfInString, randMove2, %key%
						{
							moveOne=%with%
							moveTwo=%val%
							
							if (moveOne=moveTwo) {
								WinActivate, ahk_class MozillaWindowClass
								sleep 100
								goto, endNow1
							}
							
							WinActivate, ahk_class MozillaWindowClass
							sleep 50
							%val%()
							goto, endNow1
						}
						sleep 1
					}
				}	
				
				endNow1:
				if (scrollOrMove=3) and (currentError = 0) {
					scrollCheckResult:=this.FFScrollCheckNoMove()
					sleep 100
					
					if (scrollCheckResult=0) {
						goto, nextMove12
					}
					
					posScroll:=this.FFVScrollPosPix()
					Random, broinagore, 0, 3
					if (posScroll=138) {
						countUp:=0
					}
					sleep 900
					Loop, %countUp%
					{
						posScroll:=this.FFVScrollPosPix()
						posStart:=posScroll+8
						posSend:=posScroll-30
						MouseClick, left, 1010, %posStart%, 1, 3, D
						sleep 200
						MouseClick, left, 1010, %posSend%, 1, 3, U
						sleep 150
					}
				}
				
				nextMove12:
				sleep 827
				return
		}
		
	;check for existance of scrollbar - 1 have scroll, 0 no scroll
		FFScrollCheckNoMove() {
			sbReal:=1
			black = 0x000000
			activeRab:=this.FFNomerActiveTab()
			tab1DocLoc := "application.grouping1.property_page.x.unknown_object1.document1"
			
			StringReplace, tab1DocLoc, tab1DocLoc, .x, %activeTab%
			Wtab1:=Acc_GetW("Location", tab1DocLoc, 0, "ahk_class MozillaWindowClass")
			PixelGetColor, colorScroll, 1010, 671

			if (Wtab1=1015) and (colorScroll = black) {
				sbReal:=1
			} else if (Wtab1=1015) and (colorScroll != black) {
				sbReal:=0
			} else if ( colorScroll = black) {
				sbReal:=1
			} else {
				sbReal:=0
			}
			
			return, sbReal
		}
		
	;Scroll Position
		FFVScrollPosPix() {
			scrollX:=1018
			scrollY:=138
			colorCheck=0x404040
			
			Loop {
				PixelGetColor, colorScroll, %scrollX%, %scrollY%
				scrollY:=scrollY+1
				if (colorScroll1=colorCheck) {
					scrollPos:=scrollY-1
					goto, endScrollPos
				}
				if (scrollY>690) {
					scrollY:=138
				}
			}
			endScrollPos:
			
			return, scrollPos
		}
		
		FFScrollMid(errorLoadingSite) {
			scrollX:=1018
			scrollY:=144
			colorCheck=0x404040
			
			this.FRandomScroll(errorLoadingSite)
			sleep 400
			scrollCheckres := this.FFScrollCheckNoMove()
			sleep 100
			if (scrollCheckres=0) {
				sleep 100
				return
			}
			Loop {
				PixelGetColor, colorScroll, %scrollX%, %scrollY%
				scrollX:=scrollY+1
				if (colorScroll=colorCheck) {
					scrollPos:=scrollY-1
					Loop {
						PixelGetColor, colorScroll2, %scrollX%, %scrollY%
						scrollY:=scrollY+1
						if (colorScroll2 != colorCheck) {
							se1:=scrollY-1
							middle:=Ceil(scrollPos+((se1-scrollPos)/2))
							sbpos:=400    
							MouseClick, left, 1010, %middle%, 1, 3, D
							sleep 200
							MouseClick, left, 1010, %sbpos%, 1, 3, U
							sleep 100
							return
						}
					}
				}
			}
		}
		
		FFChangeCrAlZ() {
			this.CrAlZ()
			this.FFwaitAll()	
			sleep 100
			return
		}
		
		FFMainObject() {
			mainLocation	:= "application.grouping1.property_page2.unknown_object1.document1"
			currentObject 	:= Acc_Get("Object", mainLocation, 0, "ahk_class MozillaWindowClass")
			return, currentObject
		}
		
		;scroll website into visible zone
		FFOnScreenLocation(WorkSitePath, SearchEngine, clickButton="left"){
			YandexCheck=yandex
			
			Loop
			{
				WorkSiteX:=Acc_GetX("Location", WorkSitePath, 0, "ahk_class MozillaWindowClass")
				WorkSiteY:=Acc_GetY("Location", WorkSitePath, 0, "ahk_class MozillaWindowClass")
				WorkSiteH:=Acc_GetH("Location", WorkSitePath, 0, "ahk_class MozillaWindowClass")
				
				IfInString, SearchEngine, %YandexCheck%
				{
					valuemove	:= 225
					Xmclick		:= 29 
					Ymclick		:= 186 
					OffsetX		:= 38
					OffsetY		:= 10
				} else {
					valuemove	:= 210
					Xmclick		:= 6
					Ymclick		:= 300
					OffsetX		:= 17
					OffsetY		:= 10
				}
				
				if (WorkSiteY > valuemove) 
				{
					endsitesite:=WorkSiteY+WorkSiteH
					
					if (WorkSiteY<650) and (endsitesite<650)
					{
						this.OffsetLMouseClick(WorkSiteX, WorkSiteY, OffsetX, OffsetY, clickButton)
						goto, endOSL
					} 
					else 
					{
						this.FFScroll(Xmclick, Ymclick, 1)
					}
				} 
				else 
				{

					this.FFScroll(Xmclick, Ymclick, 0)
				}
				sleep 25
			}
			endOSL:
			sleep 300
			return
		}	
	}
	
	