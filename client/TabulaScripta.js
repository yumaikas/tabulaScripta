class TabulaScripta {
  constructor() {
    this.canvas = document.getElementById("tabula");
    this.canvas.width = document.body.clientWidth;
    this.canvas.height = document.body.clientHeight;
    this.context = this.canvas.getContext("2d");

    this.columnWidth = 100.0;
    this.rowHeight = 30.0;

    this.draw();
  }

  onResize() {
    this.canvas.width = document.body.clientWidth;
    this.canvas.height = document.body.clientHeight;
    this.draw();
  }

  draw() {
    this.context.clearRect(0.0, 0.0, this.canvas.width, this.canvas.height);
    this.context.strokeStyle = "#808080";
    this.context.strokeWidth = 1.0;
    for (let lineX = 0.0; lineX < this.canvas.width; lineX += this.columnWidth) {
      this.context.beginPath();
      this.context.moveTo(lineX, 0.0);
      this.context.lineTo(lineX, this.canvas.height);
      this.context.stroke();
    }
    for (let lineY = 0.0; lineY < this.canvas.height; lineY += this.rowHeight) {
      this.context.beginPath();
      this.context.moveTo(0.0, lineY);
      this.context.lineTo(this.canvas.width, lineY);
      this.context.stroke();
    }
  }
}