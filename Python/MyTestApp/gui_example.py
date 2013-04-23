# -*- coding: utf-8 -*-
# Python SL4A (Scripting Layer For Android) script example with WebView GUI, showing 
# how to exchange events between HTML/JavaScript & Python on Android. -->

# Python interface to Android provided by SL4A.
import android
import json
from sympy import *
droid = android.Android()

# Define menu items 'About' and 'Quit', with events 'menu-about' and 'menu-quit'.
droid.addOptionsMenuItem('About','menu-about',None,"ic_menu_info_details")
droid.addOptionsMenuItem('Quit','menu-quit',None,"ic_lock_power_off")

# Open the WebView GUI written in HTML/JavaScript.
droid.webViewShow('file:///sdcard/sl4a/scripts/Webview.html')
droid.log('Started Webview')
#Using from assets file:///android_asset/html/index.html

# Loop waiting for events.
while True:
    # Wait for an event.
    eventResult = droid.eventWait(10000).result
    if eventResult == None:
        continue
    # If 'menu-about' event happens, then a about dialog is shown using Python SL4A UIFacade.
    elif eventResult["name"] == "menu-about":
        droid.dialogCreateAlert('About Python WebView Template', 
            'Python WebView Template is a simple example of Python SL4A (Scripting Layer For Android) ' + \
            'with webview (HTML + JavaScript) user interface, showing how to exchange events between ' + \
            'HTML + JavaScript & Python on Android.\n(http://www.RobertoColistete.net/Python/Android/)\n'+ \
            'LGPLv3 (C) 2012 Roberto Colistete Jr.')
        droid.dialogSetNeutralButtonText('Ok')
        droid.dialogShow()
        droid.dialogGetResponse().result
        droid.dialogDismiss()
        
    # If 'menu-quit' event happens, then the program is closed.
    elif eventResult["name"] == "menu-quit":
        break
    # If 'calculate' event (from the webview submit button) happens, then the result is calculated.
    elif eventResult["name"] == "calculate":
        # The 'calculation' result is a simple text manipulation, just by example.
        droid.makeToast("Hello !")
        try:
            expression = eventResult['data']
            result = ('Expression has %d characters :\n' % len(expression))+expression
            result += '\nExpression repeated 100 times:\n'+(expression+'\n')*100
            # Send the event 'calculation-result' with the calculated result text to the webview.
            droid.makeToast("Result"+result)
            #a=Rational(1,2)
            x=Rational(2)**50/Rational(10)**50
            print x
            droid.log("Processed x")
            #droid.log(x)
            #droid.makeToast("Result"+json.dumps(x))
            #droid.makeToast("Sympy:"+a)
            droid.eventPost('calculation-result',result)
            #droid.makeToast("After")
        except:

            droid.makeToast("Later !")