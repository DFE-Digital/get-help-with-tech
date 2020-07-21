## Create an org unit for these devices

Create an organisation unit called ‘DfE Devices’ in your Google Admin Console.

## Enrol your Chromebooks

Before you enrol your devices, please ensure that you have the correct number of Chrome licenses available in your domain by going to ‘Devices’ > ‘Chrome devices’ and click the ‘Upgrades’ button in the top right. If you don’t have enough licenses for the number of devices you need to enrol and manage, please contact [dfepcs@computacenter.com](mailto:dfepcs@computacenter.com).

Follow these instructions to enrol your devices:

1. Unbox multiple devices and turn on
2. Connect to WiFi
3. On login screen press ctrl + alt + e (or click ‘More options’ > ‘Enterprise Enrollment’)
4. Enter credentials on enrollment screen (use credentials from an account on your domain)
5. Wait for ‘Your Chromebook has been successfully enrolled’ and click ‘Next’

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

    ![Google Admin Console](/devices/userlogins1.png)

2. Select **Device Management**.

    ![Device Management](/devices/userlogins2.png)

3. In the menu on the left-hand side of the Device Management window, select **Chrome Management**.

    ![Select ‘Chrome Management’](/devices/userlogins3.png)

4. In the Chrome Management window, select **Apps & Extensions**.

    ![Select ‘Apps and Extensions’](/devices/userlogins4.png)

5. Click ‘Users and Browsers’ and if applicable, select the relevant OU from the left hand side.
6. Click the yellow + icon (bottom right hand corner) and choose ‘Add the Chrome App or Extension by ID’ option to search for the ID of the Cisco Umbrella Chromebook client extension **jcdhmojfecjfmbdpchihbeilohgnbdci** (Searching by name will not work.)

    ![Yellow icon for ‘Add the Chrome App or Extension by ID’](/devices/userlogins5.png)
    ![Add the extension by ID](/devices/userlogins6.png)

7.  Select **Force Install**. This ensures that Chromebook users in the selected Organization Unit cannot remove or disable the extension.
8.  Select **Save** (top right) if necessary. You have finished installing the Cisco Umbrella Chromebook client extension. Next, proceed with the next section to install the Cisco Umbrella Chromebook client application.

#### Part 2: Install the Cisco Umbrella Chromebook Client Application

1. Repeat the process of adding an app or extension by ID

    ![Screenshot showing locally added App](/devices/userlogins7.png)
    ![Yellow icon for ‘Add the Chrome App or Extension by ID’](/devices/userlogins5.png)

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
            "Value": false
          },
          "vaIPs": {
            "Value": []
          }
        }

    ![Screenshot showing locally added App](/devices/userlogins9.png)

5.  Select Save (top right). You have finished installing the Cisco Umbrella Chromebook client application.

#### Part 3 \[Optional\] Installing Cisco Umbrella Root CA

Cisco Umbrella highly recommends the following:

* In order to avoid certificate errors when accessing the block page, you must install the Cisco Umbrella root certificate on your Chromebooks. For more information on how to deploy certificates, see [Google's documentation](https://protect-eu.mimecast.com/s/NuEWCz7QoTwy3rmHY5Hyk?domain=support.google.com) and use the attached Root CA to be uploaded.

The Umbrella root certificate to link your device to the DfE Block page can be downloaded from [https://bit.ly/2zr2gM8](https://protect-eu.mimecast.com/s/AfZ9CAMWxflPgR1c4DrQR?domain=bit.ly)

Follow these instructions to deploy the Cisco Umbrella Root CA to your Chrome devices:

1. Head to [https://admin.google.com](https://protect-eu.mimecast.com/s/sYqZCy97nS2Qg4yh0jila?domain=admin.google.com).
2. Click **Devices**.
3. On the left, click **Networks**.
4. Click Certificates > **Create Certificate**.

    ![Click ‘Create Certificate’](/devices/userlogins10.png)

5. Give the certificate a name
6. Choose the certificate file to upload and click **Upload**.
7. In the **‘Certificate authority’** section click **‘Chromebook’**

    ![Select ‘Chromebook’](/devices/userlogins11.png)

8. Click Add to confirm.
9. After installing the browser extension and Application for the first time, test it by going to [internetbadguys.com](internetbadguys.com) on the Chromebook. A Cisco Umbrella filtering page should appear. It may take a number of minutes after installing the browser extension and app before the blocking comes into effect.

#### Removing the Umbrella clients from the Chrome Devices

If you remove Cisco Umbrella then you are responsible for providing alternative safety software.

Should you wish to remove Umbrella from the Chrome devices, please follow the instructions below.

1. Follow steps 1 - 5 from Part 1 of this guide
2. Click on both the app and extension and click the bin icon in the right hand sidebar.

    ![Screenshot showing Force Install](/devices/userlogins12.png)
