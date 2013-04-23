# Template for getting information and dynamically build a webpage from the data.
# Data is probably stored in the dictionary format

import android

# HTML template
template = '''<html>
                  <head>
                  </head>
                  <body>
                      <h1>Contacts</h1>
                      <ul id="contacts"></ul>
                      <script type="text/javascript">
                          var droid = new Android();
                          var contacts=droid.contactsGet(['display_name']);
                          var container = document.getElementById('contacts');
                          for (var i=0;i<=contacts.result.length;i++){
                            var data = contacts.result[i];
                            contact = '<li>';
                            contact = contact + data[0];
                            contact = contact + '<li>';
                            container.innerHTML = container.innerHTML + contact;
                          }
                        </script>
                  </body>
                </html>'''

f = open('/sdcard/sl4a/scripts/contacts.html')
f.write(template)
f.close()

droid = android.Android
droid.webViewShow('file:///sdcard/sl4a/scripts/contacts.html')

