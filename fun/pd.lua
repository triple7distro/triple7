task.spawn(function()
    for _, v in getconnections(game.ReplicatedStorage.Remotes.NotificationMessage.OnClientEvent) do
        if v.Function then
            v.Function("YOU ARE RUNNING THE LATEST TRIPLE7 BRANCH!!!", 10, 1)
        end
    end
end)
