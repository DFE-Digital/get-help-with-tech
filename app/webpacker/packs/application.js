require.context('govuk-frontend/govuk/assets');

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

import { initAll } from 'govuk-frontend';
import initResponsibleBodiesAutocomplete from "../scripts/responsible-bodies-autocomplete";
import '../styles/application.scss';
import initWarnOnUnsavedChanges from "../scripts/warn-on-unsaved-changes";

initAll();
initWarnOnUnsavedChanges();
import {initSelectAllNone} from '../scripts/mno/extra-mobile-data-requests'

initSelectAllNone();
initResponsibleBodiesAutocomplete();
