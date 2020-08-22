/* global $ */

(function (global) {
  'use strict'

  var GOVUK = global.GOVUK || {}
  GOVUK.Modules = GOVUK.Modules || {}

  GOVUK.Modules.FilterableTable = function () {
    var that = this
    that.start = function (element) {
      const rows = element.find('tbody tr')
      const tableInput = element.find('.js-filter-table-input')
      let filterForm

      element.on('keyup change', '.js-filter-table-input', filterTableBasedOnInput)

      if (element.find('a.js-open-on-submit').length > 0) {
        filterForm = tableInput.parents('form')
        if (filterForm && filterForm.length > 0) {
          filterForm.on('submit', openFirstVisibleLink)
        }
      }

      function filterTableBasedOnInput (event) {
        const searchString = $.trim(tableInput.val())
        const regExp = new RegExp(escapeStringForRegexp(searchString), 'i')

        rows.each(function () {
          var row = $(this)
          if (row.text().search(regExp) > -1) {
            row.show()
          } else {
            row.hide()
          }
        })
      }

      function openFirstVisibleLink (evt) {
        evt.preventDefault()
        var link = element.find('a.js-open-on-submit:visible').first()
        window.location.href = link.attr('href')
      }

      // http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
      // https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/regexp
      // Escape ~!@#$%^&*(){}[]`/=?+\|-_:'",<.>
      function escapeStringForRegexp (str) {
        return str.replace(/[-[\]/{}()*+?.\\^$|]/g, '\\$&')
      }
    }
  }

  global.GOVUK = GOVUK
})(window)
