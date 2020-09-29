class ContactDataFile < SchoolDataFile
  def contacts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      urn: row['URN'],
      email_address: email(row),
      full_name: full_name(row),
      title: title(row),
      phone_number: phone_number(row),
    }
  end

  def skip?(row)
    school_not_open?(row) || super(row)
  end

private

  def email(row)
    choose_option(row, %w[HeadEmail MainEmail AlternativeEmail])
  end

  def full_name(row)
    [row['HeadFirstName'], row['HeadLastName']].join(' ')
  end

  def title(row)
    choose_option(row, ['HeadPreferredJobTitle', 'HeadTitle (name)']) || 'Headteacher'
  end

  def phone_number(row)
    row['TelephoneNum']
  end

  def choose_option(row, keys)
    keys.each do |key|
      return row[key] if row[key].present?
    end
    nil
  end

  def school_not_open?(row)
    !row['EstablishmentStatus (name)'].in? ['Open', 'Open, but proposed to close']
  end
end
