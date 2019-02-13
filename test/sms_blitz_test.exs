defmodule SmsBlitzTest do
  use ExUnit.Case
  doctest SmsBlitz

  test ":extra_adapters conifg option" do
    assert SmsBlitz.adapters() == [:dummy, :itagg, :nexmo, :plivo, :twilio]
    assert SmsBlitz.send_sms(:dummy, from: "", to: "", message: "")
  end
end
