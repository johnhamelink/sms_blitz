use Mix.Config

config :sms_blitz, :plivo, {"User ID", "User Token"}
config :sms_blitz, :itagg, {"Username", "Password", "Route"}
config :sms_blitz, :twilio, {"AccountSid"}
config :sms_blitz, :nexmo, {"Key", "Secret"}

if Mix.env == :test do
  config :sms_blitz, extra_adapters: %{
    dummy: SmsBlitz.Adapters.Dummy
  }
end
