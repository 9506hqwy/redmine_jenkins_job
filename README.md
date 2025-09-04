# Redmine Jenkins Job

This plugin provides a Jenkins's job operation.

## Features

- Execute Jenkins's job.
- Display Jenkins's job result.
- Display Jenkins's job standard output.
- Display link to jobs, builds, artifacts.

## Installation

1. Download plugin in Redmine plugin directory.

   ```sh
   git clone https://github.com/9506hqwy/redmine_jenkins_job.git
   ```

2. Install dependency libraries in Redmine directory.

   ```sh
   bundle install --without development test
   ```

3. Install plugin in Redmine directory.

   ```sh
   bundle exec rake redmine:plugins:migrate NAME=redmine_jenkins_job RAILS_ENV=production
   ```

4. Start Redmine

## Configuration

1. Enable plugin module.

   Check [Jenkins] in project setting.

2. Set in [Jenkins] tab in project setting.

   - [URL]

     Input Jenkins server URL.

   - [Skip SSL certificate verification]

     If the server cant not verify the server certification, check on.

   - [Link URL]

     Input Jenkins server URL for browser.
     Specify if different accessible URL from Redmine and browsable URL.
     If omitted, use `URL`.

   - [Username]

     Input account name of Jenkins server.

   - [Password or Token]

     Input password or token of account.
     Checked on the trailing checkbox if updating.

3. Save.

4. Select Jenkins's job for operating from Redmine.

5. Save.

## Notes

- Need to use `database_cipher_key` in *configuration.yml* for encrypting password or token.

- If chagnge `database_cipher_key`, see bellow process.

  1. Decrypt ciphered password or token.

     ```sh
     bundle exec rails redmine_jenkins_job:db:decrypt RAILS_ENV=production
     ```

  2. Change value of `database_cipher_key`.

  3. Encrypt plain password or token.

     ```sh
     bundle exec rails redmine_jenkins_job:db:encrypt RAILS_ENV=production
     ```

- If use this plugin behind nginx proxy, need to configure nginx for avoiding decoding URL percent encoding
  because of contains '/' in Jenkins's job identifier. e.g. use `$request_uri`.

- Need to re-enable job in [Jenkins] tab after rename or move job another folder.

## Tested Environment

- Redmine (Docker Image)
  - 4.0
  - 4.1
  - 4.2
  - 5.0
  - 5.1
  - 6.0
- Database
  - SQLite
  - MySQL 5.7 or 8.0
  - PostgreSQL 14
- Jenkins
  - 2.60.3
  - 2.164.3
  - 2.346.3
  - 2.387.2
