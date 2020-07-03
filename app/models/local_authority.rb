class LocalAuthority < ResponsibleBody
  # We can't use an enum in any meaningful way here,
  # as the three-letter code is what we need to preserve
  # from the imported data. If we supply this hash as an
  # enum, then any local authority records appear to have
  # organisation_type of nil.
  # It's awkward having an enum on the Trust but not on this.
  # Open to suggestions (and PRs!) on a better way.
  ORGANISATION_TYPES = {
    'BGH': 'Borough',
    'CIT': 'City',
    'CC': 'City corporation',
    'COMB': 'Combined authority',
    'CA': 'Council area',
    'CTY': 'County',
    'DIS': 'District',
    'LBO': 'London borough',
    'MD': 'Metropolitan district',
    'NMD': 'Non-metropolitan district',
    'SRA': 'Strategic regional authority',
    'UA': 'Unitary authority',
  }
end
