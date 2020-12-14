import accessibleAutocomplete from "accessible-autocomplete";

const initResponsibleBodiesAutocomplete = () => {
  try {
    const id = "#support-user-responsible-body-form-responsible-body-field";
    const responsibleBodiesSelect = document.querySelector(id);
    if (!responsibleBodiesSelect) return;

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: responsibleBodiesSelect,
      showAllValues: true,
      confirmOnBlur: false
    });
  } catch (err) {
    console.error("Could not enhance responsible bodies select:", err);
  }
};

export default initResponsibleBodiesAutocomplete;
