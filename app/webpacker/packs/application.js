require.context('govuk-frontend/govuk/assets');

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import '../styles/application.scss';

import { initAll } from 'govuk-frontend';
import initResponsibleBodiesAutocomplete from "../scripts/responsible-bodies-autocomplete";
import initWarnOnUnsavedChanges from "../scripts/warn-on-unsaved-changes";
import {initSelectAllNone} from '../scripts/select-all-or-none-checkboxes'
import initSchoolAutocomplete from "../scripts/school-autocomplete";

initAll();
initWarnOnUnsavedChanges();

initSelectAllNone();
initResponsibleBodiesAutocomplete(
  {
    input: "[data-autocomplete-rb]",
  }
);
initSchoolAutocomplete(
  {
    input: "[data-autocomplete-school]",
  }
);
