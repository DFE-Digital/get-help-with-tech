import accessibleAutocomplete from "accessible-autocomplete";

const initResponsibleBodiesAutocomplete = () => {
  try {
    const inputIds = [
      "#support-user-responsible-body-form-responsible-body-id-field",
      '#school-search-form-responsible-body-id-field',
      '#support-ticket-academy-details-form-academy-name-field',
      '#support-ticket-academy-details-form-academy-name-field-error',
      '#support-ticket-local-authority-details-form-local-authority-name-field',
      '#support-ticket-local-authority-details-form-local-authority-name-field-error'
    ];

    inputIds.forEach(inputId => {
      const responsibleBodiesSelect = document.querySelector(inputId);
      if (!responsibleBodiesSelect) return;

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: responsibleBodiesSelect,
        showAllValues: true,
        confirmOnBlur: false,
        dropdownArrow: () => '',
        displayMenu: 'overlay'
      });
    });
  } catch (err) {
    console.error("Could not enhance responsible bodies select:", err);
  }
};

export default initResponsibleBodiesAutocomplete;
