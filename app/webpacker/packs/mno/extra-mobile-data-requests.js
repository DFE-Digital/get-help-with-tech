const hideFallbackOnLoad = (component) => {
  component.querySelectorAll('.non-js-only').forEach((el) => {
    el.style.display = 'none'
  })

  component.querySelectorAll('.js-only').forEach((el) => {
    el.style.display = 'block'
  })
}

const changeCheckboxStateForEachRow = (event) => {
  const $allNoneCheckbox = event.target
  const controlledItems = $allNoneCheckbox.closest('table').querySelectorAll('tbody input[type=checkbox]')

  controlledItems.forEach((checkbox) => {
    checkbox.checked = $allNoneCheckbox.checked
  })
}

let setupIndividualComponent = ($component) => {
  const $selectAllNoneCheckbox = $component.querySelector('thead input[type=checkbox]')

  hideFallbackOnLoad($component)

  $selectAllNoneCheckbox.addEventListener('change', changeCheckboxStateForEachRow)
}

const initSelectAllNone = () => {
  const $components = document.querySelectorAll('[data-module="app-select-all-none"]')

  if( $components.length === 0 ){ return false }

  $components.forEach((component) =>{
    setupIndividualComponent(component)
  })
}

export {
  initSelectAllNone,
  setupIndividualComponent
}

