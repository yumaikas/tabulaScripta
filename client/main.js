window.onload = function() {
  canvas = document.getElementById("tabula");
  canvas.width = document.body.clientWidth;
  canvas.height = document.body.clientHeight;
  context = canvas.getContext("2d");
  draw();
};

window.onresize = function() {
  canvas.width = document.body.clientWidth;
  canvas.height = document.body.clientHeight;
  draw();
};

function draw() {
  context.clearRect(0.0, 0.0, canvas.width, canvas.height);
  let columnWidth = 100.0;
  let rowHeight = 30.0;
  context.strokeStyle = "#808080";
  context.strokeWidth = 1.0;
  for (let lineX = 0.0; lineX < canvas.width; lineX += columnWidth) {
    context.beginPath();
    context.moveTo(lineX, 0.0);
    context.lineTo(lineX, canvas.height);
    context.stroke();
  }
  for (let lineY = 0.0; lineY < canvas.height; lineY += rowHeight) {
    context.beginPath();
    context.moveTo(0.0, lineY);
    context.lineTo(canvas.width, lineY);
    context.stroke();
  }
}