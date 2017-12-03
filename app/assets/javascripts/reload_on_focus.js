(function() {
  var blurred = false;

  window.addEventListener('blur', function() {
    blurred = true;
  });

  window.addEventListener('focus', function() {
    if (blurred) location.reload();
  });
})();
