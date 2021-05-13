def expect_download(content_type:, filename: nil)
  expect(page.response_headers['Content-Type']).to eq(content_type)
  header = page.response_headers['Content-Disposition']
  expect(header).to match(/^attachment/)
  expect(header).to match(/filename="#{filename}"$/) if filename.present?
end
