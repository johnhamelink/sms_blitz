# SmsBlitz
[![Build Status](https://travis-ci.org/johnhamelink/sms_blitz.svg?branch=master)](https://travis-ci.org/johnhamelink/sms_blitz)

SmsBlitz is a library for elixir that allows you to send SMS messages through multiple different providers.

SmsBlitz provides a generic behaviour to make it easy to write conforming client libraries, while also making it simple for developers to choose which provider to use (you could use [ex_phone_number](https://github.com/socialpaymentsbv/ex_phone_number) to detect the destination country and use the cheapest provider for that country, for example).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add sms_blitz to your list of dependencies in `mix.exs`:
  
```elixir
        def deps do
          [{:sms_blitz, "~> 0.1.1"}]
        end
```

  2. Ensure sms_blitz is started before your application:
  
```elixir
        def application do
          [applications: [:sms_blitz]]
        end
```

## Setup

Setting up with SmsBlitz is easy. You simply add the authentication details for the providers you want to use into to your config:

```elixir
config :sms_blitz, plivo: {"api_token", "api_key"}
config :sms_blitz, itagg: {"username", "password", "route"}
config :sms_blitz, twilio: {"account_sid"}
config :sms_blitz, nexmo: {"account_key", "account_secret"}
```

You can find out which adapters are available like so (note that the list of adapters is not the same as the list of adapters which has been configured correctly!):

```elixir
SmsBlitz.adapters
# [:plivo, :itagg, :twilio, :nexmo]
```

Then you can send the SMS to the provider as simply as this:

```elixir
SmsBlitz.send_sms(:adapter, from: "Johnny", to: "07123456789", message: "Here's Johnny!")
```

Where `:adapter` is the adapter you've chosen from the list.


The output of the `send_sms/2` command above will either be like:

```elixir
%{
  id: "id here",
  result_string: "Things went well",
  status_code: "1337"
}
```

Or an Array of maps formatted as above. **It's important that you handle both types of responses!**
