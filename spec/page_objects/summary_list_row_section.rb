class SummaryListRowSection < SitePrism::Section
  element :key_element, 'dt'
  element :value_element, 'dd:nth-of-type(1)'
  element :action_element, 'dd:nth-of-type(2)'

  def key
    key_element.text
  end

  def value
    value_element.text
  end

  def follow_action_link
    action_element.find('a').click
  end
end
