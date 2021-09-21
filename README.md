# Striker

- This projects aims to provide necessary APIs for a bowling game based on https://en.wikipedia.org/wiki/Ten-pin_bowling.

## Features
* This is an API only application that provides APIs for following tasks for bowling :  
  * Start a game
  * Update scores of a round
  * Get scores
* Created documentation using `rswag` gem and can be found here : http://localhost:3000/api-docs/index.html  

## Technical details  

* Uses Ruby on Rails, ruby version - ruby  3.0.2, rails version - Rails 6.1.4.1
* Uses PostreSQL database
* Uses Rspec and FactoryBot for testing
* Uses Rubocop for analysing and formatting code. Maintaining zero offences as of yet.

## Steps to run locally 

1. Install & setup PostgreSQL locally
4. Run `bundle install`
5. Run `rails db:migrate`
7. Start rails server - `rails s`
8. Go to http://localhost:3000/api-docs/index.html for API documentation
