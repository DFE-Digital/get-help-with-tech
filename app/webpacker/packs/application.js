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
initResponsibleBodiesAutocomplete();
initSchoolAutocomplete(
  {
    input: "support-school-suggestion-form-name-or-urn-field",
    path: "/support/schools/results",
    hiddenFieldForURN: 'support_school_suggestion_form_school_urn'
  }
);
