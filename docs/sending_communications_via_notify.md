# Sending communications via GOV.UK Notify

## GOV.UK Notify

The Notify site for our project is found at 
https://www.notifications.service.gov.uk/services/71eea423-f9c5-4b7f-aac9-c88a4ca4dea2

## Using Notify in the code

The code uses Rails mailers but not to actually deliver e-mails.
Instead they communicate to Notify which performs the delivery on our behalf.
This approach keeps our service consistent with other GOV.UK services and allows
alternative communication methods such as postal mail.

There are no e-mail templates within the Rails codebase. Mailers
are still used but only to deliver the relevant variables to Notify
(where the templates are stored) which actually
delivers communication to recipients. (Specs for our mailers
test that the variables are set correctly). Rails sends these messages
asynchronously in a background job.

## The Notify Web app

When creating a new template in Notify, there's a "Template ID" which needs
to pasted back into the Rails app (`config/settings.yml`).

Mailshot e-mails (which aren't sent in response to some event occurring
within the app) are sent via Notify. To send to a large group
we upload a CSV with a row for each set of attributes required
by the template. This is usually for a large group of recipients
and happens occasionally.
