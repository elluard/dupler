defmodule Duper.Results do
  use GenServer

  @me __MODULE__

  # API

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  def add_hash_for(path, hash) do
    GenServer.cast(@me, {:add, path, hash})
  end

  def find_duplicates() do
    GenServer.call(@me, :find_duplicates)
  end

  # 서버

  def init(:no_args) do
    {:ok, %{}}
  end

  def handle_cast({:add, path, hash}, results) do
    results =
      Map.update(
        results, # 업데이트 할 map
        hash, # 업데이트할 map 의 key 값
        [path], # 항목이 있을경우, 저장할 형태
        fn existing -> #항목이 있을경우, 이 함수의 결과를 저장함
          [path | existing]
        end
      )

    {:noreply, results}
  end

  def handle_call(:find_duplicates, _from, results) do
    {
      :reply,
      hashes_with_more_than_one_path(results),
      results
    }
  end

  defp hashes_with_more_than_one_path(results) do
    results
    |> Enum.filter(fn {_hash, paths} -> length(paths) > 1 end)
    |> Enum.map(&elem(&1, 1)) # 이 구문은 fn x -> elem(x, 1) end 로 변경된다, "처음 배우는 엘릭서 프로그래밍 97페이지"
  end
end
