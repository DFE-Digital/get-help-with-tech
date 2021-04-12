# Zendesk

## Introduction

The project's Zendesk is at https://get-help-with-tech-education.zendesk.com/

Zendesk is used for:

* managing support tickets
* tracking orders

In the app there are Google Forms which could generate a Zendesk ticket.

The support team might ask us to extract ticket data, for example, data related to macros.
(In Zendesk, "macros" are template responses to common queries.)
Also they might want a list of all users to see if DfE can save on licensing costs, say.

## The "Zendesk Macro Statistics" spreadsheet

The support team periodically (and manually) perform a 
CSV export and import it into a new sheet within a spreadsheet
they maintain on Google Drive.

Sometimes support erroneously use "set tags" rather than "add tags"
(it replaces the set of existing tags with just one
selected tag). For this reason "set tags" and "add tags" appear in the CSV
just in case mistakes have been made.

To export the CSV within our app:

1. Click "Zendesk statistics"
1. Click "Get information about macros"

### Zendesk admin

Administration is mainly managed by Hugh Brown and Anita Holcroft.

#### Macros

In Zendesk they're found under `Admin > Macros`.

The macro name *must* be formatted correctly, otherwise you can't export a CSV.
A correct example is `[Allocations - 4G]:: Allocation request - More evidence required`

#### Tokens

You can generate a token locally for testing at `Admin > API`.

`ghwt+support+admin` is the user account for production (and has a token already set up).

## How a service user generates a Zendesk ticket 

We'd like to encourage service users to provide their queries via a form rather 
than e-mail because then we're collecting structured data, however
the Zendesk form has been implemented relatively recently in the service (at the time of
writing this document in Apr 2021) so we'll still have many existing users wanting to continue to 
e-mail us.

Within our app, users will need to go to `Contact Us > Get Support`. 
This will create a single ticket which could have multiple categories 
(depending on the number of checkboxes the user ticked within the wizard). 
When the user clicks "Submit request", the Zendesk ticket is created.
Our app then responds with a ticket ID. 

(Occasionally, the e-mail sent out with the reference number is blocked by spam filters).

### Development

For local dev and review apps, the ticket ID is randomly generated 
(so is meaningless but allows us to see the flow within these environments).

## Code

The code uses the [zendesk-api](https://github.com/doximity/zendesk_api) gem.
Our app mainly uses Zendesk's support API.

### `app/services/zendesk_service.rb`

The magic numbers in the `CUSTOM_FIELD_IDS` hash are pasted from Zendesk.

### `app/models/support_ticket.rb`

This serves to store the ticket whilst it's being built up throughout the wizard.
When we get a success status back from Zendesk in response to finally posting a
ticket we delete the record we've built up.

The Form Objects pattern allows the record to be built up one question per page 
(as per the GDS guidelines).
