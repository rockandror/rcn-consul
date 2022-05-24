class AddDescriptionsFieldsToPollTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_translations, :answers_descriptions_link_text, :text
    add_column :poll_translations, :answers_descriptions_title, :string
  end
end
