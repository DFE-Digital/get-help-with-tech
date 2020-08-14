class RemoveClosedLocalAuthorities < ActiveRecord::Migration[6.0]
  def up
    closed_la_codes = %w[BKM AYL CHN SBU WYO WEY WDO PUR NDO EDO DOR CHC POL BMH SED FOR WSO TAU WAV SUF]
    LocalAuthority
      .where(local_authority_eng: closed_la_codes)
      .delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
