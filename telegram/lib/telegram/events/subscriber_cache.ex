defmodule TelegramService.Events.SubscriberCache do
  @table_name :subscriptions

  def add_subscription(chat_id, contract, topic) do
    ConCache.update(@table_name, subscription_key(contract, topic), fn
      nil -> MapSet.new(chat_id)
      subscribers = %MapSet{} -> MapSet.put(chat_id)
    end)
  end

  def remove_subscription(chat_id, contract, topic) do
    ConCache.update(@table_name, subscription_key(contract, topic), fn
      nil -> MapSet.new()
      subscribers = %MapSet{} -> MapSet.delete(chat_id)
    end)
  end

  def get_subscribers(contract, topic) do
    case ConCache.get(@table_name, subscription_key(contract, topic)) do
      subscribers = %MapSet{} -> subscribers |> MapSet.to_list()
      _ -> []
    end
  end

  defp subscription_key(contract, topic), do: {contract, topic}
end
