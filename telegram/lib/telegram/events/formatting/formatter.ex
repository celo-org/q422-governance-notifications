defmodule TelegramService.Events.MessageFormatter do

  #cusd celo mainnet transfer
  def format(%{
    "topic" => "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    "contract_address_hash" => "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    "transaction_hash" => tx_hash,
    "params" => %{
      "from" => from,
      "to" => to,
      "value" => value,
    }
    }) do
    """
    cUSD Transfer:
  From: #{from}
  To: #{to}
  Value: #{value} cUSD

  View at https://explorer.celo.org/mainnet/tx/#{tx_hash}
"""
  end

end