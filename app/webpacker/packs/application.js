require.context('govuk-frontend/govuk/assets');

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import '../styles/application.scss';

import { initAll } from 'govuk-frontend';
import initResponsibleBodiesAutocomplete from "../scripts/responsible-bodies-autocomplete";
import initWarnOnUnsavedChanges from "../scripts/warn-on-unsaved-changes";
import {initSelectAllNone} from '../scripts/select-all-or-none-checkboxes'
import initSchoolAutocomplete from "../scripts/autocomplete";

initAll();
initWarnOnUnsavedChanges();

initSelectAllNone();
initResponsibleBodiesAutocomplete();
initSchoolAutocomplete(
  {
    input: "support-new-user-school-form-name-or-urn-field",
    path: "/support/schools/results",
    hiddenFieldForURN: 'support_new_user_school_form_school_urn'
  }
);
