let ts;

window.onload = function() {
  ts = new TabulaScripta();
};

window.onresize = function() {
  ts.onResize();
};