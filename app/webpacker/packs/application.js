require.context('govuk-frontend/govuk/assets');

import '../styles/application.scss';
import { initAll } from 'govuk-frontend';
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";

initAll();
initWarnOnUnsavedChanges();

require('jquery')
require('./mno/extra-mobile-data-requests.js');
