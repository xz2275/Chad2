import android
import sys
import types

# Test imports.
import android
import gdata.docs.service
import sqlite3
import termios
import time
import urllib2
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# greetings
def greetings():
    title = 'Hi, this is Chad.'
    message = 'Welcome! I am currently a simple Android App that performs time series analysis for FRED data.'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('Touch me')
    droid.dialogSetNegativeButtonText('Cancel')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

# prompt the user to key in the pass code for the program
def getPassword():
    code = droid.dialogGetPassword('Yes, you need a password to access the service').result
    
    while True:
        if code == "carol":
            break
        else:
            if popError() is False:
                sys.exit(0)                
            else:
                code = droid.dialogGetInput('Yes, you need a password to access the service').result            
    return 

# create a message box asking for series ID
def getSeriesId():
    seriesID = droid.dialogGetInput('Key in the Series ID. \
                                    For example: DEXUSEU').result
    return seriesID

# load data given seriesID
def getData(seriesID):
    web = 'http://research.stlouisfed.org/fred2/data/'
    url = web + seriesID.upper() + '.txt'
    
    # if user had the wrong series id, prompt a choice
    
    while True:
        try:
            datafile = urllib2.urlopen(url)
            break
        except:
            if popError() is False:
                sys.exit(0)                
            else:
                seriesID =  getSeriesId()
                url = web + seriesID.upper() + '.txt'
                     
    info = ['Title', 'Series ID', 'Source', 'Frequency', 'Units', 'Date Range']
    for i in xrange(3):
        line = datafile.next()
        info[i] = line
    temp = datafile.next()
    temp = datafile.next()
    info[3] = datafile.next()
    info[4] = datafile.next()
    info[5] = datafile.next()
#     datafile = '/sdcard/' + seriesID.upper() + '.csv'
#    open(datafile,'wb').write(urllib2.urlopen(url).read())

    title = 'Here is your data'
    message = info[0] + info[1] + info[2] + info[3] + info[4] + info[5]
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('Continue')
    droid.dialogSetNegativeButtonText('Cancel')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

def emailAlert():
    title = 'Next'
    message = 'Press CONTINUE to request for time series analysis on the data. The result will be sent to you via email.'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('Continue')
    droid.dialogSetNegativeButtonText('Cancel')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

# send the data to a computer via email 
def sendEmail(seriesID):
    web = 'http://research.stlouisfed.org/fred2/data/'
    url = web + seriesID.upper() + '.txt'
    datafile = urllib2.urlopen(url)
    msg = MIMEText(datafile.read())
    datafile.close()
    
    msg['Subject'] = '[Carol] ' + seriesID.upper()
    msg['From'] = 'carolz1207@gmail.com'
    
    # mailto = droid.dialogGetInput('Email the data to chad.android.app@gmail.com): ').result 
    #chad.android.app@gmail.com
    msg['To'] = 'chad.android.app@gmail.com'
    username = droid.dialogGetInput('Google Username').result
    password = droid.dialogGetPassword('Password', 'For ' + username).result
    
    server = smtplib.SMTP('smtp.gmail.com:587')
    server.ehlo()
    server.starttls()
    
    count = 1                 
    while True:
        try:
            server.login(username,password)
            break
        except:
            count = count + 1
            if count is 5:
                title = 'You tried too many times...'
                message = 'I need to quit.'
                droid.dialogCreateAlert(title, message)
                droid.dialogSetPositiveButtonText('Ok')
                sys.exit(0)
                
            if (popError() is False):
                sys.exit(0)
            else:
                username = droid.dialogGetInput('Google Username').result
                password = droid.dialogGetPassword('Password', 'For ' + username).result
    
    count = 1
    while True:
        try:
            server.sendmail(msg['From'], msg['To'], msg.as_string())
            break
        except:
            count = count + 1
            if count is 5:
                title = 'You tried too many times...'
                message = 'I need to quit.'
                droid.dialogCreateAlert(title, message)
                droid.dialogSetPositiveButtonText('Ok')
                sys.exit(0)
    
            if (popError() is False):
                sys.exit(0)    
    
    server.quit()
    
    # horizontal bar
    horizontal_progress()
        
    # Tell the user the email has been sent
    title = 'Ah Ha!'
    message = 'You just sent the email!'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('OK')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

# this is a general error message that can be called 
def popError():
    title = 'Oops...'
    message = 'Press OK to try again, CANCEL to quit the program.'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('Ok')
    droid.dialogSetNegativeButtonText('Cancel')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

# add progress bar
def horizontal_progress():
    title = 'Be patient'
    message = 'Your phone needs a while'
    droid.dialogCreateHorizontalProgress(title, message, 100)
    droid.dialogShow()
    for x in range(0, 100):
        time.sleep(0.03)
        droid.dialogSetCurrentProgress(x)
    droid.dialogDismiss()
    return True

if __name__ == '__main__':
    # testing if phone is connect to computer
    droid = android.Android()
    if greetings() is False:
        sys.exit(0)
    getPassword()
    # prompt user to key in password to the program
    
    seriesID = getSeriesId()
    
    # download the data and display data info
    if getData(seriesID) is False:
        sys.exit(0)
    # prompt the user to email data
    if emailAlert() is False:
        sys.exit(0)
    # get user email and send
    sendEmail(seriesID)
    droid.makeToast("Check your email in a bit :)")
    


