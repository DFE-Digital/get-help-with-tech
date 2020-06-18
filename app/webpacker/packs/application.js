require.context('govuk-frontend/govuk/assets');

import '../styles/application.scss';
import Rails from 'rails-ujs';
import { initAll } from 'govuk-frontend';

Rails.start();
initAll();

require('jquery')
require('./mno/recipients');
