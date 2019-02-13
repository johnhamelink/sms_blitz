defmodule SmsBlitz.Adapters.TestTest do
  use ExUnit.Case
  alias SmsBlitz.Adapters.Test

  test "send sms" do
    Test.send_sms(nil, from: "me", to: "you", message: "love")
    assert_receive {:sms, from: "me", to: "you", message: "love"}
  end
end
