# FileExplorerV2

This Project is a web-based alternative for the popular tool [FileZilla](https://en.wikipedia.org/wiki/FileZilla). All a user has to do is to clone and run this repository on their remote server and the application should allow them to browse and make edits to all the files on their server as if they were on their local machine.

## Setup Guide

### Step 1: Make sure Ruby and Rails are installed

```bash
sudo apt update && upgrade
sudo apt install ruby ruby-dev ruby-bundler build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev git
sudo gem install rails
```
If this fails please refer to Ruby on Rails' [official installation documentaion](https://guides.rubyonrails.org/install_ruby_on_rails.html)

### Step 2: Clone the Repository

```bash
git clone https://github.com/ym733/fileExplorerV2.git
cd fileExplorerV2
```

### Step 3: Bundle Gems & Create DB 

```bash
sudo bundle install
rails db:create db:migrate
```

### Step 4: Enter DB console 

```bash
rails c
```

### Step 4: Create password for admin user 

```bash
Password.create({LoginType: "admin", isActive: true, password: "", password_confirmation: ""})

exit
```

### Step 4: Start the server 

```bash
rails s -b 0.0.0.0 -p 3000
```

Now you should be able to open the application through the following IP `http://<host-machine-IP>:3000`

## Project specific Guides

### How to setup/reset user password

1. Open the `/setup` endpoint on the application
2. Click on `Enter admin Password` then Enter the Admin's password
3. Go to `Setup/Reset Password`
4. Enter the new user password
5. Click `Submit` after confirming the password

### How to setup an OTP

1. Open the `/setup` endpoint on the application
2. Click on `Enter admin Password` then Enter the Admin's password
3. Go to `Add OTP Device`
4. QR Code should automatically be generated
5. Scan QR Code with Authenticator App

### How to Change Root Directory

1. Open the file `app/controllers/main_controller.rb`
2. Inside of the index funtion exists the variable `@root_directory_path`
3. Change the value of this variable to which ever you want the root directory to be
4. Example: `/home/ym733/CertainProject`