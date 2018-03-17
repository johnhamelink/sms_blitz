defmodule SmsBlitz.Adapters.ItaggTest do
  use ExUnit.Case
  alias SmsBlitz.Adapters.Itagg
  import Mock
  @config {"user", "password", "p"}

  test "#authenticate" do
    expected = %{
      uri: "https://secure.itagg.com/smsg/sms.mes",
      auth: [
        usr: "user",
        pwd: "password",
        route: "p"
      ]
    }

    assert Itagg.authenticate(@config) == expected
  end

  describe "#send_sms" do
    test "sending an sms successfullly" do
      auth = Itagg.authenticate(@config)
      response = "error code|error text|submission reference\n 0|sms submitted|eb725f96b4b094d5f8318741cc1a545f-2"
      fake_response = %HTTPoison.Response{status_code: 200, body: response}
      with_mock HTTPoison, [post: fn _, _ -> {:ok, fake_response} end] do
        result =
          Itagg.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == [%{id: "eb725f96b4b094d5f8318741cc1a545f-2", result_string: "sms submitted", status_code: 200}]
      end
    end

    test "sending an sms and receiving an error" do
      auth = Itagg.authenticate(@config)
      response = "error code|error text|submission reference\n 102|submission failed (insufficient funds)|0"
      fake_response = %HTTPoison.Response{status_code: 500, body: response}

      with_mock HTTPoison, post: fn _, _ -> {:ok, fake_response} end do
        result =
          Itagg.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == [%{id: "0", result_string: "submission failed (insufficient funds)", status_code: 500}]
      end
    end
  end
end
