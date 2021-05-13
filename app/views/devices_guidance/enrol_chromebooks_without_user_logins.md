To do this you need to:

* ensure you have a role account for your devices
* configure Chrome management policies if they do not already exist
* enrol your Chromebooks
* deploy and configure Cisco filtering extension


[Watch a video that explains how to set up your Google Admin console](https://www.youtube.com/watch?v=XP6Y_iIi8Dg&feature=youtu.be)

## Create a role account

Complete the following steps in your Google Admin Console:

1. Create an organisation unit called ‘DfE Devices’
2. Create a user to enrol the Chromebooks

*  The user should be in the ‘DfE devices’ domain (the same one you’re adding the devices to)
*  Make the password something fairly simple as you are going to be using this many times to enrol the Chrome devices

## Configure Chrome management policies

In your Admin console head to ‘Devices’ > ‘ Chrome Management’.

You’ll then need to go into each section and configure the following policies:

### User and browser settings

<table class="govuk-table">
  <thead class="govuk-table__head">
    <tr class="govuk-table__row">
      <th scope="col" class="govuk-table__header">Policy</th>
      <th scope="col" class="govuk-table__header">Configuration</th>
    </tr>
  </thead>
  <tbody class="govuk-table__body">
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Device enrollment</th>
      <td class="govuk-table__cell">Place Chrome device in user organisation</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Enrollment permissions</th>
      <td class="govuk-table__cell">Allow users in this organisation to enrol new devices</td>
    </tr>
  </tbody>
</table>

### Device settings

<table class="govuk-table">
  <thead class="govuk-table__head">
    <tr class="govuk-table__row">
      <th scope="col" class="govuk-table__header">Policy</th>
      <th scope="col" class="govuk-table__header">Configuration</th>
    </tr>
  </thead>
  <tbody class="govuk-table__body">
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Forced re-enrollment</th>
      <td class="govuk-table__cell">Force device to re-enrol after wiping</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Verified access</th>
      <td class="govuk-table__cell">Enable for content protection</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Sign-in restriction</th>
      <td class="govuk-table__cell">Do not allow any user to sign in</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Accessibility control</th>
      <td class="govuk-table__cell">Allow user to control accessibility settings on the sign-in screen</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Auto-update settings</th>
      <td class="govuk-table__cell">Allow auto-updates</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Managed guest session</th>
      <td class="govuk-table__cell">Auto-launch managed guest session</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Device reporting</th>
      <td class="govuk-table__cell">
        Disable device state reporting
        <br>
        Disable tracking of recent device users
      </td>
    </tr>
  </tbody>
</table>

#### Managed Guest session settings

<table class="govuk-table">
  <thead class="govuk-table__head">
    <tr class="govuk-table__row">
      <th scope="col" class="govuk-table__header">Policy</th>
      <th scope="col" class="govuk-table__header">Configuration</th>
    </tr>
  </thead>
  <tbody class="govuk-table__body">
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Managed guest session</th>
      <td class="govuk-table__cell">Auto-launch managed guest session</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Custom terms of service</th>
      <td class="govuk-table__cell">Optional</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Action on lid close</th>
      <td class="govuk-table__cell">Sleep or logout</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Incognito mode</th>
      <td class="govuk-table__cell">Disallow incognito mode</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Pages to load on startup</th>
      <td class="govuk-table__cell">Configure a set of web pages that will be most useful to your users</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">SafeSearch and Restricted mode</th>
      <td class="govuk-table__cell">Enforce Google safe search and moderate restricted mode on YouTube</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Managed bookmarks</th>
      <td class="govuk-table__cell">Configure useful bookmarks for your users</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Bookmark bar</th>
      <td class="govuk-table__cell">Enable bookmark bar</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Accessibility options in the system tray menu</th>
      <td class="govuk-table__cell">Show accessibility options in the system tray menu</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">External storage devices</th>
      <td class="govuk-table__cell">Allow external storage devices</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Download restrictions</th>
      <td class="govuk-table__cell">Block dangerous downloads</td>
    </tr>
  </tbody>
</table>

#### Apps and extensions

A top-level set of web apps and Chrome extensions can be force installed for all devices at the top level. These can also be customised and different apps deployed at different organisation unit levels. If you have any web apps that you need to deploy, choose ‘Managed guest sessions’ and you can add apps or pin websites to the taskbar using the ‘+’ button.

## Enrolling Chromebooks

Before you enrol your devices, ensure that you have the correct number of Chrome licenses available in your domain by going to ‘Devices’ > ‘Chrome devices’ and click the ‘Upgrades’ button in the top right. If you do not have enough licenses for the number of devices you need to enrol and manage, [contact us](/get-support).

Follow these instructions to enrol your devices:

1. Unbox multiple devices and turn on
2. Connect to WiFi (open hotspot or ensure hostnames open on network)
3. On login screen press ‘ctrl’ + ‘alt’ + ‘e’ (or click ‘More options’ > ‘Enterprise Enrollment’)
4. Enter credentials on enrollment screen (use the role account you created earlier)
    1. Username: `XXXX@dfeschool.com`
    2. Password: `qqqqwwww`
5. Wait for ‘Your Chromebook has been successfully enrolled’ and click ‘Next’
6. When the device has auto launched in a Managed Guest Session, you can turn it off and repackage it

## Deploy Cisco Umbrella on your Chromebooks

<div class="govuk-inset text govuk-!-margin-bottom-4">
  <p class="govuk-body govuk-!-margin-bottom-0">
    Licenses for Cisco Umbrella provided with Chromebooks will expire on 30 September 2021. It’s your responsibility to avoid risks to the online safety of the children and young people you are providing devices to. You can arrange for your own Cisco Umbrella licenses to extend beyond 30 September 2021 or enable alternative security settings.
  </p>
</div>

The below content is taken from the [Cisco Umbrella Client Deployment Guide](https://protect-eu.mimecast.com/s/0RnpCrmB6fnzpmDtYCsC4?domain=docs.umbrella.com) and abbreviated for the purpose of this deployment.

### Installation Guide

There are 3 parts to this installation:

1. Installing the Cisco Umbrella Chromebook client extension on your Chromebooks
2. Installing the Cisco Umbrella Chromebook client application on your Chromebooks
3. (Optional) Installing Cisco Umbrella Root CA

Details of the JSON configuration needed to install Cisco Umbrella Chromebook client application are available in the [Support Portal](https://computacenterprod.service-now.com/dfe). Search for 'Cisco Umbrella' within the 'How do I' section.

You can also find instructions for removing Umbrella Chromebook software in the [last section of this guide](#Removing-the-Umbrella-clients-from-the-Chrome-Devices).

#### Prerequisites

The Cisco Umbrella Chromebook client uses the ports below. Make sure that:

* Port 53 (UDP) is accessible to [208.67.220.220](https://208.67.220.220) and [208.67.222.222](https://208.67.222.222) on your firewall
* [https://registration.polaris.qq.opendns.com](https://registration.polaris.qq.opendns.com) is accessible from your device

<h4 class="govuk-heading-s" id="part-1-install-the-cisco-umbrella-chromebook-client-extension">Part 1: Install the Cisco Umbrella Chromebook Client Extension</h4>

1. Log into [https://admin.google.com](https://admin.google.com).

    ![Google Admin Console](/devices/nouserlogins1.png)

2. Select **Devices**.

    ![Device Management](/devices/nouserlogins2.png)

3. In the menu on the left-hand side of the Device Management window, select **Chrome management**.

    ![Select ‘Chrome Management’](/devices/nouserlogins3.png)

4. In the Chrome Management window, select **Apps & extensions**.

    ![Select ‘Apps & Extensions’](/devices/nouserlogins4.png)

5. Click ‘Managed Guest Sessions’ and if applicable, select the relevant OU from the left hand side.
6. Click the yellow + icon (bottom right hand corner) and choose ‘Add the Chrome app or extension by ID’ option to search for the ID of the Cisco Umbrella Chromebook client extension **jcdhmojfecjfmbdpchihbeilohgnbdci** (Searching by name will not work.)

    ![Yellow icon for ‘Add the Chrome App or Extension by ID’](/devices/nouserlogins5.png)

7. Select **Force Install**. This ensures that Chromebook users in the selected Organization Unit cannot remove or disable the extension.
8. Select **Save** (top right) if necessary. You have finished installing the Cisco Umbrella Chromebook client extension. Next, proceed with the next section to install the Cisco Umbrella Chromebook client application.

#### Part 2: Install the Cisco Umbrella Chromebook Client Application

1. Repeat the process of adding an app or extension by ID

    ![Add the extension by ID](/devices/nouserlogins6.png)

    ![Click the yellow ‘+’ icon](/devices/nouserlogins7.png)

    ![Select ‘Force install’](/devices/nouserlogins8.png)

2. Search for the ID of the Cisco Umbrella Chromebook client application **cpnjigmgeapagmdimmoenaghmhilodfg** (Searching by name will not work.)
3. Select **Force Install**. This ensures that Chromebook users in the selected Organization Unit cannot remove or disable the application.
4. Find the JSON configuration to enter into the ‘Policy for extensions’ box in the [Support Portal](https://computacenterprod.service-now.com/dfe). Search for 'Cisco Umbrella' within the 'How do I' section.

    ![Screenshot showing locally added App](/devices/nouserlogins9.png)

5. Select Save (top right). You have finished installing the Cisco Umbrella Chromebook client application.

#### Part 3 (Optional) Installing Cisco Umbrella Root CA

Cisco Umbrella highly recommends the following:

* In order to avoid certificate errors when accessing the block page, you must install the Cisco Umbrella root certificate on your Chromebooks. For more information on how to deploy certificates, see [Google's documentation](https://support.google.com) and use the attached Root CA to be uploaded.

The Umbrella root certificate to link your device to the DfE Block page can be downloaded from [https://bit.ly/2zr2gM8](https://protect-eu.mimecast.com/s/AfZ9CAMWxflPgR1c4DrQR?domain=bit.ly)

Follow these instructions to deploy the Cisco Umbrella Root CA to your Chrome devices:

1. Head to [https://admin.google.com](https://admin.google.com).
2. Click **Devices**.
3. On the left, click **Networks**.
4. Click Certificates > **Create certificate**.

    ![Click ‘Create Certificate’](/devices/nouserlogins10.png)

5. Give the certificate a name
6. Choose the certificate file to upload and click **Upload**.
7. In the **‘Certificate authority’** section click **‘Chromebook’**.

    ![Select ‘Chromebook’](/devices/nouserlogins11.png)

8. Click Add to confirm.
9. After installing the browser extension and application for the first time, test it by going to [internetbadguys.com](https://internetbadguys.com) on the Chromebook. A Cisco Umbrella filtering page should appear. It may take a number of minutes after installing the browser extension and app before the blocking comes into effect.

#### Removing the Umbrella clients from the Chrome Devices

If you remove Cisco Umbrella, you are responsible for providing alternative safety software.

To remove Cisco Umbrella from your Chrome devices, follow the instructions below:

1. Follow steps 1 to 5 from [part 1 of this guide](#part-1-install-the-cisco-umbrella-chromebook-client-extension)
2. Click on both the app and extension and click the bin icon in the right-hand sidebar.

    ![Screenshot showing Force Install](/devices/nouserlogins12.png)
