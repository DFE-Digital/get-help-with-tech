require.context('govuk-frontend/govuk/assets');

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

import { initAll } from 'govuk-frontend';
import initResponsibleBodiesAutocomplete from "./responsible-bodies-autocomplete";
import '../styles/application.scss';
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";

initAll();
initWarnOnUnsavedChanges();
import {initSelectAllNone} from './mno/extra-mobile-data-requests'

initSelectAllNone();
initResponsibleBodiesAutocomplete();
