import android
import sys
import types

# Test imports.
import android
from bs4 import BeautifulSoup
import gdata.docs.service
import sqlite3
import termios
import time
import urllib2
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# testing if phone is connect to computer
droid = android.Android()

# greetings
def greetings():
    title = 'Hi, this is Chad.'
    message = 'Welcome! I am currently a simple App that performs simple time series analysis for FRED data.'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('Try me')
    droid.dialogSetNegativeButtonText('Cancel')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'

# create a message box asking for series ID
def getSeriesId():
    seriesID = droid.dialogGetInput('Key in the Series ID. \
                                    For example: DEXUSEU').result
    return seriesID

# load data given seriesID
# TODO: add smart error handling for false data request 
# TODO: parse the downloaded data so it's properly comma delimited
def getData(seriesID):
    web = 'http://research.stlouisfed.org/fred2/data/'
    url = web + seriesID.upper() + '.txt'
    datafile = urllib2.urlopen(url)
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
    message = 'Do you want to email the data? '
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
    
    msg['Subject'] = 'The contents of %s' % seriesID
    msg['From'] = 'carolz1207@gmail.com'
    
    # mailto = droid.dialogGetInput('Email the data to chad.android.app@gmail.com): ').result 
    #chad.android.app@gmail.com
    msg['To'] = 'chad.android.app@gmail.com'
    username = droid.dialogGetInput('Google Username').result
    password = droid.dialogGetPassword('Password', 'For ' + username).result
    
    server = smtplib.SMTP('smtp.gmail.com:587')
    server.ehlo()
    server.starttls()
    try:
        server.login(username,password)
    except:
        return False
    # TODO: error hander
    try:
        server.sendmail(msg['From'], msg['To'], msg.as_string())
    except:
        return False
    server.quit()
    
    title = 'Ah Ha!'
    message = 'You just sent an email!'
    droid.dialogCreateAlert(title, message)
    droid.dialogSetPositiveButtonText('OK')
    droid.dialogShow()
    response = droid.dialogGetResponse().result
    return response['which'] == 'positive'
    


# grab the processed data from the folder and plot it
# references: 
# http://pandas.pydata.org/pandas-docs/dev/io.html#csv-text-files
# http://pandas.pydata.org/pandas-docs/dev/visualization.html

# add progress bar
def horizontal_progress():
    title = 'Be patient'
    message = 'Your phone needs a while'
    droid.dialogCreateHorizontalProgress(title, message, 100)
    droid.dialogShow()
    for x in range(0, 100):
        time.sleep(0.1)
        droid.dialogSetCurrentProgress(x)
        droid.dialogDismiss()
    return True

if __name__ == '__main__':
    if greetings() is False:
        sys.exit(0)
    seriesID = getSeriesId()
    droid.makeToast(seriesID)
    # download the data and display data info
    if getData(seriesID) is False:
        sys.exit(0)
    # prompt the user to email data
    if emailAlert() is False:
        sys.exit(0)
    # get user email and send
    sendEmail(seriesID)
    
    
