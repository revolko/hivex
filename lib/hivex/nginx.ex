defmodule Hivex.Nginx do
  @moduledoc """
  Module providing functionality to manage Nginx server

  TODO: move most of the parameters to config
  """
  alias DockerEx.Exec

  def add_server(config_file, server_name, location, container_name, container_port) do
    server_conf =
      "server {" <>
        "listen 80;server_name #{server_name}; location #{location} {" <>
        "proxy_pass http:://#{container_name}:#{container_port};}}\n"

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
      0 -> {:ok}
      code -> {:error, code}
    end
  end

  defp wait_for_docker_command(%{"Running" => false, "ExitCode" => code}) do
    code
  end

  defp wait_for_docker_command(%{"Running" => true, "ID" => exec_instance_id}) do
    {:ok, exec_instance} = Exec.inspect_exec_instance(exec_instance_id)
    wait_for_docker_command(exec_instance)
  end
end
