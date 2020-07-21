defmodule RtgWeb.Js.Finish do
  @moduledoc """
  相手
  """

  alias ElixirScript.JS
  alias RtgWeb.Js.Canvas
  alias RtgWeb.Js.Date
  alias RtgWeb.Js.GameChannel
  alias RtgWeb.Js.Gen2D
  alias RtgWeb.Js.Math
  alias ElixirScript.Web

  use Gen2D

  @dialyzer [:no_fail_call, :no_return]

  @type t :: %{}

  @pi :math.pi()
  #  @radius 60

  @impl Gen2D
  def init(args) do
    {_, canvas} = args.find(fn {k, _}, _, _ -> k == :canvas end, args)
    #    current = %{x: canvas.width / 2, y: canvas.height / 2}

    state = %{
      result: nil
    }

    GameChannel.on("finish", fn msg, _, _ ->
      msg = JS.object_to_map(msg)
      Gen2D.cast(canvas.__id__, id(), {:finish, msg.result})
    end)

    {:ok, state}
  end

  @impl Gen2D
  def handle_cast({:finish, result}, state) do
    #    now = Date.now()
    state = %{state | result: result}
    {:ok, state}
  end

  @impl Gen2D
  def handle_frame(canvas, state) do
    if state.result != nil do
      Canvas.set(canvas, "fillStyle", "#ffffff")

      canvas.context.fillText(
        state.result,
        canvas.width / 2,
        canvas.height / 2
      )

      Web.Console.log(state.result)
    end

    #    Canvas.set(canvas, "strokeStyle", "#F33")
    #    canvas.context.beginPath()
    #    canvas.context.arc(state.current.x, state.current.y, @radius, 0, @pi * 2)
    #    canvas.context.stroke()
    {:ok, state}
  end

  defp next(state) do
    now = Date.now()

    cond do
      state.current == state.dest ->
        state

      state.anim.end <= now ->
        %{state | current: state.dest, prev: state.dest}

      true ->
        time = Math.sin((now - state.anim.start) / (state.anim.end - state.anim.start) * @pi / 2)
        x = state.prev.x + (state.dest.x - state.prev.x) * time
        y = state.prev.y + (state.dest.y - state.prev.y) * time
        %{state | current: %{x: x, y: y}}
    end
  end
end
