import accessibleAutocomplete from "accessible-autocomplete";

const initResponsibleBodiesAutocomplete = ({input}) => {
  try {
    const responsibleBodiesSelect = document.querySelector(input);
    if (!responsibleBodiesSelect) return;

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: responsibleBodiesSelect,
      showAllValues: true,
      confirmOnBlur: false,
      dropdownArrow: () => '',
      displayMenu: 'overlay'
    });
  } catch (err) {
    console.error("Could not enhance responsible bodies select:", err);
  }
};

export default initResponsibleBodiesAutocomplete;
