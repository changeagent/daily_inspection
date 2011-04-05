set :application, "daily_inspection"
set :repository,  "https://example.com/svn/passion/trunk/#{application}"

set :scm_username, Capistrano::CLI.ui.ask('SVN user:')
set :scm_password, Capistrano::CLI.password_prompt('SVN password:')
set :scm, :subversion
role :web, "192.168.1.1"
role :app, "192.168.1.1"
role :db,  "192.168.1.1", :primary => true

set :use_sudo, false

set :user, "root"
set :password, "password"

set :deploy_to, "/var/app/#{application}"

set :deploy_via, :export

# Passengerを再起動するため、
# :restartタスクを上書いて、RAILS_ROOT/tmpにrestart.txtを作成する。
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # Passengerを再起動するため、RAILS_ROOT/tmpにrestart.txtを作成する（またはアップデートする）
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"

    rails_root = "#{deploy_to}/current"
    # apacheユーザがログ出力できるようにRAILS_ROOT以下の所有権を変更する
    run "#{try_sudo} chown -R apache:apache #{rails_root}/*"
    # アプリケーション公開用のシンボリックリンクを設定する。
    run "#{try_sudo} ln -s #{rails_root}/public /var/www/html/#{deploy_to.split('/').last}"
  end
end
