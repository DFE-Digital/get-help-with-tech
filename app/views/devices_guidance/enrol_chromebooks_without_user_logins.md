You need to:  

* Ensure you have a role account for your devices
* Configure Chrome management policies if they don’t already exist
* Enrol your Chromebooks
* Deploy and configure Cisco filtering extension

[Watch a video that explains how to set up your Google Admin console](https://www.youtube.com/watch?v=XP6Y_iIi8Dg&feature=youtu.be)

## Create a role account

In your Google Admin Console complete the following:  

1. Create an organisation unit called ‘DfE Devices’
2. Create a user to enrol the Chromebooks

*  The user should be in the ‘DfE devices’ domain (the same one you’re adding the devices to)
*  Make the password something fairly simple as you are going to be using this many times to enroll the Chrome devices

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
      <td class="govuk-table__cell">Please configure a set of web pages that will be most useful to your users</td>
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

#### Apps and Extensions

A top level set of web apps and Chrome extensions can be force installed for all devices at the top level. These can also be customised and different apps deployed at different organisation unit levels. If you have any web apps that you need to deploy, choose ‘Managed guest sessions’ and you can add apps or pin websites to the taskbar using the plus button.

## Enrolling Chromebooks

Before you enrol your devices, please ensure that you have the correct number of Chrome licenses available in your domain by going to ‘Devices’ > ‘Chrome devices’ and click the ‘Upgrades’ button in the top right. If you don’t have enough licenses for the number of devices you need to enrol and manage, please contact [dfepcs@computacenter.com](mailto:dfepcs@computacenter.com).

Follow these instructions to enrol your devices:

1. Unbox multiple devices and turn on
2. Connect to WiFi (open hotspot or ensure hostnames open on network)
3. On login screen press ctrl + alt + e (or click ‘More options’ > ‘Enterprise Enrollment’)
4. Enter credentials on enrollment screen (use the role account you created earlier)
    1. Username: `XXXX@dfeschool.com`
    2. Password: `qqqqwwww`
5. Wait for ‘Your Chromebook has been successfully enrolled’ and click ‘Next’
6. When the device has auto launched in a Managed Guest Session, you can turn it off and repackage it

## Deploy Cisco Umbrella on your Chromebooks

The below content is taken from the [Cisco Umbrella Client Deployment Guide](https://protect-eu.mimecast.com/s/0RnpCrmB6fnzpmDtYCsC4?domain=docs.umbrella.com) and abbreviated for the purpose of this deployment.

### Installation Guide

There are three parts to this installation:

* Installing the Cisco Umbrella Chromebook client extension on your Chromebooks
* Installing the Cisco Umbrella Chromebook client application on your Chromebooks
* \[Optional\] Installing Cisco Umbrella Root CA

You can also find instructions for removing Umbrella Chromebook software in the last section of this guide.

#### Prerequisites

The Cisco Umbrella Chromebook client uses the ports below. Please make sure that:

* Port 53 (UDP) is accessible to [208.67.220.220](https://protect-eu.mimecast.com/s/hoy2Cv8RkfLPGlys0FtmR?domain=208.67.220.220) and [208.67.222.222](https://protect-eu.mimecast.com/s/-_QaCwK2liV47NRhg7CKN?domain=208.67.222.222) on your firewall
* [https://registration.polaris.qq.opendns.com](https://protect-eu.mimecast.com/s/AMEeCx28mHRgyXQsPeuWK?domain=registration.polaris.qq.opendns.com) is accessible from your device

#### Part 1: Install the Cisco Umbrella Chromebook Client Extension

1. Log into [https://admin.google.com](https://protect-eu.mimecast.com/s/sYqZCy97nS2Qg4yh0jila?domain=admin.google.com).

    ![Google Admin Console](/devices/nouserlogins1.png)

2. Select **Device Management**.

    ![Device Management](/devices/nouserlogins2.png)

3. In the menu on the left-hand side of the Device Management window, select **Chrome Management**.

    ![Select ‘Chrome Management’](/devices/nouserlogins3.png)

4. In the Chrome Management window, select **Apps & Extensions**.

    ![Select ‘Apps & Extensions’](/devices/nouserlogins4.png)

5. Click ‘Managed Guest Sessions’ and if applicable, select the relevant OU from the left hand side.
6. Click the yellow + icon (bottom right hand corner) and choose ‘Add the Chrome App or Extension by ID’ option to search for the ID of the Cisco Umbrella Chromebook client extension **jcdhmojfecjfmbdpchihbeilohgnbdci** (Searching by name will not work.)

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
4. Copy the JSON configuration below into the ‘Policy for extensions’ on the right hand side.  

        {
          "googleDirectoryService": {
            "Value": false
          },
          "organizationInfo": {
            "Value": {
              "organizationId": 3478346,
              "regToken": "fCq5QoEewxSHcMhdaPSaV9QidrFRELvN"
            }
          },
          "publicSession": {
            "Value": true
          },
          "vaIPs": {
            "Value": []
          }
        }

    ![Screenshot showing locally added App](/devices/nouserlogins9.png)

5. Select Save (top right). You have finished installing the Cisco Umbrella Chromebook client application.

#### Part 3 \[Optional\] Installing Cisco Umbrella Root CA

Cisco Umbrella highly recommends the following:

* In order to avoid certificate errors when accessing the block page, you must install the Cisco Umbrella root certificate on your Chromebooks. For more information on how to deploy certificates, see [Google's documentation](https://protect-eu.mimecast.com/s/NuEWCz7QoTwy3rmHY5Hyk?domain=support.google.com) and use the attached Root CA to be uploaded.

The Umbrella root certificate to link your device to the DfE Block page can be downloaded from [https://bit.ly/2zr2gM8](https://protect-eu.mimecast.com/s/AfZ9CAMWxflPgR1c4DrQR?domain=bit.ly)

Follow these instructions to deploy the Cisco Umbrella Root CA to your Chrome devices:

1. Head to [https://admin.google.com](https://protect-eu.mimecast.com/s/sYqZCy97nS2Qg4yh0jila?domain=admin.google.com).
2. Click **Devices**.
3. On the left, click **Networks**.
4. Click Certificates > **Create Certificate**.

    ![Click ‘Create Certificate’](/devices/nouserlogins10.png)

5. Give the certificate a name
6. Choose the certificate file to upload and click **Upload**.
7. In the **‘Certificate authority’** section click **‘Chromebook’**.

    ![Select ‘Chromebook’](/devices/nouserlogins11.png)

8. Click Add to confirm.
9. After installing the browser extension and Application for the first time, test it by going to [internetbadguys.com](internetbadguys.com) on the Chromebook. A Cisco Umbrella filtering page should appear. It may take a number of minutes after installing the browser extension and app before the blocking comes into effect.

#### Removing the Umbrella clients from the Chrome Devices

Should you wish to remove Umbrella from the Chrome devices, please follow the instructions below.

1. Follow steps 1 - 5 from Part 1 of this guide
2. Click on both the app and extension and click the bin icon in the right hand sidebar.

    ![Screenshot showing Force Install](/devices/nouserlogins12.png)
