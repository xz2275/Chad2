import android, datetime, smtplib, urllib2
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

seriesID = 'DEXUSEU'
web = 'http://research.stlouisfed.org/fred2/data/'
url = web + seriesID.upper() + '.txt'
datafile = urllib2.urlopen(url)
msg = MIMEText(datafile.read())
datafile.close()

msg['Subject'] = 'The contents of %s' % seriesID
msg['From'] = 'carolz1207@gmail.com'
msg['To'] = 'chad.android.app@gmail.com'

username = 'carolz1207@gmail.com'
password = 'forAndroid'
server = smtplib.SMTP('smtp.gmail.com:587')
server.ehlo()
server.starttls()
server.login(username,password)
server.sendmail(msg['From'], msg['To'], msg.as_string())
server.quit()

print "OK"
