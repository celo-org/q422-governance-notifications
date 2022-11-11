defmodule TelegramService.Events.Subscriptions do
  @moduledoc "Context for event subscriptions"

  alias TelegramService.Events.SubscriberCache, as: Cache

  @cusd_proxy "0x765de816845861e75a25fca122bb6898b8b1282a"
  @erc20_transfer_topic "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
  @transfer_with_comment_topic "0xe5d4e30fb8364e57bc4d662a07d0cf36f4c34552004c4c3624620a2c1d1c03dc"

  def subscribe(chat_id), do: subscribe(chat_id, @cusd_proxy, @erc20_transfer_topic)
  def subscribe(chat_id, contract_address, topic) do
    Cache.add_subscription(chat_id, contract_address, topic)
  end

  def unsubscribe(chat_id), do: unsubscribe(chat_id, @cusd_proxy, @erc20_transfer_topic)
  def unsubscribe(chat_id, contract_address, topic) do
    Cache.remove_subscription(chat_id, contract_address, topic)
  end

  def get_subscribers(%{"contract_address_hash" => contract, "topic" => topic}) do
    get_subscribers(contract, topic)

  end

  def get_subscribers(contract_address, topic) do
    Cache.get_subscribers(contract_address, topic)
  end

  def subscribe_once(chat_id, contract_address, topic) do

  end
end