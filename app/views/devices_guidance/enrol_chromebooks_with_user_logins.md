## Create an organisational unit for these devices

Create an organisational unit called ‘DfE Devices’ in your Google Admin Console.

## Enrol your Chromebooks

Before you enrol your devices, ensure that you have the correct number of Chrome licenses available in your domain by going to ‘Devices’ > ‘Chrome devices’ and clicking the ‘Upgrades’ button in the top right. If you do not have enough licenses for the number of devices you need to enrol and manage, [contact us](/get-support).

Follow these instructions to enrol your devices:

1. Unbox multiple devices and turn on
2. Connect to WiFi
3. On login screen press ‘ctrl’ + ‘alt’ + ‘e’ (or click ‘More options’ > ‘Enterprise Enrollment’)
4. Enter credentials on enrollment screen (use credentials from an account on your domain)
5. Wait for ‘Your Chromebook has been successfully enrolled’ and click ‘Next’

## Deploy Cisco Umbrella on your Chromebooks

The content below is taken from the [Cisco Umbrella Client Deployment Guide](https://protect-eu.mimecast.com/s/0RnpCrmB6fnzpmDtYCsC4?domain=docs.umbrella.com) and has been abbreviated for the purpose of this deployment.

### Installation Guide

There are 3 parts to this installation:

1. Installing the Cisco Umbrella Chromebook client extension on your Chromebooks
2. Installing the Cisco Umbrella Chromebook client application on your Chromebooks
3. (Optional) Installing Cisco Umbrella Root CA

Details of the JSON configuration needed to install Cisco Umbrella Chromebook client application are available in the [Support Portal](https://computacenterprod.service-now.com/dfe). Search for ‘Cisco Umbrella’ within the ‘How do I’ section.

You can also also find instructions for removing Umbrella Chromebook software in the [last section](#Removing-the-Umbrella-clients-from-the-Chrome-devices) of this guide.

#### Prerequisites

The Cisco Umbrella Chromebook client uses the ports below. make sure that:

* Port 53 (UDP) is accessible to [208.67.220.220](https://protect-eu.mimecast.com/s/hoy2Cv8RkfLPGlys0FtmR?domain=208.67.220.220) and [208.67.222.222](https://protect-eu.mimecast.com/s/-_QaCwK2liV47NRhg7CKN?domain=208.67.222.222) on your firewall
* [https://registration.polaris.qq.opendns.com](https://protect-eu.mimecast.com/s/AMEeCx28mHRgyXQsPeuWK?domain=registration.polaris.qq.opendns.com) is accessible from your device

<h4 class="govuk-heading-s" id="part-1-install-the-cisco-umbrella-chromebook-client-extension">Part 1: Install the Cisco Umbrella Chromebook Client Extension</h4>

1. Log into [https://admin.google.com](https://protect-eu.mimecast.com/s/sYqZCy97nS2Qg4yh0jila?domain=admin.google.com).

    ![Google Admin Console](/devices/userlogins1.png)

2. Select **Devices**.

    ![Device Management](/devices/userlogins2.png)

3. In the menu on the left-hand side of the Device Management window, select **Chrome management**.

    ![Select ‘Chrome Management’](/devices/userlogins3.png)

4. In the Chrome Management window, select **Apps & extensions**.

    ![Select ‘Apps and Extensions’](/devices/userlogins4.png)

5. Click ‘Users and Browsers’ and if applicable, select the relevant OU from the left-hand side.
6. Click the yellow + icon in the bottom right-hand corner and choose ‘Add the Chrome app or extension by ID’ option to search for the ID of the Cisco Umbrella Chromebook client extension **jcdhmojfecjfmbdpchihbeilohgnbdci** (searching by name will not work.)

    ![Yellow icon for ‘Add the Chrome App or Extension by ID’](/devices/userlogins5.png)
    ![Add the extension by ID](/devices/userlogins6.png)

7.  Select **Force install**. This ensures that Chromebook users in the selected Organization Unit cannot remove or disable the extension.
8.  Select **Save** (top-right) if necessary. You have finished installing the Cisco Umbrella Chromebook client extension. Proceed with the next section to install the Cisco Umbrella Chromebook client application.

#### Part 2: Install the Cisco Umbrella Chromebook Client Application

1. Repeat the process of adding an app or extension by ID

    ![Screenshot showing locally added App](/devices/userlogins7.png)
    ![Yellow icon for ‘Add the Chrome App or Extension by ID’](/devices/userlogins5.png)

2. Search for the ID of the Cisco Umbrella Chromebook client application **cpnjigmgeapagmdimmoenaghmhilodfg** (Searching by name will not work.)
3. Select **Force install**. This ensures that Chromebook users in the selected Organization Unit cannot remove or disable the application.
4. Find the JSON configuration to enter into the ‘Policy for extensions’ box in the [Support Portal](https://computacenterprod.service-now.com/dfe). Search for ‘Cisco Umbrella’ within the ‘How do I’ section.

    ![Screenshot showing locally added App](/devices/userlogins9.png)

5.  Select Save (top right). You have finished installing the Cisco Umbrella Chromebook client application.

#### Part 3 (Optional) Installing Cisco Umbrella Root CA

Cisco Umbrella highly recommends the following:

* In order to avoid certificate errors when accessing the block page, you must install the Cisco Umbrella root certificate on your Chromebooks. For more information on how to deploy certificates, see [Google’s documentation](https://protect-eu.mimecast.com/s/NuEWCz7QoTwy3rmHY5Hyk?domain=support.google.com) and use the attached Root CA to be uploaded.

The Umbrella root certificate to link your device to the DfE block page can be downloaded from [https://bit.ly/2zr2gM8](https://protect-eu.mimecast.com/s/AfZ9CAMWxflPgR1c4DrQR?domain=bit.ly)

Follow these instructions to deploy the Cisco Umbrella Root CA to your Chrome devices:

1. Head to [https://admin.google.com](https://protect-eu.mimecast.com/s/sYqZCy97nS2Qg4yh0jila?domain=admin.google.com).
2. Click **Devices**.
3. On the left, click **Networks**.
4. Click Certificates > **Create certificate**.

    ![Click ‘Create Certificate’](/devices/userlogins10.png)

5. Give the certificate a name
6. Choose the certificate file to upload and click **Upload**.
7. In the **‘Certificate authority’** section click **‘Chromebook’**

    ![Select ‘Chromebook’](/devices/userlogins11.png)

8. Click ‘Add’ to confirm.
9. After installing the browser extension and Application for the first time, test it by going to [internetbadguys.com](internetbadguys.com) on the Chromebook. A Cisco Umbrella filtering page should appear. It may take a number of minutes after installing the browser extension and app before the blocking comes into effect.

#### Removing the Umbrella clients from the Chrome Devices

If you remove Cisco Umbrella then you are responsible for providing alternative safety software.

To remove Cisco Umbrella from your Chrome devices, follow the instructions below:

1. Follow steps 1 to 5 from [part 1 of this guide](#part-1-install-the-cisco-umbrella-chromebook-client-extension)
2. Click on both the app and extension, then click the bin icon in the <span class="app-no-wrap">right-hand</span> sidebar.

    ![Screenshot showing Force Install](/devices/userlogins12.png)
