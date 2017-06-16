Using Orthanc
=============

You have successfully installed the Windows package of Orthanc by
Osimis! Orthanc is now running as a Windows service in the
background.

By default, Orthanc listens to incoming DICOM connections on TCP port
4242 and incoming HTTP connections on TCP port 8042.

You can interact with Orthanc by opening its administrative Web
interface, that is called "Orthanc Explorer". This can be done by
clicking the link in the Start Menu or by opening your web browser at
http://127.0.0.1:8042/app/explorer.html. Please remember that Orthanc
Explorer does not support Microsoft Internet Explorer.

Content of the package 17.6.0
-----------------------------

Orthanc server                        1.2.0
Osimis Web viewer plugin              0.9.0
Modality worklists plugin             1.2.0
Serve folders plugin                  1.2.0
Orthanc Web viewer plugin             2.2
DICOMweb plugin                       0.3
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4


Folders
-------

* STORAGE: During the installation, you were asked to choose a storage
  folder where Orthanc stores its database. By default, this folder is
  "C:\Orthanc". Running the uninstaller will remove the Orthanc
  program files from your system, but it will not delete this storage
  folder.

  If you wish to delete the data Orthanc has saved, delete this
  storage folder (e.g. C:\Orthanc) after uninstalling Orthanc. Keep
  this in mind if you use Orthanc to store protected health
  information (PHI).

* CONFIGURATION: The Orthanc configuration files can be found inside
  the folder "Configuration" within the installation directory. A
  shortcut to the configuration folder is present in the Start Menu to
  access and modify it more easily.

* LOGS: The Orthanc log files can be found inside the folder "Logs"
  within the installation directory.

* PLUGINS: By default, Orthanc will look within the "Plugins" folder
  within the installation directory to find its plugins.


Troubleshooting
---------------

1. Verify that the service called "Orthanc" is running using the
   Services control panel (for quick access, launch the command
   "services.msc").

2. Make sure you do not use Internet Explorer to open Orthanc
   Explorer, but rather Chrome or Firefox.

3. Verify that your firewall is configured to allow inbound
   connections to the TCP ports Orthanc is listening on (by default,
   4242 and 8042).

4. Verify that no other applications are using the ports that Orthanc
   is listening on. For instance, Juniper is known to also use the
   port 4242 for its VPN solutions.

5. By default, remote access to Orthanc Explorer is disallowed for
   security reasons. Turn the option "RemoteAccessAllowed" to "true"
   in the Orthanc configuration file if you wish to access Orthanc
   from another computer.

6. Check the Orthanc logs in the "Logs" folder within the installation
   directory.

7. Check the Orthanc Book and associated FAQ:
   https://orthanc.chu.ulg.ac.be/book/index.html
   https://orthanc.chu.ulg.ac.be/book/faq.html

8. Post a request for help to the Orthanc Users group:
   https://groups.google.com/forum/#!forum/orthanc-users


Homepage
--------

You can find more information at the official homepage of Orthanc:
http://www.orthanc-server.com/


Note
----

The content of this file is adapted from the unofficial Windows
installer of Orthanc developed by Lury:
https://github.com/luryco/OrthancService/blob/master/InstallerAssets/README.txt
