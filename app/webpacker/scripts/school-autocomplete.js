import accessibleAutocomplete from "accessible-autocomplete";

export const getPath = (endpoint,query) => {
  return `${endpoint}?query=${query}`;
}

export const request = endpoint => {
  let xhr = null; // Hoist this call so that we can abort previous requests.

  return (query, callback) => {
    if (xhr && xhr.readyState !== XMLHttpRequest.DONE) {
      xhr.abort();
    }
    const path = getPath(endpoint, query);

    xhr = new XMLHttpRequest();
    xhr.addEventListener("load", evt => {
      let results = [];
      try {
        results = JSON.parse(xhr.responseText);
      } catch (err) {
        console.error(
          `Failed to parse results from endpoint ${path}, error is:`,
          err
        );
      }
      callback(results);
    });
    xhr.open("GET", path);
    xhr.send();
  };
};

const initSchoolAutocomplete = ({input}) => {
  const $input = document.querySelector(input);

  if ($input === null) {
    return
  }

  const $hiddenFieldForURN = document.getElementById($input.dataset.autocompleteSchoolHiddenField);
  const inputValueTemplate = result => (typeof result === "string" ? result : result && result.name);
  const suggestionTemplate = result =>
    typeof result === "string" ? result : result && `${result.name} (${result.urn}, ${result.town}, ${result.postcode})`;
  const updateSchoolURN = option =>
    $hiddenFieldForURN.value = option ? option.urn : "";
  try {
    if($input) {
      const $autocompleteDiv = document.createElement('div');
      $autocompleteDiv.class = 'govuk-body';
      $input.insertAdjacentElement('afterend', $autocompleteDiv);

      accessibleAutocomplete({
        element: $autocompleteDiv,
        id: $input.id,
        showNoOptionsFound: true,
        name: $input.name,
        defaultValue: $input.value,
        minLength: 3,
        source: request($input.dataset.autocompleteSchoolPath),
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate
        },
        onConfirm: updateSchoolURN,
        confirmOnBlur: false
      });

      $input.parentNode.removeChild($input);
    }
  } catch(err) {
    console.error("Failed to initialise schools autocomplete:", err);
  }
};

export default initSchoolAutocomplete;
