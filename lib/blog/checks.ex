defmodule Zukini.Blog.Checks do
  def for_file_attrs(attrs, filename) do
    is_index = Path.basename(filename, ".md") == "_index"

    Map.update(attrs, :filename, filename, fn _ -> filename end)
    |> Map.update(:is_index, is_index, fn _ -> is_index end)
  end

  def check_non_empty_list(%{filename: fname, is_index: false} = attrs, key) do
    case Map.get(attrs, key) do
      nil ->
        IO.inspect(attrs)
        IO.puts("#{fname} does not have #{key} defined")

      [] ->
        IO.puts("#{fname} has an empty #{key} list, find atleast one!")

      _ ->
        nil
    end

    attrs
  end

  def check_non_empty_list(%{is_index: true} = attrs, _) do
    attrs
  end

  def check_date_defined(%{is_index: false, filename: fname} = attrs, field) do
    case Map.get(attrs, field, nil) do
      nil ->
        IO.puts("#{fname} does not specify a date field #{field}")

      %{__struct__: Date} ->
        nil

      _ ->
        IO.puts("#{fname} is something other than a date! got:")
        IO.inspect(attrs)
    end

    attrs
  end

  def check_date_defined(%{is_index: true} = attrs, _) do
    attrs
  end
end
