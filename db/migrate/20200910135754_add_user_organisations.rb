class AddUserOrganisations < ActiveRecord::Migration[6.0]
  def up
    create_table :user_organisations do |t|
      t.references  :user
      t.references  :organisation, polymorphic: true, index: { name: 'ix_user_orgs_org_type_org_id' }
      t.timestamps
    end

    add_index :user_organisations, [:organisation_type, :organisation_id, :user_id], unique: true, name: 'ix_user_orgs_org_type_org_id_user_id'
    add_index :user_organisations, [:user_id, :organisation_type, :organisation_id], unique: true, name: 'ix_user_orgs_user_id_org_type_org_id'
    add_index :user_organisations, :created_at
    add_index :user_organisations, :updated_at

    User.where.not(school_id: nil).each do |user|
      UserOrganisation.create!(user: user, organisation: user.school)
    end
    User.where.not(responsible_body_id: nil).each do |user|
      UserOrganisation.create!(user: user, organisation: user.responsible_body)
    end

    remove_column :users, :school_id
    remove_column :users, :responsible_body_id
  end

  def down
    add_reference :users, :responsible_body, foreign_key: true
    UserOrganisation.where(organisation_type: 'ResponsibleBody').each do |user_org|
      user_org.user.update!(responsible_body_id: user_org.organisation_id)
    end
    add_index :users, :responsible_body_id

    add_reference :users, :school, foreign_key: true
    UserOrganisation.where(organisation_type: 'School').each do |user_org|
      user_org.user.update!(school_id: user_org.organisation_id)
    end
    add_index :users, :school_id

    drop_table :user_organisations
  end
end
