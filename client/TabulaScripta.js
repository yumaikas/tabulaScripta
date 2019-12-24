class TabulaScripta {
  constructor() {
    this.canvas = document.getElementById("tabula");
    this.canvas.width = document.body.clientWidth;
    this.canvas.height = document.body.clientHeight;
    this.context = this.canvas.getContext("2d");

    this.columnWidth = 80.0;
    this.rowHeight = 20.0;

    this.cells = {};
    this.cells[5] = {};
    this.cells[5][8] = "10.1";
    this.cells[5][9] = "73.64";
    this.cells[8] = {};
    this.cells[8][0] = "Blahblahblah";
    this.cells[8][13] = "This is meaningful.";

    this.draw();
  }

  onResize() {
    this.canvas.width = document.body.clientWidth;
    this.canvas.height = document.body.clientHeight;
    this.draw();
  }

  draw() {
    this.context.clearRect(0.0, 0.0, this.canvas.width, this.canvas.height);

    this.context.strokeStyle = "#FFFFFF";
    this.context.lineWidth = 0.25;
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

    //TODO: Scale font.
    this.context.fillStyle = "#FFFFFF";
    this.context.font = "12px serif";
    this.context.textAlign = "left";
    this.context.textBaseline = "hanging";
    for (let [ columnIndex, columns ] of Object.entries(this.cells)) {
      for (let [ rowIndex, cellString ] of Object.entries(columns)) {
        this.context.fillText(cellString, parseFloat(columnIndex) * this.columnWidth + 2.0, (parseFloat(rowIndex) + 0.5) * this.rowHeight - 4.0);
      }
    }
  }
}