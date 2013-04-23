import android
import pprint
import time
import urllib
import os

# Simple HTML template using python's format string syntax. 
template = '''<html><body> 
<h1>Battery Status</h1> 
<ul> 
<li><strong>Status: %(status)s</li> 
<li><strong>Temperature: %(temperature)s</li> 
<li><strong>Level: %(level)s</li> 
<li><strong>Plugged In: %(plugged)s</li> 
</ul> 
</body></html>''' 

if __name__ == '__main__':     
	droid = android.Android()


    # Wait until we have readings from the battery.     droid.batteryStartMonitoring()     result = None     while result is None:         result = droid.readBatteryData().result         time.sleep(0.5)              # Write out the HTML with the values from our battery reading.     f = open('/sdcard/sl4a/scripts/battstats.html', 'w')     f.write(template % result)     f.close()     # Show the resulting HTML page.     droid.webViewShow('file:///sdcard/sl4a/scripts/battstats.html')

Ferrill, Paul (2011-06-27). Pro Android Python with SL4A (Kindle Locations 3636-3640). Apress. Kindle Edition.  
droid = android.Android()
droid.makeToast("This script is running")


downloads = '/sdcard0/download'
def _reporthook(numblocks, blocksize, filesize, url=None):
     base = os.path.basename(url)
     try:
             percent = min((numblocks*blocksize*100)/filesize,100)
     except:
             percent = 100
     if numblocks !=0:
             droid.dialogSetMaxProgress(filesize)
             droid.dialogSetCurrentProgress(numblocks*blocksize)
 
def main():
    global droid
    droid = android.Android()
    url = droid.getClipboard().result
    dst = droid.dialogGetInput('Filename', 'Save file as:', os.path.basename(url)).restul
    droid.dialogCreateHorizontalProgress('Downloading...', 'Saving %s from web.' %dst)
    droid.dialogShow()
    urllib.urlretrieve(url, downloads + dst, lambda nb, bs, fs, url=url:_reporthook(nb, bs,fs,url))
    droid.dialogDismiss()
    droid.dialogCreateAlert('Operation Finished', '%s has been saved to %s.' % (url, downloads+dst))
    droid.dialogSetPositiveButtonText('OK')
    droid.dialogShow()
 
if __name__ == '__main__':
    main()







# check UIfasade for UI related functions
droid.dialogCreateTimePicker()
droid.dialogShow()
response = droid.dialogGetResponse().result
print str(response['hour']) + ":" + str(response['minute'])

# sending emails from python (can grab whatever needed and send it to the user)
# code in chapter 7 of the book if needed 

# print all the applications in the phone and their location
apps = droid.getLaunchableApplications()
#droid.pick(u'content://contacts/people')
#pprint.pprint(apps.result)
type(apps)

# get contacts from the phone 
contacts = droid.queryContent('content://com.android.contacts/data/phones',\
	['display_name', 'data1'], None,None,None).result
	
for c in contacts:
	print c


# Do a search
droid.search('python')