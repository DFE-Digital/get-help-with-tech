# User friendly GOV.UK date formats, based on:
# https://www.gov.uk/guidance/style-guide/a-to-z-of-gov-uk-style#dates
# https://www.gov.uk/guidance/style-guide/a-to-z-of-gov-uk-style#times

# 1 January 2021
Date::DATE_FORMATS[:govuk_date] = '%-e %B %Y'

# 1 Jan 2021
Date::DATE_FORMATS[:govuk_date_short] = '%-e %b %Y'

# 1 January 2021 1:15pm
Time::DATE_FORMATS[:govuk_date] = '%-e %B %Y %-I:%M%P'

# 1 Jan 2021 1:15pm
Time::DATE_FORMATS[:govuk_date_short] = '%-e %b %Y %-I:%M%P'

# 1:15pm
Time::DATE_FORMATS[:govuk_time] = '%-I:%M%P'
