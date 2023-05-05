# frozen_string_literal: true

namespace :redmine_jenkins_job do
  namespace :db do
    desc 'Encrypts Jenkins secret in the database.'
    task encrypt: :environment do
      unless JenkinsSetting.encrypt_all(:secret)
        raise "Some objects could not be saved after encryption, update was rolled back."
      end
    end

    desc 'Decrypts Jenkins secret in the database.'
    task decrypt: :environment do
      unless JenkinsSetting.decrypt_all(:secret)
        raise "Some objects could not be saved after decryption, update was rolled back."
      end
    end
  end
end
