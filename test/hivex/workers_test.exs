defmodule Hivex.WorkersTest do
  use Hivex.DataCase

  alias Hivex.Workers

  describe "workers" do
    alias Hivex.Workers.Worker

    import Hivex.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hivex.WorkersFixtures

    @invalid_attrs %{name: nil, access_key_hash: nil}
    @access_key "random_key"

    test "list_workers/1 returns all scoped workers" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      worker = worker_fixture(scope, @access_key)
      other_worker = worker_fixture(other_scope, @access_key)
      assert Workers.list_workers(scope) == [worker]
      assert Workers.list_workers(other_scope) == [other_worker]
    end

    test "get_worker!/2 returns the worker with given id" do
      scope = user_scope_fixture()
      worker = worker_fixture(scope, @access_key)
      other_scope = user_scope_fixture()
      assert Workers.get_worker!(scope, worker.id) == worker
      assert_raise Ecto.NoResultsError, fn -> Workers.get_worker!(other_scope, worker.id) end
    end

    test "create_worker/2 with valid data creates a worker" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Worker{} = worker} =
               Workers.create_worker(scope, valid_attrs, @access_key)

      assert worker.name == "some name"
      assert worker.access_key_hash == :crypto.hash(:sha256, @access_key)
      assert worker.user_id == scope.user.id
    end

    test "create_worker/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Workers.create_worker(scope, @invalid_attrs, @access_key)
    end

    # test "update_worker/3 with valid data updates the worker" do
    #   scope = user_scope_fixture()
    #   worker = worker_fixture(scope, @access_key)
    #   update_attrs = %{name: "some updated name", access_key: "some updated access_key"}
    #
    #   assert {:ok, %Worker{} = worker} = Workers.update_worker(scope, worker, update_attrs)
    #   assert worker.name == "some updated name"
    #   assert worker.access_key == "some updated access_key"
    # end
    #
    # test "update_worker/3 with invalid scope raises" do
    #   scope = user_scope_fixture()
    #   other_scope = user_scope_fixture()
    #   worker = worker_fixture(scope, @access_key)
    #
    #   assert_raise MatchError, fn ->
    #     Workers.update_worker(other_scope, worker, %{})
    #   end
    # end
    #
    # test "update_worker/3 with invalid data returns error changeset" do
    #   scope = user_scope_fixture()
    #   worker = worker_fixture(scope, @access_key)
    #   assert {:error, %Ecto.Changeset{}} = Workers.update_worker(scope, worker, @invalid_attrs)
    #   assert worker == Workers.get_worker!(scope, worker.id)
    # end

    test "delete_worker/2 deletes the worker" do
      scope = user_scope_fixture()
      worker = worker_fixture(scope, @access_key)
      assert {:ok, %Worker{}} = Workers.delete_worker(scope, worker)
      assert_raise Ecto.NoResultsError, fn -> Workers.get_worker!(scope, worker.id) end
    end

    test "delete_worker/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      worker = worker_fixture(scope, @access_key)
      assert_raise MatchError, fn -> Workers.delete_worker(other_scope, worker) end
    end

    test "change_worker/2 returns a worker changeset" do
      scope = user_scope_fixture()
      worker = worker_fixture(scope, @access_key)
      assert %Ecto.Changeset{} = Workers.change_worker(scope, worker)
    end
  end
end
