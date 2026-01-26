defmodule HivexWeb.ImageController do
  use HivexWeb, :controller

  alias DockerEx.Images

  def index(conn, _params) do
    {:ok, images} = Images.list_images()

    # filter named images
    images = Enum.filter(images, fn image -> length(image["RepoTags"]) != 0 end)

    render(conn, :index, images: images)
  end

  def pull(conn, %{"from_image" => from_image} = params) do
    tag = Map.get(params, "tag", "latest")
    # TODO: make it async -- it takes too long
    {:ok, _} = Images.create_image(from_image, tag)

    send_resp(conn, :created, "")
  end

  def build(conn, %{"remote_url" => remote_url, "name" => name} = params) do
    tag = Map.get(params, "tag", "latest")
    # TODO: make it async -- it takes too long
    {:ok, _} = Images.build_image(remote_url, name, tag)

    send_resp(conn, :created, "")
  end
end
