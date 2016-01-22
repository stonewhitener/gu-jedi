final class Line {
  public final PVector start;
  public final PVector end;
  public final double radian;
  public final double length;
  
  public Line(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    
    double length = sqrt(pow((end.x - start.x), 2) + pow((end.y - start.y), 2));
    
    if (length <= 0) {
      this.length = 1;
    } else {
      this.length = length;
    }
    
    this.radian = atan2((end.x - start.x), (end.y - start.y));
  }
  
  public Line clone() {
    return new Line(new PVector(start.x, start.y), new PVector(end.x, end.y));
  }
}