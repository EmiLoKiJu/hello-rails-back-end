<a name="hello--rails-react"></a>

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
- [💻 Getting Started](#getting-started)
  - [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [Tutorial](#tutorial)
  - [Install](#install)
  - [Usage](#usage)
  - [Run tests](#run-tests)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [📝 License](#license)

<!-- PROJECT DESCRIPTION -->

# 📖 [hello--rails-react] <a name="about-project"></a>
hello--rails-react, is a way to greet someone in a very difficult way

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Client</summary>
  <ul>
    <li><a href="https://www.ruby-lang.org/en/">Ruby</a></li>
    <li><a href="https://rubyonrails.org/">Ruby on Rails</a></li>
  </ul>
</details>

<details>
  <summary>Ruby on Rails</summary>
  <ul>
    <li><a href="https://guides.rubyonrails.org/getting_started.html#what-is-rails-questionmark">Ruby on Rails introduction</a></li>
  </ul>
</details>

<details>
<summary>Database</summary>
  <ul>
    <li><a href="https://www.postgresql.org/">PostgreSQL</a></li>
  </ul>
</details>

<!-- Features -->

### Key Features <a name="key-features"></a>

- **ROR**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 💻 Getting Started <a name="getting-started"></a>
<!-- https://github.com/EmiLoKiJu/hello--rails-react -->

To get a local copy of this project and run it in your computer, follow these steps.

### Prerequisites

In order to run this project you need:
- Ruby 3.0.1 or above
- Ruby on rails 7.0.8 or above

### Tutorial <a name="tutorial"></a>

This project was build in windows 10, using vscode.

To create this project run the following command:

```
rails new hello-rails-back-end -d postgresql --api
```

install these gems:

gem "bcrypt", "~> 3.1.7" (you will find this one commented in the gemfile)
gem "rack-cors" (you will find this one commented in the gemfile)
gem 'jwt'

put those lines in the gemfile and then run bundle install

After that, go to the config/initializers/cors.rb and uncomment this section:

```
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

note: I changed origins to '*' so it allows all origins, which is fine for now.

Add this routes to the routes.rb file:
```
Rails.application.routes.draw do
  resource :users, only: [:create]
  post '/login', to: 'users#login'
  get 'auto_login', to: 'users#auto_login'
end
```

generate the user model as follows:

```
rails g model User username:string password_digest:string
```

in the user model, put the following code:
```
class User < ApplicationRecord
  has_secure_password
end
```

generate the controller for the user:
```
rails g controller Users
```

then, create and migrate the database with db:create and db:migrate

In the db/seeds.rb, create a user as follows:
```
user = User.create(username: 'username1', password: 'password1')
```
then, you can do db:seed to create the user to the database.

For the app/controllers/application_controller.rb file, copy the following:

```
class ApplicationController < ActionController::API
  before_action :authorized
  
  def encode_token(payload)
    JWT.encode(payload, 'yourSecret')
  end

  def auth_header
    # { Authorization: 'bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # Header: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, 'yourSecret', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'please log in' }, status: :unauthorized unless
    logged_in?
  end
end

```

For the users_controller.rb file, copy the following code:
```
class UsersController < ApplicationController
  before_action :authorized, only: [:auto_login]

  #REGISTER
  def create
    @user = User.create(user_params)
    if @user.valid?
      token = enconde_token({user_id: @user.id})
      render json: {user: @user, token: token}
    else
      render json: {error: 'Invalid username or password'}
    end
  end

  # LOGGING IN
  def login
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      token = encode_token({user_id: @user.id})
      render json: {user: @user, token: token}
    else
      render json: {error: 'Invalid username or password'}
    end
  end

  def auto_login
    render json: @user
  end

  private

  def user_params
    params.permit(:username, :password, :age)
  end
end

```

Now you're ready to test the API. Go to an api platform (I use postman) and do a post request with the following:

POST localhost:3000/login

for the body, select the raw option, and JSON data, then insert the following data:
```
{
  username: "username1",
  password: "password1"
}
```

after pressing the send button, you should see a response like this:

```
{
    "user": {
        "id": 1,
        "username": "username1",
        "password_digest": "(encoded password)",
        "created_at": "2023-10-24T19:06:55.117Z",
        "updated_at": "2023-10-24T19:06:55.117Z"
    },
    "token": "(token)"
}
```

For autologin testing, set the call to GET, change the address to localhost:auto_login, and add the following header:

Authorization                        bearer (your token)

Just to be a little more clear with that, in javascript the headers would look like this: 
```
const headers = new Headers({
  'Authorization': 'bearer (your token)'
});
```
You don't need to put a body to the call this time. The response should look like this:
```
{
    "id": 1,
    "username": "username1",
    "password_digest": "(encoded password)",
    "created_at": "2023-10-24T19:06:55.117Z",
    "updated_at": "2023-10-24T19:06:55.117Z"
}
```

I wanted to generate a greeting that belongs to a user, so I ran the following command:

```
rails g scaffold Greeting text:string user:references
```

Then I migrate the database with rails db:migrate
In the greetings_controller.rb, I added "before_action :authorized" so it checks if you're authorized
I also added @greeting.user = @user for the create greeting so it assigns the user to the greeting
I added @greetings = Greeting.where user: @user.id to the greeting index so it shows all greetings that belongs to a user.
And finally I customized the controller so it has the random greeting function. I also added a route in the config/routes.rb file for this purpose.

To check the greeting working, I used postman again. I logged in, I took the token and put it into the header Authorization, and then I did a get request for checking if it is working to http://localhost:3000/greetings. It returned null, because I haven't created any greeting yet.

I updated the seed.rb file. It looks like this now:

```
greeting1 = Greeting.create(text: 'Hello, World!', user_id: 1)
greeting2 = Greeting.create(text: 'Greetings!', user_id: 1)
greeting3 = Greeting.create(text: 'Welcome!', user_id: 1)
greeting4 = Greeting.create(text: 'Hi there!', user_id: 1)
greeting5 = Greeting.create(text: 'Good day!', user_id: 1)

```
note: if I don't delete the line "user = User.create(username: 'username1', password: 'password1')" from the file, it recreates this user again after running rails db:seed the second time.

After I run rails db:seed, The database has been populated with the new data, and now I can make a GET request with the token as an authorization header with an address to localhost:3000/greetings/random, and I get a random greeting.


### Setup

To get a local copy up and running follow these simple example steps.

Clone this repository in the desired folder:
```
cd my-folder
git clone https://github.com/EmiLoKiJu/hello-rails-react.git
```

### Install

To install this project:
```
cd hello-rails-react
code .
bundle install
```
### Usage

To run the project, make sure you configured your database correctly, then execute the following command:
```sh
  rails db:create
  rails db:migrate
  rails db:seed
```

After the database is set up, run the following command:
```
rails server
```

Then check the link of the rails server (it should be http://localhost:3000/)

### Run tests

Not implemented tests

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- AUTHORS -->
## 👥 Authors <a name="authors"></a>

👤 **Gabriel Rozas**
- GitHub: [@EmiLoKiJu](https://github.com/EmiLoKiJu)
- Twitter: [@GabrielRozas12](https://twitter.com/GabrielRozas12)
- LinkedIn: [grozas](https://www.linkedin.com/in/grozas/)

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- FUTURE FEATURES -->

## 🔭 Future Features <a name="future-features"></a>

- Nothing so far

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>

I welcome contributions to enhance the functionality and user experience of the Morse_Translator project. If you have any ideas, suggestions, or bug reports, feel free to open an issue or submit a pull request.

If you'd like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with descriptive commit messages.
4. Push your changes to your forked repository.
5. Submit a pull request to the main repository, explaining your changes in detail.

Please adhere to the coding conventions and guidelines specified in the project.

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](../../issues).

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- SUPPORT -->

## ⭐️ Show your support <a name="support"></a>

If you like this project give it a star ⭐️

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- FAQ -->

## ❓ FAQ <a name="faq"></a>

- **Can I use the project for any purpose?**

  - Yes, you can use this files for anything you need

- **Do I need to ask for permission?**

  - No need to ask for permission.


<!-- ACKNOWLEDGEMENTS -->

## 🙏 Acknowledgments <a name="acknowledgements"></a>

** I would like to thank to Microverse for giving this inspiring project **

<p align="right">(<a href="#hello--rails-react">back to top</a>)</p>

<!-- LICENSE -->

## 📝 License <a name="license"></a>

This project is [MIT](./MIT.md) licensed.
