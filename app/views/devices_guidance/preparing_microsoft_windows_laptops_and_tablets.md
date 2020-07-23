## Managing settings and software

Microsoft Windows devices come with an operating system and security and antivirus software installed. They also include content filtering and remote management settings that are ready to use.

Content filtering and remote management will stop working when the licences expire on 31 March 2021. You can replace the DfE settings with your own at any point.

### Operating system

Microsoft Windows laptops and tablets come with the Windows 10 Pro Education operating system.

### Security and antivirus

Microsoft Windows devices feature Bitlocker disk encryption to protect the privacy of data with TPM 2.0 and include the following security and antivirus software:

* Windows Information Protection
* Windows Defender Credential/System Guard
* Windows Defender Exploit Guard
* Windows Defender Antivirus

### Education software

Microsoft Windows devices do not have Office 365 applications installed, but school-aged children will be able to use Office 365 online, if you or their school have an active subscription. A child or young person not in school (such as a care leaver) can make use of their own preferred online system.

Schools can [apply to get set up on Office 365 Education](https://covid19.thekeysupport.com/remote-learning/) for free. Office 365 Education includes Microsoft Word, Excel and Powerpoint as well as many mobile device management features.

## Mobile device management

Computacenter will send all Microsoft Windows laptops and tablets to you with security settings already configured and managed by the Department for Education (DfE) using Microsoft Intune.

These mobile device management (MDM) settings safeguard children and young people from inappropriate content and prevent them from making changes to files or settings that might stop the device from working. It is not possible to tailor the configured MDM to meet local needs. Anything you try to install yourself may be lost when the DfE MDM is updated every 2 hours.

We will not actively monitor users' activity on the devices. Websites users visit on their devices will not be logged by Cisco Umbrella. Those logs would not be available to the LA or trust but could help ensure that ongoing filtering is effective, for example by letting us test whether it's working after we adjust filtering rules.

You can loan the devices out to users straight away as the MDM will be in place until 31 March 2021. After this, the MDM will expire. The devices will continue to work with the last settings provided by DfE but they will no longer be managed or updated.

**If you remove the MDM provided by DfE or continue using the devices after 31 March 2021, it’s your responsibility to set up alternative safeguarding measures to avoid risks to the children and young people in your care.**

You can take control of the devices at any time by restoring them to factory settings and applying your own remote management solution. This will restore the machine to its original state without any DfE software or settings, and it will no longer be enrolled in the DfE device management system.

## Content filtering

Microsoft Windows devices come with a web-filtering service called Cisco Umbrella installed. This blocks a range of illegal and inappropriate content and limits searching to the ‘Safe Search’ provided by popular search engines.

The web-filtering settings are designed to make the devices safe to use and suitable for a wide range of users from pre-school children up to care leavers.

This filtering should not prevent legitimate use of the devices. Your technical contact will have [access to support](/devices/support-and-maintenance) to report any incident.

The first time the device connects to a new network, there will be a short delay before the content filtering starts to work. This usually takes less than 15 seconds but could take up to 2.5 minutes. During this time, users may be able to access any website without restriction while Cisco Umbrella registers the new device and checks network ports. DfE is working with Cisco to reduce this delay. Any updates made to support this will be deployed to the devices automatically.

When you loan the devices out, it’s important to underline that parents and guardians should supervise the internet use of children and young people in their care. Local authorities should be alert to cases where parents or guardians of children with a social worker may not be in a position to do this.

See government advice on:  

* [safeguarding](https://www.gov.uk/government/publications/closure-of-educational-settings-information-for-parents-and-carers), which signposts parents to trusted providers and includes detailed advice on keeping children safe online (this includes information on home filters, age appropriate parental controls, the risks of platforms and apps, and how to have age appropriate conversations with children about online safety)
* [support for parents and carers to keep children safe from online harm](https://www.gov.uk/government/publications/coronavirus-covid-19-keeping-children-safe-online/coronavirus-covid-19-support-for-parents-and-carers-to-keep-children-safe-online), which outlines resources to help keep children safe from different risks online and where to go to receive support and advice
* [support to stay safe online](https://www.gov.uk/guidance/covid-19-staying-safe-online), which includes information on security and privacy settings

## Installing your own software and settings

To install your own software or replace the mobile device management you will need to restore factory settings on the device. This will remove all of the security and protection features on the device.

You will need to do this for each device individually.

You can technically install software on the devices without resetting them, but the DfE mobile device management may remove it from the device within 2 hours.

Find out [how to access support](/devices/support-and-maintenance) if you need help setting up your own mobile device management.

### Who can request passwords and programs to reset devices

Local admin passwords are needed to reset devices and install new software. An executable program is required to unlock BIOS settings.

For security, only someone nominated as a technical contact for the device order can request this information. The local authority or trust is responsible for keeping this information secure when sharing it with colleagues who are preparing devices for children and young people.

Please see the ‘Request your local admin passwords and BIOS program’ section below to find out how to make a request.

If you’re unsure who your technical contact is, please email [COVID.TECHNOLOGY@education.gov.uk](mailto:COVID.TECHNOLOGY@education.gov.uk) and include the name of the local authority or trust that ordered the devices.

### How to reset Microsoft devices so you can add your own software and settings

To install your own software or replace Cisco Umbrella and Microsoft Intune you’ll need to restore factory settings on the device. This will remove all of the security and protection features on the device.

You’ll need to do this for each device individually.

1.  Request your local admin passwords and BIOS program

    Your technical contact must request these from the XMA support desk before you can reset your devices. For security, schools cannot request these themselves unless they’re a single academy trust that ordered devices directly from Computacenter.

    Your technical contact should email DFE.Support@xma.co.uk and provide the serial numbers for any devices you want to reset. Serial numbers will be provided with the email Computacenter sends to technical contacts when they dispatch your devices.

2.  Restore your device’s factory settings

    **You must ensure the device is connected to power throughout this process.**

    1. Boot the device and login to the local admin account
        1.  Device boots into localuser
        2.  Logout of localuser
        3.  Login as the local admin user: .\\localadmin
        4.  Enter the local admin password for that device, supplied by the XMA support desk

    2.  Enable the recovery partition
        1.  Run the cmd application “as administrator”
        2.  Enable the recovery partition using the command: reagentc /enable
        3.  The output should say: “Operation Successful”
        4.  Check the partition status using the command: reagentc /info
        5.  The partition should now be: “Enabled”

    3.  Unlock the device BIOS

        1.  Follow the instructions provided by XMA which will be correct for your device type. This usually includes running a program “as administrator” which removes password protection from the BIOS and enables network and USB boot options, but please refer to instructions from the XMA support team.

    4.  Logout with “change user” to get to the login screen

        1.  Hold <shift> and click on the power icon and then “restart”
        2.  The device should enter a “Troubleshoot” menu
        3.  Select “reset this PC”
        4.  Select “remove everything”
        5.  If the above sequence doesn’t work then you should be able to enter recovery mode using the relevant key combination for the device manufacturer at boot:
            * HP: press F9 key
            * ASUS: press F9 key “continuously”
            * Lenovo: press FN+F11 keys at the same time
            * Dynabook (Toshiba): press and hold 0 (zero) key

    5.  The device should reboot into “Reset this PC”

        1.  Select “No - remove provisioning packages...”
        2.  Select “Clean the drive fully”
        3.  Select “reset” to confirm

3.  Install your own software

    You can install your own software, settings and MDM once the device has been reset. If you need help setting up your MDM, please contact the XMA service desk by emailing [DFE.Support@xma.co.uk](mailto:DFE.Support@xma.co.uk).

## About Cisco Umbrella and Microsoft Intune

Cisco Umbrella is a web-filtering solution pre-installed on devices that prevents users from accessing illegal or inappropriate content. Microsoft Intune is a mobile device management solution installed on devices to prevent users from making changes, such as removing security settings and installing software.

The DfE’s pre-installed settings will be in place until 31 March 2021. After this, the devices will continue to work with the last settings installed by Intune, but will no longer be managed or updated.

It‘s not possible to tailor the pre-installed settings to meet local needs. You may find you can make changes, such as installing additional software, but these changes may be overwritten by Intune when it next updates the device.

The only way you can add your own long-term settings to the device is by restoring it to its original state, removing Microsoft Intune and Cisco Umbrella.

Bitlocker encryption has not been enabled on the devices to make it easier for you to reimage them. We recommend adding these settings when you reset devices to protect the data that users store on devices.

**If you remove the pre-installed settings provided by DfE, it’s your responsibility to set up alternative safeguarding measures to avoid risks to the children and young people in your care.**

## User guidance for young people and their carers

User guides on setting up Microsoft devices are available for download. You can share these with young people and their parents, guardians and carers.

Each user guide includes space for you to enter contact information for the person or team offering IT support to device users.

* [Microsoft devices: User guidance](/devices/getting-started-with-your-microsoft-windows-device)
