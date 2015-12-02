class Line {
  public PVector start;
  public PVector end;

  public Line(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }

  public float radian() {
    return atan((end.y - start.y) / (end.x - start.x));
  }
}

