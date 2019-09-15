#!/usr/bin/python2
"""
This script provides an appindicator user interface to the custom usb periphery
switch 'perswitch'. It detects if the perswitch is connected and sets it's menu
labels accordingly. By click on a label the user can turn the electrical power
of the respective device on and off.

Tested with Ubuntu 12.04 LTS, September 1, 2012 when I was a python n00b
Written by con-f-use@gmx.net
"""
################################################################################
# INCLUDES
################################################################################

import subprocess   # Call the program PERScom wich does the actual swtiching
import re           # Regular expression substitution
import appindicator # Appindicator as user interface (will create a tray icon under Ubuntu and most modern Linux distributions)
import gtk          # Menus in the appindicator tray icon
from pyudev import Context, Monitor          # Monitor perswitch being plugged/unplugged
from pyudev.glib import GUDevMonitorObserver # Under Ubuntu install with 'sudo apt-get install python-pyudev'
import dbus
from dbus.mainloop.glib import DBusGMainLoop

perscom = '~/PERScom' # home/confus/misc/gbin/PERScom

################################################################################
# IMPORTANT GLOBALS
################################################################################

menu_items = []     # Menu items in the
handler_ids = []    # Handler id's for the menu signal connections
perswitch = None    # Udev device of the perswitch (identifier)

if 'Ubuntu' in subprocess.check_output('lsb_release -i'):
    perscom = '/home/confus/sync/gbin/PERScom'

################################################################################
# FUNCTIONS AND CALLBACKS
################################################################################

def pin_status(pin):
    command = "%s 2 %d status | grep -oE '(on|off)$'" % (perscom,pin+1)
    command = subprocess.check_output(command, shell=True)
    return re.sub("\n\s*\n*", "", command)

def pin_toggle(pin):
    """Toggles the pin status, i.e. the power on a periphery device connected to a certain pin number of the perswitch."""
    command = "%s 2 %d toggle | grep -oE '(on|off)$'" % (perscom,pin+1)
    command = subprocess.check_output(command, shell=True)
    return re.sub("\n\s*\n*", "", command)

def menuitem_response_callback(w, pin):
    """Handles the clicking of a menu item: Updates label and toggles pin."""
    pin_toggle(pin)
    text = menu_items[pin].get_child().get_text()
    status = pin_status(pin)
    text = re.sub("(on|off)$", status, text)
    menu_items[pin].get_child().set_text(text)
    print status, pin

def wiifus_callback(w):
    subprocess.Popen("gnome-terminal -x python /home/confus/misc/gbin/wiifus.py", shell=True)

def perswitch_added_callback(observer, device):
    """Sets labels and signals for the menu items if the perswitch is connected."""
    global perswitch
    global hander_ids
    if 'product' in device:
        if device.attributes['product'] == u'PERswitch':
            perswitch = device
            print device.attributes['product']
            for j in range(0,5):
                text = menu_items[j].get_child().get_text()
                text = re.sub("(on|off|n\.a\.)$", pin_status(j), text)
                menu_items[j].get_child().set_text(text)
                handler_ids[j] = menu_items[j].connect("activate", menuitem_response_callback, j)
            return
        else: print 'No perswitch currently connected'
    else: print 'No product in device?', device.attributes.__repr__

def perswitch_removed_callback(observer, device):
    """Unsets labels and signals for the menu items when perswitch is disconnected."""
    if device == perswitch:
        print "Removed."
        for j in range(0,5):
            text = menu_items[j].get_child().get_text()
            text = re.sub("(on|off)$", "n.a.", text)
            menu_items[j].get_child().set_text(text)
            menu_items[j].disconnect(handler_ids[j])

# Update list on resume
def handle_resume_callback():
    print 'resuming'
    for device in context.list_devices(subsystem='usb'): #loop all usb devices
        perswitch_added_callback(None, device) # searches for the perswitch and sets the menu entries

################################################################################
# MAIN CODE
################################################################################

# CREATE INDICATOR
if __name__ == "__main__":
    ind = appindicator.Indicator(
        'perswitch',
        'emblem-cool',#'gdu-smart-unknown'
        appindicator.CATEGORY_OTHER
    )
    ind.set_status (appindicator.STATUS_ACTIVE)

# CREATE MENU
menu = gtk.Menu()

# devices
for j, label in enumerate(["Scanner","Sound","Drucker","Platte","unused"]):
    menu_items.append(gtk.MenuItem("%s - n.a." % label))
    menu.append( menu_items[j] )
    handler_ids.append( -1*j )
    menu_items[j].show()
# other items
tmp = gtk.SeparatorMenuItem()
menu.append(tmp)
tmp.show()
wiifus = gtk.MenuItem('wiifus')
wiifus.connect('activate', wiifus_callback)
menu.append(wiifus)
wiifus.show()
tmp = gtk.MenuItem('Quit')
tmp.connect('activate', gtk.main_quit)
menu.append(tmp)
tmp.show()

# HANDLE CONNECT AND DISCONNECT OF THE PERSWITCH
# Find out the device path of our perswitch
context = Context()
handle_resume_callback()

# Monitor changes to the connection status of perswitch
monitor = Monitor.from_netlink(context)
monitor.filter_by(subsystem='usb')
observer = GUDevMonitorObserver(monitor)
observer.connect('device-added', perswitch_added_callback)
observer.connect('device-removed', perswitch_removed_callback)
monitor.enable_receiving()

# Detect hibernate/resume
DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
bus.add_signal_receiver(handle_resume_callback, 'Resuming', 'org.freedesktop.UPower', 'org.freedesktop.UPower')

# USE THE WHOLE THING
ind.set_menu(menu)
gtk.main()
