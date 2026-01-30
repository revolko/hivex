defmodule Hivex.Nginx do
  @moduledoc """
  Module providing functionality to manage Nginx server

  TODO: move most of the parameters to config
  """
  alias DockerEx.Exec
  alias DockerEx.Containers
  alias Hivex.Containers, as: DbContainers
  alias Hivex.Containers.Container, as: DbContainer
  @module_config Application.compile_env(:hivex, __MODULE__)
  @skip_containers ["/hivex-proxy-1", "/hivex-postgres-1"]

  def add_server(server_name, nginx_port, container_port, location \\ "/") do
    config_file = @module_config[:config_file]

    server_conf =
      "server {" <>
        "listen #{nginx_port};server_name #{server_name}; location #{location} {" <>
        "proxy_pass http://127.0.0.1:#{container_port};}}\n"

    with {:ok, file} <- File.open(config_file, [:append]) do
      IO.binwrite(file, server_conf)
    end
  end

  def reload_server({:docker, container_id}) do
    {:ok, exec_instance} =
      with {:ok, %{"Id" => exec_instance_id}} <-
             Exec.create_exec_instance(container_id, %Exec.CreateExecInstance{
               Cmd: ["nginx", "-s", "reload"]
             }),
           {:ok, _} <- Exec.start_exec_instance(exec_instance_id, %Exec.StartExecInstance{}),
           do: Exec.inspect_exec_instance(exec_instance_id)

    case wait_for_docker_command(exec_instance) do
      0 -> :ok
      code -> {:error, code}
    end
  end

  def update_nginx_config() do
    config_file = @module_config[:config_file]

    nginx_conf =
      DbContainers.list_containers()
      |> Enum.map(fn %DbContainer{} = container ->
        create_server_record("_", container.proxy_port, container.host_port)
      end)
      |> Enum.join()

    with {:ok, file} <- File.open(config_file, [:write]),
         :ok <- IO.binwrite(file, nginx_conf) do
      reload_server({:docker, "hivex-proxy-1"})
    end
  end

  defp wait_for_docker_command(%{"Running" => false, "ExitCode" => code}) do
    code
  end

  defp wait_for_docker_command(%{"Running" => true, "ID" => exec_instance_id}) do
    {:ok, exec_instance} = Exec.inspect_exec_instance(exec_instance_id)
    wait_for_docker_command(exec_instance)
  end

  defp create_server_record(server_name, nginx_port, host_port, location \\ "/") do
    "server {" <>
      "listen #{nginx_port};server_name #{server_name}; location #{location} {" <>
      "proxy_pass http://127.0.0.1:#{host_port};}}\n"
  end
end
