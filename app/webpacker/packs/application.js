require.context('govuk-frontend/govuk/assets');

import '../styles/application.scss';
import { initAll } from 'govuk-frontend';

initAll();

require('jquery')
require('./mno/extra-mobile-data-requests.js');
