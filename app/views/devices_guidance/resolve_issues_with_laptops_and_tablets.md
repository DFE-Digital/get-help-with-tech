## Problems logging into Windows devices

Some users with Windows devices with DfE settings applied may experience a bug that makes it difficualt for them to log in to their laptops and tablets.
Users may find that the login is defaulting to the .\localadmin account and asking for a password, which they will not have.

To fix this issue, laptop users will need to change the username in the login box from ".\localadmin" to ".\localuser" (the dot and backslash are part of the username)/.

* If a local user password has been set, enter the password and press 'Return'
* If no local user password has been set, leave the password blank and press 'Return'

The device will need to connect to the internet so it can receive the fix update. Leave the device turned on, charging and connected to the internet for at least 3 hours for the fix to be applied.

After 3 hours, the device should be restarted. If the fix has been successful, the device should show the username as “localuser”. If the device does not login automatically or the username is not “localuser” at the login prompt, the fix has not been applied and the user should repeat the process.

We’ve illustrated these steps in our [user guidance](/devices/getting-started-with-your-microsoft-windows-device), which you can share with anyone using your Microsoft devices.

You can [contact us](/get-support) if this issue persists after completing these steps.

## Sound issues

Some users have reported issues with the audio output of their devices. Windows updates have been released which should resolve this, but we are making additional solutions available.

### DfE restricted devices

Audio drivers will be installed via Microsoft Intune the next time the device is connected to the internet.

### Standard devices

Download the driver for your device and either include them in your Images or install using the file included in the download. You can manually download updated audio drivers.

* [Download Tactus Geobook audio drivers](https://geo-computers.zendesk.com/hc/en-us/articles/360016119557-GeoBook1E-Drivers)
* [Download Dynabook audio drivers](https://uk.dynabook.com/support/drivers/laptops/)

## PXE boot issues
 
If you are looking to reimage Tactus Geobooks using PXE boot, you may experience difficulties due to there being no RJ54 ethernet port.

The following USB to RJ45 adapters have passed compatibility tests by our delivery partner. We do not promote or recommend any particular devices or manufacturers.

For Tactus Geobooks GE109:

* Belkin F4U047bt (USB-A)
* Belkin B2B048 (USB-A)
* Belkin INC001bt (USB-C)
* Dell 0YX2FJ (USB-A)
* StarTech USB31000S (USB-A)
* StarTech US1GC30B (USB-C)

For Tactus Geobooks GE114:

* StarTech USB31000S (USB-A)

## Additional support
Guidance is available for [ordering and managing laptops and tablets](/devices), [replacing faulty devices](/devices/replace-a-faulty-device), and what to do if you have [technical issues with a 4G wireless router](/devices/resolve-issues-with-4g-wireless-routers). 

[Contact us](/get-support) if you have any other hardware queries.
