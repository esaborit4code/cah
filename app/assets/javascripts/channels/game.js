App.cable.subscriptions.create("GameChannel",
{
  received: function(data) {
    window.location.reload();
  }
});
