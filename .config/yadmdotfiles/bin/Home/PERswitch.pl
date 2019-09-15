#!/usr/bin/env perl
# GUI frontent for obdev's usbtool specificaly designed to send commands to a
#+custom build usb power switch. Other handy tools are implemented as well (such
#+as the wiiremote script starter). This is a rather customized script for
#+personal use.
# by con-f-use@gmx.net

# INCLUDES AND GLOBALS
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';
use utf8;

$usbtool = "/home/confus/misc/gbin/usbtool -w -P PERswitch control in vendor device";

################################################################################
################################### CALLBACKS ##################################
################################################################################

# CALLBACK TO OPEN THE MENU
sub popupMenu {
    ($widget, $button, $time) = @_;
    # update pin status
    $i = 0;
    foreach( @menuItem ) {
        $i++;
        $itmLabel = $_->get_child;
        $itmTxt = $itmLabel->get_label;
        $itmTxt =~ s/\ (off|on)$//;
        $usbReturn = qx($usbtool 1 0x020$i 0);
        if($usbReturn =~ /.*0x00.*/) {
            $itmLabel->set_label("$itmTxt off");
            @pinState[$i] = 0;
        } else {
            $itmLabel->set_label("$itmTxt on");
            @pinState[$i] = 1;
        }
    }
    # open menu
    ($x, $y, $push_in) = Gtk2::StatusIcon::position_menu($menu, $widget);
    $menu->show_all();
    $menu->popup( undef, undef, sub{return ($x,$y,0)}, undef, $button, $time);
}

# CALLBACK TO START THE WIIMOTE REMOTE CONTROL SCRIPT
sub wiimote {
    if( fork()==0 ) {
        system('gnome-terminal -x python /home/confus/misc/gbin/wiifus.py');
        exit 0;
    }
}

# CALLBACK FOR THE ACTUAL SWITCHING
sub togglePin {
    $pin = @_[1];
    $call = @pinState[$pin] == 1 ? 0 : 1;
    if($pin == 1) {
        system("gksudo umount /dev/mapper/crypt1; $usbtool 2 0x020$pin $call");
        return;
    }
    system("$usbtool 2 0x020$pin $call");
    print $pin;
}

################################################################################
################################# INITIALISATION ###############################
################################################################################

#CREATE STATUS ICON
$status_icon = Gtk2::StatusIcon->new_from_stock('gtk-preferences');
$status_icon->set_tooltip("Controls a custom build power switch");
$status_icon->signal_connect('popup-menu', \&popupMenu);
$status_icon->signal_connect('activate', \&popupMenu);
$status_icon->set_visible(1);

# CREATE MENU
$menu = Gtk2::Menu->new();

# item for the wiimote handle script
$menuItem = Gtk2::MenuItem->new('Wiimote');
$menuItem->signal_connect('activate', \&wiimote );
$menu->append($menuItem);

# one item for each channel of the switch
$menu->append(Gtk2::SeparatorMenuItem->new);
$i = 0;
foreach ("Scanner","Sound","Drucker","Platte","unused 2") {
    $i++;
    $menuItem = Gtk2::MenuItem->new($_);
    $menuItem->signal_connect('activate', \&togglePin, $i);
    $menu->append($menuItem);
    push (@menuItem, $menuItem);    #holds all menu items related to the switch
    push (@pinState, 0);            #holds their status (on|off)
}

# quit button
$menu->append(Gtk2::SeparatorMenuItem->new);
$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-quit');
$menuItem->signal_connect('activate', sub{Gtk2->main_quit();} );
$menu->append($menuItem);

Gtk2->main();
