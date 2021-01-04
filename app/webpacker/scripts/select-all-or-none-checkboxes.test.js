import * as SelectAllNone from './select-all-or-none-checkboxes'

describe('initSelectAllNone', () => {

  const mockHTML = '<table data-module="app-select-all-none">' +
    '  <thead>' +
    '    <tr>' +
    '      <th>' +
    '        <div class="non-js-only">' +
    '          Select' +
    '          <br>' +
    '          <a href="#">all</a>' +
    '          | ' +
    '          <a href="#">none</a>' +
    '        </div>' +
    '        <div class="js-only">' +
    '          <input type="checkbox">' +
    '        </div>' +
    '      </th>' +
    '    </tr>' +
    '  </thead>' +
    '  <tbody>' +
    '    <tr>' +
    '      <td>' +
    '        <input type="checkbox" value="1">' +
    '      </td>' +
    '    </tr>' +
    '    <tr>' +
    '      <td>' +
    '        <input type="checkbox" value="2">' +
    '      </td>' +
    '    </tr>' +
    '    <tr>' +
    '      <td>' +
    '        <input type="checkbox" value="3">' +
    '      </td>' +
    '    </tr>' +
    '  </tbody>' +
    '</table>'


  describe('when method is called and there is no SelectAllNone component on the page', () => {

    it('should return false with no further action', () => {
      document.body.innerHTML = '<div></div>'
      expect(SelectAllNone.initSelectAllNone()).toBeFalsy()
      document.body.innerHTML = ''
    })

  })

  describe('when method is called and there is a SelectAllNone component on the page', () => {
    beforeAll(() => {
      document.body.innerHTML = mockHTML

      SelectAllNone.initSelectAllNone()
    })

    it('should hide non-js-only if js is enabled', () => {
      expect(document.querySelectorAll('.non-js-only')[0].style.display).toBe('none')
    })

    it('should show js-only if js is enabled', () => {
      expect(document.querySelectorAll('.js-only')[0].style.display).toBeNull
    })

    it('should check every checkbox if all-items checkbox is checked', () => {
      document.querySelector('thead input[type="checkbox"]').click()
      const options = document.querySelectorAll('input[type="checkbox"]')
      expect(Array.from(options).filter(checkbox => checkbox.checked).length).toBe(4)
    })

    it('should uncheck every checkbox if all-items checkbox is checked', () => {
      document.querySelectorAll('input[type="checkbox"]').forEach((el) => {
        el.checked = true
      })
      document.querySelector('thead input[type="checkbox"]').click()
      const options = document.querySelectorAll('input[type="checkbox"]')

      document.querySelectorAll('input[type="checkbox"]')
      expect(Array.from(options).filter(checkbox => checkbox.checked).length).toBe(0)
    })
  })

  describe('when method is called and there are multiple SelectAllNone components on the page', () => {


    beforeEach(() => {
      document.body.innerHTML = mockHTML + mockHTML
      jest.spyOn( SelectAllNone, 'setupIndividualComponent')
    })

    afterEach( () =>{
      document.body.innerHTML = ''
    })

    it('should setup an instance for each component on the page', () => {
      SelectAllNone.initSelectAllNone()
      expect(SelectAllNone.setupIndividualComponent).toBeCalledTimes(2)
    })

    it('should only tick the options for the component it relates to', () => {
      const firstComponent = document.querySelector('table:first-of-type')
      const firstComponentOptions = firstComponent.querySelectorAll('input[type="checkbox"]')
      const secondComponent = document.querySelector('table:last-of-type')
      const secondComponentOptions = secondComponent.querySelectorAll('input[type="checkbox"]')

      SelectAllNone.initSelectAllNone()
      secondComponent.querySelector('thead input[type="checkbox"]').click()

      expect(Array.from(firstComponentOptions).filter(checkbox => checkbox.checked).length).toBe(0)
      expect(Array.from(secondComponentOptions).filter(checkbox => checkbox.checked).length).toBe(4)

    })
  })
})
