require.context('govuk-frontend/govuk/assets');

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

import { initAll } from 'govuk-frontend';
import '../styles/application.scss';
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";

initAll();
initWarnOnUnsavedChanges();

require('jquery')
require('./mno/extra-mobile-data-requests.js');
